////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "bsp.h"
#include "device_config.h"
#include "userDef.h"
#include "source.h"
#include "intc.h"
#include "mmc.h"
#include "efx_mmc_driver.h"

char buf[BLOCK_SIZE*MAX_BLK_BUF];
char rd_buf[BLOCK_SIZE*MAX_BLK_BUF];


void main() {

	bsp_init();
	struct mmc *mmc;
	struct mmc_cmd *cmd;
	struct mmc_data *data;
	struct mmc_config *cfg;
	struct mmc_ops *ops;
	int fail=1;
	u32 total_block_n,n;
	u64 timer_start,timer_end;
	u32 rd_timer_start,rd_timer_end;
	u32 ts,te;

	mmc=malloc(sizeof(struct mmc));
	cfg=malloc(sizeof(struct mmc_config));
	ops=malloc(sizeof(struct mmc_ops));
	cmd=malloc(sizeof(struct mmc_cmd));
	data=malloc(sizeof(struct mmc_data));



	bsp_printf("\n\r*** Starting SDHC Demo ***\n\r");
	bsp_printf("\r\nInitialize ..");

	//Allocation Struct Space

	memset(mmc, 0, sizeof(struct mmc));
	memset(cfg, 0, sizeof(struct mmc_config));
	memset(ops, 0, sizeof(struct mmc_ops));
	memset(cmd, 0, sizeof(struct mmc_cmd));
	memset(data, 0, sizeof(struct mmc_data));
	memset(buf, 0, (sizeof(char)*BLOCK_SIZE*MAX_BLK_BUF));
	memset(rd_buf, 0, (sizeof(char)*BLOCK_SIZE*MAX_BLK_BUF));

	mmc->cfg = cfg;		//pass the pointer after malloc in struct
	mmc->cfg->ops = ops;//pass the pointer after malloc in struct

	sd_ctrl_mmc_probe(mmc, SDHC_BASE); //init SD Card driver

	IntcInitialize(mmc);	// init interrupt

	SD_CardInitial(mmc,cmd);	//init SD Card
	bsp_printf("Done\r\n");

	if(DEBUG_PRINTF_EN == 1)
		bsp_printf("WR ADDR 0x%x Rd ADDR 0x%x\r\n",buf,rd_buf);

	SD_InitRandomBuff(buf,BLOCK_SIZE*MAX_BLK_BUF);	//init write buffer with random data;


	//Read/Write Test with Speed

	//!!!!warning it will crash the SD card data!!!!

	total_block_n = ((u32)(mmc->capacity/512));

	bsp_printf("**************START SPEED TEST*******************\r\n");
	bsp_printf("**SD CLOCK SPEED = %d\r\n",SD_CLK_FREQ);
	bsp_printf("**CARD SPEED = %d kHz\r\n",mmc->tran_speed/1000);
	bsp_printf("**CARD SIZE = %d Mbyte Total BLOCK = %d\r\n",(u32)(mmc->capacity/1024/1024),total_block_n);
	bsp_printf("**SD BUS WIDTH = %d\r\n",mmc->bus_width);
	bsp_printf("**BLOCK SIZE = %d BUFFER OF BLOCK = %d\r\n",BLOCK_SIZE,MAX_BLK_BUF);
	bsp_printf("**TEST SIZE = %d kbyte\r\n",(BLOCK_SIZE*MAX_BLK_BUF)/1024);
	bsp_printf("*************************************************\r\n");

	bsp_printf("\r\n\n!!!!Warning it will crash the SD card data!!!!\r\n\n");
	bsp_printf("      ###Push Any Key to Continue###\r\n\n");

//	while(1)
//	{
//		if(uart_read(BSP_UART_TERMINAL))
//			break;
//	}

	for(n=0;n<total_block_n;n+=MAX_BLK_BUF)
	{
		// Erase Block
		SD_EraseBlk(mmc,cmd,0,MAX_BLK_BUF);

		// Get write start time
		timer_start=clint_getTime(BSP_CLINT);

		// Write to block
		SD_WRITE_BLOCK(mmc,0,buf,MAX_BLK_BUF);

		// Get write finish time
		timer_end=clint_getTime(BSP_CLINT);

		// Get read start time
		rd_timer_start=clint_getTime(BSP_CLINT);

		// Read from block
		SD_READ_BLOCK(mmc,0,rd_buf,MAX_BLK_BUF);

		//Get read finish time
		rd_timer_end=clint_getTime(BSP_CLINT);


		SD_ReadWriteCompare(buf,rd_buf,timer_start,timer_end,rd_timer_start,rd_timer_end,MAX_BLK_BUF,n,total_block_n);	//compare 2 buffer with speed calculation

	}
}
