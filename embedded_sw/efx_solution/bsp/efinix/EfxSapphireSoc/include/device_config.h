////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////
//Soft Sapphire Device Config Ti180J484

#ifndef DEV_CONFIG
#define DEV_CONFIG

//TSE MAC Related 
#define TSEMAC_BASE 		 0xe1810000
#define TSEMAC_DMASG_BASE	 IO_APB_SLAVE_2_INPUT
#define TSE_DMASG_RX_CH		 0
#define TSE_RX_INTR			 SYSTEM_PLIC_USER_INTERRUPT_B_INTERRUPT
#define TSE_DMASG_TX_CH		 1
#define TSE_TX_INTR			 SYSTEM_PLIC_USER_INTERRUPT_C_INTERRUPT
#define PHY_ADDR   			 0x0
#define SUPPORT_ETH_HOT_PLUG 0

//RTC - DS3231
#define RTC_DS3231_SUPPORT  1
#define RTC_I2C_BASE_ADDR   SYSTEM_I2C_1_IO_CTRL

//SDHC
#define SDHC_BASE		    0xe1800000
#define SDHC_INTERRUPT		SYSTEM_PLIC_USER_INTERRUPT_D_INTERRUPT

//ISP
#define ISP_DMA_BASE 		IO_APB_SLAVE_0_INPUT
#define ISP_DMA_INTERRUPT 	SYSTEM_PLIC_USER_INTERRUPT_A_INTERRUPT
#define ISP_AXI4_SLAVE_BASE SYSTEM_AXI_A_BMB
#define ISP_CAM_APB3 		IO_APB_SLAVE_1_INPUT
#define I2C_CTRL_MIPI		SYSTEM_I2C_0_IO_CTRL
#define I2C_CTRL_HZ         SYSTEM_CLINT_HZ

//Camera
//Define the picam version. By default is set to Picam V2.
#define PICAM_VERSION 		2

//Resolution of Display
#define FRAME_WIDTH         1280
#define FRAME_HEIGHT        720
















#endif
