////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "efx_emmc_driver.h"
#include "userDef.h"

static u32 boot_partition_size_calculate(struct mmc *mmc);
static int efx_emmc_boot_write(struct mmc *mmc, struct mmc_cmd *cmd, enum data_bus_width bus_width, u32 par_num, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en);
static int efx_emmc_boot_read_all(struct mmc *mmc, struct mmc_cmd *cmd, u32 bus_width, u32 par_num, u32 *buf, u32 dma_en);
static int efx_emmc_boot_read_single(struct mmc *mmc, struct mmc_cmd *cmd, u32 bus_width, u32 par_num, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en);
static int efx_emmc_boot_erase(struct mmc *mmc, struct mmc_cmd *cmd, u32 par_num, u32 start_addr, u32 erase_unit_num, enum erase_type erase_mode);
static int efx_emmc_boot_send_data(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en);
static int efx_emmc_boot_receive_data_all(struct mmc *mmc, u32 block_cnt, u32 block_size, u32 clk_mhz, u32 *buf, u32 dma_en);
static int efx_emmc_boot_receive_data_single(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en);

static u32 boot_partition_size_calculate(struct mmc *mmc)
{
    u32 boot_partition_size = 128*1024*(mmc->boot_size_mult);  // byte
    
    return boot_partition_size;

}

static int efx_emmc_boot_write(struct mmc *mmc, struct mmc_cmd *cmd, enum data_bus_width bus_width, u32 par_num, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en)
{
    
    u32 boot_mode = 0; /* [0x0]sdr + backward compatible timings, [0x1]:sdr + high speed timing ,[0x2]:ddr */
    u32 reset_boot_bus_conditions = 0;
    u32 boot_bus_width = 0;
    u32 boot_bus_conditions = 0;
    u32 hs_boot_mode  = 0;
    u32 ddr_boot_mode = 0;
    u32 partition_access = 0;
    u32 boot_partition_enable = 0; /* Fixed to 0 */
    u32 boot_ack = 0; /* Fixed to 0 */
    u32 partition_config = 0;
    u32 ddr_mode = 0;
    u32 clk_mhz = 25;
    u32 timing_interface = 0; /* [0x0] backwards compatibility interface timing  [0x1] High Speed */
    u32 ret = 0;
    
    /* Emmc initialization */
    efx_emmc_init(mmc, cmd);
    
    hs_boot_mode  = (mmc->boot_info >> 2) & 0x1;
    ddr_boot_mode = (mmc->boot_info >> 1) & 0x1;
    
    if ((ddr_boot_mode == 1) && (bus_width != x1)) {
        boot_mode = 0x2;
    } else if (hs_boot_mode == 1) {
        boot_mode = 0x1;
    } else {
        boot_mode = 0x0;
    }
    
    if (boot_mode == 0x0) {
        timing_interface = 0x0;
    } else {
        timing_interface = 0x1;
    }
    
    if (boot_mode == 0x2) {
        ddr_mode = ddr;
    } else {
        ddr_mode = sdr;
    }
    
    if (boot_mode == 0x0) {
        clk_mhz = 25;
    } else {
        clk_mhz = 50;
    }

    if (bus_width == x1) {
        boot_bus_width = 0x0;
    } else if(bus_width == x4) {
        boot_bus_width = 0x1;
    } else if(bus_width == x8) {
        boot_bus_width = 0x2;
    } else {
        bsp_printf_full("Error: bus_width error in boot writing\r\n");
        return -1;
    }
    
    if (par_num == 0x1) {
        partition_access = 0x1;
    } else if(par_num == 0x2) {
        partition_access = 0x2;
    } else {
        bsp_printf_full("Error: partition number error\r\n");
        return -1;
    }

    /* Set frequency and bus width */
    efx_emmc_config_clk(mmc, clk_mhz*1000);
    efx_emmc_config_hs_timing(mmc, cmd, 0x0, timing_interface);
    efx_emmc_config_bus_mode(mmc, cmd, ddr_mode, bus_width);
    
    /* Set emmc device boot_bus_conditions */
    boot_bus_conditions = (boot_mode << 3) | (reset_boot_bus_conditions << 2) | (boot_bus_width << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 177, boot_bus_conditions);
    
    /* Enter into boot partition */
    partition_config = (boot_ack << 6) | (boot_partition_enable << 3) | (partition_access << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 179, partition_config);
    
    /* Write data in boot partition */
    ret = efx_emmc_boot_send_data(mmc, block_cnt, addr, buf, dma_en);
    
    /* Quit boot partition */
    partition_access = 0x0;
    partition_config = (boot_ack << 6) | (boot_partition_enable << 3) | (partition_access << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 179, partition_config);
    
    if(ret != 0) {
        bsp_printf_full("Error: boot partition write fail\r\n");
        return -1;
    }

    return 0;
}

