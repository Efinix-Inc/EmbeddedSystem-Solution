////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file main.c: rtcDemo 
*
* @brief This demo uses the I2C peripheral to communicate with on-board PCF8523 RTC module
* 		 on Ti375C529. It allows user to change various configuration such as real-time data 
*		 with convertible 12/24hr time system, alarm, battery setting of the PCF8523 module
*		 if ENABLE_MAIN_MENU is set to 1 in peri.h else it will print the real-time data every 
*		 few seconds.
*
* @note To run this example design, please make sure the following requirements are fulfilled:
* 		1. Ti375C529 Dev Board
* 		2. Enable UART0 and I2C1
*
*		User are allowed to configure certain parameters in peri.h (User defined Section)
*		1. I2C_FREQ 		=> Frequency of I2C, default set to 100kHz
*		2. DEBUG_MODE		=> Print detail info for debug purpose if enabled.
*		3. ENABLE_MAIN_MENU => Allow user to select various configuration if enabled.
*
******************************************************************************/

#include <stdint.h>
#include "bsp.h"
#include "device_config.h"
#include "io.h"
#include <stdlib.h>
#include "stdbool.h"
#include "i2c.h"

//RTC Driver
#include "peri.h"

//Global variable							
char 			new_line_detected		= 0;
uint32_t		counter 				= 0;
uint8_t 		buffer [200];

#ifdef RTC_PCF8523_SUPPORT
#ifdef I2C_CTRL


void main() {
	//Initialization
	peri_init();
	i2c_init();
	Rtc_init();
	time_data myConfig; //Initialize timedata struct
	uint8_t TIME_CONFIG = 0;
	uint8_t stopper = 0;
	states state = IDLE;
	while (1) {

#if(!ENABLE_MAIN_MENU) //Disable main menu to print real-time data every few seconds. 
		getdata(&myConfig);
		bsp_printf("%d/%d/20%s%d \r\n", get_days(&myConfig),
				get_months(&myConfig), (get_years(&myConfig)<10)? "0" : "",get_years(&myConfig));
		bsp_printf("%s,%d%s %s 20%s%d\r\n",
				DayStrings[get_weekdays(&myConfig) - 1], get_days(&myConfig),
				get_days_ordinalno(&myConfig),
				MonthStrings[get_months(&myConfig) - 1], (get_years(&myConfig)<10)? "0" : "",get_years(&myConfig));
		if (myConfig.timesystem == 1){
			//12 hour time system is selected.
			bsp_printf("Current Time: %d:%s%d:%s%d%s  \r\n\n",
					get_hours(&myConfig),
					(get_minutes(&myConfig) < 10) ? "0" : "",
					get_minutes(&myConfig),
					(get_seconds(&myConfig) < 10) ? "0" : "",
					get_seconds(&myConfig),
					(myConfig.PM) ? (meridiem[1]) : (meridiem[0]));
		}
		else{
			// 24 hour time system is selected
			bsp_printf("Current Time: %d:%s%d:%s%d  \r\n\n",
					get_hours(&myConfig),
					(get_minutes(&myConfig) < 10) ? "0" : "",
					get_minutes(&myConfig),
					(get_seconds(&myConfig) < 10) ? "0" : "",
					get_seconds(&myConfig));
		}
		for (uint32_t i = 0; i < SYSTEM_CLINT_HZ; i++)
			asm("nop"); //Show data every few seconds
	}
}

