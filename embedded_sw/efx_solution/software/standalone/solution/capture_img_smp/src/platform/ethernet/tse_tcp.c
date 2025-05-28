////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "platform/ethernet/tse_tcp.h"
#include "lwip/include/lwip/err.h"
int incoming_packet=0;

void isrInit(){

   	// Configure PLIC
	// Cpu 0 accept all interrupts with priority above 0
	plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_2, 0);

	// TSE RX interrupt
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_2, TSE_RX_INTR, 1);
 	plic_set_priority(BSP_PLIC, TSE_RX_INTR, 1);

   // Enable interrupts
   // Set the machine trap vector (../common/trap.S)
	csr_write(mtvec, trap_entry);
   // Enable external interrupts
    csr_set(mie, MIE_MEIE);
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

void additionalSetting(void){
	u32 Value = 0;
	Value = read_u32(TSEMAC_BASE+COMMAND_CONFIG);
	MacRxEn(1);
	//mac_reg command_config Reg
	write_u32(0x00040053, (TSEMAC_BASE+COMMAND_CONFIG));
	Value = read_u32(TSEMAC_BASE+COMMAND_CONFIG);

	//set mac address
	write_u32(0x33221100, (TSEMAC_BASE+MAC_ADDR_LO));
	write_u32(0x5544, (TSEMAC_BASE+MAC_ADDR_HI));

	//Set MDIO Divider
	write_u32(0xFF, (TSEMAC_BASE+DIVIDER_PRE));

	//set mac addr
	write_u32(0xFFFFFFFF, (TSEMAC_BASE+MAC_ADDR_MAKE_LO));
	write_u32(0x0000FFFF, (TSEMAC_BASE+MAC_ADDR_MAKE_HI));
}


u64_t sys_jiffies(void)
{
	u64 get_time;

	get_time = clint_getTime(BSP_CLINT);
    return ((get_time)/(BSP_CLINT_HZ/1000));
}

u64_t sys_now(void)
{
	u64 get_time;

	get_time = clint_getTime(BSP_CLINT);

	return ((get_time)/(BSP_CLINT_HZ/1000));

}



// Callback function when data is successfully sent
err_t my_sent_callback(void *arg, struct tcp_pcb *tpcb, u16_t len) {
    bsp_printf("[ETH]: Successfully sent %d bytes.\r\n", len);
    total_bytes_sent+=len;
    xprintf("[ETH]: Total Bytes Sent: %lu bytes.\r\n",total_bytes_sent);
    // Continue sending the file
	soc_write_buffer_flush();
    send_file(bytes_read,tpcb,filename);
    return ERR_OK;
}



UINT read_file(const char *filename) {
    FIL file;
    BYTE bom[3];  // Buffer for BOM check
    //data_cache_invalidate_all();
	//soc_write_buffer_flush();

    if (f_open(&file, filename, FA_READ) == FR_OK) {
        bsp_printf("[SD]: Reading file from SD card: %s...\r\n", filename);
        bsp_uDelay(100000);

        // Read first 3 bytes to check encoding
        f_read(&file, bom, 3, &bytes_read);
        f_lseek(&file, 0);  // Reset file pointer

        if (bytes_read >= 3 && bom[0] == 0xEF && bom[1] == 0xBB && bom[2] == 0xBF) {
            bsp_printf("[SD]: UTF-8 file detected with BOM.\r\n");
        } else if (bytes_read >= 2 && bom[0] == 0xFF && bom[1] == 0xFE) {
            bsp_printf("[SD]: UTF-16 LE file detected.\r\n");
        } else if (bytes_read >= 2 && bom[0] == 0xFE && bom[1] == 0xFF) {
            bsp_printf("[SD]: UTF-16 BE file detected.\r\n");
        } else {
            bsp_printf("[SD]: No BOM detected, assuming ASCII or UTF-8 without BOM.\r\n");
        }

        if (f_read(&file, Buff, sizeof(Buff), &bytes_read) == FR_OK ){
        	if (bytes_read > sizeof(Buff)) {
        	    bsp_printf("[SD]: Warning - file size exceeds buffer size!\r\n");
        	    return 0;
        	}
        	xprintf("[SD]: %lu bytes read from %s\r\n", bytes_read,filename);
        	f_close(&file);
        }
        else xprintf("[SD]: Failed to read %s\r\n!",filename);
    }
    else xprintf("[SD]: File %s not exist \r\n!",filename);

    FRESULT result = dump_buffer_to_file("dump.bmp", Buff, bytes_read);
    //data_cache_invalidate_all();
    return bytes_read;

}
void send_file(UINT bytes_read, struct tcp_pcb *tpcb, const char *filename) {
	err_t err = ERR_OK;

	while (remaining > 0 ) {
		err = ERR_OK;
		//soc_write_buffer_flush();
        UINT chunk = MIN(remaining, 4000);
        err_t err = tcp_write(tpcb, ptr_Buff, chunk, TCP_WRITE_FLAG_COPY);
        if (err == ERR_OK) {
            ptr_Buff   += chunk;
            remaining  -= chunk;
            //soc_write_buffer_flush();
            tcp_output(tpcb);   // flush immediately, or rely on LwIP’s scheduling
        }
        else if (err == ERR_MEM) {
            // out of buffer space—give control back to LwIP
            return;
        }
        else {
            bsp_printf("[ETH]: TCP write fatal error: %d\r\n", err);
            return;
        }


	}
	xprintf("[ETH]: Available TCP buffer: %lu bytes.\r\n", tcp_sndbuf(tpcb));
	if ((remaining == 0) && (bytes_read == total_bytes_sent))
	{
		bsp_printf("--------------------\r\n");
		bsp_printf("[ETH]: Transfer Complete.\r\n");
		xprintf("[ETH]: Available TCP buffer: %lu bytes.\r\n", tcp_sndbuf(tpcb));
		xprintf("[ETH]: Total Bytes Read from %s: %lu bytes.\r\n",filename, bytes_read);
		xprintf("[ETH]: Total Bytes Sent to %s : %lu bytes.\r\n",ipaddr_ntoa(&tpcb->remote_ip),total_bytes_sent);
		bsp_printf("[ETH]: Close the TCP Connection.\r\n");
		bsp_printf("--------------------\r\n>");
		tcp_close(tpcb); // Close the TCP connection
	}


}