static int efx_emmc_boot_read_all(struct mmc *mmc, struct mmc_cmd *cmd, u32 bus_width, u32 par_num, u32 *buf, u32 dma_en)
{
    /* bus_width: recommend to set x4 or x8 */
    
    u32 boot_mode = 0; /* [0x0]sdr + backward compatible timings, [0x1]:sdr + high speed timing ,[0x2]:ddr */
    u32 reset_boot_bus_conditions = 0;
    u32 boot_bus_width = 0;
    u32 boot_bus_conditions = 0;
    u32 hs_boot_mode  = 0;
    u32 ddr_boot_mode = 0;
    u32 alt_boot_mode = 0;
    u32 partition_access = 0; /* Fixed to 0 */
    u32 boot_partition_enable = 0;
    u32 boot_ack = 0; /* Fixed to 0 */
    u32 partition_config = 0;
    u32 clk_mhz = 25;
    u32 tuning_bus_width = x4;
    u32 ret = 0;
    
    u32 block_cnt = 0;
    u32 block_size = 512;  /* Fixed to 512 */
    u32 boot_partition_size = 0;
    
    /* Emmc initialization */
    efx_emmc_init(mmc, cmd);

    hs_boot_mode  = (mmc->boot_info >> 2) & 0x1;
    ddr_boot_mode = (mmc->boot_info >> 1) & 0x1;
    alt_boot_mode = (mmc->boot_info >> 0) & 0x1;
    boot_partition_size = boot_partition_size_calculate(mmc);  // byte

    if (alt_boot_mode == 0) {
        bsp_printf_full("Error: Device does not support alternative boot method\r\n");
        return -1;
    }

    if (hs_boot_mode == 1) {
        boot_mode = 0x1;
    } else {
        boot_mode = 0x0;
    }
    
    if (boot_mode == 0x0) {
        clk_mhz = 25;
    } else {
        clk_mhz = 50;
    }
    
    if (bus_width == x1) {
        boot_bus_width = 0x0;
    } else if(bus_width == x4) {
        boot_bus_width = 0x1;
    } else if(bus_width == x8) {
        boot_bus_width = 0x2;
    } else {
        bsp_printf_full("Error: bus_width error\r\n");
        return -1;
    }
    
    if (par_num == 0x1) {
        boot_partition_enable = 0x1;
    } else if(par_num == 0x2) {
        boot_partition_enable = 0x2;
    } else {
        bsp_printf_full("Error: partition number error\r\n");
        return -1;
    }
    
    if (bus_width == x1) {
        tuning_bus_width = x4;
    } else {
        tuning_bus_width = bus_width;
    }
    
    /* Tuning in hs200 mode */
    efx_emmc_switch_bus_speed_mode(mmc, cmd, hs200, tuning_bus_width, clk_mhz, 0x0);

    /* Set emmc device boot_bus_conditions */
    boot_bus_conditions = (boot_mode << 3) | (reset_boot_bus_conditions << 2) | (boot_bus_width << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 177, boot_bus_conditions);

    /* Set emmc device partition_config */
    partition_config = (boot_ack << 6) | (boot_partition_enable << 3) | (partition_access << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 179, partition_config);
    
    /* Set frequency and bus_width */
    efx_emmc_config_clk(mmc, clk_mhz*1000);
	efx_emmc_config_ip_bus_mode(sdr, bus_width);
    
    /* Enter into boot state and read boot partition data */
    block_cnt = boot_partition_size / block_size;
    ret = efx_emmc_boot_receive_data_all(mmc, block_cnt, block_size, clk_mhz, buf, dma_en);
    
    /* Enter into idle state */
    sd_send_cmd(mmc, cmd, MMC_CMD_GO_IDLE_STATE, MMC_RSP_NONE, 0x0);
    
    if(ret != 0) {
        bsp_printf_full("Error: boot partition read fail\r\n");
        return -1;
    }
    
    return 0;

}

