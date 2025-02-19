////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef DMASG_CONFIG_H
#define DMASG_CONFIG_H

#include "bsp.h"
#include "dmasg.h"
#include "device_config.h"

//For DMA interrupt
uint32_t hw_accel_mm2s_active;
uint32_t hw_accel_s2mm_active;
uint32_t cam_s2mm_active;
uint32_t display_mm2s_active;

#define DMASG_BASE            ISP_DMA_BASE
#define PLIC_DMASG_CHANNEL    ISP_DMA_INTERRUPT

//Each channel connects to only 1 port, hence all ports are referred as port 0.
#define DMASG_CAM_S2MM_CHANNEL         0
#define DMASG_CAM_S2MM_PORT            0

#define DMASG_DISPLAY_MM2S_CHANNEL     1
#define DMASG_DISPLAY_MM2S_PORT        0

#define DMASG_HW_ACCEL_S2MM_CHANNEL    2
#define DMASG_HW_ACCEL_S2MM_PORT       0

#define DMASG_HW_ACCEL_MM2S_CHANNEL    3
#define DMASG_HW_ACCEL_MM2S_PORT       0

void trap_entry();
void dma_init();
void crash();


#endif
