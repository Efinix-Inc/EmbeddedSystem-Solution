////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef SRC_UTILS_H_
#define SRC_UTILS_H_
#include <stdio.h>
#include <stdarg.h>
#include "bsp.h"
//#include "device_config.h"
#include "userDef.h"

u32 reg_read(u32 reg);
void reg_write(u32 val, u32 reg);
void reg_set_bit(u32 reg, u32 bit);
void reg_clear_bit(u32 reg, u32 bit);
u32 reg_is_bit_set(u32 reg, u32 bit);
u32 reg_is_bit_cleared(u32 reg, u32 bit);

u32 sys_reg_read(u32 reg);
void sys_reg_write(u32 val, u32 reg);
void sys_reg_set_bit(u32 reg, u32 bit);
void sys_reg_clear_bit(u32 reg, u32 bit);

u32 val_is_bit_set(u32 val, u32 bit);
u32 val_is_bit_cleared(u32 val, u32 bit);

u32 largest_number(int start, int stop);
int are_arrays_equal(const u32 *arr1, const u32 *arr2, size_t size);

void debug_printf(const char *format, ...);
u32 cycle_to_us(u32 clk_khz, u32 cycle);
int ceiling_division(int numerator, int denominator);
uint64_t get_timer_ticks();
double ticks_to_seconds(uint64_t ticks);
#endif /* SRC_UTILS_H_ */
