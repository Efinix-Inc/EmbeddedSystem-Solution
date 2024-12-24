////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "plic.h"
#include "clint.h"
#include "bsp.h"
#include "device_config.h"
#include "riscv.h"

void init();
void main();
void trap();
void crash();
void trap_entry();
void UartInterrupt();

#define UART_A_SAMPLE_PER_BAUD 8
#define CORE_HZ BSP_CLINT_HZ

void init(){
    // TX FIFO empty interrupt enable
    //uart_TX_emptyInterruptEna(BSP_UART_TERMINAL,1);   
    
    // RX FIFO not empty interrupt enable
    uart_RX_NotemptyInterruptEna(BSP_UART_TERMINAL,1);  

    //configure PLIC
    //cpu 0 accept all interrupts with priority above 0
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0); 

    //enable SYSTEM_PLIC_USER_INTERRUPT_A_INTERRUPT rising edge interrupt
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT, 1);

    //enable interrupts
    csr_write(mtvec, trap_entry); //Set the machine trap vector (../common/trap.S)
    csr_set(mie, MIE_MEIE); //Enable external interrupts
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

//Called by trap_entry on both exceptions and interrupts events
void trap(){
    int32_t mcause = csr_read(mcause);
    //Interrupt if set, exception if cleared
    int32_t interrupt = mcause < 0;    
    int32_t cause     = mcause & 0xF;

    if(interrupt){
        switch(cause){
        case CAUSE_MACHINE_EXTERNAL: UartInterrupt(); break;
        default: crash(); break;
        }
    } else {
        crash();
    }
}

void UartInterrupt_Sub()
{
    if (uart_status_read(BSP_UART_TERMINAL) & 0x00000100){
        
        bsp_printf("\nuart 0 tx fifo empty interrupt routine \r\n");
        // TX FIFO empty interrupt Disable
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) & 0xFFFFFFFE);  
        // TX FIFO empty interrupt enable
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x01); 
    }
    else if (uart_status_read(BSP_UART_TERMINAL) & 0x00000200){

        bsp_printf("\nuart 0 rx fifo not empty interrupt routine \r\n");
        // RX FIFO not empty interrupt Disable
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) & 0xFFFFFFFD);          
        //Dummy Read Clear FIFO
        uart_write(BSP_UART_TERMINAL, uart_read(BSP_UART_TERMINAL));    
        // RX FIFO not empty interrupt enable
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x02);                    
    }
}

void UartInterrupt()
{

    uint32_t claim;
    //While there is pending interrupts
    while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
        switch(claim){
        case SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT: UartInterrupt_Sub(); break;
        default: crash(); break;
        }
        //unmask the claimed interrupt
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim); 
    }
}

void crash(){
    bsp_printf("\r\n*** CRASH ***\r\n");
    while(1);
}

void main() {
	bsp_init();
    init();
    bsp_printf("uart 0 interrupt demo ! \r\n");
    bsp_printf("start typing on terminal to interrupt uart... \r\n");
    while(1){
        while(uart_readOccupancy(BSP_UART_TERMINAL)){
            uart_write(BSP_UART_TERMINAL, uart_read(BSP_UART_TERMINAL));
        }
    }
}


