#include <metal/io.h>
#include <metal/sys.h>
#include <metal/utilities.h>
#include <stdint.h>

#define SSTATUS_SIE  (1UL << 1)

unsigned int sys_irq_save_disable(void)
{
    unsigned long flags;
    __asm__ volatile ("csrrc %0, sstatus, %1"
                      : "=r"(flags) : "r"(SSTATUS_SIE) : "memory");
    return (unsigned int)(flags & SSTATUS_SIE);
}

void sys_irq_restore_enable(unsigned int flags)
{
    if (flags & SSTATUS_SIE) {
        __asm__ volatile ("csrs sstatus, %0" :: "r"(SSTATUS_SIE) : "memory");
    }
}

void sys_irq_enable(unsigned int vector)
{
    metal_unused(vector);
    /* Intentional no-op */
}

void sys_irq_disable(unsigned int vector)
{
    metal_unused(vector);
    /* Intentional no-op */
}

void metal_machine_cache_flush(void *addr, unsigned int len)
{
    metal_unused(addr);
    metal_unused(len);
    /* TODO for Ti375. */
}

void metal_machine_cache_invalidate(void *addr, unsigned int len)
{
    metal_unused(addr);
    metal_unused(len);
    /* TODO for Ti375. */
}

void metal_generic_default_poll(void)
{
    __asm__ volatile ("wfi");
}

void *metal_machine_io_mem_map(void *va, metal_phys_addr_t pa,
                               size_t size, unsigned int flags)
{
    metal_unused(pa);
    metal_unused(size);
    metal_unused(flags);
    /* No MMU */
    return va;
}