// TCP Receive Callback
err_t tcp_server_receive(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err) {

	if (p == NULL) {
        tcp_close(tpcb);
        //pbuf_free(p);
        return ERR_OK;
    }

    char *msg = (char *)p->payload;

    // If the client sends "send <filename>", send the requested file
    if (strncmp(msg, "send", 4) == 0) {

        sscanf(msg + 5, "%s", filename);  // Extract filename from message
        bsp_printf("[ETH]: User requested file transfer: %s\r\n", filename);
        tcp_sent(tpcb, my_sent_callback);
        bytes_read=read_file(filename);
        ptr_Buff = Buff;
    	remaining = bytes_read;
    	total_bytes_sent =0;
    	bsp_printf("[ETH]: Sending file: %s...\r\n", filename);
    	//soc_write_buffer_flush();
        send_file(bytes_read,tpcb, filename);

    }

    pbuf_free(p);
    return ERR_OK;
}

err_t tcp_server_accept(void *arg, struct tcp_pcb *newpcb, err_t err) {
    tcp_recv(newpcb, tcp_server_receive);
    bsp_printf("[ETH]:New connection from %s\r\n", ipaddr_ntoa(&newpcb->remote_ip));
    return ERR_OK;
}

// Initialize TCP Server
struct tcp_pcb *tcp_server_init(void) {
    struct tcp_pcb *tpcb = tcp_new();
    if (tpcb == NULL) {
        bsp_printf("[ETH]: Error creating PCB.\r\n");
        return NULL;
    }

    if (tcp_bind(tpcb, IP_ADDR_ANY, 5001) != ERR_OK) {
        bsp_printf("[ETH]: TCP bind failed.\r\n");
        return NULL;
    }

    tpcb = tcp_listen(tpcb);
    tcp_accept(tpcb, tcp_server_accept);

    bsp_printf("[ETH]: TCP server started on port 5001.\r\n");
    return tpcb;
}


 void LwIP_Init(void)
 {
 
     IP4_ADDR(&ipaddr,IP_ADDR0,IP_ADDR1,IP_ADDR2,IP_ADDR3);
     IP4_ADDR(&netmask,NETMASK_ADDR0,NETMASK_ADDR1,NETMASK_ADDR2,NETMASK_ADDR3);
     IP4_ADDR(&gw,GW_ADDR0,GW_ADDR1,GW_ADDR2,GW_ADDR3);


     /* Initilialize the LwIP stack without RTOS */
     lwip_init();

     /* add the network interface (IPv4/IPv6) without RTOS */
     netif_add(&gnetif, &ipaddr, &netmask, &gw, NULL,
               &ethernetif_init, &ethernet_input);

     /* Registers the default network interface */
     netif_set_default(&gnetif);

     if (netif_is_link_up(&gnetif))
     {
      /*When the netif is fully configured this function must be called */
         netif_set_up(&gnetif);

     }
     else
     {
         /* When the netif link is down this function must be called */
         netif_set_down(&gnetif);
     }
 }

void clock_sel(int speed)
{
	int val=0;

	if(speed == TSE_Speed_1000Mhz)
		val=0x03;
	else
		val=0x00;
}

