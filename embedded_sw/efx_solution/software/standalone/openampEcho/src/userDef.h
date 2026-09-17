////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSocRV64/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#ifndef SRC_USERDEF_H_
#define SRC_USERDEF_H_

#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------------*/
/* User Configuration
/* -----------------------------------------------------------------------------**/

/* -----------------------------------------------------------------------------*/
/*  USER DEBUG CONFIGURATION
/* -----------------------------------------------------------------------------*/
// --- DEBUG_MODE ---
    // 0 = Asserts OFF, Logs removed
    // 1 = Asserts ON, Logs filtered
#define DEBUG_MODE 1
// --- ACTIVE_DEBUG_MOD --- This is the list of available module to debug
    // DBG_MOD_SYS          // Enable Log for RISCV Extension
    // DBG_MOD_IRQ          // Enable Log for IRQ, mtrap
    // DBG_MOD_FAULT        // Enable Log for System Fault
    // DBG_MOD_UART         // Enable Log for UART Driver
    // DBG_MOD_I2C          // Enable Log for I2C Driver
    // DBG_MOD_SPI          // Enable Log for SPI Driver
    // DBG_MOD_SPI_FLASH    // Enable Log for SPI FLASH Driver
    // DBG_MOD_RTC          // Enable Log for RTC Driver
    // DBG_MOD_CAM          // Enable Log for CAM Driver
    // DBG_MOD_SENSOR       // Enable Log for Sensor (temp sensor)
    // DBG_MOD_MAIN         // Enable Log for main.c
    // DBG_MOD_ALL          // Enable all Logs
#define ACTIVE_DEBUG_MOD   DBG_MOD_ALL

// --- ACTIVE_MIN_LVL ---
    // DBG_LVL_ALL     0   // Show Info, Warn, Error
    // DBG_LVL_WARN    1   // Show Warn, Error
    // DBG_LVL_ERR     2   // Show Error only
    // DBG_LVL_NONE    3   // Silence
#define ACTIVE_MIN_LVL   DBG_LVL_WARN


#ifdef __cplusplus
}
#endif // C_plusplus

#endif /* SRC_USERDEF_H_ */
