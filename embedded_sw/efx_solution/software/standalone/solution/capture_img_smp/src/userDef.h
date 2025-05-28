////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////


#ifndef USERDEF_H_
#define USERDEF_H_

#include <stdlib.h>
#include <string.h>
#include "soc.h"
#include "type.h"
#include "mmc.h"
#include "device_config.h"
/************************** Hardware Header File ***************************/

#define I2C_CTRL		RTC_I2C_BASE_ADDR
#define I2C_FREQ		100000	//100kHz
#define I2C_CTRL_HZ		SYSTEM_CLINT_HZ
#define CORE_HZ			BSP_CLINT_HZ

/************************** BMP Reader Setting ***************************/

#define BMP_HEADER_SIZE 54
#define IMG_START_ADDR        	0x01000000 //0x01000000
#define DDR_START_ADDRESS  		0x01000000
#define img_array       		((uint32_t*)IMG_START_ADDR)
#define DDR_SIZE           		(FRAME_WIDTH*FRAME_WIDTH*3 + 0x100)

/************************** Main Header File ***************************/

//RTC - PCF8523
#ifdef  RTC_PCF8523_SUPPORT
#include "device/pcf8523.h"
#else
#include "device/ds3231.h"
#endif
time_data myConfig;

/*
 * Define DMA_MODE to enable DMA access instead of PIO access
 * DMA access provides higher throughput compared to PIO access.
 */
#define DMA_MODE

/*
 * Define DEBUG_PRINTF_EN to enable debug message printing
 * This can help with debugging during development.
 */
#define DEBUG_PRINTF_EN 0

/************************** SDHC ***************************/
#define MAX_CLK_FREQ  50000//KHz
#define SD_CLK_FREQ   MAX_CLK_FREQ//KHz
#define SDHC_ADDR     0x100
#define BLOCK_SIZE    0x200
#define MAX_BLK_BUF   0x1
#define DATA_WIDTH    0x2 //0x0:1-bit mode; 0x2:4-bit mode;

/************************** TSEMAC ***************************/
#define configIP_ADDR0		192
#define configIP_ADDR1		168
#define configIP_ADDR2		31
#define configIP_ADDR3		55

#define configMAC_ADDR0	 	0x00
#define configMAC_ADDR1 	0x11
#define configMAC_ADDR2 	0x22
#define configMAC_ADDR3 	0x33
#define configMAC_ADDR4 	0x44
#define configMAC_ADDR5 	0x41
#define TEST_MODE   		0 //0:Normal Mode; 1:Link partner Test Mode;
#define PAT_NUM 			0
#define PAT_DLEN			8
#define PAT_IPG				4095 //4095//255
#define PAT_TYPE			0 //0:UDP Pattern; //1:MAC Pattern;
#define DST_MAC_H 			0xffff
#define DST_MAC_L 			0xffffffff
#define SRC_MAC_H 			(configMAC_ADDR5<<8)|configMAC_ADDR4
#define SRC_MAC_L 			(configMAC_ADDR3<<24)|(configMAC_ADDR2<<16)|(configMAC_ADDR1<<8)|configMAC_ADDR0//0x5e0060c8
#define SRC_IP 				(configIP_ADDR3<<24)|(configIP_ADDR2<<16)|(configIP_ADDR1<<8)|configIP_ADDR0
#define DST_IP 				0xc0a80165
#define SRC_PORT			0x0521
#define DST_PORT			0x2715

/************************** TSEMAC HW Header File ***************************/

#define TSE_Speed_1000Mhz	0x04
#define TSE_Speed_100Mhz	0x02
#define TSE_Speed_10Mhz		0x01

/************************** SDHC INTC Header File *****************************/
#define INT_ENABLE                0xffffffcf
#define INT_COMMAND_COMPLETE      0x1
#define INT_TRANSFER_COMPLETE     0x2
#define INT_BLOCK_GAP_EVENT       0x4
#define INT_BUFFER_WRITE_READY    0x10
#define INT_BUFFER_READ_READY     0x20
#define INT_CARD_INSERTION        0x40
#define INT_CARD_REMOVAL          0x80
#define INT_COMMAND_TIMEOUT_ERROR 0x10000
#define INT_COMMAND_CRC_ERROR     0x20000
#define INT_COMMAND_END_BIT_ERROR 0x40000
#define INT_COMMAND_INDEX_ERROR   0x80000
#define INT_DATA_CRC_ERROR        0x200000

#define UART_DECIMAL_OFFSET 48
#define STATE_HOUR          0x00
#define STATE_MINUTES       0x01
#define STATE_SECONDS       0x02
#define STATE_WEEK_DAY      0x03
#define STATE_DAYS          0x04
#define STATE_MONTH         0x05
#define STATE_YEAR          0x06
#define STATE_CONFIG        0x07
#define STATE_EXIT          0x08

#define ASCII_LOWER_CASE_Q  0x71
#define ASCII_UPPER_CASE_Q  0x51

/************************** Application Header File ***************************/
#define TX_ENA_MASK    		0xFFFFFFFE
#define RX_ENA_MASK    		0xFFFFFFFD
#define XON_GEN_MASK 		0xFFFFFFFB
#define PROMIS_EN_MASK   	0xFFFFFFEF
#define PAD_EN_MASK   		0xFFFFFFDF
#define CRC_FWD_MASK   		0xFFFFFFBF
#define PAUSE_IGNORE_MASK   0xFFFFFEFF
#define TX_ADDR_INS_MASK   	0xFFFFFBFF
#define LOOP_ENA_MASK   	0xFFFF7FFF
#define ETH_SPEED_MASK   	0xFFF8FFFF
#define XOFF_GEN_MASK 		0xFFBFFFFF
#define CNT_RST_MASK 		0x7FFFFFFF

/************************** Peripherals *****************************/
extern struct mmc *mmc;
extern struct mmc_cmd *xmmc_cmd;
extern struct mmc_data *data;

//time_data myConfig;

static
const char HelpMsg[] =

	" v - Enable Camera and HDMI Display. \r\n"
	" d - Enable HDMI Display only. \r\n"
	" z - Disable Camera and HDMI Display. \r\n"
	" x <file> - Read BMP format file. \r\n"
	" c - Capture Image when camera/display is enabled. \r\n"
	"\r\n";

#endif
