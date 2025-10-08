////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "bsp.h"
#include "emmc.h"
#include "efx_emmc_driver.h"
#include "utils.h"

/**
 * Generates an array of random u32 values that sum to a specified total.
 * Each value is in the range [1, 65535].
 *
 * @param targetSum The desired sum of all values in the array
 * @param size Pointer to store the resulting array size
 * @return Dynamically allocated array of random values, NULL if allocation fails
 *         or if constraints cannot be satisfied
 *
 * Note: Caller is responsible for freeing the returned array
 */
u32* generate_random_array(u32 targetSum, u32* size) {
    // Initial validation
    if (targetSum == 0) {
        *size = 0;
        return NULL;
    }

    // Determine array size - minimum required elements
    u32 max_value = 65535;
    u32 min_elements = (targetSum + max_value - 1) / max_value; // Ceiling division

    // Add some randomness to the array size
    u32 additional_elements = rand() % 5; // 0 to 4 additional elements
    u32 array_size = min_elements + additional_elements;

    // Validate that the target sum can be achieved
    if (array_size > targetSum) {
        // Target sum is too small to distribute among this many elements
        // (since minimum value is 1)
        array_size = targetSum; // Each element will be 1
    }

    // Allocate memory for the array
    u32* result = (u32*)malloc(array_size * sizeof(u32));
    if (result == NULL) {
        *size = 0;
        return NULL;
    }

    // Initialize all elements to 1 (minimum value)
    u32 current_sum = array_size; // Starting with all 1s
    for (u32 i = 0; i < array_size; i++) {
        result[i] = 1;
    }

    // Distribute the remaining sum randomly across the array
    u32 remaining = targetSum - current_sum;

    while (remaining > 0) {
        for (u32 i = 0; i < array_size && remaining > 0; i++) {
            // Calculate maximum additional value we can add to this element
            u32 max_add = max_value - result[i];
            if (max_add > 0) {
                // Choose a random amount to add, limited by what's remaining
                u32 add = 1 + (rand() % (max_add < remaining ? max_add : remaining));
                result[i] += add;
                remaining -= add;
            }
        }

        // If we can't distribute any more (all elements at max value)
        if (remaining > 0) {
            u32 can_distribute = 0;
            for (u32 i = 0; i < array_size; i++) {
                if (result[i] < max_value) {
                    can_distribute = 1;
                    break;
                }
            }

            if (!can_distribute) {
                // Free the array and return NULL as we can't satisfy the constraint
                free(result);
                *size = 0;
                return NULL;
            }
        }
    }

    *size = array_size;
    return result;
}

/**
 * Checks if a buffer of u32 values contains all zeros or all ones.
 *
 * @param buffer Pointer to the buffer to check
 * @param length Number of u32 elements in the buffer
 * @return 0 if all zeros, 1 if all ones, -1 if mixed values
 */
int check_buffer_zeros_or_ones(const u32 *buffer, size_t length) {
    if (buffer == NULL || length == 0) {
        return -1;  // Invalid input
    }

    // Check first value to determine what we're looking for
    u32 first_value = buffer[0];

    // Only two valid patterns: all zeros or all ones
    if (first_value != 0 && first_value != 0xFFFFFFFF) {
        return -1;  // Mixed values (first element is neither 0 nor 0xFFFFFFFF)
    }

    // Check remaining elements match the pattern
    for (size_t i = 1; i < length; i++) {
        if (buffer[i] != first_value) {
            return -1;  // Mixed values
        }
    }

    // Return 0 for all zeros, 1 for all ones
    return (first_value == 0) ? 0 : 1;
}

u32 compare_buffers(const u32* buffer1, const u32* buffer2, size_t size_mb) {
    // Calculate number of u32 elements for the given size in MB
    // 1 MB = 1024 * 1024 bytes
    // Each u32 is 4 bytes
    size_t num_elements = (size_mb * 1024 * 1024) / sizeof(u32);

    // Check for NULL pointers
    if (buffer1 == NULL || buffer2 == NULL) {
        debug_printf("Error: NULL buffer pointer(s) provided\r\n");
        return 0;
    }

    // Compare each element
    for (size_t i = 0; i < num_elements; i++) {
        if (buffer1[i] != buffer2[i]) {
        	debug_printf("Error: Buffers differ at element %zu (%.2f MB): %u vs %u\r\n",
                   i, (float)(i * sizeof(u32)) / (1024 * 1024), buffer1[i], buffer2[i]);
            return 0;
        }
    }

    // If we get here, the buffers are identical
    debug_printf("All %zu MB compared: Buffers are identical\r\n", size_mb);
    return 1;
}

