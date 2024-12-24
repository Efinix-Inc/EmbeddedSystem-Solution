////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*
 * source.c
 *
 *  Created on: 17 Mar 2021
 *      Author: user
 */
#include "bsp.h"
#include "device_config.h"
#include "userDef.h"
#include "efx_mmc_driver.h"
#include "mmc.h"

static const int fbase[] = {
	10000,
	100000,
	1000000,
	10000000,
};

static const int multipliers[] = {
	0,	/* reserved */
	10,
	12,
	13,
	15,
	20,
	25,
	30,
	35,
	40,
	45,
	50,
	55,
	60,
	70,
	80,
};

void SD_READ_CSD(struct mmc *mmc, struct mmc_cmd *cmd)
{
	sd_send_cmd(mmc,cmd,MMC_CMD_SEND_CSD,MMC_RSP_R2,(mmc->rca<<16));
	mmc->csd[0]= cmd->response[0];
	mmc->csd[1]= cmd->response[1];
	mmc->csd[2]= cmd->response[2];
	mmc->csd[3]= cmd->response[3];

	mmc->capacity = (((mmc->csd[1]>>8) &0x3FFFFF)+1)*512;
	mmc->capacity *=1024;
	mmc->tran_speed = multipliers[(mmc->csd[2]>>27) &0x07] * fbase[(mmc->csd[2]>>24) &0x03];

	if(DEBUG_PRINTF_EN == 1)
	{
		bsp_printf("CSD 0x%x 0x%x 0x%x 0x%x\r\n",mmc->csd[0],mmc->csd[1],mmc->csd[2],mmc->csd[3]);
		bsp_printf("FILE_FORMAT = %d\r\n",(mmc->csd[0]>>2) &0x03);		//[11:10]
		bsp_printf("TMP_WRITE_PROTECT = %d\r\n",(mmc->csd[0]>>4) &0x01);//[12]
		bsp_printf("PERM_WRITE_PROTECT = %d\r\n",(mmc->csd[0]>>5) &0x01);//[13]
		bsp_printf("COPY = %d\r\n",(mmc->csd[0]>>6) &0x01);			//[14]
		bsp_printf("FILE_FORMAT_GRP = %d\r\n",(mmc->csd[0]>>7) &0x01);//[15]
		//[20:16]
		bsp_printf("WRITE_BL_PARTIAL = %d\r\n",(mmc->csd[0]>>13) &0x01);//[21]
		bsp_printf("WRITE_BL_LEN = %d\r\n",(mmc->csd[0]>>14) &0x0F);//[25:22]
		bsp_printf("R2W_FACTOR = %d\r\n",(mmc->csd[0]>>18) &0x07);//[28:26]
		//[30:29]
		bsp_printf("WP_GRP_ENABLE = %d\r\n",(mmc->csd[0]>>23) &0x01);//[31]

		bsp_printf("WP_GRP_SIZE = %d\r\n",(mmc->csd[0]>>24) &0x7F);//[38:32]

		bsp_printf("SECTOR_SIZE = %d\r\n",((mmc->csd[1] & 0x3F)<<1)|((mmc->csd[0])>>31 &0x1));//[45:39]
		bsp_printf("ERASE_BLK_EN = %d\r\n",(mmc->csd[1]>>6) &0x01);//[46]
		//[47]
		bsp_printf("C_SIZE = %d\r\n",(mmc->csd[1]>>8) &0x3FFFFF);//[69:48]
		//[75:70]
		bsp_printf("DSR_IMP = %d\r\n",(mmc->csd[2]>>4) &0x01);//[76]
		bsp_printf("READ_BLK_MISAIGN = %d\r\n",(mmc->csd[2]>>5) &0x01);//[77]
		bsp_printf("WRITE_BLK_MISAIGN = %d\r\n",(mmc->csd[2]>>6) &0x01);//[78]
		bsp_printf("READ_BL_PARTIAL = %d\r\n",(mmc->csd[2]>>7) &0x01);//[79]
		bsp_printf("READ_BL_LEN = %d\r\n",(mmc->csd[2]>>8) &0x0F);//[83:80]
		bsp_printf("CCC = %d\r\n",(mmc->csd[2]>>12) &0x0FFF);//[95:84]
		bsp_printf("TRAN_SPEED = 0x%x\r\n",(mmc->csd[2]>>24) &0x0FF);//[103:96]
		bsp_printf("NSAC = 0x%x\r\n",(mmc->csd[3]) &0x0FF);//[111:104]
		bsp_printf("TAAC = 0x%x\r\n",(mmc->csd[3]>>8) &0x0FF);//[119:112]
		//[125:120]
		bsp_printf("TAAC = 0x%x\r\n",(mmc->csd[3]>>22) &0x03);//[127:126]
		bsp_printf("mmc->capacity = %d\r\n",(((mmc->csd[1]>>8) &0x3FFFFF)+1)*512);
		bsp_printf("mmc->tran_speed = %d\r\n",mmc->tran_speed);
	}


}