static int efx_emmc_boot_read_single(struct mmc *mmc, struct mmc_cmd *cmd, u32 bus_width, u32 par_num, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en)
{
    /* bus_width: recommend to set x4 or x8 */

    u32 boot_mode = 0; /* [0x0]sdr + backward compatible timings, [0x1]:sdr + high speed timing ,[0x2]:ddr */
    u32 reset_boot_bus_conditions = 0;
    u32 boot_bus_width = 0;
    u32 boot_bus_conditions = 0;
    u32 hs_boot_mode  = 0;
    u32 ddr_boot_mode = 0;
    u32 partition_access = 0;
    u32 boot_partition_enable = 0; /* Fixed to 0 */
    u32 boot_ack = 0; /* Fixed to 0 */
    u32 partition_config = 0;
    u32 clk_mhz = 25;
    u32 tuning_bus_width = x4;
    u32 timing_interface = 0; /* [0x0] backwards compatibility interface timing  [0x1] High Speed */
    u32 ret = 0;
    
    /* Emmc initialization */
    efx_emmc_init(mmc, cmd);
    
    hs_boot_mode  = (mmc->boot_info >> 2) & 0x1;
    ddr_boot_mode = (mmc->boot_info >> 1) & 0x1;
    
    if (hs_boot_mode == 1) {
        boot_mode = 0x1;
    } else {
        boot_mode = 0x0;
    }
    
    if (boot_mode == 0x0) {
        timing_interface = 0x0;
    } else {
        timing_interface = 0x1;
    }
    
    if (boot_mode == 0x0) {
        clk_mhz = 25;
    } else {
        clk_mhz = 50;
    }
    
    if (bus_width == x1) {
        boot_bus_width = 0x0;
    } else if (bus_width == x4) {
        boot_bus_width = 0x1;
    } else if (bus_width == x8) {
        boot_bus_width = 0x2;
    } else {
        bsp_printf_full("Error: bus_width error\r\n");
        return -1;
    }
    
    if (par_num == 0x1) {
        partition_access = 0x1;
    } else if(par_num == 0x2) {
        partition_access = 0x2;
    } else {
        bsp_printf_full("Error: partition number error\r\n");
        return -1;
    }
    
    if (bus_width == x1) {
        tuning_bus_width = x4;
    } else {
        tuning_bus_width = bus_width;
    }
    
    /* Tuning in hs200 mode */
    efx_emmc_switch_bus_speed_mode(mmc, cmd, hs200, tuning_bus_width, clk_mhz, 0x0);
    
    /* Set frequency and bus width */
    efx_emmc_config_clk(mmc, clk_mhz*1000);
    efx_emmc_config_hs_timing(mmc, cmd, 0x0, timing_interface);
    efx_emmc_config_bus_mode(mmc, cmd, sdr, bus_width);
    
    /* Set emmc device boot_bus_conditions */
    boot_bus_conditions = (boot_mode << 3) | (reset_boot_bus_conditions << 2) | (boot_bus_width << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 177, boot_bus_conditions);

    /* Enter into boot partition */
    partition_config = (boot_ack << 6) | (boot_partition_enable << 3) | (partition_access << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 179, partition_config);

    ret = efx_emmc_boot_receive_data_single(mmc, block_cnt, addr, buf, dma_en);
    
    /* Quit boot partition */
    partition_access = 0x0;
    partition_config = (boot_ack << 6) | (boot_partition_enable << 3) | (partition_access << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 179, partition_config);
    
    if(ret != 0) {
        bsp_printf_full("Error: boot partition read fail\r\n");
        return -1;
    }

    return 0;
}

