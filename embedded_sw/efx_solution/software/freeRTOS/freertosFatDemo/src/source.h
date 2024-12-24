////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef SRC_SOURCE_H_
#define SRC_SOURCE_H_

void SD_CMD(struct mmc *mmc, struct mmc_cmd *cmd);
void SD_CardInitial(struct mmc *mmc, struct mmc_cmd *cmd);
void SD_EraseBlk(struct mmc *mmc, struct mmc_cmd *cmd,u32 sd_addr, u32 blk_count);
void SD_WRITE_BLOCK(struct mmc *mmc, u32 addr, void* src, u32 blocksw);
void SD_READ_BLOCK(struct mmc *mmc, u32 addr, void* dest, u32 blocks);
char SD_ReadWriteCompare(char* wrbuf, char* rdbuf ,u64 wr_start ,u64 wr_end ,u64 rd_start ,u64 rd_end,u32 block_count,u32 current_blk,u32 total_blk);
void SD_InitRandomBuff(char* buf, u32 size);
void SD_READ_CSD(struct mmc *mmc, struct mmc_cmd *cmd);

#endif /* SRC_SOURCE_H_ */
