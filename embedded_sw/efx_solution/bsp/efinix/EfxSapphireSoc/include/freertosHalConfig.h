#pragma once
#include "bsp.h"

#define PLIC_MACHINE_TIMER_ID           SYSTEM_PLIC_SYSTEM_CORES_0_EXTERNAL_INTERRUPT
#define configMTIME_BASE_ADDRESS        (BSP_CLINT + 0xBFF8)
#define configMTIMECMP_BASE_ADDRESS     (BSP_CLINT + 0x4000)
#define configCPU_CLOCK_HZ              ( ( uint64_t ) ( BSP_CLINT_HZ ) )