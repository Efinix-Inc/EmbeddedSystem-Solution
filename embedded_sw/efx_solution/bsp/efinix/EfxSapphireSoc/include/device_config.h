////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

//HPS Device Config Ti375C529

#ifndef DEV_CONFIG
#define DEV_CONFIG

// Axi-Interconnect Base Address (Master Interface)
#define SLB_BASE                    (SYSTEM_AXI_A_BMB + 0x00000000 ) //Soft Logic Block
#define SDHC_BASE                   (SYSTEM_AXI_A_BMB + 0x01000000 ) // SDHC
#define TSEMAC_BASE                 (SYSTEM_AXI_A_BMB + 0x01100000 ) // TSEMAC
#define ISP_AXI4_SLAVE_BASE         (SYSTEM_AXI_A_BMB + 0x01200000 ) // Hardware Accelerator
#define EMMC_ADDR                   (SYSTEM_AXI_A_BMB + 0x01300000 ) // EMMC
#define SYS_REG_ADDR                (SYSTEM_AXI_A_BMB + 0x01400000 ) // SYS REG

// Interrupt
#define ISP_DMA_INTERRUPT 	        SYSTEM_PLIC_USER_INTERRUPT_P_INTERRUPT
#define TSE_RX_INTR                 SYSTEM_PLIC_USER_INTERRUPT_Q_INTERRUPT
#define TSE_TX_INTR                 SYSTEM_PLIC_USER_INTERRUPT_R_INTERRUPT
#define SDHC_INTERRUPT		        SYSTEM_PLIC_USER_INTERRUPT_S_INTERRUPT
#define USB_INTERRUPT		        SYSTEM_PLIC_USER_INTERRUPT_T_INTERRUPT
#define EMMC_INTERRUPT              SYSTEM_PLIC_USER_INTERRUPT_U_INTERRUPT

// APB3
#define ISP_DMA_BASE                IO_APB_SLAVE_0_INPUT
#define ISP_CAM_APB3                IO_APB_SLAVE_1_INPUT
#define TSEMAC_DMASG_BASE           IO_APB_SLAVE_2_INPUT

// TSEMAC
#define PHY_ADDR                    0x0
#define TSE_DMASG_RX_CH             0
#define TSE_DMASG_TX_CH             1
#define SUPPORT_ETH_HOT_PLUG        0

// MIPI - I2C
#define I2C_CTRL_HZ                 SYSTEM_CLINT_HZ
#define I2C_CTRL_MIPI		        SYSTEM_I2C_0_IO_CTRL

// RTC - PCF8523
#define RTC_PCF8523_SUPPORT         1
#define RTC_I2C_BASE_ADDR           SYSTEM_I2C_1_IO_CTRL

// Temp Sensor - EMC1413
#define EMC1413_SUPPORT             1
#define TEMP_SENSOR_I2C_BASE_ADDR   SYSTEM_I2C_1_IO_CTRL

//Resolution of Display
#define FRAME_WIDTH         1920
#define FRAME_HEIGHT        1080

//Camera
//Define the picam version. By default is set to Picam V3.
#define PICAM_VERSION 		3

// Use to convert bmp to ppm (printed on terminal)
#define PPM_PRINT			0
#define IMG_POS_CENTER		1 // Image is printed on the center of display

#endif
