////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file peri.h
*
* @brief Header file contain function prototype for interrupt handler and some
*		 parameter that used for RTCDriver_C529Demo.
*
*
******************************************************************************/
#include "riscv.h"
#include "plic.h"
#include "clint.h"
#include "device_config.h"

#define I2C_CTRL_HZ     		SYSTEM_CLINT_HZ
#define I2C_CTRL				RTC_I2C_BASE_ADDR
#define UART_0_SAMPLE_PER_BAUD 	8
#define UART_DECIMAL_OFFSET 	48

#include "device/pcf8523.h"

//Global Variables
extern char 		new_line_detected		;
extern uint32_t		counter 				;
extern uint8_t 		buffer [200]			;

//User Defined
#define I2C_FREQ          100000 	//100kHz
#define	DEBUG_MODE		  0			//Enable Debug Mode for detail printing
#define ENABLE_MAIN_MENU  1 		//Enable main menu at default

//Main Menu Strings
#define  	SELECT_STRING	"************Rtc Demo Main Menu***************  \r\n" \
							"Please key in the selection and press enter: \r\n" \
							"1: Check Time 2: Check Alarm 3: Configure Time\r\n" \
							"4: Set Alarm  5: Disable/Reset Alarm \r\n" \
							"6: Change TimeSystem (12/24hrs)\r\n" \
							"7: Change Battery mode \r\n" \
							"8: Check Battery information \r\n" \
							"9: Soft Reset on RTC module \r\n" \
							"*****************************************  \r\n\n"

//Structure for RTCdemo
typedef enum {
	IDLE,
	CONFIGURATION,
	GET_WRITE_DATA
}  states;


extern states state ; 

//Function prototype
void crash();
void trap();
void trap_entry();
void uartIsr();
void isrRoutine();
void i2c_init();
void peri_init();
void Rtc_init();