// Function to allocate and fill a buffer with random u32 data
u32* create_empty_buffer(size_t size_mb) {
    // Calculate number of u32 elements for the given size in MB
    // 1 MB = 1024 * 1024 bytes
    // Each u32 is 4 bytes
    size_t num_elements = (size_mb * 1024 * 1024) / sizeof(u32);

    // Allocate memory
    u32* buffer = (u32*)malloc(num_elements * sizeof(u32));

    // Check if allocation was successful
    if (buffer == NULL) {
        bsp_printf("Error: Memory allocation failed!\r\n");
        return NULL;
    }

    debug_printf("Successfully allocated %zu MB (%zu elements)\r\n",
           size_mb, num_elements);

    return buffer;
}

// Function to allocate and fill a buffer with random u32 data
u32* create_random_buffer(size_t size_mb) {
    // Calculate number of u32 elements for the given size in MB
    // 1 MB = 1024 * 1024 bytes
    // Each u32 is 4 bytes
    size_t num_elements = (size_mb * 1024 * 1024) / sizeof(u32);

    // Allocate memory
    u32* buffer = (u32*)malloc(num_elements * sizeof(u32));

    // Check if allocation was successful
    if (buffer == NULL) {
        bsp_printf("Error: Memory allocation failed!\r\n");
        return NULL;
    }

    debug_printf("Successfully allocated %zu MB (%zu elements)\r\n",
           size_mb, num_elements);

    // Seed the random number generator
    //srand((unsigned int)time(NULL)); //Seed in main.c

    // Fill the buffer with random u32 data
    for (size_t i = 0; i < num_elements; i++) {
        // Generate random 32-bit value
        // rand() typically returns 15-16 bits of randomness, so combine multiple calls
        buffer[i] = ((u32)rand() << 16) | ((u32)rand() & 0xFFFF);
    }

    return buffer;
}