static int efx_emmc_boot_erase(struct mmc *mmc, struct mmc_cmd *cmd, u32 par_num, u32 start_addr, u32 erase_unit_num, enum erase_type erase_mode)
{
    u32 partition_access = 0;
    u32 boot_partition_enable = 0; /* Fixed to 0 */
    u32 boot_ack = 0; /* Fixed to 0 */
    u32 partition_config = 0;
    u32 ret = 0;
    
    /* Emmc initialization */
    efx_emmc_init(mmc, cmd);
    
    if (par_num == 0x1) {
        partition_access = 0x1;
    } else if(par_num == 0x2) {
        partition_access = 0x2;
    } else {
        bsp_printf_full("Error: partition number error\r\n");
        return -1;
    }
    
    if (erase_mode != erase && erase_mode != trim) {
        bsp_printf_full("Error: Invalid erase mode\r\n");
        return -1;
    }
    
    /* Enter into boot partition */
    partition_config = (boot_ack << 6) | (boot_partition_enable << 3) | (partition_access << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 179, partition_config);
    
    /* Start erase or trim */
    if (erase_mode == erase) {
        ret = efx_emmc_erase(mmc, cmd, start_addr, erase_unit_num);
    } else if (erase_mode == trim) {
        ret = efx_emmc_trim(mmc, cmd, start_addr, erase_unit_num);
    }
    
    /* Quit boot partition */
    partition_access = 0x0;
    partition_config = (boot_ack << 6) | (boot_partition_enable << 3) | (partition_access << 0);
    efx_emmc_write_ext_csd(mmc, cmd, 179, partition_config);
    
    if(ret != 0) {
        bsp_printf_full("Error: erase fail\r\n");
        return -1;
    }

    return 0;
    
}

