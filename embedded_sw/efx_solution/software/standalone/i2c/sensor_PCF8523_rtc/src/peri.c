////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file peri.c

* @brief This file is used for system intialization and interrupt handler. 
*
* The available functions are:
* - peri_init        : Initiates the configuration of UART.
* - i2c_init         : Initiates the configuration of I2C.
* - RTC_init         : Initiates battery switch-over and battery low detection 
*                      function and it also check battery information.  
* - uartIsr()	     : Handles UART interrupt sub-events such as TX FIFO
*		               empty interrupt and RX FIFO not empty interrupt.
* - isrRoutine()     : Handles UART interrupts by claiming pending interrupts
* 		               and processing them through UartInterrupt_Sub().
* - crash            : Handles the system crash scenario by printing a crash 
* 		               message and entering an infinite loop.
* - trap             : Handles exceptions and interrupts in the system.
*
******************************************************************************/

#include "bsp.h"
#include "device_config.h"
#include "io.h"
#include "i2c.h"
#include "peri.h"
#include "plic.h"

/******************************** System Initialization  ***********************************************/



/******************************************************************************
*
* @brief This function initiates the configuration of UART.

* @param uartA.dataLength 		=> Enumerated value indicating the data length configuration.
* @param uartA.parity 			=> Enumerated value indicating the parity configuration.
* @param uartA.stop				=> Enumerated value indicating the stop bit configuration.
* @param uartA.clockDivider		=> Clock divider value for UART communication.
* @return None.
*
******************************************************************************/
void peri_init() {
	//int notInterrupt_count = 0;
	Uart_Config uartA;
	uartA.dataLength = BITS_8;
	uartA.parity = NONE;
	uartA.stop = ONE;
	uartA.clockDivider = BSP_CLINT_HZ / (115200 * UART_0_SAMPLE_PER_BAUD) - 1;
	uart_applyConfig(BSP_UART_TERMINAL, &uartA);

    // RX FIFO not empty interrupt enable
    uart_RX_NotemptyInterruptEna(BSP_UART_TERMINAL,1);

    // Configure PLIC
    // Cpu 0 accept all interrupts with priority above 0
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);

    // Enable SYSTEM_PLIC_USER_INTERRUPT_A_INTERRUPT rising edge interrupt
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT, 1);

    // Enable interrupts
    // Set the machine trap vector (../common/trap.S)
    csr_write(mtvec, trap_entry);
    // Enable external interrupts
    csr_set(mie, MIE_MEIE);
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

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
void i2c_init() {

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
}

/******************************************************************************
*
* @brief This function initiates battery switch-over and battery low detection 
*        function and it also check battery information.  
*
* @return None.
*
******************************************************************************/
void Rtc_init() {
	bsp_printf("Welcome to RTC Demo for Ti375C529\r\n\n");
	bsp_printf("************START OF SYSTEM INITIALIZATION************\r\n");

	//Checking control register
	bsp_printf("\r\nChecking CR information now ! \r\n");
	readCR_RTC();

	//Enable battery switch-over and battery low detection function
    bsp_printf("\r\nEnable battery switch-over!\r\nEnable battery low detection function! \r\n");
	battery_mode_RTC(3);

	//Checking battery information
    bsp_printf("\r\nChecking battery information now ! \r\n");
    print_battery_status_RTC();
    bsp_printf("*************END OF SYSTEM INITIALIZATION*************\r\n\n\n");

#if (ENABLE_MAIN_MENU)
	bsp_printf(SELECT_STRING);
#else
	bsp_printf("Showing time data now!\r\n");
#endif


}

/******************************** Interrupt Handler  ***********************************************/

/******************************************************************************
*
* @brief This function handles UART interrupt sub-events such as TX FIFO 
*		 empty interrupt and RX FIFO not empty interrupt.
*
******************************************************************************/
void uartIsr()
{
    if (uart_status_read(BSP_UART_TERMINAL) & 0x00000100){

    	// Disable TX FIFO empty interrupt
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) & 0xFFFFFFFE);
        // Enable TX FIFO empty interrupt
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x01);

    }
    else if (uart_status_read(BSP_UART_TERMINAL) & 0x00000200){

    	// Disable RX FIFO not empty interrupt
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) & 0xFFFFFFFD);
        // Read to clear RX FIFO
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
        // Enable RX FIFO not empty interrupt
        uart_status_write(BSP_UART_TERMINAL,uart_status_read(BSP_UART_TERMINAL) | 0x02);

    }
}

/******************************************************************************
*
* @brief This function handles UART interrupts by claiming pending interrupts 
* 		 and processing them through uartIsr().
*
******************************************************************************/
void isrRoutine()
{
    uint32_t claim;
    // While there is pending interrupts
    while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
        switch(claim){
        case SYSTEM_PLIC_SYSTEM_UART_0_IO_INTERRUPT: uartIsr(); break;
        default: crash(); break;
        }
        // Unmask the claimed interrupt
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
    }
}

/******************************************************************************
*
* @brief This function handles the system crash scenario by printing a crash 
* 		 message and entering an infinite loop.
*
******************************************************************************/
void crash(){
    bsp_printf("\r\n*** CRASH ***\r\n");
    while(1);
}

/******************************************************************************
*
* @brief This function handles exceptions and interrupts in the system.
*
* @note It is called by the trap_entry function on both exceptions and interrupts 
* 		events. If the cause of the trap is an interrupt, it checks the cause of 
* 		the interrupt and calls corresponding interrupt handler functions. If 
* 		the cause is an exception or an unhandled interrupt, it calls a 
*		crash function to handle the error.
*
******************************************************************************/
void trap(){
    int32_t mcause = csr_read(mcause);
    // Interrupt if true, exception if false
    int32_t interrupt = mcause < 0;
    int32_t cause     = mcause & 0xF;

    if(interrupt){
        switch(cause){
        case CAUSE_MACHINE_EXTERNAL: isrRoutine(); break;
        default: crash(); break;
        }
    } else {
        crash();
    }
}
