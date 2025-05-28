////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef HEADER_EVSOC_H_
#define HEADER_EVSOC_H_

#include "bsp.h"
#include "device_config.h"
#include "userDef.h"
#include "uart.h"
#include "i2c.h"
#include "vexriscv.h"
#include "clint.h"
#include "plic.h"
#include "dmasg.h"
#include "vision/common.h"
#include "vision/apb3_cam.h"
#include "vision/axi4_hw_accel.h"
#include "vision/dmasg_config.h"
#include "vision/isp.h"

#if PICAM_VERSION == 3
   #include "vision/PiCamV3Driver.h"
#else
	#include "vision/PiCamDriver.h"
#endif

extern int select_demo_mode;

void dma_vision_disabled();
void evsoc_reset();
void cam_disabled();
void evsoc_main();
void dma_vision_init();
void evsoc_init(uint8_t camera_stream_enabled);
void externalInterrupt_evsoc();
void dma_uart_init();



#endif 
