////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file peri.h
*
* @brief Header file contain function prototype for interrupt handler and some
*		 parameter that used for RTCDriver_DS3231.
*
*
******************************************************************************/
#include "riscv.h"
#include "plic.h"
#include "clint.h"
#include "bsp.h"
#include "device_config.h"

#define I2C_CTRL_HZ     		SYSTEM_CLINT_HZ
#define I2C_CTRL				RTC_I2C_BASE_ADDR
#define UART_A_SAMPLE_PER_BAUD 	8
#define UART_DECIMAL_OFFSET     48


#include "device/ds3231.h"

//Global Variables
extern char 		new_line_detected		;
extern uint32_t		counter 				;
extern uint8_t 		buffer [200]			;

//User Defined
#define I2C_FREQ                100000 	//100kHz
#define ENABLE_MAIN_MENU        1 		//Disable main menu at default



//String for RTC Demo
#define  LAUNCH_STRING 		"*****************************************  \r\n\n" \
						"	RTCC i2c Configuration Demo 			\r\n\n"
#define  SELECT_STRING	"*****************************************  \r\n" \
						"Please key in the selection and press enter: \r\n" \
						"1: Check Time 2: Check Alarm 3: Configure Time\r\n" \
						"4: Set Alarm  5: Disable/Reset Alarm \r\n" \
						"6: Change TimeSystem (12/24hrs)\r\n" \
						"*****************************************  \r\n\n"
#define Alarm_mode_string 	" Available Alarm 1 Mode \r\n" \
							" Mode 1 - Trigger every second \r\n" \
							" Mode 2 - Trigger every minute whens seconds match  \r\n" \
							" Mode 3 - Trigger every hour when minutes and seconds match  \r\n" \
							" Mode 4 - Trigger once per day when hours, minutes and seconds match  \r\n" \
							" Mode 5 - Trigger alarm when date (day of month), hours, minutes and seconds match  \r\n" \
							" Mode 6 - Trigger when day (day of week), hours, minutes and seconds match  \r\n \n" 
#define demo_mode_string    " In this demo, Alarm 1 Mode is fix to TRIGGER every minute when seconds match\r\n\r\n "

#define INVALID_ADDR_STRING	"Invalid address input,returning to previous line\r\n"

    
//Function prototype
void trap_entry();
void trap();
void crash();
void UartInterrupt();
void init();

typedef enum {
	IDLE,
	CONFIGURATION,
	GET_WRITE_DATA
} states;
