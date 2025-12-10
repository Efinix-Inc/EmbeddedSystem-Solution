////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file efx_mmc_driver.h
* 
* @brief Header file containing declarations for SD controller functions and structures.
*
* Functions:
* - sd_ctrl_write: Writes a 32-bit data value to the specified offset within the SD controller device registers.
* - sd_ctrl_read: Reads a 32-bit data value from the specified offset within the SD controller device registers.
* - sd_ctrl_cmd: Sends a command to the SD controller device and handles the response accordingly.
* - sd_ctrl_creat_Descriptor: Creates a descriptor for data transfer by allocating memory and setting up the descriptor entries.
* - sd_ctrl_data: Handles data transfer between the SD controller and the SD card.
* - sd_ctrl_check_read_write: Checks if the MMC command requires data read or write operations.
* - sd_ctrl_send_cmd: Sends the MMC command with or without data transfer based on the command type.
* - sd_ctrl_get_cd: Gets the card detect status.
* - sd_ctrl_get_wp: Gets the write protect status.
* - sd_ctrl_set_clk: Sets the clock frequency for SD operations.
* - sd_ctrl_set_bus: Sets the bus width for SD operations.
* - sd_ctrl_set_ios: Sets the I/O settings for the SD controller.
* - sd_ctrl_init: Initializes the SD controller and MMC/SD card.
* - sd_ctrl_mmc_probe: Probes and initializes the MMC/SD controller.
*
******************************************************************************/

#pragma once

#include "print.h"
#include "emmc.h"
#include "userDef.h"
#include "utils.h"
#include "tuning.h"

#define REG_VERSION 							0x0000
#define REG_BASE_REGISTER0						0x0004
#define REG_BASE_STATUS_REGISTER0				0x0008
#define REG_BASE_REGISTER1						0x000C
#define REG_ARGUMENT2 							0x0100
#define REG_BLOCK_SIZE_COUNT					0x0104
#define REG_ARGUMENT1 							0x0108
#define REG_TRANFER_MODE_COMMAND				0x010C
#define REG_COMMAND_RESP31_0 					0x0110
#define REG_COMMAND_RESP63_32 					0x0114
#define REG_COMMAND_RESP95_64 					0x0118
#define REG_COMMAND_RESP127_96 					0x011C
#define REG_BUFFER_DATA_PORT					0x0120
#define REG_PRESENT_STATE 						0x0124
#define REG_HOST_POWER_BLOCKGAP_WAKEUP_CONTROL	0x0128
#define REG_CLOCK_TIMEOUT_RESET_CONTROL			0x012C
#define REG_INTERRUPT_STATUS					0x0130
#define REG_INTERRUPT_STATUS_ENABLE				0x0134
#define REG_INTERRUPT_SIGNAL_ENABLE				0x0138
#define REG_HOST_CAPABILITIES					0x0140
#define REG_ADMA_SYSTEM_ADDR0					0x0158
#define REG_ADMA_SYSTEM_ADDR1					0x015C

#define SYS_REG_DATE							0x0000
#define SYS_REG_TEST							0x0004
#define SYS_REG_RESET							0x0008

#define MAX_DESCRIPTOR                  		65536

/*******************************************************************************
*
* @brief Structure to hold various interrupt status flags.
*
******************************************************************************/
typedef struct _IntStruct {
    u32 command_complete;           /* Command complete flag */
    u32 transfer_complete;          /* Transfer complete flag */
    u32 block_gap_event;            /* Block gap event flag */
    u32 buffer_write_ready;         /* Buffer write ready flag */
    u32 buffer_read_ready;          /* Buffer read ready flag */
    u32 command_timeout_error;      /* Command timeout error flag */
    u32 command_crc_error;          /* Command CRC error flag */
    u32 command_end_bit_error;      /* Command end bit error flag */
    u32 command_index_error;        /* Command index error flag */
    u32 data_crc_error;             /* Data CRC error flag */
} IntStruct;

/*******************************************************************************
*
* @brief Structure to hold transaction mode settings.
*
******************************************************************************/
typedef struct {
    u32 dma_enable;                     /* DMA enable flag */
    u32 block_count_enable;             /* Block count enable flag */
    u32 auto_cmd_enable;                /* Auto command enable flag */
    u32 data_transfer_direction_select; /* Data transfer direction select flag */
    u32 multi_or_single_block_select;   /* Multi or single block select flag */
} TransModeStruct;

/*******************************************************************************
*
* @brief Structure representing the SD controller device.
*
******************************************************************************/
struct sd_ctrl_dev {
    int base_addr;              	/* Base address of the SD controller */
    int clk_freq;               	/* Clock frequency */
    int f_min;                  	/* Minimum clock frequency */
    int f_max;                  	/* Maximum clock frequency */
    int app_cmd;                	/* Application command flag */
    TransModeStruct *TransModePtr; 	/* Pointer to transaction mode settings */
};

enum data_bus_width {
	x1 = 0x0,
	x4 = 0x1,
	x8 = 0x2
};

enum data_transfer_rate {
	sdr,
	ddr
};

extern volatile IntStruct IntPtr; 				/* Global interrupt status structure */
extern u32 Descriptor[1024];				/* Array to hold Descriptor */

static u32 is_cmd_or_data_bus_busy();
static u32 is_cmd_bus_busy();
static u32 is_ext_csd_config_successful(struct mmc *mmc, struct mmc_cmd *cmd);
static void efx_emmc_config_ip_bus_mode(u32 ddr_mode, u32 bus_width);
static int efx_emmc_config_dev_bus_mode(struct mmc *mmc, struct mmc_cmd *cmd, u32 ddr_mode, u32 bus_width);
static void efx_emmc_config_bus_mode(struct mmc *mmc, struct mmc_cmd *cmd, u32 ddr_mode, u32 bus_width);
static void efx_emmc_write_ext_csd(struct mmc *mmc, struct mmc_cmd *cmd, u32 index, u32 value);
static void efx_emmc_config_clk(struct mmc *mmc, u32 clk_khz);
static void efx_emmc_retrieve_cid(struct mmc *mmc, struct mmc_cmd *cmd);
static void efx_emmc_assign_rca(struct mmc *mmc, struct mmc_cmd *cmd);
static void efx_emmc_retrieve_csd(struct mmc *mmc, struct mmc_cmd *cmd);
static void efx_emmc_retrieve_ext_csd(struct mmc *mmc, struct mmc_cmd *cmd);
static int efx_emmc_switch_bus_speed_mode(struct mmc *mmc, struct mmc_cmd *cmd, enum bus_speed_mode mode, u32 bus_width, u32 clk_mhz, u32 driver_type);
static void efx_emmc_config_hs_timing(struct mmc *mmc, struct mmc_cmd *cmd, u32 driver_strength, u32 timing_interface);
static int efx_emmc_tuning(struct mmc *mmc, struct mmc_cmd *cmd, u32 bus_width);
static void efx_emmc_generate_pulse(u32 sample_cnt, u32 pll_shift);
static int efx_emmc_block_read(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en);
static int efx_emmc_block_write(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_enable);
static int efx_emmc_erase(struct mmc *mmc, struct mmc_cmd *cmd, u32 start_addr, u32 erase_unit_num);
static int efx_emmc_trim(struct mmc *mmc, struct mmc_cmd *cmd, u32 start_addr, u32 erase_unit_num);
static int erase_unit_size_calculate (struct mmc *mmc, enum erase_type type);
static u64 uda_density_calculate(struct mmc *mmc);

/*******************************************************************************
*
* @brief This function writes a 32-bit data value to the specified offset within the SD controller device registers.
*
* @param dev     Pointer to the SD controller device structure.
* @param offset  Offset address within the device registers where the data will be written.
* @param data    32-bit data value to be written.
*
******************************************************************************/
static void sd_ctrl_write(struct sd_ctrl_dev *dev, uint32_t offset, uint32_t data)
{
	write_u32(data,dev->base_addr+offset);
}

/*******************************************************************************
*
* @brief This function reads a 32-bit data value from the specified offset within the SD controller device registers.
*
* @param dev     Pointer to the SD controller device structure.
* @param offset  Offset address within the device registers from where the data will be read.
* @return        The 32-bit data value read from the specified offset.
*
******************************************************************************/
static uint32_t sd_ctrl_read(struct sd_ctrl_dev *dev, uint32_t offset)
{
	return read_u32(dev->base_addr+offset);
}

