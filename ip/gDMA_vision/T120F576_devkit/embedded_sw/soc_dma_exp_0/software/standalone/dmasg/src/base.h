#pragma once

//#include "gpio.h"
#include "uart.h"
#include "bsp.h"
#include "base.h"



/************************** Function File ***************************/
void usleep(u32 usec)
{
    bsp_uDelay(usec);
}

/************************** Function File ***************************/
void StrPrintf(char* str)
{
    uart_writeStr(SYSTEM_UART_0_IO_CTRL,str);
}

void print_hex(uint32_t val, uint32_t digits)
{
    for (int i = (4*digits)-4; i >= 0; i -= 4)
        //uart_write(UART_A, "0123456789ABCDEF"[(val >> i) % 16]);
        uart_write(BSP_UART_TERMINAL, "0123456789ABCDEF"[(val >> i) % 16]);
        uart_write(BSP_UART_TERMINAL, '\n');
        uart_write(BSP_UART_TERMINAL, '\r');
}