int non_dma_wr_rd(struct mmc *mmc, struct mmc_cmd *cmd, u32 len_mode, u32 fixed_bk_num, u32 start_addr, u32 test_size_mb,
				  double *write_speed, double *read_speed)
{
	u32 block_per_rw = 0;
	u32 block_read = 0;
	u32 block_written = 0;
	u32 byte_left = 0;
	u32 byte_read = 0;
	u32 byte_written = 0;
	u32 total_blocks = test_size_mb * 1024 * 1024 / EMMC_BLOCK_LEN;
	u32 total_cycle = 0;
    u64 start = 0;
    u64 end = 0;
    u32 ret = 0;
    double time_second = 0.0;
    double speed_mbps = 0.0; //MBps

	if (len_mode != 0 && len_mode != 1) {
		bsp_printf("Error: Invalid len mode\r\n");
		return -1;
	}

	if (fixed_bk_num < 1 || fixed_bk_num > 65535) {
		bsp_printf("Error: Invalid fixed bk num\r\n");
		return -1;
	}

    u32* src_buffer = create_random_buffer(test_size_mb);
    u32* dest_buffer = create_empty_buffer(test_size_mb);

    if (len_mode == 0) {
    	block_per_rw = fixed_bk_num;
        total_cycle = ceiling_division(total_blocks, block_per_rw);
        debug_printf("Total block %d, total cycle %d\r\n", total_blocks, total_cycle);

        bsp_printf("Non-DMA fixed block: Writing...\r\n");
        start = get_timer_ticks();
        for (int i = 0; i < total_cycle; i++) {
        	if ((total_blocks % block_per_rw != 0) && (i == (total_cycle -1))) {
        		//bsp_printf("block read %d, going to read %d\r\n", block_read, total_blocks%block_per_rw);
        		ret = efx_emmc_block_write(mmc, total_blocks % block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), src_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 0);
        	} else {
        		//bsp_printf("block read %d, going to read %d\r\n", block_read, block_per_rw);
        		ret = efx_emmc_block_write(mmc, block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), src_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 0);
        	}

        	if(ret != 0) {
        		bsp_printf("Error: Non-DMA fixed block: Write fail...\r\n");
        		ret = -1;
        		goto free_buffers;
        	}
        }
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *write_speed = ((double)test_size_mb / time_second);
        debug_printf("Non-DMA fixed block: Write speed %f MBps\r\n", *write_speed);

        bsp_printf("Non-DMA fixed block: Reading...\r\n");
        start = get_timer_ticks();
        for (int i = 0; i < total_cycle; i++) {
        	if ((total_blocks % block_per_rw != 0) && (i == (total_cycle -1))) {
        		//bsp_printf("block read %d, going to read %d\r\n", block_read, total_blocks%block_per_rw);
        		ret = efx_emmc_block_read(mmc, total_blocks % block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 0);
        	} else {
        		//bsp_printf("block read %d, going to read %d\r\n", block_read, block_per_rw);
        		ret = efx_emmc_block_read(mmc, block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 0);
        	}

        	if(ret != 0) {
        		bsp_printf("Error: Non-DMA fixed block: Read fail...\r\n");
        		ret = -1;
        		goto free_buffers;
        	}
        }
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *read_speed = ((double)test_size_mb / time_second);
        debug_printf("Non-DMA fixed block: Read speed %f MBps\r\n", *read_speed);
    } else {
        u32 total = total_blocks;
        u32 size = 0;

        u32* array = generate_random_array(total, &size);

    	bsp_printf("Non-DMA random block: Writing...\r\n");
        start = get_timer_ticks();
		for (size_t i = 0; i < size; i++) {
			block_per_rw = array[i];
			//debug_printf("Writing： block_per_rw = %d\r\n", block_per_rw);
			ret = efx_emmc_block_write(mmc, block_per_rw, start_addr + (block_written * EMMC_BLOCK_LEN / EMMC_STEP), src_buffer + (block_written * EMMC_BLOCK_LEN / 4), 0);
        	if(ret != 0) {
        		bsp_printf("Error: Non-DMA random block: Write fail\r\n");
        		ret = -1;
        		goto free_buffers;
        	}
			block_written += block_per_rw;
			//debug_printf("Block written %d\r\n", block_written);
		}
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *write_speed = ((double)test_size_mb / time_second);
        debug_printf("Non-DMA random block: Write speed %f MBps\r\n", *write_speed);

    	bsp_printf("Non-DMA random block: Reading...\r\n");
        start = get_timer_ticks();
		for (size_t i = 0; i < size; i++) {
			block_per_rw = array[i];
			//debug_printf("Reading: block_per_rw = %d\r\n", block_per_rw);
			ret = efx_emmc_block_read(mmc, block_per_rw, start_addr + (block_read * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (block_read * EMMC_BLOCK_LEN / 4), 0);
        	if(ret != 0) {
        		bsp_printf("Error: Non-DMA random block: Read fail\r\n");
        		ret = -1;
        		goto free_buffers;
        	}
			block_read += block_per_rw;
			//debug_printf("Block read %d\r\n", block_read);
		}
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *read_speed = ((double)test_size_mb / time_second);
        debug_printf("Non-DMA random block: Read speed %f MBps\r\n", *read_speed);

        free(array);
    }

    bsp_printf("Non-DMA: Comparing...\r\n");
    if (compare_buffers(src_buffer, dest_buffer, test_size_mb)) {
        bsp_printf("Non-DMA: Pass. Buffers are identical\r\n");
    } else {
    	bsp_printf("Error: Non-DMA: Fail. Buffers differ\r\n");
		ret = -1;
		goto free_buffers;
    }

free_buffers:
    free(src_buffer);
    free(dest_buffer);

    return ret;
}

int dma_wr_rd_erase(struct mmc *mmc, struct mmc_cmd *cmd, u32 len_mode, u32 fixed_bk_num, u32 start_addr,
					 enum erase_type erase_mode, u32 erase_en ,u32 test_size_mb, double *write_speed, double *read_speed, double *erase_speed)
{
	u32 block_per_rw = 0;
	u32 block_read = 0;
	u32 block_written = 0;
	u32 byte_left = 0;
	u32 byte_read = 0;
	u32 byte_written = 0;
	u32 total_blocks = test_size_mb * 1024 * 1024 / EMMC_BLOCK_LEN;
	u32 erase_unit_size = 0;
	u32 erase_unit_num = 0;
	u32 total_cycle = 0;
    u64 start = 0;
    u64 end = 0;
    u32 ret = 0;
    double time_second = 0.0;

