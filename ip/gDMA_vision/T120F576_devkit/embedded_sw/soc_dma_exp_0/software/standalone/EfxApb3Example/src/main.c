#include <stdint.h>

#include "bsp.h"
#include "gpio.h"
#include "uart.h"
#include "apb3_cl.h"

#ifdef SPINAL_SIM
#define LOOP_UDELAY 100
#else
#define LOOP_UDELAY 100000
#endif

void main() {
    struct example_apb3_ctrl_reg cfg={0};
    bsp_init();

    gpio_setOutputEnable(BSP_LED_GPIO, BSP_LED_MASK);
    gpio_setOutput(BSP_LED_GPIO, 0x00000000);

    uart_writeStr(BSP_UART_TERMINAL, "Enabling Memory Checker\n\r");
    cfg.exampleLED = 1;
    cfg.exampleMemoryStart = 1; 
    example_register_write(&cfg);

    while(1){
        gpio_setOutput(BSP_LED_GPIO, gpio_getOutput(BSP_LED_GPIO) ^ BSP_LED_MASK);
        bsp_uDelay(LOOP_UDELAY);
    }
}