/*******************************************************************************
*
* @brief This function sends a command to the SD controller device and handles the response accordingly.
*
* @param mmc  Pointer to the MMC structure.
* @param cmd  Pointer to the MMC command structure containing command details.
* @return     0 on success, -1 on failure.
*
******************************************************************************/
static int sd_ctrl_cmd(struct mmc *mmc, struct mmc_cmd *cmd)
{
	int time_out;
	u32 Value;
	struct sd_ctrl_dev *dev = mmc->priv;

	IntPtr.command_complete = 0x0;
	IntPtr.command_timeout_error = 0x0;
	IntPtr.command_crc_error = 0x0;
	IntPtr.command_end_bit_error = 0x0;
	IntPtr.command_index_error = 0x0;

	if(DEBUG_PRINTF_EN == 1)
	{
		if(dev->app_cmd)
			bsp_printf_full("----[ACMD %d ARG 0x%x Rsp %d ]----\r\n",cmd->cmdidx, cmd->cmdarg,cmd->resp_type);
		else
			bsp_printf_full("----[CMD %d ARG 0x%x Rsp %d ]----\r\n",cmd->cmdidx, cmd->cmdarg,cmd->resp_type);
	}

	reg_write(cmd->cmdarg, REG_ARGUMENT1);

	//Transfer Mode
	Value = 0;
	Value |= (dev->TransModePtr->dma_enable&0x1)<<0;
	Value |= (dev->TransModePtr->block_count_enable&0x1)<<1;
	Value |= (dev->TransModePtr->auto_cmd_enable&0x3)<<2;
	Value |= (dev->TransModePtr->data_transfer_direction_select&0x1)<<4;
	Value |= (dev->TransModePtr->multi_or_single_block_select&0x1)<<5;
	//Command
	//-resp_type [000b:No Response; 001b:R2; 010 b:R3,R4; 110b:R1,R5,R6,R7; 011b:R1b,R5b;]
	if(cmd->resp_type & MMC_RSP_PRESENT)
	{
			 if(cmd->resp_type & MMC_RSP_BUSY)		Value |= 0x03<<16;
		else if(cmd->resp_type & MMC_RSP_136)		Value |= 0x01<<16;
		else										Value |= 0x02<<16;

		if(cmd->resp_type & MMC_RSP_CRC)			Value |= 0x01<<19;
		if(cmd->resp_type & MMC_RSP_OPCODE)			Value |= 0x01<<20;
	}

	//-data_present_select
	if(dev->app_cmd) {
		Value |= 0x0<<21;
	} else{
		switch(cmd->cmdidx){
		case MMC_CMD_SWITCH:				Value |= 0x0<<21; break;	//CMD6
		case MMC_CMD_READ_SINGLE_BLOCK:		Value |= 0x1<<21; break;	//CMD17
		case MMC_CMD_READ_MULTIPLE_BLOCK:	Value |= 0x1<<21; break;	//CMD18
		case MMC_CMD_WRITE_SINGLE_BLOCK:	Value |= 0x1<<21; break;	//CMD24
		case MMC_CMD_WRITE_MULTIPLE_BLOCK:	Value |= 0x1<<21; break;	//CMD25
		default:							Value |= 0x0<<21; break;	//else
		}
	}

	//-command_type
	Value |= 0x0<<22;
	//-command_index
	Value |= (cmd->cmdidx&0x3f)<<24;

	if(cmd->resp_type & MMC_RSP_BUSY) {
		bsp_printf_full("value 0x%x\r\n", Value);
//		Value = 0x6030000;
	}

	//Wait CMD Status idle.
	while(is_cmd_bus_busy()) {
		bsp_uDelay(1);
	}
	bsp_printf_full("cmd%d value 0x%x\r\n", cmd->cmdidx, Value);
	reg_write(Value, REG_TRANFER_MODE_COMMAND);

	if(cmd->resp_type & MMC_RSP_BUSY) {
		while (is_cmd_bus_busy()) {
			bsp_uDelay(1);
		}
	}

	time_out = 0;
	while(1) {
		if(IntPtr.command_complete == 0x1) {
			IntPtr.command_complete = 0x0;
			if((IntPtr.command_timeout_error == 0x0) && (IntPtr.command_crc_error == 0x0) &&
			   (IntPtr.command_end_bit_error == 0x0) && (IntPtr.command_index_error == 0x0))  {
				bsp_printf_full("Info : CMD Succeed!\n\r");

				if((cmd->resp_type&0xf) == 0x0) {//No Response
				} else if(cmd->resp_type & MMC_RSP_136) {//Response Length 136
					cmd->response[0] = reg_read(REG_COMMAND_RESP31_0);//cmd_resp[31:0]
					cmd->response[1] = reg_read(REG_COMMAND_RESP63_32);//cmd_resp[63:32]
					cmd->response[2] = reg_read(REG_COMMAND_RESP95_64);//cmd_resp[95:64]
					cmd->response[3] = reg_read(REG_COMMAND_RESP127_96);//cmd_resp[127:96]
				} else {//Response Length 48
					cmd->response[0] = reg_read(REG_COMMAND_RESP31_0);//cmd_resp[31:0]
					cmd->response[1] = reg_read(REG_COMMAND_RESP63_32);//cmd_resp[63:32]
				}

			} else {
				if (IntPtr.command_timeout_error) bsp_printf_full("Error: CMD Failed. CMD timeout error!\n\r");
				else if (IntPtr.command_crc_error) bsp_printf_full("Error: CMD Failed. CMD CRC error!\n\r");
				else if (IntPtr.command_end_bit_error) bsp_printf_full("Error: CMD Failed. CMD end bit error!\n\r");
				else if (IntPtr.command_index_error) bsp_printf_full("Error: CMD Failed. CMD index error!\n\r");
				else bsp_printf_full("Error: CMD Failed. Unknown error!\n\r");

				IntPtr.command_timeout_error = 0x0;
				IntPtr.command_crc_error = 0x0;
				IntPtr.command_end_bit_error = 0x0;
				IntPtr.command_index_error = 0x0;
			}

			break;
		}
	}

	if(cmd->cmdidx == MMC_CMD_APP_CMD)
		dev->app_cmd =1;
	else
		dev->app_cmd =0;

	mmc->priv = dev;

	return 0;
}

/**
 * @brief Create ADMA2 descriptor table for SD/EMMC controller
 *
 * @param mmc Pointer to mmc structure containing device info
 * @param blocks Number of blocks to transfer
 * @param block_size Size of each block in bytes
 * @param src Source buffer address for data transfer
 *
 * @return 0 on success, negative value on error
 */
static int sd_ctrl_creat_Descriptor(struct mmc *mmc, u32 blocks, u32 block_size, u32 *src)
{
    struct sd_ctrl_dev *dev = mmc->priv;

    /* Get pointer to descriptor table - should be pre-allocated and properly aligned */
    struct adma2_desc *desc_table = (struct adma2_desc *)mmc->Descriptor;

    /* Calculate total transfer length */
    u32 total_length = block_size * blocks;

    /* ADMA2 has a maximum transfer size of 65536 bytes per descriptor */
    #define MAX_DESCRIPTOR_LENGTH 65536

    /* Calculate how many descriptor lines we need */
    u32 desc_count = total_length / MAX_DESCRIPTOR_LENGTH;
    if (total_length % MAX_DESCRIPTOR_LENGTH) {
        desc_count++;
    }

    /* Make sure we don't exceed the allocated space for descriptors
     * Assuming a maximum of 6400 descriptors was allocated
     */
    if (desc_count > 6400) {
        return -1; /* Too many descriptors needed */
    }

    /* Clear the descriptor table memory */
    memset(desc_table, 0, desc_count * sizeof(struct adma2_desc));

    /* Create the descriptor table entries */
    u32 remaining_length = total_length;
    u32 curr_src_addr = (u32)(uintptr_t)src;

    for (u32 i = 0; i < desc_count; i++) {
        /* Calculate length for this descriptor */
        u32 xfer_length;
        if (remaining_length > MAX_DESCRIPTOR_LENGTH) {
            xfer_length = MAX_DESCRIPTOR_LENGTH;
        } else {
            xfer_length = remaining_length;
        }

        /* For ADMA2, if length is 65536, set the length field to 0 */
        u16 length_field = (xfer_length == MAX_DESCRIPTOR_LENGTH) ? 0 : (u16)xfer_length;

        /* Prepare attribute field
         * Bits [5:4]: 10b for TRAN (transfer data)
         * Bit 2: 0 for no interrupt
         * Bit 1: 1 for END (last descriptor) or 0 (not last)
         * Bit 0: 1 for VALID
         */
        u16 attr = (2 << 4) | 1; /* Valid=1, TRAN=10b */

        /* Set END bit for the last descriptor */
        if (i == desc_count - 1) {
            attr |= (1 << 1); /* End=1 */
        }

        /* Fill the descriptor entry */
        desc_table[i].attr_length = (attr & 0xFFFF) | ((length_field & 0xFFFF) << 16);
        desc_table[i].addr = curr_src_addr;

        /* Update for next descriptor */
        curr_src_addr += xfer_length;
        remaining_length -= xfer_length;
    }

    /* Set the ADMA system address register to the physical address of the descriptor table */
    reg_write((u32)(uintptr_t)desc_table, REG_ADMA_SYSTEM_ADDR0);

    return 0;
}

/*******************************************************************************
*
* @brief This function handles data transfer between the SD controller and the SD card.
*
* @param mmc Pointer to the MMC structure representing the MMC/SD card.
* @param cmd Pointer to the MMC command structure.
* @param data Pointer to the MMC data structure containing data transfer information.
* @return Returns 0 upon successful data transfer.
*
******************************************************************************/
static int sd_ctrl_data(struct mmc *mmc, struct mmc_cmd *cmd, struct mmc_data *data)
{
	u32 buf=0,tmp=0;
	struct sd_ctrl_dev *dev =mmc->priv;

	//Transfer Mode Set
	if(DEBUG_PRINTF_EN == 1)
	{
		bsp_printf_full("Write OPS Addr = 0x%x\r\n",dev->base_addr);
		bsp_printf_full("IntPtr.transfer_complete %d \r\n",IntPtr.transfer_complete);
	}

#ifdef DMA_MODE

	dev->TransModePtr->dma_enable = 0x1;
	if(data->flags==MMC_DATA_WRITE)
		sd_ctrl_creat_Descriptor(mmc,data->blocks,data->blocksize,data->src);
	else
		sd_ctrl_creat_Descriptor(mmc,data->blocks,data->blocksize,data->dest);

#else
	dev->TransModePtr->dma_enable = 0x0;
#endif

	if(data->blocks == 0x1) {
		dev->TransModePtr->auto_cmd_enable = 0x0;
	} else {
		dev->TransModePtr->auto_cmd_enable = 0x1;
	}

	if(data->flags==MMC_DATA_WRITE)
		dev->TransModePtr->data_transfer_direction_select = 0x0;
	else
		dev->TransModePtr->data_transfer_direction_select = 0x1;

	mmc->priv = dev;

	//Set Block Size & Block Count
		reg_write(((data->blocks&0xffff)<<16) | EMMC_BLOCK_LEN, REG_BLOCK_SIZE_COUNT);;//sdhc_reg - Block Size & Block Count Register

		sd_ctrl_cmd(mmc,cmd);


		if(DEBUG_PRINTF_EN == 1)
		{
			if((cmd->response[0]>>3)&0x1) bsp_printf_full("CS-AKE_SEQ_ERROR\r\n");
			if((cmd->response[0]>>5)&0x1) bsp_printf_full("CS-APP_CMD\r\n");
			if((cmd->response[0]>>8)&0x1) bsp_printf_full("CS-READY_FOR_DATA\r\n");
			bsp_printf_full("CS-CURRENT_STATE %d\r\n", (cmd->response[0]>>9)&0xf);
			if((cmd->response[0]>>13)&0x1) bsp_printf_full("CS-ERASE_RESET\r\n");
			if((cmd->response[0]>>14)&0x1) bsp_printf_full("CS-CARD_ECC_DISABLED\r\n");
			if((cmd->response[0]>>15)&0x1) bsp_printf_full("CS-WP_ERASE_SKIP\r\n");
			if((cmd->response[0]>>16)&0x1) bsp_printf_full("CS-CSD_OVERWRITE\r\n");
			if((cmd->response[0]>>19)&0x1) bsp_printf_full("CS-ERROR\r\n");
			if((cmd->response[0]>>20)&0x1) bsp_printf_full("CS-CC_ERROR\r\n");
			if((cmd->response[0]>>21)&0x1) bsp_printf_full("CS-CARD_ECC_FAILED\r\n");
			if((cmd->response[0]>>22)&0x1) bsp_printf_full("CS-ILLEGALCOMMAND\r\n");
			if((cmd->response[0]>>23)&0x1) bsp_printf_full("CS-COM_CRC_ERROR\r\n");
			if((cmd->response[0]>>24)&0x1) bsp_printf_full("CS-LOCK_UNLOCK_FAILED\r\n");
			if((cmd->response[0]>>25)&0x1) bsp_printf_full("CS-CARD_IS_LOCKED\r\n");
			if((cmd->response[0]>>26)&0x1) bsp_printf_full("CS-WP_VIOLATION\r\n");
			if((cmd->response[0]>>27)&0x1) bsp_printf_full("CS-ERASE_PARAM\r\n");
			if((cmd->response[0]>>28)&0x1) bsp_printf_full("CS-ERASE_SEQ_ERROR\r\n");
			if((cmd->response[0]>>29)&0x1) bsp_printf_full("CS-BLOCK_LEN_ERROR\r\n");
			if((cmd->response[0]>>30)&0x1) bsp_printf_full("CS-ADDRESS_ERROR\r\n");
			if((cmd->response[0]>>31)&0x1) bsp_printf_full("CS-OUT_OF_RANGE\r\n");
		}

#ifndef DMA_MODE

	if(data->flags==MMC_DATA_WRITE)
	{
		for(int i=0; i<(data->blocks); i++) {

			//Wait one block data can be written to the buffer.
			while(1) {
				if(reg_read(REG_PRESENT_STATE)&0x400) {
					break;
				}
				//bsp_uDelay(1);
			}
			//Write One Block
			for(int j=0; j<((data->blocksize)/4); j++) {

				buf = data->src[tmp++];
				buf |= data->src[tmp++]<<8;
				buf |= data->src[tmp++]<<16;
				buf |= data->src[tmp++]<<24;
				//bsp_printf_full("WRITE %x \r\n",buf);

				reg_write(buf, REG_BUFFER_DATA_PORT);//sdhc_reg - buffer_data_port Register
			}
		}
	}
	else
	{
		for(int i=0; i<data->blocks; i++) {
			//Wait readable block data exists in the buffer.
			while(1) {
				if(reg_read(REG_PRESENT_STATE)&0x800) {
					break;
				}
				//bsp_uDelay(1);
			}
			//Read One Block
			for(int j=0; j<(BLOCK_SIZE/4); j++) {
				buf = reg_read(REG_BUFFER_DATA_PORT);

				data->dest[tmp++]=buf & 0xFF;
				data->dest[tmp++]=(buf>>8) & 0xFF;
				data->dest[tmp++]=(buf>>16) & 0xFF;
				data->dest[tmp++]=(buf>>24) & 0xFF;

				//bsp_uDelay(1);//Must ensure that the read rate is lower than the SD clock rate.
			}
			reg_write(0x20, REG_INTERRUPT_STATUS);
		}
	}

#endif
	//Wait Transfer Complete Interrupt
	while(1) {
		if(IntPtr.transfer_complete == 0x1) {
			IntPtr.transfer_complete = 0x0;
			//bsp_uDelay(100);
			break;
		}
	}
	return 0;
}


