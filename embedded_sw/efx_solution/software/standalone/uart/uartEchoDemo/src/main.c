////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "bsp.h"
#include "device_config.h"

void main() {
    uint8_t dat;

    bsp_init();
    bsp_printf("Uart echo demo ! \r\n");
    bsp_printf("Start typing on terminal to send character... \r\n");
    while(1)
    {
        while(uart_readOccupancy(BSP_UART_TERMINAL)){
            dat=uart_read(BSP_UART_TERMINAL);
            bsp_printf("echo character: %c \r\n", dat);
        }
    }
}