#else //Enable main menu for configuring time, etc
		switch (state) {
		case IDLE: //idle case wait for input to be 1 or 2
#if(!DEBUG_MODE)
			if ((checkalarmStatus() & !stopper)) { //Checking Alarm status when IDLE
				bsp_printf("Alarm 1 is triggered! \r\n");
				stopper = 1;
			}
#endif						
			if (new_line_detected) {
				if (buffer[0] == '1' && counter == 1) { //Check Time
					getdata(&myConfig);
					bsp_printf("Showing current time now...\r\n");
					bsp_printf("%d/%d/20%s%d \r\n", get_days(&myConfig),
							get_months(&myConfig),
							(get_years(&myConfig) < 10) ? "0" : "",
							get_years(&myConfig));
					bsp_printf("%s,%d%s %s 20%s%d\r\n",
							DayStrings[get_weekdays(&myConfig) - 1],
							get_days(&myConfig), get_days_ordinalno(&myConfig),
							MonthStrings[get_months(&myConfig) - 1],
							(get_years(&myConfig) < 10) ? "0" : "",
							get_years(&myConfig));
					if (myConfig.timesystem) {
						//12 hour time system is selected.
						bsp_printf("Current Time: %d:%s%d:%s%d%s  \r\n\n",
								get_hours(&myConfig),
								(get_minutes(&myConfig) < 10) ? "0" : "",
								get_minutes(&myConfig),
								(get_seconds(&myConfig) < 10) ? "0" : "",
								get_seconds(&myConfig),
								(myConfig.PM) ? (meridiem[1]) : (meridiem[0]));

					} else { // 24 hour time system is selected
						bsp_printf("Current Time: %d:%s%d:%s%d  \r\n\n",
								get_hours(&myConfig),
								(get_minutes(&myConfig) < 10) ? "0" : "",
								get_minutes(&myConfig),
								(get_seconds(&myConfig) < 10) ? "0" : "",
								get_seconds(&myConfig));
					}
					bsp_printf(SELECT_STRING);
					state = IDLE;
				} else if (buffer[0] == '2' && counter == 1) { //Check Alarm Status
					getdata(&myConfig);
					bsp_printf("Showing alarm status now...\r\n");
					uint8_t alarm_status = checkalarmStatus();
					if (alarm_status == 2)
						bsp_printf("Alarm STATUS: Alarm is disabled! \r\n");
					else {
						if (alarm_status == 0)
							bsp_printf(
									"Alarm STATUS: No Alarm is triggered! \r\n");
						if (alarm_status)
							bsp_printf(
									"Alarm STATUS: Alarm is triggered! \r\n");
						bsp_printf(
								"Alarm TRIGGERED CONDITION: Triggered when the time is %d:%s%d%s,%s,%d/%d/20%s%d\r\n",
								myConfig.AL_hours,
								(myConfig.AL_minutes < 10) ? "0" : "",
								myConfig.AL_minutes,
								myConfig.timesystem ?
										((myConfig.AL_status) ?
												(meridiem[1]) : (meridiem[0])) :
										"",
								DayStrings[myConfig.AL_weekdays - 1],
								myConfig.AL_days, myConfig.months,(myConfig.years<10)? "0" : "",
								myConfig.years);
					}
					bsp_printf("Back to main menu...\r\n\n");
					bsp_printf(SELECT_STRING);
					state = IDLE;

				} else if (buffer[0] == '3' && counter == 1) { //Configure Time
					bsp_printf(
							"Default setting: 24hr TimeSystem\r\nConfiguring Time...\r\n");
					bsp_printf("Press enter to start configure\n\r");
					state = CONFIGURATION;
					TIME_CONFIG = 1;

				} else if (buffer[0] == '4' && counter == 1) { //Configure Alarm
					bsp_printf("Configuring Alarm...\r\n");
					bsp_printf("Press enter to start configure\n\r");
					state = CONFIGURATION;
					TIME_CONFIG = 2;

				} else if (buffer[0] == '5' && counter == 1) { //Enable/reset
					bsp_printf("Disable/reset Alarm...\r\n");
					bsp_printf("Press enter to start configure\n\r");
					state = CONFIGURATION;
					TIME_CONFIG = 3;
				}

				else if (buffer[0] == '6' && counter == 1) { //Change Time System
					bsp_printf("Changing TimeSystem...\r\n");
					bsp_printf("Press enter to start configure\n\r");
					state = CONFIGURATION;
					TIME_CONFIG = 4;
				}

				else if (buffer[0] == '7' && counter == 1) { //Change Battery Mode
					bsp_printf("Changing battery mode..\r\n");
					bsp_printf("Press enter to start configure\n\r");
					state = CONFIGURATION;
					TIME_CONFIG = 5;
				} else if (buffer[0] == '8' && counter == 1) { //Checking battery information
					bsp_printf("\r\nChecking battery information now ! \r\n");
					print_battery_status_RTC();
					bsp_printf(SELECT_STRING);
					state = IDLE;
				} else if (buffer[0] == '9' && counter == 1) { //Checking battery information
					bsp_printf("\r\nReseting now! \r\n");
					bsp_printf(
							"\r\nPlease reconfigure the time if needed! \r\n");
					RTC_softreset();
					bsp_printf("Done! \r\n");
					bsp_printf(SELECT_STRING);
					state = IDLE;
				} else {
					bsp_printf("Invalid input. Please try again...\r\r\n");
					bsp_printf(SELECT_STRING);
					state = IDLE;
				}
				new_line_detected = 0;
				counter = 0;
			}
			break;
		case CONFIGURATION: //check if the input location is correct
			if (new_line_detected) {

				if (TIME_CONFIG == 1) {
					bsp_printf(
							"Day of week\r\n1.Sunday\r\n2.Monday\r\n3.Tuesday\r\n4.Wednesday\r\n5.Thursday\r\n6.Friday\r\n7.Saturday\r\n");
					bsp_printf("Please set the value in 24hr time system.\r\n");
					bsp_printf(
							"\r\nEnter value for time(h m s) and Day of week,days,month,year such as 14 20 00 1 16 10 23\
							that represent to 14:20 Sunday,16/10/2023 \r\n");
					state = GET_WRITE_DATA;
				}

				else if (TIME_CONFIG == 2) {
					bsp_printf("Please set the value in 24hr time system.\r\n");
					bsp_printf(
							"\r\nEnter value for time(h m day weekday) such as 14 20 08 6 that represent to 14:20 Day 8,Friday \r\n");
					state = GET_WRITE_DATA;
				}

				else if (TIME_CONFIG == 3) {
					bsp_printf("Press 0 and enter to back to main menu\r\n");
					bsp_printf("Press 1 and enter to disable Alarm\r\n");
					bsp_printf("Press 2 and enter to reset Alarm\r\n");
					state = GET_WRITE_DATA;
				}

				else if (TIME_CONFIG == 4) {
					bsp_printf("Press 0 for 24hr TimeSystem \r\n");
					bsp_printf("Press 1 for 12hr TimeSystem \r\n");
					state = GET_WRITE_DATA;
				}

				else if (TIME_CONFIG == 5) {
					bsp_printf(BATTERY_STRING);
					state = GET_WRITE_DATA;
				}
			}
			new_line_detected = 0;
			counter = 0;
			break;
		case GET_WRITE_DATA:
			if (new_line_detected) { //Setting up temporary variable for user input value
				uint8_t error = 0;
				time_data temp;
				temp.hours = (buffer[0] - UART_DECIMAL_OFFSET) * 10
						+ (buffer[1] - UART_DECIMAL_OFFSET);
				temp.minutes = (buffer[3] - UART_DECIMAL_OFFSET) * 10
						+ (buffer[4] - UART_DECIMAL_OFFSET);
				temp.seconds = (buffer[6] - UART_DECIMAL_OFFSET) * 10
						+ (buffer[7] - UART_DECIMAL_OFFSET);
				temp.weekdays = (buffer[9] - UART_DECIMAL_OFFSET);
				temp.days = (buffer[11] - UART_DECIMAL_OFFSET) * 10
						+ (buffer[12] - UART_DECIMAL_OFFSET);
				temp.months = (buffer[14] - UART_DECIMAL_OFFSET) * 10
						+ (buffer[15] - UART_DECIMAL_OFFSET);
				temp.years = (buffer[17] - UART_DECIMAL_OFFSET) * 10
						+ (buffer[18] - UART_DECIMAL_OFFSET);
				temp.AL_status = (buffer[0] - UART_DECIMAL_OFFSET);

				switch (TIME_CONFIG) {

				case 0:
					state = IDLE;
					break;

				case 1: //Checking input for any error on Time Configuration
					error = check_month_error(temp.months, temp.days,
							temp.years);
					if ((temp.hours > 23) | (temp.minutes > 59)
							| (temp.seconds > 59) | (temp.weekdays < 1)
							| (temp.weekdays > 7) | (temp.months > 12)
							| (temp.days < 1) | (temp.months < 1) | (error)) {
						bsp_printf("Invalid input, please try again\r\n");
						state = GET_WRITE_DATA;
						break;
					} else {

						bsp_printf("\n(24hour System) Time set to %d:%d:%d\r\n",
								temp.hours, temp.minutes, temp.seconds);
						bsp_printf("%s,%d %s 20%s%d\r\n",
								DayStrings[temp.weekdays - 1], temp.days,
								MonthStrings[temp.months - 1], (temp.years<10)? "0" : "", temp.years);
						bsp_printf("Back to main menu\r\n");
						bsp_printf(SELECT_STRING);
						set_timesystem(0);
						set_datetime(temp.seconds, temp.minutes, temp.hours,
								temp.weekdays, temp.days, temp.months,
								temp.years);
						TIME_CONFIG = 0;
						bsp_printf(SELECT_STRING);
						state = IDLE;
						break;
					}
				case 2: //Checking input for any error on Alarm Configuration
					if ((temp.hours > 23) | (temp.minutes > 59)
							| (temp.days < 1) | (temp.weekdays > 7)) {
						bsp_printf("Invalid input, please try again\r\n");
						state = GET_WRITE_DATA;
						break;
					} else { //Reset first before enable Alarm again
						alarmClearFlag();
						stopper = 0;
						if (myConfig.timesystem == 1) {
							set_timesystem(0);
							alarmSet(temp.minutes, temp.hours, temp.seconds,
									temp.weekdays);
							set_timesystem(1);
						} else
							alarmSet(temp.minutes, temp.hours, temp.seconds,
									temp.weekdays);
						TIME_CONFIG = 0;
						state = IDLE;
						bsp_printf("Back to main menu\r\n");
						bsp_printf(SELECT_STRING);
						break;
					}
				case 3: // Alarm
					if (temp.AL_status == 1) { // Disable alarm
						bsp_printf("Alarm is disabled\r\n");
						alarmDisable();
					} else if (temp.AL_status == 2) { //Reset alarm
						bsp_printf("Alarm is reset\r\n");
						alarmClearFlag();
					} else
						bsp_printf("Invalid input\r\n");
					state = IDLE;
					bsp_printf("Back to main menu\r\n");
					bsp_printf(SELECT_STRING);
					break;

				case 4: //Change Time System
					if (temp.AL_status > 1)
						bsp_printf("Invalid input\r\n");
					else
						set_timesystem(temp.AL_status);
					state = IDLE;
					bsp_printf("Back to main menu\r\n");
					bsp_printf(SELECT_STRING);
					break;

				case 5: // Change battery Mode
					if (temp.AL_status > 3)
						bsp_printf("Invalid input\r\n");
					else {
						battery_mode_RTC(temp.AL_status);
						bsp_printf(
								"Battery Mode %d is selected , Back to main menu\r\n",
								temp.AL_status);
					}
					state = IDLE;
					bsp_printf(SELECT_STRING);
					break;
				}
				new_line_detected = 0;
				counter = 0;

			}
			break;
		}
	}

}
#endif
#else
void main() {
    bsp_init();
    bsp_printf("I2C_CTRL is disabled, please enable it to run this app. \r\n");
}
#endif

#else
void main()
{
	bsp_init();
	bsp_printf("This example design supported in Ti375C529 only!!!\r\n");
}

#endif
