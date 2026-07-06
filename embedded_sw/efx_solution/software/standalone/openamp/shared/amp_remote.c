////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>

#include "bsp.h"
#include "riscv.h"

#include "openamp/open_amp.h"
#include "openamp_transport.h"
#include "shm_layout.h"
#include "amp_rsc_table.h"
#include "amp_trap.h"
#include "amp_remote.h"

#ifndef AMP_OPENAMP_INIT_TIMEOUT_MS
#define AMP_OPENAMP_INIT_TIMEOUT_MS 5000
#endif

static void print_efinix_logo(void)
{
    bsp_printf("\n");
    bsp_printf("EEEEEEE  FFFFFFF  IIIII  NN   NN  IIIII  XX   XX\r\n");
    bsp_printf("EE       FF         I    NNN  NN    I     XX XX\r\n");
    bsp_printf("EEEEE    FFFFF      I    NN N NN    I      XXX\r\n");
    bsp_printf("EE       FF         I    NN  NNN    I     XX XX\r\n");
    bsp_printf("EEEEEEE  FF       IIIII  NN   NN  IIIII  XX   XX\r\n");
    bsp_printf("\n");
    bsp_printf("FPGA Acceleration | RISC-V | OpenAMP\r\n");
    bsp_printf("------------------------------------------\r\n");
    bsp_printf("\n");
}

struct rpmsg_device *amp_remote_bringup(void)
{
    bsp_init();

    /* Enable trap handler for S-Mode */
    csr_write(stvec, trap_entry);
    csr_set(sie, 0x2);
    csr_set(sstatus, 0x2);

    print_efinix_logo();
    bsp_printf("BareMetal: SHM_BASE        = %x\r\n", (unsigned)SHM_BASE);
    bsp_printf("BareMetal: SHM_RSC_ADDR    = %x\r\n", (unsigned)SHM_RSC_ADDR);
    bsp_printf("BareMetal: SHM_VRING0_ADDR = %x\r\n", (unsigned)SHM_VRING0_ADDR);
    bsp_printf("BareMetal: SHM_VRING1_ADDR = %x\r\n", (unsigned)SHM_VRING1_ADDR);

    amp_publish_rsc_table();

    *(volatile uint32_t *)SHM_REMOTE_READY_ADDR = REMOTE_READY_MAGIC;
    __asm__ volatile ("fence rw, rw" ::: "memory");

    bsp_printf("BareMetal: resource table published\r\n");

    return openamp_init(AMP_OPENAMP_INIT_TIMEOUT_MS);
}