	if (len_mode != 0 && len_mode != 1) {
		bsp_printf("Error: Invalid len mode\r\n");
		return -1;
	}

	if (fixed_bk_num < 1 || fixed_bk_num > 65535) {
		bsp_printf("Error: Invalid fixed bk num\r\n");
		return -1;
	}

	if (erase_mode != erase && erase_mode != trim) {
		bsp_printf("Error: Invalid erase mode\r\n");
		return -1;
	}

    u32* src_buffer = create_random_buffer(test_size_mb);
    u32* dest_buffer = create_empty_buffer(test_size_mb);

    // Check if memory allocation succeeded
    if (src_buffer == NULL || dest_buffer == NULL) {
        bsp_printf("Error: Failed to allocate memory for buffers\r\n");
        if (src_buffer) free(src_buffer);
        if (dest_buffer) free(dest_buffer);
        return -1;
    }

    if (len_mode == 0) {
    	block_per_rw = fixed_bk_num;
        total_cycle = ceiling_division(total_blocks, block_per_rw);
        debug_printf("Total block %d, total cycle %d\r\n", total_blocks, total_cycle);

        bsp_printf("DMA fixed block: Writing...\r\n");
        start = get_timer_ticks();
        for (int i = 0; i < total_cycle; i++) {
        	if ((total_blocks % block_per_rw != 0) && (i == (total_cycle -1))) {
//        		bsp_printf("block read %d, going to read %d\r\n", block_read, total_blocks%block_per_rw);
        		ret = efx_emmc_block_write(mmc, total_blocks % block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), src_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 1);
        	} else {
//        		bsp_printf("block read %d, going to read %d\r\n", block_read, block_per_rw);
        		ret = efx_emmc_block_write(mmc, block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), src_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 1);
        	}

