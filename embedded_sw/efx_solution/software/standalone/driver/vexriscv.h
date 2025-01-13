////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#pragma once

#include "riscv.h"

//Invalidate the whole data cache
#define data_cache_invalidate_all() asm(".word(0x500F)");

//Invalidate all the data cache ways lines which could store the given address
#define data_cache_invalidate_address(address)     \
({                                             \
    asm volatile(                              \
     ".word ((0x500F) | (regnum_%0 << 15));"   \
     :                                         \
     : "r" (address)                               \
    );                                         \
})

//Write buffer flush
#define soc_write_buffer_flush()     \
({                                   \
    csr_write(0x810, 1);             \
	asm volatile ( 					\
        "1: csrr t0, 0x810      \n\t"	\
        "   andi t0, t0, 1  \n\t" \
        "   bnez t0, 1b         \n\t" \
        :							\
        :                            \
        :"t0"                           \
    ); \
})

//Invalidate the whole instruction cache
#define instruction_cache_invalidate() asm("fence.i");
