////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "utils.h"
#include "device_config.h"

u32 reg_read(u32 reg)
{
	return read_u32(EMMC_ADDR + reg);
}

void reg_write(u32 val, u32 reg)
{
	write_u32(val, EMMC_ADDR + reg);
}

u32 sys_reg_read(u32 reg)
{
	return read_u32(SYS_REG_ADDR + reg);
}

void sys_reg_write(u32 val, u32 reg)
{
	write_u32(val, SYS_REG_ADDR + reg);
}

void reg_set_bit(u32 reg, u32 bit)
{
	u32 val = 0;
	val = reg_read(reg);
	val |= (1 << bit);
	reg_write(val, reg);
}

void reg_clear_bit(u32 reg, u32 bit)
{
	u32 val = 0;
	val = reg_read(reg);
	val &= ~(1 << bit);
	reg_write(val, reg);
}

void sys_reg_set_bit(u32 reg, u32 bit)
{
	u32 val = 0;
	val = sys_reg_read(reg);
	val |= (1 << bit);
	sys_reg_write(val, reg);
}

void sys_reg_clear_bit(u32 reg, u32 bit)
{
	u32 val = 0;
	val = sys_reg_read(reg);
	val &= ~(1 << bit);
	sys_reg_write(val, reg);
}

u32 reg_is_bit_set(u32 reg, u32 bit)
{
	u32 val = 0;
	val = reg_read(reg);
	return (val & (1 << bit)) != 0;
}

u32 reg_is_bit_cleared(u32 reg, u32 bit)
{
	u32 val = 0;
	val = reg_read(reg);
	return (val & (1 << bit)) == 0;
}

u32 val_is_bit_set(u32 val, u32 bit)
{
	return (val & (1 << bit)) != 0;
}

u32 val_is_bit_cleared(u32 val, u32 bit)
{
	return (val & (1 << bit)) == 0;
}

// Function to check if two arrays are the same
int are_arrays_equal(const u32 *arr1, const u32 *arr2, size_t size)
{
	int ret = 1;
    for (size_t i = 0; i < size; i++) {
    	//bsp_printf_full("arr1[%d] %d vs arr2[%d] %d\r\n", i, arr1[i], i, arr2[i]);
        if (arr1[i] != arr2[i]) {
        	bsp_printf_full("Arrays are not equal arr1[%d] %d vs arr2[%d] %d\r\n", i, arr1[i], i, arr2[i]);
            ret = 0; // Arrays are not equal
        }
    }
    return ret; // Arrays are equal
}

// Function to calculate the largest number based on start and stop bits
u32 largest_number(int start, int stop)
{
    if (start < 0 || stop < 0 || start > stop) {
        bsp_printf_full("Invalid start or stop bit.\r\n");
        return 0; // Return 0 for invalid input
    }

    int num_bits = stop - start + 1; // Number of bits in the range
    u32 max_number = (1ULL << num_bits) - 1; // 2^num_bits - 1

    return max_number;
}

u32 cycle_to_us(u32 clk_khz, u32 cycle)
{
	u32 delay = 0;
	double period = 0.0;

	period = 1000000.0 / (clk_khz * 1000.0);
	delay = cycle * period;
	if (delay < 1) {
		delay = 1;
	}
	bsp_printf_full("Clock %dkHz, cycle %d, delay %dus\r\n", clk_khz, cycle, delay);

	return delay;
}

int ceiling_division(int numerator, int denominator)
{
    return (numerator + denominator - 1) / denominator;
}

// High-resolution timer function (platform-specific)
uint64_t get_timer_ticks() {
    return clint_getTime(BSP_CLINT);
}

// Convert timer ticks to seconds (platform-specific)
double ticks_to_seconds(uint64_t ticks) {
	bsp_printf_full("ticks %u, second %f\r\n", ticks, ticks/(SYSTEM_CLINT_HZ/1.0));
    return ticks/(SYSTEM_CLINT_HZ/1.0);
}
