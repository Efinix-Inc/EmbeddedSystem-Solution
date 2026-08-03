#ifndef SBI_H_
#define SBI_H_

#include <stdint.h>

struct sbiret {
    long error;
    long value;
};

#define LINUX_BOOT_HARTID    0

static inline void sbi_send_ipi(const unsigned long *hart_mask)
{
    register unsigned long a0 asm("a0") = (unsigned long)hart_mask;
    register unsigned long a7 asm("a7") = 4;
    asm volatile ("ecall" : "+r"(a0) : "r"(a7) : "memory");
}

static inline struct sbiret sbi_hart_stop(void)
{
    struct sbiret ret;
    register unsigned long a0 asm("a0");
    register unsigned long a1 asm("a1");
    register unsigned long a6 asm("a6") = 1;
    register unsigned long a7 asm("a7") = 0x48534D;
    asm volatile ("ecall"
                  : "=r"(a0), "=r"(a1)
                  : "r"(a6), "r"(a7)
                  : "memory");
    ret.error = (long)a0;
    ret.value = (long)a1;
    return ret;
}

#endif /* BI_H_ */