/************************** Function File ***************************/
void SD_CardInitial(struct mmc *mmc, struct mmc_cmd *cmd)
{
	u32 Value;
	char busy=0;
	u32 rca=0;
	int wait_busy_count;

    for(int i=0; i<1; i++) {

        sd_send_cmd(mmc,cmd,MMC_CMD_GO_IDLE_STATE,MMC_RSP_NONE,0);
        bsp_uDelay(1000);
        sd_send_cmd(mmc,cmd,MMC_CMD_SEND_EXT_CSD,MMC_RSP_R7,0x01AA);
        sd_send_cmd(mmc,cmd,MMC_CMD_APP_CMD,MMC_RSP_R1,0);

		wait_busy_count = 0;
        while (busy==0)
        {
                Value = 0;
                Value |= 0x1<<30;//HCS
                Value |= 0x0<<28;//XPC
                Value |= 0x0<<24;//S18R
                Value |= 0x100000;//VDD VOLTAGE
                bsp_uDelay(50000);//delay 50ms
                sd_send_cmd(mmc,cmd,MMC_CMD_APP_CMD,MMC_RSP_R1,0);
                sd_send_cmd(mmc,cmd,SD_CMD_APP_SEND_OP_COND,MMC_RSP_R3,Value);
                bsp_printf("Respose: 0x%x\r\n",cmd->response[0]);
                busy = (cmd->response[0]>>31)&0x1;
                bsp_uDelay(1000000);//delay 50ms
				
			wait_busy_count++;
			if (wait_busy_count >=10)
			{
				break;
			}
        }


        if(busy == 1) {
            break;
        } else if(i == 1) {
            bsp_printf("Err : ACMD41 OCR BUSY!\r\n");
            while(1);
        }
        bsp_uDelay(1000000);
    }

	sd_send_cmd(mmc,cmd,MMC_CMD_ALL_SEND_CID,MMC_RSP_R2,0);
	mmc->cid[0]=cmd->response[0];
	mmc->cid[1]=cmd->response[1];
	mmc->cid[2]=cmd->response[2];
	mmc->cid[3]=cmd->response[3];

	sd_send_cmd(mmc,cmd,MMC_CMD_SET_RELATIVE_ADDR,MMC_RSP_R6,0);

	mmc->rca = (cmd->response[0]&0xffff0000)>>16;
	SD_READ_CSD(mmc,cmd);
	sd_send_cmd(mmc,cmd,MMC_CMD_SELECT_CARD,MMC_RSP_R1b,(mmc->rca<<16));
	//write_u32(DATA_WIDTH, APB_0+SDHC_ADDR+0x028);//sdhc_reg - Host Control 1

	sd_send_cmd(mmc,cmd,MMC_CMD_APP_CMD,MMC_RSP_R1,(mmc->rca<<16));
	sd_send_cmd(mmc,cmd,SD_CMD_APP_SET_BUS_WIDTH,MMC_RSP_R1,DATA_WIDTH);
	sd_send_cmd(mmc,cmd,MMC_CMD_SET_BLOCKLEN,MMC_RSP_R1,BLOCK_SIZE);

	if(DEBUG_PRINTF_EN)
		bsp_printf("SD_CardInitial done\r\n");
}