/*******************************************************************************
*
* @brief This function checks if the MMC command requires data read or write operations.
*
* @param cmd Pointer to the MMC command structure.
* @return Returns 1 if the command requires data read or write operations, otherwise returns 0.
*
*******************************************************************************/

static int sd_ctrl_check_read_write(struct mmc_cmd *cmd)
{
		 if(cmd->cmdidx== MMC_CMD_READ_SINGLE_BLOCK)	return 1;
	else if(cmd->cmdidx== MMC_CMD_READ_MULTIPLE_BLOCK)	return 1;
	else if(cmd->cmdidx== MMC_CMD_WRITE_SINGLE_BLOCK)	return 1;
	else if(cmd->cmdidx== MMC_CMD_WRITE_MULTIPLE_BLOCK)	return 1;
	else	return 0;
}

/*******************************************************************************
*
* @brief This function sends the MMC command with or without data transfer 
*		 based on the command type.
*
* @param mmc Pointer to the MMC structure representing the MMC/SD card.
* @param cmd Pointer to the MMC command structure.
* @param data Pointer to the MMC data structure containing data transfer information.
* @return Returns 0 upon successful command execution.
*
*******************************************************************************/
static int sd_ctrl_send_cmd(struct mmc *mmc, struct mmc_cmd *cmd, struct mmc_data *data)
{
	if(sd_ctrl_check_read_write(cmd))
	{
		if(data)
		{
			sd_ctrl_data(mmc,cmd,data);
		}
	}
	else
	{
		sd_ctrl_cmd(mmc,cmd);
	}

	return 0;
}

/*******************************************************************************
*
* @brief This function sets the I/O settings for the SD controller.
*
* @param mmc Pointer to the MMC structure representing the MMC/SD card.
* @return Returns 0 upon successful I/O setting.
*
*******************************************************************************/
static int sd_ctrl_set_ios(struct mmc *mmc)
{
    //sd_ctrl_set_clk(mmc); // Set clock frequency
    //sd_ctrl_set_bus(mmc); // Set bus width
    return 0;
}

/*******************************************************************************
*
* @brief This function initializes the SD controller and MMC/SD card.
*
* @param mmc Pointer to the MMC structure representing the MMC/SD card.
* @return Returns 0 upon successful initialization.
*
*******************************************************************************/
static int sd_ctrl_init(struct mmc *mmc)
{
    mmc->cfg->ops->set_ios(mmc); // Set I/O settings
    return 0;
}

/*******************************************************************************
*
* @brief This function probes and initializes the MMC/SD controller.
*
* @param mmc Pointer to the MMC structure representing the MMC/SD card.
* @param base_addr Base address of the SD controller.
* @return Returns 0 upon successful probe and initialization.
*
*******************************************************************************/

static int sd_ctrl_mmc_probe(struct mmc *mmc, int base_addr)
{
    struct sd_ctrl_dev *dev;
    TransModeStruct *ptr;

    // Allocate memory for SD controller device and transfer mode structure
    dev = malloc(sizeof(struct sd_ctrl_dev));
    ptr = malloc(sizeof(TransModeStruct));

    // Initialize allocated memory with zeros
    memset(dev, 0, sizeof(struct sd_ctrl_dev));
    memset(ptr, 0, sizeof(TransModeStruct));

    // Set SD controller device properties
    dev->base_addr = base_addr;
    dev->clk_freq = SD_CLK_FREQ;
    dev->TransModePtr = ptr;

    // Set MMC private data to SD controller device
    mmc->priv = dev;

    // Set MMC configuration properties
    mmc->cfg->name = "efx_sd_controller";
    mmc->cfg->ops->send_cmd = sd_ctrl_send_cmd;
    mmc->cfg->ops->set_ios = sd_ctrl_set_ios;

    // Set MMC clock frequency and capabilities
    mmc->cfg->b_max = 1024;
    mmc->read_bl_len = BLOCK_SIZE;

    // Initialize SD controller and MMC/SD card
    sd_ctrl_init(mmc);

    return 0;
}

static void sd_send_cmd(struct mmc *mmc, struct mmc_cmd *cmd, u32 index, u32 resp_type, u32 cmdarg)
{
	struct mmc_ops *ops = mmc->cfg->ops;
	struct mmc_data *data = NULL;

	cmd->cmdidx = index;
	cmd->resp_type = resp_type;
	cmd->cmdarg =cmdarg;

	ops->send_cmd(mmc,cmd,data);
}

static u32 is_cmd_or_data_bus_busy()
{
	if (reg_is_bit_set(REG_BASE_STATUS_REGISTER0, 0)) {
//		bsp_printf_full("Command bus busy\r\n");
		return 1;
	} else if (reg_is_bit_set(REG_BASE_STATUS_REGISTER0, 1)) {
//		bsp_printf_full("Data bus busy\r\n");
		return 1;
	}
	return 0;
}

static u32 is_cmd_bus_busy()
{
	if (reg_is_bit_set(REG_BASE_STATUS_REGISTER0, 0)) {
//		bsp_printf_full("Command bus busy\r\n");
		return 1;
	}
	return 0;
}

static void efx_emmc_reset_ip()
{
	sys_reg_set_bit(SYS_REG_RESET, 0);
	bsp_uDelay(1);
	sys_reg_clear_bit(SYS_REG_RESET, 0);
	bsp_uDelay(1);
}

static void efx_emmc_reset_device()
{
	sys_reg_set_bit(SYS_REG_RESET, 1);
	bsp_uDelay(1);
	sys_reg_clear_bit(SYS_REG_RESET, 1);
	bsp_uDelay(1);
	bsp_uDelay(200);
}

static void efx_emmc_config_clk(struct mmc *mmc, u32 clk_khz)
{
	u32 delay = 0;

	if (clk_khz > 200000) {
		clk_khz = 200000;
		bsp_printf_full("Warning: Target clock exceed limit. Limit to 200MHz\r\n");
	}

	mmc->clk_div = (mmc->base_clk_freq_mhz * 1000000.0) / (clk_khz * 1000.0);

	reg_write((0x1 << 16) | (mmc->clk_div), REG_BASE_REGISTER0);
	delay = cycle_to_us(clk_khz, 74);
	bsp_uDelay(delay);
	bsp_printf_full("Clock %dkHz, clock divider %d, delay %dus\r\n", clk_khz, mmc->clk_div, delay);
}

static int efx_emmc_init(struct mmc *mmc, struct mmc_cmd *cmd)
{
	u32 addr_mode = 0;
	u32 busy = 0;
	u32 ocr = 0;
	u32 voltage_supported = 0;

	if (EMMC_RCA <= 1) {
		bsp_printf_full("Error: Invalid EMMC_RCA, it must be greater than 1\r\n");
		return -1;
	}

	mmc->base_clk_freq_mhz = reg_read(REG_HOST_CAPABILITIES) & 0x3ff;
	bsp_printf_full("EMMC base clock: %dMHz\r\n", mmc->base_clk_freq_mhz);
	mmc->max_block_len = (reg_read(REG_HOST_CAPABILITIES) >> 16) & 0xffff;
	bsp_printf_full("EMMC max block length: %d bytes\r\n", mmc->max_block_len);

	efx_emmc_config_clk(mmc, 400);

	efx_emmc_config_ip_bus_mode(0x0, 0x0);

	sd_send_cmd(mmc, cmd, MMC_CMD_GO_IDLE_STATE, MMC_RSP_NONE, 0x0);

	if (EMMC_LARGE_DENSITY == 0) {
		addr_mode = 0x0;
	} else {
		addr_mode = 0x2;
	}

	 if ((EMMC_VCCQ >= 1.1) && (EMMC_VCCQ <= 1.3)) {
		ocr = (addr_mode << 29);
	} else if ((EMMC_VCCQ >= 1.7) && (EMMC_VCCQ <= 1.95)) {
		ocr = (addr_mode << 29) | (0x1 << 7);
	} else if ((EMMC_VCCQ >= 2.7) && (EMMC_VCCQ <= 3.6)) {
		ocr = (addr_mode << 29) | (0x1ff << 15);
	} else {
		bsp_printf_full("Error: Invalid VCCQ\r\n");
		return -1;
	}
	bsp_printf_full("Host sent OCR = 0x%x\r\n", ocr);

	while (busy == 0) {
		sd_send_cmd(mmc, cmd, MMC_CMD_SEND_OP_COND, MMC_RSP_R3, ocr);
		busy = (cmd->response[0] >> 31) & 0x1;

		if (busy == 0) {
			bsp_printf_full("eMMC not yet ready\r\n");
			bsp_uDelay(200);
			continue;
		}

		bsp_printf_full("Device returned OCR = 0x%x\r\n", cmd->response[0]);
	}

	efx_emmc_retrieve_cid(mmc, cmd);

	efx_emmc_assign_rca(mmc, cmd);

	efx_emmc_retrieve_csd(mmc, cmd);

	sd_send_cmd(mmc, cmd, MMC_CMD_SEND_STATUS, MMC_RSP_R1, (EMMC_RCA << 16));

	if (((cmd->response[0] >> 9) & 0xf) != stby) {
		bsp_printf_full("Error: Failed to enter Stby state\r\n");
		return -1;
	}

	sd_send_cmd(mmc, cmd, MMC_CMD_SELECT_CARD, MMC_RSP_R1, EMMC_RCA << 16);

	sd_send_cmd(mmc, cmd, MMC_CMD_SEND_STATUS, MMC_RSP_R1, (EMMC_RCA << 16));

	if (((cmd->response[0] >> 9) & 0xf) != tran) {
		bsp_printf_full("Error: Failed to enter Tran state\r\n");
		return -1;
	}

	if (mmc->spec_vers >= 4) {
		efx_emmc_retrieve_ext_csd(mmc, cmd);  //when spec_vers >= 4, support ext_csd
	}

    sd_send_cmd(mmc, cmd, MMC_CMD_SET_BLOCKLEN, MMC_RSP_R1, EMMC_BLOCK_LEN);
    if (val_is_bit_set(cmd->response[0], 29)) {
    	bsp_printf_full("Error: Invalid BLOCK_LEN\r\n");
	    return -1;
    }

	if (EMMC_BLOCK_LEN > mmc->max_block_len) {
		bsp_printf_full("Error: EMMC_BLOCK_LEN cannot exceed %d\r\n", mmc->max_block_len);
		return -1;
	}

	bsp_printf_full("eMMC user data area capacity is 0x%llx bytes\r\n", uda_density_calculate(mmc));
	bsp_printf_full("erase_unit_size in erase mode is 0x%x bytes\r\n", erase_unit_size_calculate(mmc,erase));
	bsp_printf_full("erase_unit_size in trim mode is 0x%x bytes\r\n", erase_unit_size_calculate(mmc,trim));

	bsp_printf_full("eMMC init done\r\n");
	return 0;
}

