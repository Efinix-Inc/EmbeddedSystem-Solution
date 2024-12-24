////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "bsp.h"
#include "device_config.h"
#include "riscv.h"
#include "gpio.h"
#include "clint.h"
#include "plic.h"

#ifdef SIM
    #define LOOP_UDELAY 100
#else
    #define LOOP_UDELAY 100000
#endif

#ifdef SYSTEM_GPIO_0_IO_CTRL
    
    #define GPIO0       SYSTEM_GPIO_0_IO_CTRL

void init();
void main();
void trap();
void crash();
void trap_entry();
void externalInterrupt();

void init(){
    //configure PLIC
    //cpu 0 accept all interrupts with priority above 0
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0); 
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, SYSTEM_PLIC_SYSTEM_GPIO_0_IO_INTERRUPTS_0, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_GPIO_0_IO_INTERRUPTS_0, 1);
    //Enable rising edge interrupts
    gpio_setInterruptRiseEnable(GPIO0, 1); 
    //enable interrupts
    //Set the machine trap vector (../common/trap.S)
    csr_write(mtvec, trap_entry); 
    //Enable external interrupts
    csr_set(mie, MIE_MEIE); 
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

//Called by trap_entry on both exceptions and interrupts events
void trap(){
    int32_t mcause = csr_read(mcause);
    int32_t interrupt = mcause < 0;    //Interrupt if true, exception if false
    int32_t cause     = mcause & 0xF;
    if(interrupt){
        switch(cause){
        case CAUSE_MACHINE_EXTERNAL: externalInterrupt(); break;
        default: crash(); break;
        }
    } else {
        crash();
    }
}

void externalInterrupt(){
    uint32_t claim;
    //While there is pending interrupts
    while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
        switch(claim){
        case SYSTEM_PLIC_SYSTEM_GPIO_0_IO_INTERRUPTS_0: bsp_printf("gpio 0 interrupt routine \r\n"); break;
        default: crash(); break;
        }
        //unmask the claimed interrupt
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim); 
    }
}

//Used on unexpected trap/interrupt codes
void crash(){
    bsp_printf("\r\n*** CRASH ***\r\n");
    while(1);
}

void main() {
    bsp_init();
    bsp_printf("gpio 0 demo ! \r\n");
    bsp_printf("onboard LEDs blinking \r\n");
    //configure 4 bits gpio 0
    gpio_setOutputEnable(GPIO0, 0xe);
    gpio_setOutput(GPIO0, 0x0);
    for (int i=0; i<50; i=i+1) {
        gpio_setOutput(GPIO0, gpio_getOutput(GPIO0) ^ 0xe);
        bsp_uDelay(LOOP_UDELAY);
    }   
    bsp_printf("gpio 0 interrupt demo ! \r\n");
    bsp_printf("Ti375 press and release onboard button sw4 \r\n");
    bsp_printf("Ti180 press and release onboard button sw4 \r\n");
    bsp_printf("Ti60 press and release onboard button sw6 \r\n");
    bsp_printf("T120 press and release onboard button sw7 \r\n");
    init();
    while(1); 
}
#else
void main() {
    bsp_init();
    bsp_printf("gpio 0 is disabled, please enable it to run this app.\r\n");
}
#endif

