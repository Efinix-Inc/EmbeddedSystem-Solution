#include <stdint.h>

#include "bsp.h"
#include "gpio.h"
#include "uart.h"

#ifdef SPINAL_SIM
#define LOOP_UDELAY 100
#else
#define LOOP_UDELAY 100000
#endif

u32 axi_slave_read32(u32 address) {
	u32 data;
	data = read_u32(address);
	//temporary workaround
	//data = read_u32(address);
	return data;				
}

void print_hex(uint32_t val, uint32_t digits)
{
    for (int i = (4*digits)-4; i >= 0; i -= 4)
        //uart_write(UART_A, "0123456789ABCDEF"[(val >> i) % 16]);
        uart_write(BSP_UART_TERMINAL, "0123456789ABCDEF"[(val >> i) % 16]);
        uart_write(BSP_UART_TERMINAL, '\n');
        uart_write(BSP_UART_TERMINAL, '\r');
}


void print(uint8_t * data) {
  //uart_writeStr(UART_A, data);
  uart_writeStr(BSP_UART_TERMINAL, data);
}


void main() {
    u32 data;
	bsp_init();

    uart_writeStr(BSP_UART_TERMINAL, "AXI4 Slave Example\n\r");
    gpio_setOutputEnable(BSP_LED_GPIO, BSP_LED_MASK);
    gpio_setOutput(BSP_LED_GPIO, 0x00000000);

    for (int i=0; i < 40 ; i = i +4 ){
    write_u32(i, SYSTEM_AXI_A_BMB + i);
    data = axi_slave_read32(SYSTEM_AXI_A_BMB + i);
    print_hex(data,8);
    bsp_uDelay(LOOP_UDELAY);
    }

    while(1){
        gpio_setOutput(BSP_LED_GPIO, gpio_getOutput(BSP_LED_GPIO) ^ BSP_LED_MASK);
        bsp_uDelay(LOOP_UDELAY);
    }
}