        	if(ret != 0) {
        		bsp_printf("Error: DMA fixed block: Write fail\r\n");
        		ret = -1;
        		goto free_buffers;
        	}
        }
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *write_speed = ((double)test_size_mb / time_second);
        debug_printf("DMA fixed block: Write speed %f MBps\r\n", *write_speed);

        bsp_printf("DMA fixed block: Reading...\r\n");
        start = get_timer_ticks();
        for (int i = 0; i < total_cycle; i++) {
        	if ((total_blocks % block_per_rw != 0) && (i == (total_cycle -1))) {
        		//bsp_printf("block read %d, going to read %d\r\n", block_read, total_blocks%block_per_rw);
        		ret = efx_emmc_block_read(mmc, total_blocks % block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 1);
        	} else {
        		//bsp_printf("block read %d, going to read %d\r\n", block_read, block_per_rw);
        		ret = efx_emmc_block_read(mmc, block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 1);
        	}

        	if(ret != 0) {
        		bsp_printf("Error: DMA fixed block: Read fail\r\n");
        		ret = -1;
        		goto free_buffers;
        	}
        }
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *read_speed = ((double)test_size_mb / time_second);
        debug_printf("DMA fixed block: Read speed %f MBps\r\n", *read_speed);
    } else {
        u32 total = total_blocks;
        u32 size = 0;

        u32* array = generate_random_array(total, &size);

        // Check if array allocation succeeded
        if (array == NULL) {
            bsp_printf("Error: Failed to allocate memory for array\r\n");
            ret = -1;
            goto free_buffers;
        }

    	bsp_printf("DMA random block: Writing...\r\n");
        start = get_timer_ticks();
		for (size_t i = 0; i < size; i++) {
			block_per_rw = array[i];
			//debug_printf("Writing： block_per_rw = %d\r\n", block_per_rw);
			ret = efx_emmc_block_write(mmc, block_per_rw, start_addr + (block_written * EMMC_BLOCK_LEN / EMMC_STEP), src_buffer + (block_written * EMMC_BLOCK_LEN / 4), 1);
        	if(ret != 0) {
        		bsp_printf("Error: DMA random block: Write fail\r\n");
        		ret = -1;
                free(array); // Free array before jumping to free_buffers
        		goto free_buffers;
        	}
			block_written += block_per_rw;
			//debug_printf("Block written %d\r\n", block_written);
		}
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *write_speed = ((double)test_size_mb / time_second);
        debug_printf("DMA random block: Write speed %f MBps\r\n", *write_speed);

    	bsp_printf("DMA random block: Reading...\r\n");
        start = get_timer_ticks();
		for (size_t i = 0; i < size; i++) {
			block_per_rw = array[i];
			//debug_printf("Reading: block_per_rw = %d\r\n", block_per_rw);
			ret = efx_emmc_block_read(mmc, block_per_rw, start_addr + (block_read * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (block_read * EMMC_BLOCK_LEN / 4), 1);
        	if(ret != 0) {
        		bsp_printf("Error: DMA random block: Read fail\r\n");
        		ret = -1;
                free(array); // Free array before jumping to free_buffers
        		goto free_buffers;
        	}
			block_read += block_per_rw;
			//debug_printf("Block read %d\r\n", block_read);
		}
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *read_speed = ((double)test_size_mb / time_second);
        debug_printf("DMA random block: Read speed %f MBps\r\n", *read_speed);

        free(array);
    }

    bsp_printf("DMA: Comparing...\r\n");
    if (compare_buffers(src_buffer, dest_buffer, test_size_mb)) {
        bsp_printf("DMA: Pass. Buffers are identical\r\n");
    } else {
    	bsp_printf("Error: DMA: Fail. Buffers differ\r\n");
		ret = -1;
		goto free_buffers;
    }

    if(erase_en == 0x0) {
    	goto free_buffers;
    }

    if (erase_mode == erase) { // erase
    	bsp_printf("DMA: Start erasing...\r\n");
    	start = get_timer_ticks();
    	erase_unit_size = erase_unit_size_calculate(mmc, erase);
    	if(erase_unit_size == 0) {
            bsp_printf("Error: DMA: Failed to calculate erase unit size\r\n");
            ret = -1;
            goto free_buffers;
        }
    	erase_unit_num = test_size_mb * 1024 * 1024 / erase_unit_size;
    	ret = efx_emmc_erase(mmc, cmd, start_addr, erase_unit_num);
        if(ret != 0) {
        	bsp_printf("Error: DMA: Erase fail\r\n");
        	ret = -1;
        	goto free_buffers;
        }
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *erase_speed = ((double)test_size_mb / time_second);
        debug_printf("DMA: Erase speed %f MBps\r\n", *erase_speed);
    } else { // trim
    	bsp_printf("DMA: Start trimming...\r\n");
    	start = get_timer_ticks();
    	erase_unit_size = erase_unit_size_calculate(mmc, trim);
    	if(erase_unit_size == 0) {
            bsp_printf("Error: DMA: Failed to calculate trim unit size\r\n");
            ret = -1;
            goto free_buffers;
        }
    	erase_unit_num = test_size_mb * 1024 * 1024 / erase_unit_size;
    	ret = efx_emmc_trim(mmc, cmd, start_addr, erase_unit_num);
        if(ret != 0) {
        	bsp_printf("Error: DMA: Trim fail\r\n");
        	ret = -1;
        	goto free_buffers;
        }
        end = get_timer_ticks();
        time_second = ticks_to_seconds(end - start);
        *erase_speed = ((double)test_size_mb / time_second);
        debug_printf("DMA: Trim speed %f MBps\r\n", *erase_speed);
    }

    // Read back after erase/trim for verification
    block_per_rw = 65535;
    total_cycle = ceiling_division(total_blocks, block_per_rw);
    for (int i = 0; i < total_cycle; i++) {
    	if ((total_blocks % block_per_rw != 0) && (i == (total_cycle -1))) {
    		//bsp_printf("block read %d, going to read %d\r\n", block_read, total_blocks%block_per_rw);
    		ret = efx_emmc_block_read(mmc, total_blocks % block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 1);
    	} else {
    		//bsp_printf("block read %d, going to read %d\r\n", block_read, block_per_rw);
    		ret = efx_emmc_block_read(mmc, block_per_rw, start_addr + (i * block_per_rw * EMMC_BLOCK_LEN / EMMC_STEP), dest_buffer + (i * block_per_rw * EMMC_BLOCK_LEN / 4), 1);
    	}

        if(ret != 0) {
        	bsp_printf("Error: DMA: Read for erase verify fail\r\n");
        	ret = -1;
        	goto free_buffers;
        }
    }

    u32 ret_val = check_buffer_zeros_or_ones(dest_buffer, test_size_mb);
    if ((erase_mode == erase) && (ret_val == 0 || ret_val == 1)) { // erase
    	bsp_printf("DMA: Erase successful. Entire area are %d\r\n", ret_val);
    } else if ((erase_mode == trim) && (ret_val == 0 || ret_val == 1)) { // trim
    	bsp_printf("DMA: Trim successful. Entire area are %d\r\n", ret_val);
    } else {
    	bsp_printf("Error: DMA: Erase/Trim failed. Not entire area are 0 or 1\r\n");
        ret = -1;
        goto free_buffers;
    }

free_buffers:
    free(src_buffer);
    free(dest_buffer);

    return ret;
}

