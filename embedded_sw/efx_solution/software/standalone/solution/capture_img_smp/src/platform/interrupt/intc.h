////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef HEADER_INTC_H_
#define HEADER_INTC_H_

#include <stdint.h>
#include "bsp.h"
#include "device_config.h"
#include "userDef.h"
#include "plic.h"
#include "riscv.h"
#include "efx_mmc_driver.h"
#include "evsoc.h"

void IntcInitialize();


// Hart 1 State
#define IDLE   0
#define INIT   1
#define STREAM 2
#define RESET  3

extern u32 evsoc_reset_f;
extern u32 h1_state;
extern u32 h2_state;
#endif
