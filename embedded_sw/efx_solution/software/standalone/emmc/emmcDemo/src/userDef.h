////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef USERDEF_H_
#define USERDEF_H_

#include "soc.h"

/************************** Hardware Header File ***************************/
//The following parameters are described in the ug document
#define EMMC_VCCQ			1.8
#define EMMC_LARGE_DENSITY	1
#define EMMC_RCA			2
#define EMMC_BLOCK_LEN		512
#define EMMC_STEP           ((EMMC_LARGE_DENSITY == 0) ? 1 : 512ULL)

/************************** Main Header File ***************************/
#define DEBUG_PRINTF_EN   	1

/************************** SDHC Header File ***************************/
#define MAX_CLK_FREQ  		400			//KHz
#define SD_CLK_FREQ   		MAX_CLK_FREQ	//KHz
#define BLOCK_SIZE    		0x200
#define MAX_BLK_BUF   		0x100
#define DATA_WIDTH    		0x2 			//0x0:1-bit mode; 0x2:4-bit mode;

/************************** INTC Header File *****************************/
#define INT_ENABLE  				0xffffffcf
#define INT_COMMAND_COMPLETE      	0x1
#define INT_TRANSFER_COMPLETE     	0x2
#define INT_BLOCK_GAP_EVENT       	0x4
#define INT_BUFFER_WRITE_READY    	0x10
#define INT_BUFFER_READ_READY     	0x20
#define INT_COMMAND_TIMEOUT_ERROR 	0x10000
#define INT_COMMAND_CRC_ERROR     	0x20000
#define INT_COMMAND_END_BIT_ERROR 	0x40000
#define INT_COMMAND_INDEX_ERROR   	0x80000
#define INT_DATA_CRC_ERROR        	0x200000


#endif