static void efx_emmc_retrieve_cid(struct mmc *mmc, struct mmc_cmd *cmd)
{
	u32 pnm[6] = {0};

	sd_send_cmd(mmc, cmd, MMC_CMD_ALL_SEND_CID, MMC_RSP_R2, 0x0);
	bsp_printf_full("CID:\r\n");
	bsp_printf_full("cmd->response[3]:%.8x\r\n", cmd->response[3]);
	bsp_printf_full("cmd->response[2]:%.8x\r\n", cmd->response[2]);
	bsp_printf_full("cmd->response[1]:%.8x\r\n", cmd->response[1]);
	bsp_printf_full("cmd->response[0]:%.8x\r\n", cmd->response[0]);
	pnm[5] = (cmd->response[2] >> 24) & 0x00ff;
	pnm[4] = (cmd->response[2] >> 16) & 0x00ff;
	pnm[3] = (cmd->response[2] >> 8 ) & 0x00ff;
	pnm[2] = (cmd->response[2] >> 0 ) & 0x00ff;
	pnm[1] = (cmd->response[1] >> 24) & 0x00ff;
	pnm[0] = (cmd->response[1] >> 16) & 0x00ff;

	bsp_printf_full("\r\n");
	bsp_printf_full("---- CID table begin ----\r\n");
	bsp_printf_full("MID    = 0x%x\r\n", (cmd->response[3] >> 16) & 0x00ff);
	bsp_printf_full("CBX    = 0x%x\r\n", (cmd->response[3] >> 8 ) & 0x0003);
	bsp_printf_full("OID    = 0x%x\r\n", (cmd->response[3] >> 0 ) & 0x00ff);
	bsp_printf_full("PNM    = 0x%x%x%x%x%x%x\r\n", pnm[5], pnm[4], pnm[3], pnm[2], pnm[1], pnm[0]);
	bsp_printf_full("PRV    = 0x%x\r\n", (cmd->response[1] >> 8 ) & 0x00ff);
	bsp_printf_full("PSN    = 0x%x\r\n", ((cmd->response[1] & 0x00ff) << 24) | (cmd->response[0] >> 8 & 0xffffff));
	bsp_printf_full("MDT    = 0x%x\r\n", (cmd->response[0] >> 0 ) & 0x00ff);
	bsp_printf_full("---- CID table end ----\r\n");
	bsp_printf_full("\r\n");
}

static void efx_emmc_assign_rca(struct mmc *mmc, struct mmc_cmd *cmd)
{
	sd_send_cmd(mmc, cmd, MMC_CMD_SET_RELATIVE_ADDR, MMC_RSP_R1, EMMC_RCA << 16);
}

static void efx_emmc_retrieve_csd(struct mmc *mmc, struct mmc_cmd *cmd)
{
	sd_send_cmd(mmc, cmd,MMC_CMD_SEND_CSD, MMC_RSP_R2, (EMMC_RCA << 16));

	bsp_printf_full("CSD:\r\n");
	bsp_printf_full("cmd->response[3]:%.8x\r\n", cmd->response[3]);
	bsp_printf_full("cmd->response[2]:%.8x\r\n", cmd->response[2]);
	bsp_printf_full("cmd->response[1]:%.8x\r\n", cmd->response[1]);
	bsp_printf_full("cmd->response[0]:%.8x\r\n", cmd->response[0]);
	mmc->spec_vers = (cmd->response[3] >> 18) & 0x000f;
	mmc->erase_grp_size = (cmd->response[1] >> 2 ) & 0x001f;
	mmc->erase_grp_mult = ((cmd->response[1] & 0x0003) << 3) | ((cmd->response[0] >> 29) & 0x0007);
	mmc->c_size = (((cmd->response[2] & 0x0003) << 10) | ((cmd->response[1] >> 22) & 0x03ff));
	mmc->c_size_mult = ((cmd->response[1] >> 7 ) & 0x0007);
	mmc->read_bl_len = ((cmd->response[2] >> 8 ) & 0x000f);

	bsp_printf_full("\r\n");
	bsp_printf_full("---- CSD table begin ----\r\n");
	bsp_printf_full("CSD_STRUCTURE      = 0x%x\r\n", (cmd->response[3] >> 22) & 0x0003);
	bsp_printf_full("SPEC_VERS          = 0x%x\r\n", (cmd->response[3] >> 18) & 0x000f);
	bsp_printf_full("TAAC               = 0x%x\r\n", (cmd->response[3] >> 8 ) & 0x00ff);
	bsp_printf_full("NSAC               = 0x%x\r\n", (cmd->response[3] >> 0 ) & 0x00ff);
	bsp_printf_full("TRAN_SPEED         = 0x%x\r\n", (cmd->response[2] >> 24) & 0x00ff);
	bsp_printf_full("CCC                = 0x%x\r\n", (cmd->response[2] >> 12) & 0x0fff);
	bsp_printf_full("READ_BL_LEN        = 0x%x\r\n", (cmd->response[2] >> 8 ) & 0x000f);
	bsp_printf_full("READ_BL_PARTIAL    = 0x%x\r\n", (cmd->response[2] >> 7 ) & 0x0001);
	bsp_printf_full("WRITE_BLK_MISALIGN = 0x%x\r\n", (cmd->response[2] >> 6 ) & 0x0001);
	bsp_printf_full("READ_BL_MISALIGN   = 0x%x\r\n", (cmd->response[2] >> 5 ) & 0x0001);
	bsp_printf_full("DSR_IMP            = 0x%x\r\n", (cmd->response[2] >> 4 ) & 0x0001);
	bsp_printf_full("C_SIZE             = 0x%x\r\n", ((cmd->response[2] & 0x0003) << 10) | ((cmd->response[1] >> 22) & 0x03ff));
	bsp_printf_full("VDD_R_CURR_MIN     = 0x%x\r\n", (cmd->response[1] >> 19) & 0x0007);
	bsp_printf_full("VDD_R_CURR_MAX     = 0x%x\r\n", (cmd->response[1] >> 16) & 0x0007);
	bsp_printf_full("VDD_W_CURR_MIN     = 0x%x\r\n", (cmd->response[1] >> 13) & 0x0007);
	bsp_printf_full("VDD_W_CURR_MAX     = 0x%x\r\n", (cmd->response[1] >> 10) & 0x0007);
	bsp_printf_full("C_SIZE_MULT        = 0x%x\r\n", (cmd->response[1] >> 7 ) & 0x0007);
	bsp_printf_full("ERASE_GRP_SIZE     = 0x%x\r\n", (cmd->response[1] >> 2 ) & 0x001f);
	bsp_printf_full("ERASE_GRP_MULT     = 0x%x\r\n", ((cmd->response[1] & 0x0003) << 3) | ((cmd->response[0] >> 29) & 0x0007));
	bsp_printf_full("WP_GRP_SIZE        = 0x%x\r\n", (cmd->response[0] >> 24) & 0x001f);
	bsp_printf_full("WP_GRP_ENABLE      = 0x%x\r\n", (cmd->response[0] >> 23) & 0x0001);
	bsp_printf_full("DEFAULT_ECC        = 0x%x\r\n", (cmd->response[0] >> 21) & 0x0003);
	bsp_printf_full("R2W_FACTOR         = 0x%x\r\n", (cmd->response[0] >> 18) & 0x0003);
	bsp_printf_full("WRITE_BL_LEN       = 0x%x\r\n", (cmd->response[0] >> 14) & 0x000f);
	bsp_printf_full("WRITE_BL_PARTIAL   = 0x%x\r\n", (cmd->response[0] >> 13) & 0x0001);
	bsp_printf_full("CONTENT_PROT_APP   = 0x%x\r\n", (cmd->response[0] >> 8 ) & 0x0001);
	bsp_printf_full("FILE_FORMAT_GRP    = 0x%x\r\n", (cmd->response[0] >> 7 ) & 0x0001);
	bsp_printf_full("COPY               = 0x%x\r\n", (cmd->response[0] >> 6 ) & 0x0001);
	bsp_printf_full("PERM_WRITE_PROTECT = 0x%x\r\n", (cmd->response[0] >> 5 ) & 0x0001);
	bsp_printf_full("TMP_WRITE_PROTECT  = 0x%x\r\n", (cmd->response[0] >> 4 ) & 0x0001);
	bsp_printf_full("FILE_FORMAT        = 0x%x\r\n", (cmd->response[0] >> 2 ) & 0x0003);
	bsp_printf_full("ECC                = 0x%x\r\n", (cmd->response[0] >> 0 ) & 0x0003);
	bsp_printf_full("---- CID table end ----\r\n");
	bsp_printf_full("\r\n");
}

