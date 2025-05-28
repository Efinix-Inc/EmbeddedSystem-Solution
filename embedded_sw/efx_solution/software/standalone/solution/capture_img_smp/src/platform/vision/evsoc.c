////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////


#include <stdint.h>
#include <stdlib.h>
#include "platform/vision/evsoc.h"


void dma_vision_init(){
   //configure PLIC
   plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_1, 0); //cpu 1 accept all interrupts with priority above 0

   //enable PLIC DMASG channel 0 interrupt listening (But for the demo, we enable the DMASG internal interrupts later)
   plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_1, PLIC_DMASG_CHANNEL, 1);
   plic_set_priority(BSP_PLIC, PLIC_DMASG_CHANNEL, 1);

   //enable interrupts
   csr_write(mtvec, trap_entry); //Set the machine trap vector (../common/trap.S)
   csr_set(mie, MIE_MEIE); //Enable external interrupts
   csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}


void evsoc_reset (){
	bsp_printf("Please wait...\r\n");
	data_cache_invalidate_all();
	dmasg_interrupt_pending_clear(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, 0xFFFFFFFF);
	//dmasg_interrupt_pending_clear(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, 0xFFFFFFFF);
	while(dmasg_busy(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL) && dmasg_busy(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL)){ bsp_printf(".");}
	dmasg_stop(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL);
	dmasg_stop(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL);
	msDelay(500);
    Set_MipiRst(1);
    Set_MipiRst(0);
    bsp_printf("\n\rCamera & Display is disabled successfully.\r\n>");

}

void evsoc_init(uint8_t camera_stream_enabled){
	
	if(dmasg_busy(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL) | dmasg_busy(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL)){ bsp_printf("DMA is busy\r\n"); while(1);}


    Set_MipiRst(1);
    Set_MipiRst(0);

    uart_writeStr(BSP_UART_TERMINAL, "Image Signal Processing Demo!\n\r");
    dma_vision_init();

    if (camera_stream_enabled){
    uart_writeStr(BSP_UART_TERMINAL, "Initialize MIPI I2C.....\n\r");
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
    //SET camera pre-processing RGB gain value
    Set_RGBGain(1,5,3,7);

    }

    /******************************************************SETUP DMA & UART********************************************************/

    uart_writeStr(BSP_UART_TERMINAL, "Initialize DMA.....\n\r");
    dmasg_priority(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL,  0, 0);
    dmasg_priority(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL,      0, 0);

    /*******************************************************Trigger Display********************************************************/



    //Array name to be modified to DDR location used for display
    //Colour bar & Red dots at 4 corners of active display
    //Initialize test image in cam_array - Default


    //To check display functionality
    uart_writeStr(BSP_UART_TERMINAL, "Initialize test display content..\n\r");
    for (int y=0; y<FRAME_HEIGHT; y++) {
        for (int x=0; x<FRAME_WIDTH; x++) {
            if ((x<3 && y<3) || (x>=FRAME_WIDTH-3 && y<3) || (x<3 && y>=FRAME_HEIGHT-3) || (x>=FRAME_WIDTH-3 && y>=FRAME_HEIGHT-3)) {
            	img_array [y*FRAME_WIDTH + x] = 0x000000FF; //RED
            } else if (x<(FRAME_WIDTH/4)) {
            	img_array [y*FRAME_WIDTH + x] = 0x0000FF00; //GREEN
            } else if (x<(FRAME_WIDTH/4 *2)) {
            	img_array [y*FRAME_WIDTH + x] = 0x00FF0000; //BLUE
            } else if (x<(FRAME_WIDTH/4 *3)) {
            	img_array [y*FRAME_WIDTH + x] = 0x000000FF; //RED
            } else {
                img_array [y*FRAME_WIDTH + x] = 0x00FF0000; //BLUE
            }
        }
    }
    data_cache_invalidate_all();

    //Trigger display DMA once then the rest handled by DMA (Direct mode DMA)
    uart_writeStr(BSP_UART_TERMINAL, "Trigger display DMA..\n\r");

    //SELECT start address of to be displayed data accordingly - Default
    dmasg_input_memory(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, IMG_START_ADDR, 16);
    dmasg_output_stream(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, DMASG_DISPLAY_MM2S_PORT, 0, 0, 1);
    dmasg_interrupt_config(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, DMASG_CHANNEL_INTERRUPT_CHANNEL_COMPLETION_MASK);
    dmasg_direct_start(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, (FRAME_WIDTH*FRAME_HEIGHT)*4, 0);  //Without self restart
    display_mm2s_active = 1;   //Display always active


    if (camera_stream_enabled) {

#if PICAM_VERSION == 3
    	PiCamV3_StartStreaming();
#endif
    	uart_writeStr(BSP_UART_TERMINAL, "\nPress 'c' for camera capture..\n\r>");
        EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG3_OFFSET, 0x00000000); //RGB

        //Trigger camera DMA
        dmasg_input_stream(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, DMASG_CAM_S2MM_PORT, 1, 0);
        dmasg_output_memory(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, IMG_START_ADDR, 16);
        //dmasg_interrupt_config(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, DMASG_CHANNEL_INTERRUPT_CHANNEL_COMPLETION_MASK);
        dmasg_direct_start(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, (FRAME_WIDTH*FRAME_HEIGHT)*4, 0);

        //cam_s2mm_active = 1;
        //Indicate start of S2MM DMA to camera building block via APB3 slave
        EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG4_OFFSET, 0x00000001);
        EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG4_OFFSET, 0x00000000);

        //Trigger storage of one captured frame via APB3 slave
        EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG2_OFFSET, 0x00000001);
        EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG2_OFFSET, 0x00000000);

        //Wait for DMA transfer completion
        //while(dmasg_busy(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL));
        //data_cache_invalidate_all();

    }
    else uart_writeStr(BSP_UART_TERMINAL, ">");

}

void evsoc_main(){

	//data_cache_invalidate_all();
    EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG3_OFFSET, 0x00000000); //RGB
    //Trigger camera DMA
    //bsp_printf("Camera main\r\n");
    dmasg_input_stream(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, DMASG_CAM_S2MM_PORT, 1, 0);
    dmasg_output_memory(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, IMG_START_ADDR, 16);
    dmasg_direct_start(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL, (FRAME_WIDTH*FRAME_HEIGHT)*4, 0);
    //Indicate start of S2MM DMA to camera building block via APB3 slave
    EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG4_OFFSET, 0x00000001);
    EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG4_OFFSET, 0x00000000);
    //Trigger storage of one captured frame via APB3 slave
    EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG2_OFFSET, 0x00000001);
    EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG2_OFFSET, 0x00000000);

    //cam_s2mm_active = 1;
    //Wait for DMA transfer completion
    while(dmasg_busy(DMASG_BASE, DMASG_CAM_S2MM_CHANNEL));
    data_cache_invalidate_all();

}



