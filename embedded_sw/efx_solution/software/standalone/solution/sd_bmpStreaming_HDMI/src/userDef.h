////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
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
#define IMG_START_ADDR        	0x01000000
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

/************************** INTC Header File *****************************/
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

/************************** Peripherals *****************************/
extern struct mmc *mmc;
extern struct mmc_cmd *xmmc_cmd;
extern struct mmc_data *data;

//time_data myConfig;

static
const char HelpMsg[] =
	"[Buffer controls]\r\n"
	" bd <ofs> - Dump working buffer\r\n"
	" be <ofs> [<data>] ... - Edit working buffer\r\n"
	" br <pd#> <lba> [<count>] - Read disk into working buffer\r\n"
	" bw <pd#> <lba> [<count>] - Write working buffer into disk\r\n"
	" bf <val> - Fill working buffer\r\n"
	"[File system controls]\r\n"
	" fi <ld#> [<mount>]- Force initialized the volume\r\n"
	" fs [<path>] - Show volume status\r\n"
	" fl [<path>] - Show a directory\r\n"
	" fo <mode> <file> - Open a file\r\n"
	"    mode 0 => Open existing file\r\n"
	"    mode 1 => Open as read file\r\n"
	"    mode 2 => Open as write file\r\n"
	"    mode 4 => Create new file\r\n"
	"    mode 8 => Create new file always\r\n"
	"    mode 16 => Open a file always\r\n"
	"    mode 48 => Open a file append\r\n"
	" fc - Close the file\r\n"
	" fe <ofs> - Move fp in normal seek\r\n"
	" fd <len> - Read and dump the file\r\n"
	" fr <len> - Read the file\r\n"
	" fw <len> <val> - Write to the file\r\n"
	" fn <org.name> <new.name> - Rename an object\r\n"
	" fu <name> - Unlink an object\r\n"
	" fv - Truncate the file at current fp\r\n"
	" fk <name> - Create a directory\r\n"
	" fa <atrr> <mask> <object name> - Change attribute of an object\r\n"
	" ft <year> <month> <day> <hour> <min> <sec> <name> - Change timestamp of an object\r\n"
	" fx <src.file> <dst.file> - Copy a file\r\n"
	" fg <path> - Change current directory\r\n"
	" fq - Show current directory\r\n"
	" fb <name> - Set volume label\r\n"
	" fm - Create FAT32 file system\r\n"
	" fz [<len>] - Change/Show R/W length for fr/fw/fx command\r\n"
	"[Misc commands]\r\n"
	" md[b|h|w] <addr> [<count>] - Dump memory\r\n"
	" mf <addr> <value> <count> - Fill memory\r\n"
	" me[b|h|w] <addr> [<value> ...] - Edit memory\r\n"
	" t [<hour> <min> <sec> <dayOfTheWeek> <day> <month> <year>] - Set/Show RTC\r\n"
		"    <dayOfTheWeek> = 1: Sunday, 2: Monday, 3: Tuesday, 4: Wednesday, "
		"5: Thursday, 6: Friday, 7: Saturday \r\n"
	" x <file> - Read BMP format file\r\n"
	" v - Enable HDMI Display to display bmp format file \r\n"
	" z - Flush Image Buffer\r\n"
	"\r\n";

#endif
