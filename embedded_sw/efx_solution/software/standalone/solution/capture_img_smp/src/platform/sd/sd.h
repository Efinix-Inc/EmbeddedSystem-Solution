////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef SRC_SD_H_
#define SRC_SD_H_

#include <stdbool.h> // Include boolean type support
#include <stdio.h>
#include "mmc.h"
#include "device_config.h"
#include "efx_mmc_driver.h"
#include "fatfs/ff.h"
#include "fatfs/diskio.h"
#include "fatfs/xprintf.h"

#include "platform/misc/bmp.h"
#include "platform/interrupt/intc.h"


/********************************* Initialize SD ***********************************/

// Define buffer size based on your BMP file maximum expected size
#define BMP_MAX_FILE_SIZE (FRAME_WIDTH * FRAME_HEIGHT * 3 + 54)  // Header + Pixel Data

// Declare buffer for BMP data (defined in sd.c)
extern uint8_t Buff[BMP_MAX_FILE_SIZE];
extern uint8_t small_buff[50];

// FATFS File System Components (extern for global access)
extern FATFS FatFs;
extern FIL File[2];
extern DIR Dir;
extern FILINFO Finfo;
extern FATFS *fs;

// Declare SD/MMC Variables
extern volatile UINT Timer;
extern struct mmc *mmc;
extern struct mmc_cmd *xmmc_cmd;
extern struct mmc_data *data;
extern struct mmc_config *cfg;
extern struct mmc_ops *ops;

// File System Type Strings
extern const char *ft[];

// Additional missing global variables
extern char Line[256];
extern char *ptr, *ptr2;
extern unsigned char v;
extern long p1, p2, p3;
extern BYTE res, b, drv;
extern UINT s1, s2, cnt, blen;
extern DWORD ofs, sect, blk[2], dw;
extern QWORD acc_size; //, acc_files, acc_dirs;
extern UINT acc_files, acc_dirs;

// Function Prototypes
bool printOrSetRTCTime(char *ptr);
void put_rc(FRESULT rc);
void sd_init();
void sd_main();
void putChar(char c);
FRESULT scan_files(char *path, UINT *n_dir, UINT *n_file, QWORD *sz_file);


// Variable for enable vision in sd_main()
extern u32 capture_enabled;
extern u32 display_enabled;
extern u32 camera_enabled;
extern u32 eth_enabled;

#endif /* SRC_SD_H_ */
