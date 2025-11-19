////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
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
#include "vision/common.h"
#include "vision/apb3_cam.h"
#include "vision/dmasg_config.h"
#include "vision/axi4_hw_accel.h"
#include "vision/isp.h"

#if PICAM_VERSION == 3
   #include "vision/PiCamV3Driver.h"
#else
	#include "vision/PiCamDriver.h"
#endif

//Lwip Library
#include "lwip/init.h"
#include "lwip/ip4_addr.h"
#include "lwip/ip_addr.h"
#include "lwip/netif.h"
#include "lwip/timeouts.h"
#include "netif/ethernet.h"
#include "ethernetif.h"
#include "lwiperf.h"
#include "lwip/udp.h"
#include "lwip/pbuf.h"
int cur_des;

//Phy Driver
#include "efx_tse_mac.h"
#include "efx_tse_phy.h"


void trap_entry();
static void send_frame_udp();
void uart_demo_mode_selection();


 /* USER CODE END 0 */
ip4_addr_t ipaddr;
ip4_addr_t netmask;
ip4_addr_t gw;
ip4_addr_t client_addr;

struct netif gnetif;
int incoming_packet=0;
static struct udp_pcb *upcb;
static ip_addr_t dest_ip;
static const u16_t dest_port = 5005;
static uint16_t frame_id = 0;
u32 *src;  // declare outside
u32 select_demo_mode= 0;      //For demo mode selection




void isrRoutine(){
   uint32_t claim;
   // While there is pending interrupts
   while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
      switch(claim){
	  // TSE DMA INTERRUPT
		  case TSE_RX_INTR:
				dmasg_interrupt_config(TSEMAC_DMASG_BASE, 0, DMASG_CHANNEL_INTERRUPT_LINKED_LIST_UPDATE_MASK);
				//flush_data_cache();
				break;
#if STATIC_STREAM
#else
	      case SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT:
	         uart_demo_mode_selection();
	         break;
#endif
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
   	uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x02);   
   
   	// Configure PLIC
	// Cpu 0 accept all interrupts with priority above 0
   	plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0); 

	// TSE RX interrupt
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, TSE_RX_INTR, 1);
 	plic_set_priority(BSP_PLIC, TSE_RX_INTR, 1);
#if STATIC_STREAM
#else
    //Enable SYSTEM_PLIC_USER_INTERRUPT_A_INTERRUPT rising edge interrupt
 	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT, 1);
 	plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT, 2); //1
#endif
   // Enable interrupts
   // Set the machine trap vector (../common/trap.S)
   csr_write(mtvec, trap_entry); 
   // Enable external interrupts
   csr_set(mie, MIE_MEIE);       
   csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}





#if STATIC_STREAM
// Usage: Fill physical memory with RGB888 pixel.
static void generate_test_image() {
	for (int y = 0; y < CROP_H; y++) {
		for (int x = 0; x < CROP_W; x++) {
			uint32_t idx = (y * CROP_W + x) * 3;
			if ((x < 3 && y < 3) || (x >= CROP_W - 3 && y < 3)
					|| (x < 3 && y >= CROP_H - 3)
					|| (x >= CROP_W - 3 && y >= CROP_H - 3)) {
				rgb_buffer[idx + 0] = 255; // R
				rgb_buffer[idx + 1] = 0;
				rgb_buffer[idx + 2] = 0;
			} else if (x < (CROP_W / 4)) {
				rgb_buffer[idx + 0] = 0; // G
				rgb_buffer[idx + 1] = 255;
				rgb_buffer[idx + 2] = 0;
			} else if (x < (CROP_W / 4 * 2)) {
				rgb_buffer[idx + 0] = 0; // B
				rgb_buffer[idx + 1] = 0;
				rgb_buffer[idx + 2] = 255;
			} else if (x < (CROP_W / 4 * 3)) {
				rgb_buffer[idx + 0] = 255; // R
				rgb_buffer[idx + 1] = 0;
				rgb_buffer[idx + 2] = 0;
			} else {
				rgb_buffer[idx + 0] = 0; // B
				rgb_buffer[idx + 1] = 0;
				rgb_buffer[idx + 2] = 255;
			}
		}
	}
}
#else
// Usage: Crop input pixel from camera to smaller size, ignore Alpha in RGBA (4 bytes)
static void crop_frame_to_txbuffer()
{
    uint8_t *dst = (uint8_t *)tx_frame;
    switch(select_demo_mode) {
    default:
    		src = (uint32_t *)rgb_buffer;  // 4 bytes per pixel (RGBX)
    		break;
    case 2:
			src = (uint32_t *)sobel_buffer;  // 4 bytes per pixel (RGBX)
			break;
    }

    for (int y = 0; y < CROP_H; y++) {
        uint32_t *src_row = src + (y * FRAME_WIDTH);

        for (int x = 0; x < CROP_W; x++) {
            uint32_t pix = src_row[x];
            *dst++ = (pix >> 0) & 0xFF;   // R
            *dst++ = (pix >> 8) & 0xFF;   // G
            *dst++ = (pix >> 16) & 0xFF;  // B
        }
    }
}

