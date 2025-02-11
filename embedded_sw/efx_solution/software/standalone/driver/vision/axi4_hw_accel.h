////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef AXI4_HW_ACCEL_H
#define AXI4_HW_ACCEL_H

#include "bsp.h"
#include "device_config.h"

#define EXAMPLE_AXI4_SLV   ISP_AXI4_SLAVE_BASE

#define EXAMPLE_AXI4_SLV_REG0_OFFSET   0  //sobel_thresh_val           (Write)
#define EXAMPLE_AXI4_SLV_REG1_OFFSET   4  //hw_accel_mode              (Write)
#define EXAMPLE_AXI4_SLV_REG2_OFFSET   8  //dma_wr_init_done           (Write)
#define EXAMPLE_AXI4_SLV_REG3_OFFSET   12 //32'hABCD_1234              (Read - verify slave read)
#define EXAMPLE_AXI4_SLV_REG4_OFFSET   16 //debug_hw_accel_fifo_status (Read)
#define EXAMPLE_AXI4_SLV_REG5_OFFSET   20 //debug_dma_in_fifo_wcount   (Read)
#define EXAMPLE_AXI4_SLV_REG6_OFFSET   24 //debug_dma_out_fifo_rcount  (Read)
#define EXAMPLE_AXI4_SLV_REG7_OFFSET   28 //debug_dma_out_status       (Read)

#endif
