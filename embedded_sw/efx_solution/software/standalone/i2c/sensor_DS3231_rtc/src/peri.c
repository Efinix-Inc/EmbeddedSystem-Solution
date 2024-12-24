////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file peri.c

* @brief This file is used for system intialization and interrupt handler. 
*
******************************************************************************/

#include "bsp.h"
#include "device_config.h"
#include "io.h"
#include "i2c.h"
#include "peri.h"

/**************************************************************************INTIALIZATION OF I2C and UART********************************************************************************/

/******************************************************************************
*
* @brief This function initiates the configuration of I2C by setting it to 100kHz. 
*
* @param i2c.samplingClockDivider => Sampling rate = (FCLK/(samplingClockDivider + 1).
* 							   	  => Controls the rate at which the I2C controller samples SCL/SDA.
* @param i2c.timeout => Inactive timeout clock cycle. 
* 				     => Setting the timeout value to zero will disable the timeout feature.
* @param i2c.tsuDat  => Data setup time. 
* @param i2c.tLow    => The number of clock cycles of SCL in LOW state.
* @param i2c.tHigh   => The number of clock cycles of SCL in HIGH state.
* @param i2c.tBuf 	 => The number of clock cycles delay before master can initiate a 
*                       START bit after a STOP bit is issued.
* @return None.
*
******************************************************************************/
void init(){
    // Initial I2C Protocol
    I2c_Config i2c;

    //100kHz
    I2c_Config i2c_mipi;
    int freq = I2C_FREQ;
    i2c_mipi.samplingClockDivider = 3;
    i2c_mipi.timeout = I2C_CTRL_HZ/1000;
    i2c_mipi.tsuDat  = I2C_CTRL_HZ/(I2C_FREQ*5);

    /* T_low & T_high = i2c period / 2  */
    i2c_mipi.tLow  = I2C_CTRL_HZ/(I2C_FREQ*2);
    i2c_mipi.tHigh = I2C_CTRL_HZ/(I2C_FREQ*2);
    i2c_mipi.tBuf  = I2C_CTRL_HZ/(I2C_FREQ);

    i2c_applyConfig(I2C_CTRL, &i2c_mipi);

    Uart_Config uartA;
    uartA.dataLength = BITS_8;
    uartA.parity = NONE;
    uartA.stop = ONE;
    uartA.clockDivider = I2C_CTRL_HZ/(115200*UART_A_SAMPLE_PER_BAUD)-1;
    uart_applyConfig(BSP_UART_TERMINAL, &uartA);

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
    csr_write(mstatus, csr_read(mstatus)| MSTATUS_MPP | MSTATUS_MIE);

}
/***********************************************************************************UART INTERRUPT*************************************************************************************/

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
        // TX FIFO empty interrupt Disable
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) & 0xFFFFFFFE);
        // TX FIFO empty interrupt enable
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x01);
    }
    else if (uart_status_read(BSP_UART_TERMINAL) & 0x00000200){
        // RX FIFO not empty interrupt Disable
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) & 0xFFFFFFFD);
        //Dummy Read Clear FIFO
        char uart_read_data = uart_read(BSP_UART_TERMINAL);
        uart_write(BSP_UART_TERMINAL, uart_read_data);

        if(uart_read_data == '\r'){ //if newline detected
        	new_line_detected = 1;
        	uart_write(BSP_UART_TERMINAL, '\r');
        }
        else{
        	buffer[counter] = uart_read_data;
        	counter++;
        }
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