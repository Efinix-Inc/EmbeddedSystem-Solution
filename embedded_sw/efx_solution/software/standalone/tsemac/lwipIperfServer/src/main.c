////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////
#include <stdint.h>
#include "bsp.h"
#include "userDef.h"
#include "prescaler.h"
#include "timer.h"
#include "clint.h"
#include "riscv.h"
#include "plic.h"
#include "device_config.h"

//Lwip Library
#include "lwip/init.h"
#include "lwip/ip4_addr.h"
#include "lwip/ip_addr.h"
#include "lwip/netif.h"
#include "lwip/timeouts.h"
#include "netif/ethernet.h"
#include "ethernetif.h"
#include "lwiperf.h"


//Phy Driver
#include "efx_tse_mac.h"
#include "efx_tse_phy.h"

void trap_entry();
/**************************** TSE **************************/
/*Static IP ADDRESS: IP_ADDR0.IP_ADDR1.IP_ADDR2.IP_ADDR3 */
 #define IP_ADDR0                    configIP_ADDR0
 #define IP_ADDR1                    configIP_ADDR1
 #define IP_ADDR2                    configIP_ADDR2
 #define IP_ADDR3                    configIP_ADDR3
 
 /*NETMASK*/
 #define NETMASK_ADDR0               255
 #define NETMASK_ADDR1               255
 #define NETMASK_ADDR2               255
 #define NETMASK_ADDR3                 0
 
 /*Gateway Address*/
 #define GW_ADDR0                    configIP_ADDR0
 #define GW_ADDR1                    configIP_ADDR1
 #define GW_ADDR2                    configIP_ADDR2
 #define GW_ADDR3                    1
 /* USER CODE END 0 */
 
 ip4_addr_t ipaddr;
 ip4_addr_t netmask;
 ip4_addr_t gw;
 ip4_addr_t client_addr;

struct netif gnetif;

int incoming_packet=0;

//Used on unexpected trap/interrupt codes
void crash(){
	bsp_printf("\n*** CRASH ***\n");
	while(1);
}

void isrRoutine(){
	uint32_t claim;
   // While there is pending interrupts
	while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
		switch(claim){
	  // TSE DMA INTERRUPT
		  case TSE_RX_INTR:
			dmasg_interrupt_config(TSEMAC_DMASG_BASE, 0, DMASG_CHANNEL_INTERRUPT_LINKED_LIST_UPDATE_MASK);
				data_cache_invalidate_all();
			break;

			default: crash(); break;
		}
      plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim); //unmask the claimed interrupt
	}
}

//Called by trap_entry on both exceptions and interrupts events
void trap(){
	int32_t mcause = csr_read(mcause);
	int32_t interrupt = mcause < 0;
	int32_t cause     = mcause & 0xF;
	if(interrupt){
		switch(cause){
		case CAUSE_MACHINE_EXTERNAL: isrRoutine(); break;
		default: crash(); break;
		}
	} else {
		crash();
	}
}

void isrInit(){

	// RX FIFO not empty interrupt enable
   	//uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x02);

   	// Configure PLIC
	// Cpu 0 accept all interrupts with priority above 0
	plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);

	// TSE RX interrupt
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, TSE_RX_INTR, 1);
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
void main() {

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
  	bsp_printf("Info: Phy Init ..\n\r");
	bsp_printf("Info: Waiting Link Up ..\n\r");
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

	lwiperf_start_tcp_server( &ipaddr, 5001, NULL, NULL );

	bsp_printf("Info: iperf server Up\n\r\n\r");

	bsp_printf("=========================================\n\r");
	bsp_printf("======Lwip Raw Mode Iperf TCP Server ====\n\r");
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

	bsp_printf("=========================================\n\r");


    while (1) {
        /************************* TSE *****************************/
    	//CntMonitor();
		if(check_dma_status(cur_des))
		{
			ethernetif_input(&gnetif);	//get ethernet input packet event
		}
#if SUPPORT_ETH_HOT_PLUG 
		else
		{
			net_status=(drv_sel)?rtl8211_drv_rddata(26):Phy_Rd_normal(0x11);

			if(((drv_sel)?((net_status & 0x04) == 0): ((net_status&0x2400) != 0x2400))&& (check_connect))
			{
				check_connect=0;
       			bsp_printf("Link Info: Disconnected -- \n\r");
			}
			else if(((drv_sel)?(net_status & 0x04): ((net_status&0x2400) == 0x2400)) && (!check_connect))
			{
				check_connect=1;
       			bsp_printf("Link Info: Connected -- \n\r");
				speed=(drv_sel)?rtl8211_drv_linkup():PhyGetSpeed();
				if(speed == TSE_Speed_1000Mhz)		link_speed = 1000;
				else if(speed == TSE_Speed_100Mhz)	link_speed = 100;
				else if(speed == TSE_Speed_10Mhz)	link_speed = 10;
				else							    link_speed = 0;
				MacNormalInit(speed);
				bsp_printf("======link Speed: \t%d Mbps\n\r",link_speed);

       		}
       			sys_check_timeouts();
			}
#endif


	}
}