static int efx_emmc_switch_bus_speed_mode(struct mmc *mmc, struct mmc_cmd *cmd, enum bus_speed_mode mode, u32 bus_width, u32 clk_mhz, u32 driver_type)
{
	u32 card_is_locked = 0;

	efx_emmc_config_clk(mmc, 400);

	sd_send_cmd(mmc, cmd, MMC_CMD_SEND_STATUS, MMC_RSP_R1, (EMMC_RCA << 16));

	card_is_locked = val_is_bit_set(cmd->response[0], 25);

	if (card_is_locked) {
		bsp_printf_full("Error: Card is locked\r\n");
		return -1;
		//TODO: Support unlock via CMD42
	}

	if ((mode == hs200) || (mode == hs400)) {
		if (mmc->spec_vers < 4) {
			bsp_printf_full("Error: HS200/HS400 mode only supported by SPEC_VERS >= 4 \r\n");
			return -1;
		}

		if ((EMMC_VCCQ != 1.2) && (EMMC_VCCQ != 1.8)) {
			bsp_printf_full("Error: HS200/HS400 mode only support 1.2V and 1.8V\r\n");
			return -1;
		}

		efx_emmc_retrieve_ext_csd(mmc, cmd);
	}

	if ((driver_type < 0x0) || (driver_type > 0x4)){
		bsp_printf_full("Error: Driver type value out of range");
		return -1;
	} else if (((1 << driver_type) & mmc->driver_strength) == 0x0){
		bsp_printf_full("Error: Device does not support target driver type value");
		return -1;
	}

	if (mode == hs200) {
		if ((bus_width != x4) && (bus_width != x8)) {
			bsp_printf_full("Error: HS200 mode only support 4-bit and 8-bit bus width\r\n");
			return -1;
		}
		if (val_is_bit_cleared(mmc->device_type, 4) && (EMMC_VCCQ == 1.8)) {
			bsp_printf_full("Error: Device does not support HS200 - 1.8 V I/O\r\n");
			return -1;
		}
		if (val_is_bit_cleared(mmc->device_type, 5) && (EMMC_VCCQ == 1.2)) {
			bsp_printf_full("Error: Device does not support HS200 - 1.2 V I/O\r\n");
			return -1;
		}
	} else if (mode == hs400) {
		if (bus_width != x8) {
			bsp_printf_full("Error: HS400 mode only support 8-bit bus width\r\n");
			return -1;
		}
		if (val_is_bit_cleared(mmc->device_type, 6) && (EMMC_VCCQ == 1.8)) {
			bsp_printf_full("Error: Device does not support HS400 - 1.8 V I/O\r\n");
			return -1;
		}
		if (val_is_bit_cleared(mmc->device_type, 7) && (EMMC_VCCQ == 1.2)) {
			bsp_printf_full("Error: Device does not support HS400 - 1.2 V I/O\r\n");
			return -1;
		}
	}

	if((mode == hs400) || (mode == hsddr)){
		if(EMMC_BLOCK_LEN != 512){
			bsp_printf_full("Error: When data rate is ddr mode, EMMC_BLOCK_LEN must be 512 bytes\r\n");
			return -1;
		}
	}

	if (mode == hs200) {
		bsp_printf_full("Switch to HS200 mode\r\n");
		efx_emmc_config_hs_timing(mmc, cmd, driver_type, 0x1);
		efx_emmc_config_bus_mode(mmc, cmd, sdr, bus_width);
		efx_emmc_config_hs_timing(mmc, cmd, driver_type, 0x2);
		efx_emmc_config_clk(mmc, 1000 * clk_mhz);
		efx_emmc_tuning(mmc, cmd, bus_width);
	} else if (mode == hs400) {
		bsp_printf_full("Switch to HS400 mode\r\n");
		efx_emmc_config_hs_timing(mmc, cmd, driver_type, 0x1);
		efx_emmc_config_bus_mode(mmc, cmd, ddr, bus_width);
		efx_emmc_config_hs_timing(mmc, cmd, driver_type, 0x3);
		efx_emmc_config_clk(mmc, 1000 * clk_mhz);
		efx_emmc_tuning(mmc, cmd, bus_width);
	} else if (mode == hssdr) {
		bsp_printf_full("Error: HS SDR mode not supported yet\r\n");
		return -1;
	} else if (mode == hsddr) {
		bsp_printf_full("Error: HS DDR mode not supported yet\r\n");
		return -1;
	} else {
		bsp_printf_full("Error: Legacy mode not supported yet\r\n");
		return -1;
	}

	if((mode != hs400) && (mode != hsddr)){
	    sd_send_cmd(mmc, cmd, MMC_CMD_SET_BLOCKLEN, MMC_RSP_R1, EMMC_BLOCK_LEN);
	    if (val_is_bit_set(cmd->response[0], 29)) {
		    bsp_printf_full("Error: Invalid BLOCK_LEN\r\n");
		    return -1;
	    }
	}

	return 0;
}

static void efx_emmc_retrieve_ext_csd(struct mmc *mmc, struct mmc_cmd *cmd)
{
	const u32 bytes_per_read = 4;
	const u32 read_count = 512 / bytes_per_read;
	const u32 ext_csd_len = 512;
	u8 ext_csd[ext_csd_len];
	u32 ext_csd_val = 0;
	u32 read_ready = 0;

	memset(ext_csd, 0, sizeof(ext_csd));

	reg_write(0x00010200, REG_BLOCK_SIZE_COUNT);
	reg_write(0x0, REG_ARGUMENT1);
	reg_write(0x083a0010, REG_TRANFER_MODE_COMMAND);

	while (!read_ready) {
		read_ready = reg_is_bit_set(REG_PRESENT_STATE, 11);
		if (!read_ready) {
			bsp_uDelay(200);
			bsp_printf_full("EXT_CSD not yet ready\r\n");
		}
	}

	for (int i = 0; i < read_count; i++) {
		ext_csd_val = reg_read(REG_BUFFER_DATA_PORT);
		ext_csd[i * bytes_per_read + 3] = (ext_csd_val >> 24) & 0xff;
		ext_csd[i * bytes_per_read + 2] = (ext_csd_val >> 16) & 0xff;
		ext_csd[i * bytes_per_read + 1] = (ext_csd_val >> 8) & 0xff;
		ext_csd[i * bytes_per_read + 0] = (ext_csd_val >> 0) & 0xff;
	}

	mmc->erase_group_def = ext_csd[175];
	mmc->device_type = ext_csd[196];
	mmc->driver_strength = ext_csd[197];
	mmc->sec_count = ((u32)(ext_csd[215]) << 24) | ((u32)(ext_csd[214]) << 16) | ((u32)(ext_csd[213]) << 8) | ((u32)(ext_csd[212]));
	mmc->hc_erase_grp_size = ext_csd[224];
	mmc->erase_timeout_mult = ext_csd[223];
	mmc->boot_info = ext_csd[228];
	mmc->boot_size_mult = ext_csd[226];

	bsp_printf_full("ERASE_GROUP_DEF = 0x%x\r\n", mmc->erase_group_def);
	bsp_printf_full("DEVICE_TYPE = 0x%x\r\n", mmc->device_type);
	bsp_printf_full("DRIVER_STRENGTH = 0x%x\r\n", mmc->driver_strength);
	bsp_printf_full("SEC_COUNT = %d\r\n", mmc->sec_count);
	bsp_printf_full("HC_ERASE_GRP_SIZE = 0x%x\r\n", mmc->hc_erase_grp_size);
	bsp_printf_full("ERASE_TIMEOUT_MULT = 0x%x\r\n", mmc->erase_timeout_mult);
}

static void efx_emmc_config_ip_bus_mode(u32 ddr_mode, u32 bus_width)
{
	reg_write(0x0 | (ddr_mode << 3) | (bus_width << 1), REG_HOST_POWER_BLOCKGAP_WAKEUP_CONTROL);
}

static int efx_emmc_config_dev_bus_mode(struct mmc *mmc, struct mmc_cmd *cmd, u32 ddr_mode, u32 bus_width)
{
	u32 bus_mode = 0;

	if ((ddr_mode == ddr) && (bus_width == x8)) {
		bus_mode = 0x6;
	} else if ((ddr_mode == ddr) && (bus_width == x4)) {
		bus_mode = 0x5;
	} else if ((ddr_mode == sdr) && (bus_width == x8)) {
		bus_mode = 0x2;
	} else if ((ddr_mode == sdr) && (bus_width == x4)) {
		bus_mode = 0x1;
	} else if ((ddr_mode == sdr) && (bus_width == x1)) {
		bus_mode = 0x0;
	} else {
		bsp_printf_full("Error: Unsupported ddr_mode or bus_width\r\n");
		return -1;
	}

	efx_emmc_write_ext_csd(mmc, cmd, 183, bus_mode);

	if (!is_ext_csd_config_successful(mmc, cmd)) {
		bsp_printf_full("Error: Failed to configure BUS_WIDTH\r\n");
		return -1;
	}

	return 0;
}

static void efx_emmc_config_bus_mode(struct mmc *mmc, struct mmc_cmd *cmd, u32 ddr_mode, u32 bus_width)
{
	efx_emmc_config_ip_bus_mode(ddr_mode, bus_width);
	efx_emmc_config_dev_bus_mode(mmc, cmd, ddr_mode, bus_width);
}

static void efx_emmc_write_ext_csd(struct mmc *mmc, struct mmc_cmd *cmd, u32 index, u32 value)
{
	u32 cmd6_arg = 0;

	struct sd_ctrl_dev *dev = mmc->priv;

	//Transfer Mode
	dev->TransModePtr->dma_enable = 0;
	dev->TransModePtr->block_count_enable = 0;
	dev->TransModePtr->auto_cmd_enable = 0;
	dev->TransModePtr->data_transfer_direction_select = 0;
	dev->TransModePtr->multi_or_single_block_select = 0;

	cmd6_arg &= ~(0x3f << 26); //[31:26] Set to 0
	cmd6_arg |= (0x3 << 24);   //[25:24] Access, 11b, write bytes
	cmd6_arg |= ((index & 0xff) << 16); //[23:16] Index, register index
	cmd6_arg |= ((value & 0xff) << 8);  //[15:8]  Value , value to write
	cmd6_arg &= ~(0x1f << 3);  //[7:3]   Set to 0
	cmd6_arg &= ~(0x7 << 0);   //[2:0]   Cmd Set, 000b

	bsp_printf_full("index %d value 0x%x cm6 arg 0x%x\r\n", index, value, cmd6_arg);
	sd_send_cmd(mmc, cmd, MMC_CMD_SWITCH, MMC_RSP_R1b, cmd6_arg);
}

static void efx_emmc_config_hs_timing(struct mmc *mmc, struct mmc_cmd *cmd, u32 driver_strength, u32 timing_interface)
{
	u32 hs_timing = 0;
	hs_timing = (driver_strength << 4) | (timing_interface);
	efx_emmc_write_ext_csd(mmc, cmd, 185, hs_timing);
	if (!is_ext_csd_config_successful(mmc, cmd)) {
		bsp_printf_full("Error: Failed to configure HS_TIMING\r\n");
	}
}

