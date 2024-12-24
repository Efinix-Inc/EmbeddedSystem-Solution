////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "bsp.h"
#include "device_config.h"

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



/************************** Project Header File ***************************/
#define DEBUG_PRINTF_EN   	0
#define TEST_MODE   		0 //0:Normal Mode; 1:Link partner Test Mode;
#define PAT_NUM 		0
#define PAT_DLEN		8
#define PAT_IPG			4095 //4095//255
#define PAT_TYPE		0 //0:UDP Pattern; //1:MAC Pattern;
#define DST_MAC_H 		0xffff
#define DST_MAC_L 		0xffffffff
#define SRC_MAC_H 		(configMAC_ADDR5<<8)|configMAC_ADDR4
#define SRC_MAC_L 		(configMAC_ADDR3<<24)|(configMAC_ADDR2<<16)|(configMAC_ADDR1<<8)|configMAC_ADDR0//0x5e0060c8
#define SRC_IP 			(configIP_ADDR3<<24)|(configIP_ADDR2<<16)|(configIP_ADDR1<<8)|configIP_ADDR0
#define DST_IP 			0xc0a80165
#define SRC_PORT		0x0521
#define DST_PORT		0x2715

/************************** HW Header File ***************************/
#define TSE_Speed_1000Mhz	0x04
#define TSE_Speed_100Mhz	0x02
#define TSE_Speed_10Mhz		0x01

/************************** Application Header File ***************************/
#define TX_ENA_MASK    		0xFFFFFFFE
#define RX_ENA_MASK    		0xFFFFFFFD
#define XON_GEN_MASK 		0xFFFFFFFB
#define PROMIS_EN_MASK   	0xFFFFFFEF
#define PAD_EN_MASK   		0xFFFFFFDF
#define CRC_FWD_MASK   		0xFFFFFFBF
#define PAUSE_IGNORE_MASK   	0xFFFFFEFF
#define TX_ADDR_INS_MASK   	0xFFFFFBFF
#define LOOP_ENA_MASK   	0xFFFF7FFF
#define ETH_SPEED_MASK   	0xFFF8FFFF
#define XOFF_GEN_MASK 		0xFFBFFFFF
#define CNT_RST_MASK 		0x7FFFFFFF