void uart_demo_mode_selection()
{
   u32 uart_user_input;
   if (uart_status_read(BSP_UART_TERMINAL) & 0x00000200){

      uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) & 0xFFFFFFFD);   // RX FIFO not empty interrupt Disable
      uart_user_input = uart_read(BSP_UART_TERMINAL);
      uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x02);         // RX FIFO not empty interrupt enable
      //Assign UART input for demo mode selection
      if (uart_user_input == 'a') {
         select_demo_mode = 0;
         uart_writeStr(BSP_UART_TERMINAL, "Selected RGB Mode: a\n\r");
      }
       else if (uart_user_input == 'b') {
         select_demo_mode = 1;
         uart_writeStr(BSP_UART_TERMINAL, "Selected Grayscale Mode: b\n\r");
       }
       else if (uart_user_input == 'c') {
         select_demo_mode = 2;
         uart_writeStr(BSP_UART_TERMINAL, "Selected Edge Detection Mode: c\n\r");
	}
}
}
/*******************************************************EVSOC-RELATED FUNCTIONS******************************************************/

void ispExample_menu()
{
	uart_writeStr(BSP_UART_TERMINAL, "================================================================================\n\r");
	uart_writeStr(BSP_UART_TERMINAL, "                    Camera + LWIP Example Design Scenario Selection\n\r");
	uart_writeStr(BSP_UART_TERMINAL, "================================================================================\n\r");
	uart_writeStr(BSP_UART_TERMINAL, "'a' : Camera Capture + HDMI Display (RGB)                                       \n\r");
	uart_writeStr(BSP_UART_TERMINAL, "'b' : Camera Capture + RGB2Grayscale (HW) + HDMI Display                        \n\r");
	uart_writeStr(BSP_UART_TERMINAL, "'c' : Camera Capture + RGB2Grayscale & Sobel & Dilation (HW) + HDMI Display     \n\r");
	uart_writeStr(BSP_UART_TERMINAL, "================================================================================\n\n\r");
    uart_writeStr(BSP_UART_TERMINAL, "Info: Please ensure that you have run recv_udp_raw.py in the background BEFORE launch the app!!!\n\n\r");
}

void evsoc_main() {

	Set_MipiRst(1);
	Set_MipiRst(0);

	uart_writeStr(BSP_UART_TERMINAL, "Info: Init Camera MIPI I2C.....\n\r");
	mipi_i2c_init();

#if PICAM_VERSION == 3
	PiCamV3_Init();
	//SET camera pre-processing RGB gain value
	Set_RGBGain(1,5,3,7);
#else
   PiCam_init();
   //SET camera pre-processing RGB gain value
   Set_RGBGain(1,5,3,4);
#endif

    dmasg_priority(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL,      3, 0);

    bsp_printf("\r\nInfo: Start streaming.\r\n");
#if PICAM_VERSION == 3
   PiCamV3_StartStreaming();
#endif
}
#endif

