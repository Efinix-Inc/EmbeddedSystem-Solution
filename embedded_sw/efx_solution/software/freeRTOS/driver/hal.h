////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef HAL_H_
#define HAL_H_

#include "FreeRTOS.h"
#include "task.h"
#include "portmacro.h"
#include "bsp.h"
#include "device_config.h"
#include "plic.h"



    void freertos_risc_v_application_interrupt_handler(void){
        uint32_t claim;
        while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
            switch(claim){
    	    //	case YOUR_INTERRUPT_ID:
    	    //  ...
    	    //  break;
            }
            plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim); //unmask the claimed interrupt
        }
    }

#endif
