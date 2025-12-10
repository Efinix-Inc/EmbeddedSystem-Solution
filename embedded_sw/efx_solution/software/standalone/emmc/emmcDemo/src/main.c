////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "bsp.h"
#include "device_config.h"
#include "intc.h"
#include "efx_emmc_driver.h"
#include "userDef.h"
#include "test.h"
#include "boot_access.h"

#define TEST_AREA_USER 1
#define TEST_AREA_BOOT 2
#define TEST_AREA TEST_AREA_USER

#define TEST_USER_ENTIRE 1
#define TEST_USER_SINGLE 2
#define TEST_USER TEST_USER_SINGLE

void main()
{
	bsp_init();

	struct mmc *mmc;
	struct mmc_cmd *cmd;
	struct mmc_data *data;
	struct mmc_config *cfg;
	struct mmc_ops *ops;

	mmc=malloc(sizeof(struct mmc));
	cfg=malloc(sizeof(struct mmc_config));
	ops=malloc(sizeof(struct mmc_ops));
	cmd=malloc(sizeof(struct mmc_cmd));
	data=malloc(sizeof(struct mmc_data));

	bsp_printf_full("\n\r--- EFX-eMMC Demo ---\n\r");
	bsp_printf_full("\r\nInitializing...\r\n");

	//Allocation Struct Space

	memset(mmc, 0, sizeof(struct mmc));
	memset(cfg, 0, sizeof(struct mmc_config));
	memset(ops, 0, sizeof(struct mmc_ops));
	memset(cmd, 0, sizeof(struct mmc_cmd));
	memset(data, 0, sizeof(struct mmc_data));

	mmc->cfg = cfg;		//pass the pointer after malloc in struct
	mmc->cfg->ops = ops;//pass the pointer after malloc in struct

	srand((unsigned int)time(NULL));

	efx_emmc_reset_ip();

	efx_emmc_reset_device();

	sd_ctrl_mmc_probe(mmc,EMMC_ADDR);

	IntcInitialize(mmc);

	efx_emmc_init(mmc, cmd);

#if TEST_AREA == TEST_AREA_USER
	u32 ret = 0 ;
	u32 len_mode = 0;        // 0:fixed block  1:random block
	u32 fixed_bk_num = 65535; // 1~65535      32768
	u32 dma_mode = 1;        // 0:non-dma  1:dma
	u32 clk_freq = 200;      // 200/100/50 MHz
	u32 erase_mode = trim;  // erase/trim
	u32 speed_mode = hs400;  // hs400/hs200
	u32 bus_width = x8;      // hs200:x4/x8  hs400:x8

	#if TEST_USER == TEST_USER_ENTIRE
		u32 whole_space_test_num = 1;
		test_entire_emmc(mmc, cmd, dma_mode, speed_mode, bus_width, clk_freq, len_mode, fixed_bk_num, erase_mode, whole_space_test_num);
	#elif TEST_USER == TEST_USER_SINGLE
		u32 test_size_mb = 8; //MB, max 487MB
		u32 start_addr = 100*(erase_unit_size_calculate(mmc,erase_mode)/EMMC_STEP);
		u32 erase_en = (((start_addr * EMMC_STEP) % erase_unit_size_calculate(mmc,erase_mode)) != 0x0)? 0:1;
		double write_speed = 0.0;
		double read_speed = 0.0;
		double erase_speed = 0.0;

		efx_emmc_switch_bus_speed_mode(mmc, cmd, speed_mode, bus_width, clk_freq, 0x0);
		if(dma_mode == 0)
			ret = non_dma_wr_rd(mmc, cmd, len_mode, fixed_bk_num, start_addr, test_size_mb, &write_speed, &read_speed);
		else {
			ret = dma_wr_rd_erase(mmc, cmd, len_mode, fixed_bk_num, start_addr,erase_mode, erase_en, test_size_mb, &write_speed, &read_speed, &erase_speed);
		}

		if (ret == 0) {
			bsp_printf_full("-------------------Test Success-------------------\r\n");
		} else {
			bsp_printf_full("-------------------Test Fail-------------------\r\n");
		}
	#endif
#elif TEST_AREA == TEST_AREA_BOOT
	u32* src_buffer = create_random_buffer(32);
	u32* dest_buffer = create_empty_buffer(32);
	u32 boot_partition_size = boot_partition_size_calculate(mmc);

	u32 dma_en = 1;        // 0:non-dma  1:dma
	u32 bus_width = x4;    // recommend to set x4/x8
	u32 read_all = 1;      // 0:single 1:all--Read out all the data in the boot area at one time
	u32 par_num = 1;       // boot partition number: 1/2
	u32 erase_type = erase; // erase/trim
	u32 addr = 0x0;
	u32 block_cnt = boot_partition_size / EMMC_BLOCK_LEN;
	u32 erase_start_addr = 0x0;
	u32 erase_unit_num = boot_partition_size / erase_unit_size_calculate (mmc, erase_type);

	u32 test_fail = 0;
	u32 ret = 0;

	efx_emmc_boot_write(mmc, cmd, bus_width, par_num, block_cnt, addr, src_buffer, dma_en);
	bsp_printf_full("-------------write finish-----------------\r\n");

	if (read_all == 1) {
		efx_emmc_boot_read_all(mmc, cmd, bus_width, par_num, dest_buffer, dma_en);  //Read out all the data in the boot area at one time
	} else {
		efx_emmc_boot_read_single(mmc, cmd, bus_width, par_num, block_cnt, addr, dest_buffer, dma_en);
	}
	bsp_printf_full("-------------read finish-----------------\r\n");

	test_fail = 0;
	for(int i=0; i<boot_partition_size/4; i++) {
		if(dest_buffer[i] != src_buffer[i]) {
			bsp_printf_full("dest_buffer[%d] = 0x%x, src_buffer[%d] = 0x%x\r\n", i, dest_buffer[i], i, src_buffer[i]);
			bsp_printf_full("-------------compare fail -----------------\r\n");
			test_fail = 1;
			break;
		}
	}

	if(test_fail == 1) {
		bsp_printf_full("*************write && read test fail *************\r\n");
		goto free_buffers;
	} else {
		bsp_printf_full("*************write && read test success *************\r\n");
	}

	bsp_printf_full("*************erase test begin *************\r\n");
	efx_emmc_boot_erase(mmc, cmd, par_num, erase_start_addr, erase_unit_num, erase_type);
	if (read_all == 1) {
		efx_emmc_boot_read_all(mmc, cmd, bus_width, par_num, dest_buffer, dma_en);  //Read out all the data in the boot area at one time
	} else {
		efx_emmc_boot_read_single(mmc, cmd, bus_width, par_num, block_cnt, addr, dest_buffer, dma_en);
	}

	test_fail = 0;
	for(int i=0; i<boot_partition_size/4; i++) {
		if((dest_buffer[i] != 0) && (dest_buffer[i] != 0xFFFFFFFF)) {
			test_fail = 1;
			break;
		}
	}

	if(test_fail == 1) {
		bsp_printf_full("-------------erase fail -----------------\r\n");
		goto free_buffers;
	} else {
		bsp_printf_full("-------------erase success -----------------\r\n");
	}

	bsp_printf_full("-------------Boot Area Test Success-----------------\r\n");

free_buffers:
	free(src_buffer);
	free(dest_buffer);

#endif
}