/*******************************************************LWIP-RELATED FUNCTIONS******************************************************/
static void send_frame_udp()
{
#if STATIC_STREAM
	generate_test_image();
#else
    crop_frame_to_txbuffer();   // Prepare cropped 100x100 RGB data
#endif
    frame_id++;

    for (uint16_t pkt = 0; pkt < MAX_PACKETS; pkt++) {
        uint32_t offset = pkt * PACKET_DATA_SIZE;
        uint32_t bytes_left = FRAME_SIZE - offset;
        uint16_t payload_len = (bytes_left > PACKET_DATA_SIZE)
                                 ? PACKET_DATA_SIZE : bytes_left;

        // Allocate a small header pbuf for frame/packet ID (4 bytes)
        struct pbuf *hdr_pbuf = pbuf_alloc(PBUF_TRANSPORT, 4, PBUF_RAM);
        if (!hdr_pbuf)
            return;

        uint8_t *hdr = (uint8_t *)hdr_pbuf->payload;
        hdr[0] = frame_id & 0xFF;
        hdr[1] = (frame_id >> 8) & 0xFF;
        hdr[2] = pkt & 0xFF;
        hdr[3] = (pkt >> 8) & 0xFF;

        // Allocate a reference pbuf pointing directly into tx_frame
        struct pbuf *data_pbuf = pbuf_alloc(PBUF_REF, payload_len, PBUF_REF);
        if (!data_pbuf) {
            pbuf_free(hdr_pbuf);
            return;
        }
#if STATIC_STREAM
        data_pbuf->payload  = &rgb_buffer[offset];
#else
        data_pbuf->payload  = &tx_frame[offset];
#endif
        data_pbuf->len      = payload_len;
        data_pbuf->tot_len  = payload_len;

        // Chain the header and data pbufs
        pbuf_cat(hdr_pbuf, data_pbuf);

        // Send the chained pbuf — LWIP will use tx_frame directly
        udp_send(upcb, hdr_pbuf);
#if DEBUG_PRINTF_EN

                // Print frame/packet info
                bsp_printf("Frame %d | Packet %d | Payload %d bytes\r\n", frame_id, pkt, payload_len);
                // Truncated hex dump
                if (payload_len <= HEX_DUMP_SHOW * 2) {
                    for (uint16_t i = 0; i < payload_len; i++) {
                        bsp_printf("%02X ", tx_frame[offset + i]);
                    }
                } else {
                    // First HEX_DUMP_SHOW bytes
                    for (uint16_t i = 0; i < HEX_DUMP_SHOW; i++) {
                        bsp_printf("%02X ", tx_frame[offset + i]);
                    }
                    bsp_printf("... ");
                    // Last HEX_DUMP_SHOW bytes
                    for (uint16_t i = payload_len - HEX_DUMP_SHOW; i < payload_len; i++) {
                        bsp_printf("%02X ", tx_frame[offset + i]);
                    }
                }
                bsp_printf("\n\n\r");
#endif

        pbuf_free(hdr_pbuf);
    }
}


