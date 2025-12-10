////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
* @file mmc.h
* 
* @brief Header file containing MMC (MultiMediaCard) related declarations and structures.
*
******************************************************************************/
#pragma once
#include <stdint.h>

#define BIT(X)	                    1<<X

#define MMC_DATA_READ		            1
#define MMC_DATA_WRITE		            2
#define MMC_CMD_GO_IDLE_STATE		    0 //Resets the SD Memory Card. 
#define MMC_CMD_SEND_OP_COND		    1 //Sends host capcity support infocmation and activate card's intialization process.
#define MMC_CMD_ALL_SEND_CID		    2
#define MMC_CMD_SET_RELATIVE_ADDR	    3
#define MMC_CMD_SET_DSR			        4
#define MMC_CMD_SWITCH			        6
#define MMC_CMD_SELECT_CARD		        7
#define MMC_CMD_SEND_EXT_CSD		    8  
#define MMC_CMD_SEND_CSD		        9  //Asks the selected card to send its card-specific data (CSD)
#define MMC_CMD_SEND_CID		        10 //Asks the selected card to send its card identification (CID)
#define MMC_CMD_STOP_TRANSMISSION	    12 //Forces the card to stop transmission in Multiple Block Read Operation.
#define MMC_CMD_SEND_STATUS		        13 //Asks the selected card to sends its status register.
#define MMC_CMD_SET_BLOCKLEN		    16 //Sets a block length for R/W cmd. Block length R/W cmd set to 512B in High Capacity card. 
#define MMC_CMD_READ_SINGLE_BLOCK	    17 //Reads a block of the size selected by the SET_BLOCKLEN command. 
#define MMC_CMD_READ_MULTIPLE_BLOCK	    18 //Continuously transfers data blocks from card to host until interupted.
#define MMC_CMD_SEND_TUNING_BLOCK_HS200	21 
#define MMC_CMD_SET_BLOCK_COUNT         23 //Reserved. 
#define MMC_CMD_WRITE_SINGLE_BLOCK	    24 //Writes a block of the size selected by the SET_BLOCKLEN command. 
#define MMC_CMD_WRITE_MULTIPLE_BLOCK	25 //Continuously writes block of data until 'Stop Tran' token is sent. 
#define MMC_CMD_ERASE_GROUP_START	    35
#define MMC_CMD_ERASE_GROUP_END		    36
#define MMC_CMD_ERASE			        38 //Erases all previously selected write blocks. 
#define MMC_CMD_APP_CMD			        55 //Defines to the card that the next command is an app specific command. 
#define MMC_CMD_RES_MAN			        62 //Reserved for Manufacturer

//Response Format
#define MMC_RSP_PRESENT                 (1 << 0)
#define MMC_RSP_136	                    (1 << 1)		/* 136 bit response */
#define MMC_RSP_CRC	                    (1 << 2)		/* expect valid crc */
#define MMC_RSP_BUSY	                (1 << 3)		/* card may send busy */
#define MMC_RSP_OPCODE	                (1 << 4)		/* response contains opcode */

#define MMC_RSP_NONE	                (0)
#define MMC_RSP_R1	                    (MMC_RSP_PRESENT|MMC_RSP_CRC|MMC_RSP_OPCODE)	//Card Status
#define MMC_RSP_R1b 	                (MMC_RSP_PRESENT|MMC_RSP_BUSY)	//Card Status with addtional of busy signal
#define MMC_RSP_R2	                    (MMC_RSP_PRESENT|MMC_RSP_136|MMC_RSP_CRC)		//Two Bytes long 
#define MMC_RSP_R3	                    (MMC_RSP_PRESENT)								//Sent by card when a READ_OCR is received
#define MMC_RSP_R6	                    (MMC_RSP_PRESENT|MMC_RSP_CRC|MMC_RSP_OPCODE)	//Published RCA response
#define MMC_RSP_R7	                    (MMC_RSP_PRESENT|MMC_RSP_CRC|MMC_RSP_OPCODE)	//Card interface condition

struct mmc;

struct mmc_cmd {
	unsigned short  cmdidx;		// Command index
	unsigned int  resp_type;	// Response type
	unsigned int  cmdarg;		// Command argument
	unsigned int  response[4];	// Response data
};

/*
 * ADMA2 descriptor structure - should be defined in a header file
 * This must be 8-byte aligned for proper operation
 */
struct adma2_desc {
    u32 attr_length;  /* Attribute (16-bit) | Length (16-bit) */
    u32 addr;         /* 32-bit address */
};

/*******************************************************************************
*
* @brief This structure defines the settings for MMC data transfer, including 
* the destination and source buffers, transfer flags, number of blocks, and 
* block size.
*
* Members:
* - dest: Destination buffer for data transfer.
* - src: Source buffer for data transfer (src buffers are read-only).
* - flags: Transfer flags.
* - blocks: Number of blocks to transfer.
* - blocksize: Size of each block.
*
******************************************************************************/
struct mmc_data {
    union {
        u32 *dest;              // Destination buffer for data transfer
        u32 *src;         // Source buffer for data transfer (read-only)
    };
    unsigned int flags;         // Transfer flags
    unsigned int blocks;        // Number of blocks to transfer
    unsigned int blocksize;     // Size of each block
};