static u32 is_ext_csd_config_successful(struct mmc *mmc, struct mmc_cmd *cmd)
{
	sd_send_cmd(mmc, cmd, MMC_CMD_SEND_STATUS, MMC_RSP_R1, (EMMC_RCA << 16));

	if (val_is_bit_set(cmd->response[0], 7)) {
		bsp_printf_full("Error: Switch error\r\n");
		return 0;
	}

	return 1;
}

static int efx_emmc_tuning(struct mmc *mmc, struct mmc_cmd *cmd, u32 bus_width)
{
	const u32 pll_shift_num = 8;
	const u32 block_cnt = 1;
	const u32 bytes_per_read = 4;
	u32 block_size = 0;
	u32 read_count = 0;
	u32 pattern = 0;
	int result_map[mmc->clk_div][pll_shift_num];
	u32 read_ready = 0;
	u32 pattern_mismatch = 0;
	u32 optimal_sample_cnt = 0;
	u32 optimal_pll_shift = 0;
	u32 map_all_zero = 1;
	u32 tuning_time = 1;

	memset(result_map, 0, sizeof(result_map));

	// Initialize entire result map to 1, tuning failure later will invalidate them
	for (int sample_cnt = 0; sample_cnt < mmc->clk_div; sample_cnt++) {
		for (int pll_shift = 0; pll_shift < pll_shift_num; pll_shift++) {
			result_map[sample_cnt][pll_shift] = 1;
		}
	}

	if (bus_width == 0x1) {
		block_size = 64; //byte
	} else if (bus_width == 0x2) {
		block_size = 128; //byte
	} else {
		bsp_printf_full("Error: eMMC tuning only applicable to 4 and 8 bit data bus\r\n");
		return -1;
	}

	read_count = block_size / bytes_per_read;

	for (int tuning_cnt = 0; tuning_cnt < tuning_time; tuning_cnt++) {
		for (int sample_cnt = 0; sample_cnt < mmc->clk_div; sample_cnt++) {
			for (int pll_shift = 0; pll_shift < pll_shift_num; pll_shift++) {
				bsp_printf_full("Tuning #%d: sample_cnt 0x%x pll_shift 0x%x\r\n", tuning_cnt, sample_cnt, pll_shift);
				IntPtr.data_crc_error = 0;
				pattern_mismatch = 0;
				efx_emmc_generate_pulse(sample_cnt, pll_shift);

				reg_write((block_cnt << 16) | (block_size), REG_BLOCK_SIZE_COUNT);
				reg_write(0x0, REG_ARGUMENT1);
				reg_write(0x153a0010, REG_TRANFER_MODE_COMMAND);

				while (1) {
					if (reg_is_bit_set(REG_PRESENT_STATE, 11)) {
						break;
					} else {
						bsp_uDelay(200);
	//					bsp_printf_full("sample_cnt %d pll_shift %d data not yet ready\r\n", sample_cnt, pll_shift);
					}
				}

				for (int i = 0; i < read_count; i++) {
					pattern = reg_read(REG_BUFFER_DATA_PORT);
					if (((bus_width == 0x1) && (pattern != tuning_block_pattern_4b_mode[i])) ||
					    ((bus_width == 0x2) && (pattern != tuning_block_pattern_8b_mode[i])) ||
					     (IntPtr.data_crc_error == 0x1)) {
						pattern_mismatch = 1;
					}
				}

				bsp_printf_full("Info :pattern_mismatch is %d\r\n", pattern_mismatch);
				if ((result_map[sample_cnt][pll_shift] == 1) && (pattern_mismatch == 0)) {
					result_map[sample_cnt][pll_shift] = 1;
				} else {
					result_map[sample_cnt][pll_shift] = 0;
				}
			}
		}
	}
	IntPtr.data_crc_error = 0;

	bsp_printf_full("Tuning map:\r\n");
	for (int i = 0; i < mmc-> clk_div; i++) {
		for (int j = 0; j < pll_shift_num; j++) {
			if (result_map[i][j] == 1) {
				map_all_zero = 0;
			}
			bsp_printf_full("%d ", result_map[i][j]);
		}
		bsp_printf_full("\r\n");
	}

		if (map_all_zero) {
			bsp_printf_full("Error: No '1' detected in entire tuning map\r\n");
			return -1;
		}

	int rows = mmc->clk_div; // Number of rows
	int cols = pll_shift_num; // Number of columns

	// Step 1: Find rows with the longest consecutive 1s
	int result[rows][1];
	int ret = 0;

	ret = find_rows_with_longest_ones(rows, cols, result_map, result);

	if (ret) {
	bsp_printf_full("Error: All sample_cnt and pll_shift combinations failed\r\n");
	return -1;
	}

	// Print the result array
	bsp_printf_full("Result array:\r\n");
	for (int i = 0; i < rows; i++) {
	bsp_printf_full("%d\r\n", result[i][0]);
	}

	// Step 2: Find the center row of the result array
	int center_row = find_center_row(rows, result);

	if (center_row != -1) {
	optimal_sample_cnt = center_row;
	bsp_printf_full("Optimal sample count: %d\r\n", optimal_sample_cnt);

	// Step 3: Find the center of the longest consecutive 1s in the original array
	int center_col = find_center_of_row(center_row, cols, result_map[center_row]);

	if (center_col != -1) {
		optimal_pll_shift = center_col;
		bsp_printf_full("Optimal PLL shift: 0x%.1x\r\n", optimal_pll_shift);
	} else {
		bsp_printf_full("No sequence of 1s found in row %d.\r\n", center_row);
	}
	} else {
	bsp_printf_full("No sequence of 1s found.\r\n");
	}

	efx_emmc_generate_pulse(optimal_sample_cnt, optimal_pll_shift);

	//test_tuning_algo();
	return 0;
}

static void efx_emmc_generate_pulse(u32 sample_cnt, u32 pll_shift)
{
	u32 pll_setting = 0;
	pll_setting = (sample_cnt << 16) | (pll_shift << 6);
	reg_write(pll_setting | 0x0, REG_BASE_REGISTER1);
	reg_write(pll_setting | 0x1, REG_BASE_REGISTER1);
	reg_write(pll_setting | 0x0, REG_BASE_REGISTER1);
	bsp_uDelay(50*1000);
}

static u64 uda_density_calculate(struct mmc *mmc)
{
	 u64 uda_density;  // user data area capacity , unit is byte

	 if (EMMC_LARGE_DENSITY == 0) {
		 uda_density = (mmc->c_size + 1) * pow(2, mmc->c_size_mult + 2) * pow(2, mmc->read_bl_len); //bytes
	 } else {
		 uda_density = mmc->sec_count * 512ULL; //bytes
	 }

	 return uda_density;
};

/**
 * Checks for any error status in the eMMC controller
 *
 * @return 0 if no errors, non-zero if errors detected
 */
static int check_for_error_status(void)
{
    u32 status = reg_read(REG_INTERRUPT_STATUS); // Replace with your actual error register

    // Check for relevant error bits in your controller
    // These are examples and need to be adjusted for your specific hardware
    const u32 DATA_CRC_ERROR = (1 << 21);
    const u32 COMMAND_TIMEOUT_ERROR = (1 << 16);
    const u32 COMMAND_CRC_ERROR = (1 << 17);
    const u32 COMMAND_END_BIT_ERROR = (1 << 18);

    // Check if any error bits are set
    if (status & (DATA_CRC_ERROR | COMMAND_TIMEOUT_ERROR | COMMAND_CRC_ERROR | COMMAND_END_BIT_ERROR)) {

        // Log the specific error
        if (status & DATA_CRC_ERROR)
            bsp_printf_full("Error: Data CRC error detected\r\n");
        if (status & COMMAND_TIMEOUT_ERROR)
            bsp_printf_full("Error: Command timeout error detected\r\n");
        if (status & COMMAND_CRC_ERROR)
            bsp_printf_full("Error: Command CRC error detected\r\n");
        if (status & COMMAND_END_BIT_ERROR)
            bsp_printf_full("Error: Command end bit error detected\r\n");

        // Clear the error status bits if needed
        reg_write(status, REG_INTERRUPT_STATUS);

        return 1; // Error detected
    }

    return 0; // No errors
}

/**
 * Reads data blocks from eMMC storage device
 *
 * @param mmc       Pointer to the MMC controller structure
 * @param block_cnt Number of blocks to read
 * @param addr      Starting address to read from
 * @param buf       Buffer to store the read data
 * @param dma_en    Flag to enable/disable DMA for the transfer (1=enabled, 0=disabled)
 *
 * @return 0 on success, negative values on different failure conditions
 */