static int efx_emmc_boot_send_data(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en)
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

    /* Calculate boot partition size and address limits */
    u32 boot_partition_size = 0;
    u32 boot_addr_max = 0;  // boot partition max address
    u32 addr_end = 0;      // End address of current write operation

    boot_partition_size = boot_partition_size_calculate(mmc);  // byte
    if (boot_partition_size == 0) {
        bsp_printf_full("Error: Failed to calculate boot partition size\r\n");
        return ERR_IO;
    }

    /* Calculate maximum address based on boot_partition_size */
    if (EMMC_LARGE_DENSITY == 0) {
        boot_addr_max = boot_partition_size - 1;
    } else {
        boot_addr_max = (boot_partition_size / 512) - 1;
    }

    /* Calculate end address of write operation, with overflow protection */
    if (EMMC_LARGE_DENSITY == 0) {
        /* Check for potential overflow */
        if (block_cnt > ((u32)-1 - addr) / EMMC_BLOCK_LEN) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN) - 1;
    } else {
        /* Check for potential overflow */
        if (block_cnt > ((u32)-1 - addr) / (EMMC_BLOCK_LEN / 512)) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN / 512) - 1;
    }

    /* Validate start and end addresses are within range */
    if (addr > boot_addr_max) {
        bsp_printf_full("Error: Write start addr %u boot_addr_max %u out of range\r\n", addr, boot_addr_max);
        return ERR_INVALID_PARAM;
    }

    if (addr_end > boot_addr_max) {
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

static int efx_emmc_boot_receive_data_all(struct mmc *mmc, u32 block_cnt, u32 block_size, u32 clk_mhz, u32 *buf, u32 dma_en)
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
    const u32 MAX_TIMEOUT = 2000000; // Maximum timeout count (adjust based on uDelay value)
    u32 delay = 0;
    

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
    if ((EMMC_LARGE_DENSITY != 0) && (((block_cnt * block_size) % 512) != 0x0)) {
        bsp_printf_full("Error: When emmc density > 2GB, read data length must be integer multiple of 512 byte\r\n");
        return ERR_INVALID_PARAM;
    }
    
    /* Verify block_size is multiple of 4 for proper word-aligned access */
    if (block_size % 4 != 0) {
        bsp_printf_full("Error: Block size must be a multiple of 4 bytes\r\n");
        return ERR_INVALID_PARAM;
    }

    /* Enter into pre-idle state */
    reg_write(0xF0F0F0F0, REG_ARGUMENT1);
    reg_write(0x0, REG_TRANFER_MODE_COMMAND);
    
    /* Min 74 clocks delay required */
    delay = cycle_to_us(clk_mhz*1000, 100);
	bsp_uDelay(delay);
    
    /* Configure block size and count register */
    reg_write(((block_cnt << 16) | block_size),REG_BLOCK_SIZE_COUNT);
    
    /* Configure command */
    cmd_index = 0;             // CMD0
    data_available = 1;        // Data transfer expected
    cmd_index_check_en = 1;    // Enable command index check
    cmd_crc_en = 1;            // Enable command CRC check
    resp_type = 0;             // no response
    multi_block_en = 1;        // Multi-block transfer
    data_direction = 1;        // Read from card
    auto_cmd_en = 0;           // Auto command enabled (likely CMD12 for stop)
    block_counter_en = 1;      // Use block counter

    /* Clear transfer complete flag before starting transfer */
    IntPtr.transfer_complete = 0x0;

    /* Create DMA descriptor if DMA is enabled */
    if (dma_en) {
        ret = sd_ctrl_creat_Descriptor(mmc, block_cnt, block_size, buf);
        if (ret != 0) {
            bsp_printf_full("Error: Failed to create DMA descriptor, error %d\r\n", ret);
            return ERR_IO;
        }
    }

    /* Build command register value from configuration bits */
    val = (cmd_index << 24) | (data_available << 21) | (cmd_index_check_en << 20) |
          (cmd_crc_en << 19) | (resp_type << 16) | (multi_block_en << 5) |
          (data_direction << 4) | (auto_cmd_en << 2) | (block_counter_en << 1) | (dma_en << 0);

    /* Start up alternative boot mode, then enter into boot state */
    reg_write(0xFFFFFFFA, REG_ARGUMENT1);
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

            /* Read block data (block_size bytes, 4 bytes at a time) */
            for (int j = 0; j < block_size / 4; j++) {
                read_data = reg_read(REG_BUFFER_DATA_PORT);
                *(buf + j + (i * block_size / 4)) = read_data;
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

static int efx_emmc_boot_receive_data_single(struct mmc *mmc, u32 block_cnt, u32 addr, u32 *buf, u32 dma_en)
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

    /* Calculate boot partition size and address limits */
    u32 boot_partition_size = 0;
    u32 boot_addr_max = 0;  // boot partition max address
    u32 addr_end = 0;      // End address of current write operation

    boot_partition_size = boot_partition_size_calculate(mmc);  // byte
    if (boot_partition_size == 0) {
        bsp_printf_full("Error: Failed to calculate boot partition size\r\n");
        return ERR_IO;
    }

    /* Calculate maximum address based on boot_partition_size */
    if (EMMC_LARGE_DENSITY == 0) {
        boot_addr_max = boot_partition_size - 1;
    } else {
        boot_addr_max = (boot_partition_size / 512) - 1;
    }

    /* Calculate end address of write operation, with overflow protection */
    if (EMMC_LARGE_DENSITY == 0) {
        /* Check for potential overflow */
        if (block_cnt > ((u32)-1 - addr) / EMMC_BLOCK_LEN) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN) - 1;
    } else {
        /* Check for potential overflow */
        if (block_cnt > ((u32)-1 - addr) / (EMMC_BLOCK_LEN / 512)) {
            bsp_printf_full("Error: Address calculation would overflow\r\n");
            return ERR_OVERFLOW;
        }
        addr_end = addr + (block_cnt * EMMC_BLOCK_LEN / 512) - 1;
    }

    /* Validate start and end addresses are within range */
    if (addr > boot_addr_max) {
        bsp_printf_full("Error: Write start addr %u boot_addr_max %u out of range\r\n", addr, boot_addr_max);
        return ERR_INVALID_PARAM;
    }

    if (addr_end > boot_addr_max) {
        bsp_printf_full("Error: Write end addr out of range\r\n");
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