/*******************************************************************************
*
* @brief This structure defines various MMC operations such as sending commands, 
* setting I/Os, initializing MMC, checking card detection, checking write protection, 
* performing host power cycle, and getting the maximum block count.
*
* Members:
* - send_cmd: Function pointer to send a command.
* - set_ios: Function pointer to set I/Os.
* - init: Function pointer to initialize MMC.
* - getcd: Function pointer to check card detection.
* - getwp: Function pointer to check write protection.
* - host_power_cycle: Function pointer to perform host power cycle.
* - get_b_max: Function pointer to get the maximum block count.
*
******************************************************************************/
struct mmc_ops {
	int (*send_cmd)(struct mmc *mmc,
			struct mmc_cmd *cmd, struct mmc_data *data);
	int (*set_ios)(struct mmc *mmc);
	int (*init)(struct mmc *mmc);
	int (*getcd)(struct mmc *mmc);
	int (*getwp)(struct mmc *mmc);
	int (*host_power_cycle)(struct mmc *mmc);
	int (*get_b_max)(struct mmc *mmc, void *dst, uint64_t blkcnt);
};

/*******************************************************************************
*
* @brief This structure holds the MMC configuration settings including MMC name,
* operations,host capabilities, supported voltages, minimum and maximum frequencies, 
* maximum block count, and partition type.
*
* Members:
* - name: Name of the MMC.
* - ops: Pointer to MMC operations.
* - host_caps: Host capabilities.
* - voltages: Supported voltages.
* - f_min: Minimum frequency.
* - f_max: Maximum frequency.
* - b_max: Maximum block count.
* - part_type: Partition type.
*
 ******************************************************************************/
struct mmc_config {
    char *name;                     // Name of the MMC
    struct mmc_ops *ops;            // Pointer to MMC operations
    unsigned int host_caps;         // Host capabilities
    unsigned int voltages;          // Supported voltages
    unsigned int f_min;             // Minimum frequency
    unsigned int f_max;             // Maximum frequency
    unsigned int b_max;             // Maximum block count
    unsigned char part_type;        // Partition type
};

/**
 * @brief Main eMMC device structure containing device properties, capabilities, and control data
 *
 * This structure represents an eMMC device instance and contains all the necessary information
 * for device identification, configuration, and operation. It includes device specifications
 * read from CSD/EXT_CSD registers, clock and timing parameters, erase capabilities, boot
 * partition information, and an aligned ADMA descriptor table for DMA transfers.
 *
 * The structure serves as the central data container passed between driver functions to
 * maintain device state and provide access to device-specific parameters needed for
 * read/write/erase operations in various speed modes (HS200/HS400).
 */
struct mmc {
    struct mmc_config *cfg;         // Pointer to MMC configuration
    void *priv;                     // Pointer to private data

    u32 base_clk_freq_mhz;
    u32 max_block_len;
    u32 spec_vers;
    u32 clk_div;
    u32 device_type;
    u32 driver_strength;
    u32 erase_group_def;
    u32 erase_grp_size;
    u32 erase_grp_mult;
    u32 hc_erase_grp_size;
    u32 erase_timeout_mult;
    u32 sec_count;
    u32 c_size;
    u32 c_size_mult;
    u32 read_bl_len;
    u32 boot_info;
    u32 boot_size_mult;
    __attribute__((aligned(8))) struct adma2_desc Descriptor[6400];
};

enum current_state {
  idle = 0,
  ready = 1,
  ident = 2,
  stby = 3,
  tran = 4,
  data = 5,
  rcv = 6,
  prg = 7,
  dis = 8,
  btst = 9,
  slp = 10
};

enum bus_speed_mode {
  legacy = 0,
  hssdr = 1,
  hsddr = 2,
  hs200 = 3,
  hs400 = 4
};

enum erase_type {
  erase = 0,
  trim  = 1
};

static const u32 tuning_block_pattern_8b_mode[] = {
		0xff00ffff, 0x0000ffff, 0xccccffff, 0xcccc33cc, 0xcc3333cc, 0xffffcccc, 0xffffeeff, 0xffeeeeff,
		0xffddffff, 0xddddffff, 0xbbffffff, 0xbbffffff, 0xffffffbb, 0xffffff77, 0x77ff7777, 0xffeeddbb,
		0x00ffffff, 0x00ffffff, 0xccffff00, 0xcc33cccc, 0x3333cccc, 0xffcccccc, 0xffeeffff, 0xeeeeffff,
		0xddffffff, 0xddffffff, 0xffffffdd, 0xffffffbb, 0xffffbbbb, 0xffff77ff, 0xff7777ff, 0xeeddbb77
};

static const u32 tuning_block_pattern_4b_mode[] = {
		0x00ff0fff, 0xccc3ccff, 0xffcc3cc3, 0xeffefffe, 0xddffdfff, 0xfbfffbff, 0xff7fffbf, 0xefbdf777,
		0xf0fff0ff, 0x3cccfc0f, 0xcfcc33cc, 0xeeffefff, 0xfdfffdff, 0xffbfffdf, 0xfff7ffbb, 0xde7b7ff7
};