void SD_EraseBlk(struct mmc *mmc, struct mmc_cmd *cmd,u32 sd_addr, u32 blk_count)
{
	sd_send_cmd(mmc,cmd,SD_CMD_ERASE_WR_BLK_START,MMC_RSP_R1,sd_addr);
	sd_send_cmd(mmc,cmd,SD_CMD_ERASE_WR_BLK_END,MMC_RSP_R1,sd_addr+(blk_count-1)*BLOCK_SIZE);
	sd_send_cmd(mmc,cmd,MMC_CMD_ERASE,MMC_RSP_R1b,0);
}


void SD_WRITE_BLOCK(struct mmc *mmc, u32 addr, void* src, u32 blocks)
{
	struct mmc_cmd *cmd;
	struct mmc_data *data;
	struct mmc_ops	*ops = mmc->cfg->ops;

	cmd = malloc(sizeof(struct mmc_cmd));
	data = malloc(sizeof(struct mmc_data));

	memset(cmd,0,sizeof(struct mmc_cmd));
	memset(data,0,sizeof(struct mmc_data));

	data->blocksize = mmc->read_bl_len;
	data->blocks = blocks;

	if(data->blocks == 1)	cmd->cmdidx=MMC_CMD_WRITE_SINGLE_BLOCK;
	else					cmd->cmdidx=MMC_CMD_WRITE_MULTIPLE_BLOCK;

	cmd->cmdarg =addr;
	cmd->resp_type=MMC_RSP_R1;

	data->src=src;
	data->flags = MMC_DATA_WRITE;

	ops->send_cmd(mmc,cmd,data);

	free(cmd);
	free(data);

	return;
}

void SD_READ_BLOCK(struct mmc *mmc, u32 addr, char* dest, u32 blocks)
{
	struct mmc_cmd *cmd;
	struct mmc_data *data;
	struct mmc_ops	*ops = mmc->cfg->ops;


	cmd = malloc(sizeof(struct mmc_cmd));
	data = malloc(sizeof(struct mmc_data));

	memset(cmd,0,sizeof(struct mmc_cmd));
	memset(data,0,sizeof(struct mmc_data));

	data->blocksize = mmc->read_bl_len;
	data->blocks = blocks;

	if(data->blocks == 1)	cmd->cmdidx=MMC_CMD_READ_SINGLE_BLOCK;
	else					cmd->cmdidx=MMC_CMD_READ_MULTIPLE_BLOCK;

	cmd->cmdarg =addr;
	cmd->resp_type=MMC_RSP_R1;
	data->dest=dest;
	data->flags = MMC_DATA_READ;


	mmc->cfg->ops->send_cmd(mmc,cmd,data);

	free(cmd);
	free(data);

	return;
}

char SD_ReadWriteCompare(char* wrbuf, char* rdbuf ,u64 wr_start ,u64 wr_end ,u64 rd_start ,u64 rd_end,u32 block_count,u32 current_blk,u32 total_blk)
{
	char err=0;
	u32 m,cmpblk;
	u32 rd_speed,wr_speed;

	if(block_count>MAX_BLK_BUF)	cmpblk=MAX_BLK_BUF;
	else						cmpblk=block_count;

	if(memcmp(wrbuf,rdbuf,sizeof(char)*cmpblk*BLOCK_SIZE))
	{
		bsp_printf("Tested Block %d/%d\n\r",current_blk,total_blk);

			for(m=0;m<(cmpblk*BLOCK_SIZE/4);m++)
			{
				if(wrbuf[m] != rdbuf[m])
				{
				bsp_printf("compare fail m=%d wr= 0x%x rd=0x%x\n\r",m,wrbuf[m],rdbuf[m]);
				err=1;
				break;
				}

			}
	}
	else
	{
		wr_speed = ((block_count*BLOCK_SIZE)*1024)/((wr_end-wr_start)/(SYSTEM_CLINT_HZ/1000000));
		rd_speed = ((block_count*BLOCK_SIZE)*1024)/((rd_end-rd_start)/(SYSTEM_CLINT_HZ/1000000));

		if((current_blk % 1024) ==0)
			bsp_printf("Tested Block %d/%d          Write s=%d KByte/s   Read s=%d KByte/s           \r",current_blk,total_blk,wr_speed,rd_speed);

	}

	return err;
}


void SD_InitRandomBuff(char* buf, u32 size)
{
	int m;

	for(m=0;m<size;m++)
	{
		buf[m] = rand() & 0xFF;
	}

	srand(buf[0]);
}

