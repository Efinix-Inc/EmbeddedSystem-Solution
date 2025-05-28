////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file main.c: capture_img
*
* @brief This demo implements the FatFS File System along with a Command Line Interface (CLI)
* 		 for user interaction. With the camera/display enabled, you can capture image
* 		 and the image will be saved into SD card.
*
* @note To run this example design, please make sure the following requirements are fulfilled:
* 		1. Supported Dev Board
* 		2. FAT32 Formatted SD Card inserted to SD1 slot
*
*		User are allowed to configure certain parameters in userDef.h (User defined Section)
*		1. DEBUG_PRINTF_EN 		=> To enable debug messages
*		2. DMA_MODE		=> To use DMA mode if uncomment, comment out to use PIO mode (DMA mode is recommended due to its higher speed)
*
*		To configure FatFS related configuration, please modify in <BSP>/efinix/EfxSapphireSoc/app/fatfs/ffconf.h
*
******************************************************************************/


#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "bsp.h"
#include "i2c.h"
#include "vexriscv.h"
#include "device_config.h"
#include "userDef.h"
#include "start.h"


#include "platform/interrupt/intc.h"
#include "platform/vision/evsoc.h"
#include "platform/sd/sd.h"
#include "platform/misc/smp.h"



/********************************* Initialize SMP ***********************************/
// Hart 1 State
#define IDLE   0
#define INIT   1
#define STREAM 2
#define RESET  3

// Stack space used by smpInit.S to provide stack to secondary harts
u8 hartStack[STACK_PER_HART*HART_COUNT] __attribute__((aligned(16)));

// Used as a synchronization barrier between all threads
volatile u32 hartCounter = 0;
u32 capture_enabled = 0;
u32 display_enabled = 0;
u32 camera_enabled  = 0;
u32 eth_enabled     = 0;

//Global Variable for Vision Variable
u32 h1_state = IDLE;
u32 h2_state = IDLE;
u32 evsoc_reset_f = 0;



extern void smpInit();


__inline__ __attribute__((always_inline)) s32 atomicAdd(s32 *a, u32 increment) {
    s32 old;
    __asm__ volatile(
          "amoadd.w %[old], %[increment], (%[atomic])"
        : [old] "=r"(old)
        : [increment] "r"(increment), [atomic] "r"(a)
        : "memory"
    );
    return old;
}







/********************************* BSP  ***********************************/

void init(){
	
	bsp_init();
    I2c_Config i2c;
    i2c.samplingClockDivider    = 3;
    i2c.timeout = I2C_CTRL_HZ/1000;
    i2c.tsuDat  = I2C_CTRL_HZ/(I2C_FREQ*5);
	/* T_low & T_high = i2c period / 2  */
    i2c.tLow  = I2C_CTRL_HZ/(I2C_FREQ*2);
    i2c.tHigh = I2C_CTRL_HZ/(I2C_FREQ*2);
	i2c.tBuf  = I2C_CTRL_HZ/(I2C_FREQ);
    i2c_applyConfig(I2C_CTRL, &i2c);
}




void mainSmp() {
    u32 hartId = csr_read(mhartid);
    atomicAdd((s32 *)&hartCounter, 1);

    while (hartCounter != HART_COUNT);  // Wait for all harts to initialize

    if (hartId == 0) {  // Main hart (hart0)
        sd_init();
        while (1) {
            sd_main();
        }
    } else if (hartId == 1) {  // Secondary hart (hart1) for vision tasks

        while (1) {
        	asm("fence r,r");
        	switch (h1_state){
        	case IDLE:
                Set_MipiRst(1); // Enter reset state when hart0 signals
                break;
        	case INIT:
                if (display_enabled) {
                	evsoc_init(0); // Enable Display Only
                	h1_state = STREAM;
                }
                if (camera_enabled ) {
                	evsoc_init(1); // Enable Camera & Display Tasks
                	h1_state = STREAM;
                }

        		break;
        	case STREAM:
                if (display_enabled) {
                	// Do nothing
                }
        		if (camera_enabled ) {
        			evsoc_main();
        			if (camera_enabled && capture_enabled) bsp_uDelay(100000); // Wait when capture is enabled
        		}
        		break;
        	case RESET:
        		// Do nothing after RESET.
        		break;
        	}
        }

}
//    else if (hartId == 2) {  // Third hart (hart1) for ethernet tasks
//
//            while (1) {
//            	asm("fence r,r");
//            	switch (h2_state){
//            	case IDLE:
//                    // Do Nothing.
//                    break;
//            	case INIT:
//                    if (eth_enabled) {
//                    	tse_tcp_init(); // Enable ethernet Only
//                    	h2_state = STREAM;
//                    }
//
//            		break;
//            	case STREAM:
//            		if (eth_enabled) {
//            			tse_tcp_main();
//            		break;
//            	case RESET:
//            		// Do nothing after RESET.
//            		break;
//            	}
//            }
//
//    }
//
//}
}



void main(){
	init(); // init Efinix related drivers
	bsp_printf("**** Camera Enablement + FatFs Demo **** \r\n");
    bsp_printf("*** Starting SMP Demo. Please launch with multicore launch script... *** \r\n");
    smp_unlock(smpInit);
    mainSmp();
}