/****************************************************************MAIN**************************************************************/
void tse_tcp_init() {

	bsp_init();
	int state;
	int n,speed=TSE_Speed_1000Mhz,link_speed=0;
	int check_connect=0;
	int net_status;
	int drv_sel;
	MacRst(1, 1);


    bsp_printf("***Starting TSEMAC Demo***\n\r");
    drv_sel = Phy_identification();
/******************************************************SETUP DMA & UART********************************************************/
	
	isrInit();

/****************************************************** SETUP ETHERNET LINK ********************************************************/
  	bsp_printf("[ETH]: Phy Init ..\n\r");
	bsp_printf("[ETH]: Waiting Link Up ..\n\r");
  	if (drv_sel)
  	{
  		rtl8211_drv_init();
  		speed=rtl8211_drv_linkup();
  	}
  	else speed = PhyNormalInit();


	//check_connect=rtl8211_drv_rddata(26);

	if(speed == TSE_Speed_1000Mhz)
		link_speed = 1000;
	else if(speed == TSE_Speed_100Mhz)
		link_speed = 100;
	else if(speed == TSE_Speed_10Mhz)
		link_speed = 10;
	else
		link_speed = 0;

	//bLink =1;
	//clock_sel(speed);
	MacNormalInit(speed);
	//additionalSetting();
	LwIP_Init();
    // Start the TCP server only once
    static struct tcp_pcb *server_pcb = NULL;
    if (server_pcb == NULL) {
        server_pcb = tcp_server_init();
    }

	//lwiperf_start_tcp_server( &ipaddr, 5001, NULL, NULL );

	bsp_printf("[ETH]: TCP server Up\n\r\n\r");

	bsp_printf("=========================================\n\r");
	bsp_printf("======Lwip Raw Mode TCP Server ====\n\r");
	bsp_printf("=========================================\n\r");

	bsp_printf("======IP: \t\t");
	bsp_printf("%d",IP_ADDR0);
	bsp_printf(".");
	bsp_printf("%d",IP_ADDR1);
	bsp_printf(".");
	bsp_printf("%d",IP_ADDR2);
	bsp_printf(".");
	bsp_printf("%d",IP_ADDR3);
	bsp_printf("\n\r");

	bsp_printf("======Netmask: \t\t");
	bsp_printf("%d",NETMASK_ADDR0);
	bsp_printf(".");
	bsp_printf("%d",NETMASK_ADDR1);
	bsp_printf(".");
	bsp_printf("%d",NETMASK_ADDR2);
	bsp_printf(".");
	bsp_printf("%d",NETMASK_ADDR3);
	bsp_printf("\n\r");

	bsp_printf("======GateWay: \t\t");
	bsp_printf("%d",GW_ADDR0);
	bsp_printf(".");
	bsp_printf("%d",GW_ADDR1);
	bsp_printf(".");
	bsp_printf("%d",GW_ADDR2);
	bsp_printf(".");
	bsp_printf("%d",GW_ADDR3);
	bsp_printf("\n\r");

	bsp_printf("======link Speed: \t");
	bsp_printf("%d",link_speed);
	bsp_printf(" Mbps\n\r");

	bsp_printf("=========================================\n\r>");
}


void tse_tcp_main() {
    while (1) {
        /************************* TSE *****************************/
    	//CntMonitor();
		if(check_dma_status(cur_des))
		{
			//CntMonitor();
			ethernetif_input(&gnetif);	//get ethernet input packet event
		}
#if SUPPORT_ETH_HOT_PLUG 
		else
		{
			net_status=(drv_sel)?rtl8211_drv_rddata(26):Phy_Rd_normal(0x11);

			if(((drv_sel)?((net_status & 0x04) == 0): ((net_status&0x2400) != 0x2400))&& (check_connect))
			{
				check_connect=0;
       			bsp_printf("[ETH]: Link Info: Disconnected -- \n\r");
			}
			else if(((drv_sel)?(net_status & 0x04): ((net_status&0x2400) == 0x2400)) && (!check_connect))
			{
				check_connect=1;
       			bsp_printf("[ETH]: Link Info: Connected -- \n\r");
				speed=(drv_sel)?rtl8211_drv_linkup():PhyGetSpeed();
				if(speed == TSE_Speed_1000Mhz)		link_speed = 1000;
				else if(speed == TSE_Speed_100Mhz)	link_speed = 100;
				else if(speed == TSE_Speed_10Mhz)	link_speed = 10;
				else							    link_speed = 0;
				MacNormalInit(speed);
				bsp_printf("[ETH]: ======link Speed: \t%d Mbps\n\r",link_speed);

       		}
       			sys_check_timeouts();
			}
#endif


	}
}
