////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef SRC_TEST_H_
#define SRC_TEST_H_

#include "emmc.h"
#include "efx_emmc_driver.h"

int dma_wr_rd_erase(struct mmc *mmc, struct mmc_cmd *cmd, u32 len_mode, u32 fixed_bk_num, u32 start_addr,
					 enum erase_type erase_mode, u32 erase_en ,u32 test_size_mb, double *write_speed, double *read_speed, double *erase_speed);

int non_dma_wr_rd(struct mmc *mmc, struct mmc_cmd *cmd, u32 len_mode, u32 fixed_bk_num, u32 start_addr, u32 test_size_mb,
				  double *write_speed, double *read_speed);

int test_entire_emmc(struct mmc *mmc, struct mmc_cmd *cmd, u32 dma, enum bus_speed_mode transfer_mode, enum data_bus_width bus_width,
					 u32 clk_freq, u32 len_mode,	u32 fixed_bk_num, enum erase_type erase_mode, u32 whole_space_test_num);

u32* create_random_buffer(size_t size_mb);
u32* create_empty_buffer(size_t size_mb);

#endif /* SRC_TEST_H_ */