int test_entire_emmc(struct mmc *mmc, struct mmc_cmd *cmd, u32 dma, enum bus_speed_mode transfer_mode, enum data_bus_width bus_width,
					 u32 clk_freq, u32 len_mode, u32 fixed_bk_num, enum erase_type erase_mode, u32 whole_space_test_num)
{
	const u32 test_size_mb = 487; //MB, max 487MB
	u64 uda_capacity = uda_density_calculate(mmc);
	u32 address = 0x0;
	u32 total_cycle = 0;
	u32 test_size_byte = test_size_mb*1024*1024;
	u32 test_size_last_mb = 0;
	u32 test_size_real_mb = 0;
	u32 test_fail = 0;
	u32 ret = 0;
	u32 erase_en = 1;
	double write_speed = 0.0;
	double read_speed = 0.0;
	double erase_speed = 0.0;
	double write_speed_sum = 0.0;
	double read_speed_sum = 0.0;
	double erase_speed_sum = 0.0;

	total_cycle = (uda_capacity % test_size_byte == 0)? ( uda_capacity / test_size_byte ) : ( uda_capacity / test_size_byte + 1 );
	test_size_last_mb = (uda_capacity % test_size_byte == 0)? test_size_mb : (uda_capacity % test_size_byte)/1024/1024;
	bsp_printf("test cycle is %d\r\n",total_cycle);

	efx_emmc_switch_bus_speed_mode(mmc, cmd, transfer_mode, bus_width, clk_freq, 0x0);

	for (int j = 1; j <= whole_space_test_num ; j++){
		address = 0x0;
		bsp_printf("-----------------all space test %d-----------------\r\n", j);
		for (int i = 1; i <= total_cycle ; i++) {
			bsp_printf("test cycle is %d/%d, test start addr is 0x%x\r\n",i,total_cycle,address);
			test_size_real_mb = (i == total_cycle)? test_size_last_mb : test_size_mb;
			if (dma) {
				ret = dma_wr_rd_erase(mmc, cmd, len_mode, fixed_bk_num, address, erase_mode, erase_en, test_size_real_mb, &write_speed, &read_speed, &erase_speed);
			} else {
				ret = non_dma_wr_rd(mmc, cmd, len_mode, fixed_bk_num, address, test_size_real_mb, &write_speed, &read_speed);
			}
			debug_printf("test %d cycle %d, write: %f MBps, read: %f MBps, erase: %f MBps\r\n", j, i, write_speed, read_speed, erase_speed);

			if (ret != 0) {
				test_fail = 1;
				bsp_printf("Error: all space test failed at cycle %d\r\n",i);
				break;
			}
			address = address + test_size_real_mb*1024*1024/EMMC_STEP;
			write_speed_sum += write_speed;
			read_speed_sum += read_speed;
			erase_speed_sum += erase_speed;
		}
		if(test_fail == 1) break;
	}

	if (test_fail == 0) {
		bsp_printf("-------------------Test Success-------------------\r\n");
		bsp_printf("Average write speed %.2f MBps\r\n", write_speed_sum / (whole_space_test_num * total_cycle));
		bsp_printf("Average read speed %.2f MBps\r\n", read_speed_sum / (whole_space_test_num * total_cycle));
		if(erase_mode == erase) {
			debug_printf("Average erase speed %.2f MBps\r\n", erase_speed_sum / (whole_space_test_num * total_cycle));
		} else if(erase_mode == trim) {
			debug_printf("Average trim speed %.2f MBps\r\n", erase_speed_sum / (whole_space_test_num * total_cycle));
		}
		ret = 0;
	} else {
		bsp_printf("-------------------Test Fail-------------------\r\n");
		ret = -1;
	}

	return ret;
}

