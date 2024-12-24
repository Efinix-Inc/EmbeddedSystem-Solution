////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef APB3_CAM_H
#define APB3_CAM_H

#include "bsp.h"
#include "device_config.h"

#define DELAY_BUSY   10

#define EXAMPLE_APB3_SLV   ISP_CAM_APB3
#define EXAMPLE_APB3_SLV_REG0_OFFSET   0  //rgb gain control
#define EXAMPLE_APB3_SLV_REG1_OFFSET   4  //mipi rst
#define EXAMPLE_APB3_SLV_REG2_OFFSET   8  //trigger_capture_frame
#define EXAMPLE_APB3_SLV_REG3_OFFSET   12 //rgb_gray
#define EXAMPLE_APB3_SLV_REG4_OFFSET   16 //cam_dma_init_done

#define EXAMPLE_APB3_SLV_REG5_OFFSET   20 //Expect 32'hABCD_5678 - Verify slave read operation
#define EXAMPLE_APB3_SLV_REG6_OFFSET   24 //debug_cam_dma_fifo_status
#define EXAMPLE_APB3_SLV_REG7_OFFSET   28 //debug_cam_dma_fifo_rcount
#define EXAMPLE_APB3_SLV_REG8_OFFSET   32 //debug_cam_dma_fifo_wcount
#define EXAMPLE_APB3_SLV_REG9_OFFSET   36 //frames_per_second

#define EXAMPLE_APB3_SLV_REG10_OFFSET  40 //NULL

#define EXAMPLE_APB3_SLV_REG11_OFFSET  44 //Expect 32'hBBCD_5678 - Verify slave read operation
#define EXAMPLE_APB3_SLV_REG12_OFFSET  48 //debug_display_dma_fifo_status
#define EXAMPLE_APB3_SLV_REG13_OFFSET  52 //debug_display_dma_fifo_rcount
#define EXAMPLE_APB3_SLV_REG14_OFFSET  56 //debug_display_dma_fifo_wcount

#define EXAMPLE_APB3_SLV_REG15_OFFSET  60 //Expect 32'hCBCD_5678 - Verify slave read operation
#define EXAMPLE_APB3_SLV_REG16_OFFSET  64 //debug_hw_accel_dma_fifo_status
#define EXAMPLE_APB3_SLV_REG17_OFFSET  68 //debug_hw_accel_in_fifo_rcount
#define EXAMPLE_APB3_SLV_REG18_OFFSET  72 //debug_hw_accel_in_fifo_wcount
#define EXAMPLE_APB3_SLV_REG19_OFFSET  76 //select_demo_mode

#define EXAMPLE_APB3_REGW(addr, offset, data) \
	write_u32(data, addr+offset)

#define EXAMPLE_APB3_REGR(addr, offset) \
	read_u32(addr+offset)

u32 example_register_read(u16 reg)
{
	u32 rdata;
	rdata = EXAMPLE_APB3_REGR(EXAMPLE_APB3_SLV, reg);
	return rdata;
}

void Set_RGBGain(u8 ena, u8 R, u8 G, u8 B)
{
	u32 data = ((B & 0x7)<<12)|((G & 0x7)<<8)|((R & 0x7)<<4)|(ena&0x1);

	EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG0_OFFSET, data);
	bsp_uDelay(DELAY_BUSY);
}

void Set_MipiRst(u8 rst)
{
	EXAMPLE_APB3_REGW(EXAMPLE_APB3_SLV, EXAMPLE_APB3_SLV_REG1_OFFSET, rst &0x01);
	bsp_uDelay(DELAY_BUSY);
}

#endif
