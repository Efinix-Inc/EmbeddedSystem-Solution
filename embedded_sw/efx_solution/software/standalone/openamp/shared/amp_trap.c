////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>

#include "bsp.h"
#include "riscv.h"

#include "sbi.h"
#include "shm_layout.h"
#include "openamp_transport.h"
#include "amp_trap.h"

#define MCAUSE_INT_BIT      0x80000000UL
#define MCAUSE_MSIP         3UL
#define MCAUSE_MSIP_FULL    (MCAUSE_INT_BIT | MCAUSE_MSIP)

#define S_SOFTWARE_INTERRUPT 1

void trap(void)
{
    uint32_t scause_val = csr_read(scause);
    uint32_t sepc_val   = csr_read(sepc);
    volatile uint32_t *ctrl_msg = (volatile uint32_t *)SHM_LINUX_CTRL_ADDR;

    (void)sepc_val;

    if ((int32_t)scause_val < 0) {
        uint32_t cause = scause_val & 0x7FFFFFFF;

        switch (cause) {
            case S_SOFTWARE_INTERRUPT:
                csr_clear(sip, 0x2);

                /* Linux req shutdown */
                if (*ctrl_msg == 0xFF00FF00) {
                    sbi_hart_stop();

                    /* Should never reach here */
                    while (1)
                        __asm__ __volatile__ ("wfi" : : : "memory");
                    break;
                }
                openamp_notified();
                break;
            default:
                bsp_printf("Hart 3: Other Interrupt: %d \r\n", cause);
                break;
        }
    }
}