// Usage: Init UDP server
void udp_sender_init()
{
    upcb = udp_new();
    if (!upcb) {
        bsp_printf("Warning: udp_new failed!\n\r");
        return;
    }

    IP4_ADDR(&dest_ip, 192, 168, 31, 222);
    udp_bind(upcb, IP_ADDR_ANY, 0);
    udp_connect(upcb, &dest_ip, dest_port);

    bsp_printf("Info: UDP sender ready -> %s:%d\n\r",
               ip4addr_ntoa(&dest_ip), dest_port);
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


/****************************************************************MAIN**************************************************************/
void main() {

	bsp_init();
	bsp_printf("***Starting Camera + Bare-metal LwIP Network Stack (via UDP) Demo***\n\r");
    HwChecksum_status();
	int state;
	int n,speed=TSE_Speed_1000Mhz,link_speed=0;
	int check_connect=0;
	int net_status;
	int drv_sel;
	MacRst(1, 1);
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
	MacNormalInit(speed);
	LwIP_Init();
	udp_sender_init();
	bsp_printf("Info: iperf server Up\n\r\n\r");

#if STATIC_STREAM
	generate_test_image();
#else
	evsoc_main();
    ispExample_menu();
#endif

    while (1) {
        /************************* TSE *****************************/
    	//CntMonitor();
		if(check_dma_status(cur_des))
		{
			ethernetif_input(&gnetif);	//get ethernet input packet event
		}
#if STATIC_STREAM

		send_frame_udp();

#else
	      //SELECT RGB or grayscale output from camera pre-processing block.
	      if(select_demo_mode==1) {
	         EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG3_OFFSET, 0x00000001); //grayscale
	      } else {
	         EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG3_OFFSET, 0x00000000); //RGB
	      }

	           //Trigger camera DMA
	           dmasg_input_stream(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, DMASG_CAM_S2MM_PORT, 1, 0);
	           dmasg_output_memory(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, CAM_START_ADDR, 16);
	           dmasg_direct_start(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, (FRAME_WIDTH*FRAME_HEIGHT)*4, 0);
	           //Indicate start of S2MM DMA to camera building block via APB3 slave
	           EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG4_OFFSET, 0x00000001);
	           EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG4_OFFSET, 0x00000000);

	           //Trigger storage of one captured frame via APB3 slave
	           EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG2_OFFSET, 0x00000001);
	           EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG2_OFFSET, 0x00000000);

	           //Wait for DMA transfer completion
	           while(dmasg_busy(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL)) {
	        	   send_frame_udp();
	           }


	           /**********************************************************HW Accelerator***********************************************************/

	           //uart_writeStr(BSP_UART_TERMINAL, "\nHardware acceleration..\n\r");

	           if(select_demo_mode==2) {

	               //SET Sobel edge detection threshold via AXI4 slave
	               write_u32(100, EXAMPLE_AXI4_SLV+EXAMPLE_AXI4_SLV_REG0_OFFSET); //Default value 100; Range 0 to 255

	               //SELECT HW accelerator mode - Make sure match with DMA transfer length setting
	               if(select_demo_mode==2)
	               write_u32(0x00000000, EXAMPLE_AXI4_SLV+EXAMPLE_AXI4_SLV_REG1_OFFSET);   //2'd0: Sobel only

	               //Trigger HW accel MM2S DMA
	               //SELECT start address of DMA input to HW accel block
	               dmasg_input_memory(DMASG_BASE, DMASG_HW_ACCEL_MM2S_CHANNEL, CAM_START_ADDR, 16);         //Camera pre-processing block performs HW RGB2grayscale conversion
	               //dmasg_input_memory(DMASG_BASE, DMASG_HW_ACCEL_MM2S_CHANNEL, GRAYSCALE_START_ADDR, 16); //RISC-V performs SW RGB2grayscale conversion
	               dmasg_output_stream(DMASG_BASE, DMASG_HW_ACCEL_MM2S_CHANNEL, DMASG_HW_ACCEL_MM2S_PORT, 0, 0, 1);

	               //SELECT dma transfer length - Make sure match with HW accelerator mode selection
	               //Additonal data is required to be fed for line buffer(s) data flushing
	               if(select_demo_mode==2)
	               dmasg_direct_start(DMASG_BASE, DMASG_HW_ACCEL_MM2S_CHANNEL, ((FRAME_WIDTH*FRAME_HEIGHT)+(FRAME_WIDTH+1))*4, 0);   //Sobel only


	               //Trigger HW accel S2MM DMA
	               dmasg_input_stream(DMASG_BASE, DMASG_HW_ACCEL_S2MM_CHANNEL, DMASG_HW_ACCEL_S2MM_PORT, 1, 0);
	               dmasg_output_memory(DMASG_BASE, DMASG_HW_ACCEL_S2MM_CHANNEL, SOBEL_START_ADDR, 16);
	               dmasg_direct_start(DMASG_BASE, DMASG_HW_ACCEL_S2MM_CHANNEL, (FRAME_WIDTH*FRAME_HEIGHT)*4, 0);

	               //Indicate start of S2MM DMA to HW accel building block via APB3 slave
	               write_u32(0x00000001, EXAMPLE_AXI4_SLV+EXAMPLE_AXI4_SLV_REG2_OFFSET);
	               write_u32(0x00000000, EXAMPLE_AXI4_SLV+EXAMPLE_AXI4_SLV_REG2_OFFSET);

	               //Wait for DMA transfer completion
	               while(dmasg_busy(DMASG_BASE, DMASG_HW_ACCEL_MM2S_CHANNEL) || dmasg_busy(DMASG_BASE, DMASG_HW_ACCEL_S2MM_CHANNEL)){
		        	   send_frame_udp();
		           }

	           }
#endif


	}
}