static int efx_emmc_block_read(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en)
{
    /* Error code definitions */
    #define ERR_INVALID_PARAM      -1  /* Invalid parameter */
    #define ERR_TIMEOUT            -2  /* Operation timed out */
    #define ERR_IO                 -3  /* I/O error during transfer */
    #define ERR_OVERFLOW           -4  /* Calculation would overflow */

    /* Command register configuration bits */
    u32 cmd_index = 0;          // Command index (bits 29-24)
    u32 data_available = 0;     // Data transfer expected (bit 21)
    u32 cmd_index_check_en = 0; // Command index check enable (bit 20)
    u32 cmd_crc_en = 0;         // Command CRC check enable (bit 19)
    u32 resp_type = 0;          // Response type (bits 17-16)
    u32 multi_block_en = 0;     // Multi-block transfer enable (bit 5)
    u32 data_direction = 0;     // Data direction (bit 4, 1=read from card)
    u32 auto_cmd_en = 0;        // Auto command enable (bits 3-2)
    u32 block_counter_en = 0;   // Block counter enable (bit 1)
    u32 val = 0;                // Register configuration value
    u32 read_data = 0;          // Temporary storage for read data
    int ret = 0;                // Return value
    u32 timeout_counter = 0;    // Timeout counter
    const u32 MAX_TIMEOUT = 1000000; // Maximum timeout count (adjust based on uDelay value)

    /* Parameter validation */
    if (buf == NULL) {
        bsp_printf_full("Error: Invalid buffer pointer\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Check buffer alignment for DMA mode */
    if (dma_en && ((uintptr_t)buf & 0x3)) {
        bsp_printf_full("Error: DMA requires 4-byte aligned buffer\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Wait until command and data lines are free with timeout */
    timeout_counter = 0;
    while (is_cmd_or_data_bus_busy()) {
        bsp_uDelay(100);
        if (++timeout_counter > MAX_TIMEOUT) {
            bsp_printf_full("Error: Timeout waiting for bus ready\r\n");
            return ERR_TIMEOUT;
        }
    }

    /* Validate block count (must be within 16-bit range) */
    if (block_cnt == 0 || block_cnt > largest_number(16, 31)) {
        bsp_printf_full("Error: Block count exceed limit. Max block count is %d\r\n", largest_number(16, 31));
        return ERR_INVALID_PARAM;
    }

    /* For high-density eMMC (>2GB), read size must be multiple of 512 bytes */
    if ((EMMC_LARGE_DENSITY != 0) && (((block_cnt * EMMC_BLOCK_LEN) % 512) != 0x0)) {
        bsp_printf_full("Error: When emmc density > 2GB, read data length must be integer multiple of 512 byte\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Verify EMMC_BLOCK_LEN is multiple of 4 for proper word-aligned access */
    if (EMMC_BLOCK_LEN % 4 != 0) {
        bsp_printf_full("Error: Block length must be a multiple of 4 bytes\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Calculate user data area density and address limits */
    u64 uda_density = 0;   // User data area density
    u32 uda_addr_max = 0;  // User data area max address
    u32 addr_end = 0;      // End address of current read operation

    uda_density = uda_density_calculate(mmc);
    if (uda_density == 0) {
        bsp_printf_full("Error: Failed to calculate user data area density\r\n");
        return ERR_IO;
    }

    /* Calculate maximum address based on eMMC density */
    if (EMMC_LARGE_DENSITY == 0) {
        uda_addr_max = uda_density - 1;
    } else {
        uda_addr_max = (uda_density / 512ULL) - 1;
    }

    /* Calculate end address of read operation, with overflow protection */
    if (EMMC_LARGE_DENSITY == 0) {
        /* Check for potential overflow (simplified check) */
        if (block_cnt > ((u64)-1 - addr) / EMMC_BLOCK_LEN) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN) - 1;
    } else {
        /* Check for potential overflow (simplified check) */
        if (block_cnt > ((u64)-1 - addr) / (EMMC_BLOCK_LEN / 512)) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN / 512) - 1;
    }

    /* Validate start and end addresses are within range */
    if (addr > uda_addr_max) {
        bsp_printf_full("Error: Read start addr %u uda_addr_max %u out of range\r\n", addr, uda_addr_max);
        return ERR_INVALID_PARAM;
    }

    if (addr_end > uda_addr_max) {
        bsp_printf_full("Error: Read end addr out of range\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Configure block size and count register */
    reg_write((block_cnt << 16) | (EMMC_BLOCK_LEN), REG_BLOCK_SIZE_COUNT);

    /* Configure command based on single or multi-block transfer */
    if (block_cnt == 1) {
        /* Single block read (CMD17) */
        cmd_index = 17;           // READ_SINGLE_BLOCK command
        data_available = 1;        // Data transfer expected
        cmd_index_check_en = 1;    // Enable command index check
        cmd_crc_en = 1;            // Enable command CRC check
        resp_type = 2;             // R1 response type (48-bit)
        multi_block_en = 0;        // Single block transfer
        data_direction = 1;        // Read from card
        auto_cmd_en = 0;           // No auto command
        block_counter_en = 0;      // Block counter disabled
    } else {
        /* Multi-block read (CMD18) */
        cmd_index = 18;            // READ_MULTIPLE_BLOCK command
        data_available = 1;        // Data transfer expected
        cmd_index_check_en = 1;    // Enable command index check
        cmd_crc_en = 1;            // Enable command CRC check
        resp_type = 2;             // R1 response type (48-bit)
        multi_block_en = 1;        // Multi-block transfer
        data_direction = 1;        // Read from card
        auto_cmd_en = 1;           // Auto command enabled (likely CMD12 for stop)
        block_counter_en = 1;      // Use block counter
    }

    /* Clear transfer complete flag before starting transfer */
    IntPtr.transfer_complete = 0x0;

    /* Create DMA descriptor if DMA is enabled */
    if (dma_en) {
        ret = sd_ctrl_creat_Descriptor(mmc, block_cnt, EMMC_BLOCK_LEN, buf);
        if (ret != 0) {
            bsp_printf_full("Error: Failed to create DMA descriptor, error %d\r\n", ret);
            return ERR_IO;
        }
    }

    /* Build command register value from configuration bits */
    val = (cmd_index << 24) | (data_available << 21) | (cmd_index_check_en << 20) |
          (cmd_crc_en << 19) | (resp_type << 16) | (multi_block_en << 5) |
          (data_direction << 4) | (auto_cmd_en << 2) | (block_counter_en << 1) | (dma_en << 0);

    /* Set the command argument (address) and issue command */
    reg_write(addr, REG_ARGUMENT1);
    reg_write(val, REG_TRANFER_MODE_COMMAND);

    /* If DMA not enabled, manually read data via buffer data port */
    if (!dma_en) {
        for (int i = 0; i < block_cnt; i++) {
            /* Wait for buffer read ready flag with timeout */
            timeout_counter = 0;
            while (reg_is_bit_cleared(REG_PRESENT_STATE, 11)) {
                bsp_uDelay(100);
                if (++timeout_counter > MAX_TIMEOUT) {
                    bsp_printf_full("Error: Timeout waiting for buffer ready\r\n");
                    return ERR_TIMEOUT;
                }

                /* Check for error conditions */
                if (check_for_error_status()) {  // Implement this function to check error bits
                    bsp_printf_full("Error: Error detected during transfer\r\n");
                    return ERR_IO;
                }
            }

            /* Read block data (EMMC_BLOCK_LEN bytes, 4 bytes at a time) */
            for (int j = 0; j < EMMC_BLOCK_LEN / 4; j++) {
                read_data = reg_read(REG_BUFFER_DATA_PORT);
                *(buf + j + (i * EMMC_BLOCK_LEN / 4)) = read_data;
            }
        }
    }

    /* Wait for transfer completion interrupt with timeout */
    timeout_counter = 0;
    while (1) {
        /* Check for transfer complete */
        if (IntPtr.transfer_complete == 0x1) {
            /* Clear flag and break */
            IntPtr.transfer_complete = 0x0;
            break;
        }

        /* Check for timeout */
        bsp_uDelay(100);
        if (++timeout_counter > MAX_TIMEOUT) {
            bsp_printf_full("Error: Timeout waiting for transfer completion\r\n");
            return ERR_TIMEOUT;
        }

        /* Check for error conditions */
        if (check_for_error_status()) {  // Implement this function to check error bits
            bsp_printf_full("Error: Error detected during transfer\r\n");
            return ERR_IO;
        }
    }

    /* Cleanup */
    #undef ERR_INVALID_PARAM
    #undef ERR_TIMEOUT
    #undef ERR_IO
    #undef ERR_OVERFLOW

    return 0;
}

/**
 * Writes data blocks to eMMC storage device
 *
 * @param mmc       Pointer to the MMC controller structure
 * @param block_cnt Number of blocks to write
 * @param addr      Starting address to write to
 * @param buf       Buffer containing the data to write
 * @param dma_en    Flag to enable/disable DMA for the transfer (1=enabled, 0=disabled)
 *
 * @return 0 on success, negative values on different failure conditions
 */
static int efx_emmc_block_write(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en)
{
    /* Error code definitions */
    #define ERR_INVALID_PARAM      -1  /* Invalid parameter */
    #define ERR_TIMEOUT            -2  /* Operation timed out */
    #define ERR_IO                 -3  /* I/O error during transfer */
    #define ERR_OVERFLOW           -4  /* Calculation would overflow */

    /* Command register configuration bits */
    u32 cmd_index = 0;          // Command index (bits 29-24)
    u32 data_available = 0;     // Data transfer expected (bit 21)
    u32 cmd_index_check_en = 0; // Command index check enable (bit 20)
    u32 cmd_crc_en = 0;         // Command CRC check enable (bit 19)
    u32 resp_type = 0;          // Response type (bits 17-16)
    u32 multi_block_en = 0;     // Multi-block transfer enable (bit 5)
    u32 data_direction = 0;     // Data direction (bit 4, 0=write to card)
    u32 auto_cmd_en = 0;        // Auto command enable (bits 3-2)
    u32 block_counter_en = 0;   // Block counter enable (bit 1)
    u32 val = 0;                // Register configuration value
    u32 write_data = 0;         // Temporary storage for write data
    int ret = 0;                // Return value
    u32 timeout_counter = 0;    // Timeout counter
    const u32 MAX_TIMEOUT = 1000000; // Maximum timeout count (adjust based on uDelay value)

    /* Parameter validation */
    if (buf == NULL) {
        bsp_printf_full("Error: Invalid buffer pointer\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Check buffer alignment for DMA mode */
    if (dma_en && ((uintptr_t)buf & 0x3)) {
        bsp_printf_full("Error: DMA requires 4-byte aligned buffer\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Wait until command and data lines are free with timeout */
    timeout_counter = 0;
    while (is_cmd_or_data_bus_busy()) {
        bsp_uDelay(100);
        if (++timeout_counter > MAX_TIMEOUT) {
            bsp_printf_full("Error: Timeout waiting for bus ready\r\n");
            return ERR_TIMEOUT;
        }
    }

    /* Validate block count (must be within 16-bit range) */
    if (block_cnt == 0 || block_cnt > largest_number(16, 31)) {
        bsp_printf_full("Error: Block count exceed limit. Max block count is %d\r\n", largest_number(16, 31));
        return ERR_INVALID_PARAM;
    }

    /* For high-density eMMC (>2GB), write size must be multiple of 512 bytes */
    if ((EMMC_LARGE_DENSITY != 0) && (((block_cnt * EMMC_BLOCK_LEN) % 512) != 0x0)) {
        bsp_printf_full("Error: When emmc density > 2GB, write data length must be integer multiple of 512 byte\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Verify EMMC_BLOCK_LEN is multiple of 4 for proper word-aligned access */
    if (EMMC_BLOCK_LEN % 4 != 0) {
        bsp_printf_full("Error: Block length must be a multiple of 4 bytes\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Calculate user data area density and address limits */
    u64 uda_density = 0;   // User data area density
    u32 uda_addr_max = 0;  // User data area max address
    u32 addr_end = 0;      // End address of current write operation

    uda_density = uda_density_calculate(mmc);
    if (uda_density == 0) {
        bsp_printf_full("Error: Failed to calculate user data area density\r\n");
        return ERR_IO;
    }

    /* Calculate maximum address based on eMMC density */
    if (EMMC_LARGE_DENSITY == 0) {
        uda_addr_max = uda_density - 1;
    } else {
        uda_addr_max = (uda_density / 512ULL) - 1;
    }

    /* Calculate end address of write operation, with overflow protection */
    if (EMMC_LARGE_DENSITY == 0) {
        /* Check for potential overflow */
        if (block_cnt > ((u64)-1 - addr) / EMMC_BLOCK_LEN) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN) - 1;
    } else {
        /* Check for potential overflow */
        if (block_cnt > ((u64)-1 - addr) / (EMMC_BLOCK_LEN / 512)) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN / 512) - 1;
    }

    /* Validate start and end addresses are within range */
    if (addr > uda_addr_max) {
        bsp_printf_full("Error: Write start addr %u uda_addr_max %u out of range\r\n", addr, uda_addr_max);
        return ERR_INVALID_PARAM;
    }

    if (addr_end > uda_addr_max) {
        bsp_printf_full("Error: Write end addr out of range\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Configure block size and count register */
    reg_write((block_cnt << 16) | (EMMC_BLOCK_LEN), REG_BLOCK_SIZE_COUNT);

    /* Configure command based on single or multi-block transfer */
    if (block_cnt == 1) {
        /* Single block write (CMD24) */
        cmd_index = 24;           // WRITE_BLOCK command
        data_available = 1;        // Data transfer expected
        cmd_index_check_en = 1;    // Enable command index check
        cmd_crc_en = 1;            // Enable command CRC check
        resp_type = 2;             // R1 response type (48-bit)
        multi_block_en = 0;        // Single block transfer
        data_direction = 0;        // Write to card
        auto_cmd_en = 0;           // No auto command
        block_counter_en = 0;      // Block counter disabled
    } else {
        /* Multi-block write (CMD25) */
        cmd_index = 25;            // WRITE_MULTIPLE_BLOCK command
        data_available = 1;        // Data transfer expected
        cmd_index_check_en = 1;    // Enable command index check
        cmd_crc_en = 1;            // Enable command CRC check
        resp_type = 2;             // R1 response type (48-bit)
        multi_block_en = 1;        // Multi-block transfer
        data_direction = 0;        // Write to card
        auto_cmd_en = 1;           // Auto command enabled (likely CMD12 for stop)
        block_counter_en = 1;      // Use block counter
    }

    /* Clear transfer complete flag before starting transfer */
    IntPtr.transfer_complete = 0x0;

    /* Create DMA descriptor if DMA is enabled */
    if (dma_en) {
        ret = sd_ctrl_creat_Descriptor(mmc, block_cnt, EMMC_BLOCK_LEN, buf);
        if (ret != 0) {
            bsp_printf_full("Error: Failed to create DMA descriptor, error %d\r\n", ret);
            return ERR_IO;
        }
    }

    /* Build command register value from configuration bits */
    val = (cmd_index << 24) | (data_available << 21) | (cmd_index_check_en << 20) |
          (cmd_crc_en << 19) | (resp_type << 16) | (multi_block_en << 5) |
          (data_direction << 4) | (auto_cmd_en << 2) | (block_counter_en << 1) | (dma_en << 0);

    /* Set the command argument (address) and issue command */
    reg_write(addr, REG_ARGUMENT1);
    reg_write(val, REG_TRANFER_MODE_COMMAND);

    /* If DMA not enabled, manually write data via buffer data port */
    if (!dma_en) {
        for (int i = 0; i < block_cnt; i++) {
            /* Wait for buffer write ready flag with timeout */
            timeout_counter = 0;
            while (reg_is_bit_cleared(REG_PRESENT_STATE, 10)) {
                bsp_uDelay(100);
                if (++timeout_counter > MAX_TIMEOUT) {
                    bsp_printf_full("Error: Timeout waiting for buffer ready\r\n");
                    return ERR_TIMEOUT;
                }

                /* Check for error conditions */
                if (check_for_error_status()) {
                    bsp_printf_full("Error: Error detected during transfer\r\n");
                    return ERR_IO;
                }
            }

            /* Write block data (EMMC_BLOCK_LEN bytes, 4 bytes at a time) */
            for (int j = 0; j < EMMC_BLOCK_LEN / 4; j++) {
                write_data = *(buf + j + (i * EMMC_BLOCK_LEN / 4));
                reg_write(write_data, REG_BUFFER_DATA_PORT);
            }
        }
    }

    /* Wait for transfer completion interrupt with timeout */
    timeout_counter = 0;
    while (1) {
        /* Check for transfer complete */
        if (IntPtr.transfer_complete == 0x1) {
            /* Clear flag and break */
            IntPtr.transfer_complete = 0x0;
            break;
        }

        /* Check for timeout */
        bsp_uDelay(100);
        if (++timeout_counter > MAX_TIMEOUT) {
            bsp_printf_full("Error: Timeout waiting for transfer completion\r\n");
            return ERR_TIMEOUT;
        }

        /* Check for error conditions */
        if (check_for_error_status()) {
            bsp_printf_full("Error: Error detected during transfer\r\n");
            return ERR_IO;
        }
    }

    /* Cleanup */
    #undef ERR_INVALID_PARAM
    #undef ERR_TIMEOUT
    #undef ERR_IO
    #undef ERR_OVERFLOW

    return 0;
}

static int check_erase_cmd_error(u32 val, u32 addr_check)
{
	if (val_is_bit_set(val, 27)) {
		bsp_printf_full("Error: Erase param error\r\n");
		return -1;
	}
	if (val_is_bit_set(val, 28)) {
		bsp_printf_full("Error: Erase sequence error\r\n");
		return -1;
	}
	if (addr_check && val_is_bit_set(val, 31)) {
		bsp_printf_full("Error: Erase address out of range\r\n");
		return -1;
	}
	return 0;
}

static int erase_unit_size_calculate (struct mmc *mmc, enum erase_type type)
{
	u32 erase_unit_size = 0;
	if(type == erase){
		if (mmc->hc_erase_grp_size != 0 && mmc->erase_timeout_mult != 0 && mmc->erase_group_def == 1) {
			erase_unit_size = 512 * 1024 * mmc->hc_erase_grp_size; //Unit is byte
		} else {
			erase_unit_size = (mmc->erase_grp_size + 1) * (mmc->erase_grp_mult + 1) * EMMC_BLOCK_LEN; //Unit is byte
		}
	} else if(type == trim) {
		erase_unit_size = EMMC_BLOCK_LEN;
	}

	return erase_unit_size;
}

static int efx_emmc_erase(struct mmc *mmc, struct mmc_cmd *cmd, u32 start_addr, u32 erase_unit_num)
{
	u32 erase_unit_size = 0;
	u32 end_addr = 0;
	u32 ret = 0;

	while (is_cmd_or_data_bus_busy()) {
		bsp_uDelay(200);
	}

	erase_unit_size = erase_unit_size_calculate(mmc,erase);
	if(erase_unit_size == 0){
		bsp_printf_full("Error: erase_unit_size is 0 byte\r\n");
		return -1;
	}

	if (EMMC_LARGE_DENSITY == 0) {
		if((start_addr % erase_unit_size) != 0x0) {
			bsp_printf_full("start_addr not on the erase unit boundary\r\n");
			return -1;
		}
	} else if(((start_addr * 512) % erase_unit_size) != 0x0) {
		bsp_printf_full("Error: start_addr not on the erase unit boundary\r\n");
		return -1;
	}

	if ((EMMC_LARGE_DENSITY != 0) && (((erase_unit_num*erase_unit_size) % 512) != 0x0)) {
		bsp_printf_full("Error: when emmc density > 2GB , erase length must be integer multiple of 512 byte\r\n");
		return -1;
	}

	if (erase_unit_num < 1) {
		bsp_printf_full("Error: erase_unit_num must be greater than or equal to 1\r\n");
		return -1;
	}

	if (EMMC_LARGE_DENSITY == 0)
		end_addr = start_addr + (erase_unit_num * erase_unit_size) - 1;
	else
		end_addr = start_addr + (erase_unit_num * erase_unit_size / 512) - 1;

	bsp_printf_full("erase process test \r\n");

	sd_send_cmd(mmc, cmd, MMC_CMD_ERASE_GROUP_START, MMC_RSP_R1, start_addr);
	ret = check_erase_cmd_error(cmd->response[0], 1);
	if (ret) return ret;

	sd_send_cmd(mmc, cmd, MMC_CMD_ERASE_GROUP_END, MMC_RSP_R1, end_addr);
	ret = check_erase_cmd_error(cmd->response[0], 1);
	if (ret) return ret;

	sd_send_cmd(mmc, cmd, MMC_CMD_ERASE, MMC_RSP_R1b, 0);
	ret = check_erase_cmd_error(cmd->response[0], 0);
	if (ret) return ret;

	while (is_cmd_or_data_bus_busy()) {
		bsp_uDelay(200);
	}

	sd_send_cmd(mmc, cmd, MMC_CMD_SEND_STATUS, MMC_RSP_R1, (EMMC_RCA << 16));
	ret = check_erase_cmd_error(cmd->response[0], 0);
	if (ret) return ret;

	return 0;
}

static int efx_emmc_trim(struct mmc *mmc, struct mmc_cmd *cmd, u32 start_addr, u32 erase_unit_num)
{
	u32 erase_unit_size = 0;
	u32 end_addr = 0;
	u32 ret = 0;

	while (is_cmd_or_data_bus_busy()) {
		bsp_uDelay(200);
	}

	erase_unit_size = erase_unit_size_calculate(mmc,trim);
	if(erase_unit_size == 0){
		bsp_printf_full("Error: erase_unit_size is 0 byte\r\n");
		return -1;
	}

	if (EMMC_LARGE_DENSITY == 0) {
		if ((start_addr % erase_unit_size) != 0x0) {
			bsp_printf_full("Error: start_addr not on the erase unit boundary\r\n");
			return -1;
		}
	} else if (((start_addr * 512) % erase_unit_size) != 0x0) {
		bsp_printf_full("Error: start_addr not on the erase unit boundary\r\n");
		return -1;
	}

	if ((EMMC_LARGE_DENSITY != 0) && (((erase_unit_num * erase_unit_size) % 512) != 0x0)) {
		bsp_printf_full("Error: When emmc density > 2GB , erase length must be integer multiple of 512 byte\r\n");
		return -1;
	}

	if (erase_unit_num < 1) {
		bsp_printf_full("Error: erase_unit_num must be greater than or equal to 1\r\n");
		return -1;
	}

	if(EMMC_LARGE_DENSITY == 0)
		end_addr = start_addr + (erase_unit_num * erase_unit_size) - 1;
	else
		end_addr = start_addr + (erase_unit_num * erase_unit_size / 512) - 1;

	sd_send_cmd(mmc, cmd, MMC_CMD_ERASE_GROUP_START, MMC_RSP_R1, start_addr);
	ret = check_erase_cmd_error(cmd->response[0], 1);
	if (ret) return ret;

	sd_send_cmd(mmc, cmd, MMC_CMD_ERASE_GROUP_END, MMC_RSP_R1, end_addr);
	ret = check_erase_cmd_error(cmd->response[0], 1);
	if (ret) return ret;

	sd_send_cmd(mmc, cmd, MMC_CMD_ERASE, MMC_RSP_R1b, 1);
	ret = check_erase_cmd_error(cmd->response[0], 0);
	if (ret) return ret;

	while (is_cmd_or_data_bus_busy()) {
		bsp_uDelay(200);
	}

	sd_send_cmd(mmc, cmd, MMC_CMD_SEND_STATUS, MMC_RSP_R1, (EMMC_RCA << 16));
	ret = check_erase_cmd_error(cmd->response[0], 0);
	if (ret) return ret;

	return 0;
}


