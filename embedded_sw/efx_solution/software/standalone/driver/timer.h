////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#pragma once

#include "type.h"
#include "io.h"

#define TIMER_CONFIG    0x00
#define TIMER_LIMIT     0x04
#define TIMER_VALUE     0x08


    readReg_u32 (timer_getConfig       , TIMER_CONFIG)
    writeReg_u32(timer_setConfig       , TIMER_CONFIG)
    
    readReg_u32 (timer_getLimit        , TIMER_LIMIT)
    writeReg_u32(timer_setLimit        , TIMER_LIMIT)
    
    readReg_u32 (timer_getValue        , TIMER_VALUE)
    
    void timer_clearValue(u32 reg){
        write_u32(0, reg + TIMER_VALUE);
    }
