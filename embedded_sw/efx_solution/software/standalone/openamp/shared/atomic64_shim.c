////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>

uint64_t __atomic_load_8(const volatile void *ptr, int memorder)
{
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    uint64_t v = *(const volatile uint64_t *)ptr;
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    return v;
}

void __atomic_store_8(volatile void *ptr, uint64_t val, int memorder)
{
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
    *(volatile uint64_t *)ptr = val;
    __atomic_thread_fence(__ATOMIC_SEQ_CST);
}
