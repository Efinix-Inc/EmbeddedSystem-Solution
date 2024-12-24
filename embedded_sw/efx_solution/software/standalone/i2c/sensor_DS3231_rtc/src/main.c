////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
 *
 * @file main.c: rtcDemo-DS3231
 *
 * @brief This demo uses the I2C peripheral to communicate with DS3231 RTC sensor
 * 		 It allows user to change various configuration such as real-time data
 *		 with convertible 12/24hr time system, alarm setting of the DS3231 RTC sensor
 * @brief This demo uses the I2C peripheral to communicate with DS3231 RTC sensor
 * 		 It allows user to change various configuration such as real-time data
 *		 with convertible 12/24hr time system, alarm setting of the DS3231 RTC sensor
 *		 if ENABLE_MAIN_MENU is set to 1 in peri.h else it will print the real-time data every
 *		 few seconds.
 *
 * @note To run this example design, please make sure the following requirements are fulfilled:
 * 		1. Ti180J484 Dev Board / T120F576 Dev Board
 * 		1. Ti180J484 Dev Board / T120F576 Dev Board
 * 		2. Enable UART0 and I2C0
 *
 *		User are allowed to configure certain parameters in peri.h (User defined Section)
 *		1. I2C_FREQ 		=> Frequency of I2C, default set to 100kHz
 *		2. ENABLE_MAIN_MENU => Allow user to select various configuration if enabled.
 *		2. ENABLE_MAIN_MENU => Allow user to select various configuration if enabled.
 *
 ******************************************************************************/
#include <stdint.h>
#include "bsp.h"
#include "device_config.h"

#include "i2c.h"
#include "stdlib.h"
#include "riscv.h"
#include "plic.h"
#include "clint.h"
#include "stdio.h"
#include "peri.h"

/***********************************************************************************RTC DEMO******************************************************************************************/

//Global variable
char new_line_detected = 0;
uint32_t counter = 0;
uint8_t buffer[200];

#ifdef RTC_DS3231_SUPPORT
#ifdef I2C_CTRL
//Global variable

void main() {
	bsp_init();
	init();
	time_data myConfig;
	uint8_t TIME_CONFIG = 0;
	uint8_t stopper = 0;
	uint8_t alarm_demo_second = 0;
	states state = IDLE;

	/*Alternative way to set time by using set_datetime function
	 /*	set_datetime(set seconds, set minutes, set hours, set 24hour time, set DOW, set days, set month , set year)*/
	//set_datetime(0,40,17,1,2,10,10,23);
	bsp_printf(LAUNCH_STRING);
	if (ENABLE_MAIN_MENU)
		bsp_printf(SELECT_STRING);
	while (1) {

		if (!ENABLE_MAIN_MENU) { //Check Time
			getdata(&myConfig);
			bsp_printf("%d/%d/20%d \r\n", get_days(&myConfig),
					get_months(&myConfig), get_years(&myConfig));
			bsp_printf("%s,%d%s %s 20%d\r\n",
					DayStrings[get_weekdays(&myConfig) - 1],
					get_days(&myConfig), get_days_ordinalno(&myConfig),
					MonthStrings[get_months(&myConfig) - 1],
					get_years(&myConfig));
			if (myConfig.timesystem)
				bsp_printf("Current Time: %d:%s%d%s  \r\n",
						get_hours(&myConfig),
						(get_minutes(&myConfig) < 10) ? "0" : "",
						get_minutes(&myConfig),
						(myConfig.PM) ? (meridiem[1]) : (meridiem[0]));
			else
				bsp_printf("Current Time: %d:%s%d:%s%d  \r\n",
						get_hours(&myConfig),
						(get_minutes(&myConfig) < 10) ? "0" : "",
						get_minutes(&myConfig),
						(get_seconds(&myConfig) < 10) ? "0" : "",
						get_seconds(&myConfig));
			bsp_printf("Temperature: %0.2f°C\r\n\n", get_temp(&myConfig));
			for (uint32_t i = 0; i < SYSTEM_CLINT_HZ / 10; i++)
				asm("nop");
			//Show data every seconds
		}

		else { //Enable main menu for configuring time, etc
			switch (state) {
			case IDLE: //idle case wait for input to be 1 or 2
				if (i2c_checkFlag(I2C_CTRL, RTC_ADDR, STATUS_ADDR)
						&& !stopper) {
					bsp_printf("Alarm 1 is trigger!!! \r\n");
					stopper = 1;
				}

				if (new_line_detected) {
					if (buffer[0] == '1' && counter == 1) { //Check Time
						bsp_printf("Showing current time now...\r\n");
						getdata(&myConfig);
						bsp_printf("%d/%d/20%d \r\n", get_days(&myConfig),
								get_months(&myConfig), get_years(&myConfig));
						bsp_printf("%s,%d%s %s 20%d\r\n",
								DayStrings[get_weekdays(&myConfig) - 1],
								get_days(&myConfig),
								get_days_ordinalno(&myConfig),
								MonthStrings[get_months(&myConfig) - 1],
								get_years(&myConfig));
						if (myConfig.timesystem)
							bsp_printf("Current Time: %d:%s%d:%s%d%s  \r\n",
									get_hours(&myConfig),
									(get_minutes(&myConfig) < 10) ? "0" : "",
									get_minutes(&myConfig),
									(get_seconds(&myConfig) < 10) ? "0" : "",
									get_seconds(&myConfig),
									(myConfig.PM) ?
											(meridiem[1]) : (meridiem[0]));
						else {
							bsp_printf("Current Time: %d:%s%d:%s%d  \r\n",
									get_hours(&myConfig),
									(get_minutes(&myConfig) < 10) ? "0" : "",
									get_minutes(&myConfig),
									(get_seconds(&myConfig) < 10) ? "0" : "",
									get_seconds(&myConfig));
						}
						bsp_printf("Temperature: %0.2f°C\r\n\n\n",
								get_temp(&myConfig));
						bsp_printf(SELECT_STRING);
						state = IDLE;
					} else if (buffer[0] == '2' && counter == 1) { //Check Alarm Status
						bsp_printf("Showing alarm status now...\r\n");
						if (getAlarmMode(&myConfig)) {
							//Alarm Mode 2
							bsp_printf(
									"\n\nAlarm will trigger when the time is %d:%d:%d \r\n",
									get_hours(&myConfig),
									get_minutes(&myConfig), alarm_demo_second);
							checkalarmStatus(1);
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
						bsp_printf(
								"\r\nEnter value for time(h m s) and Day of week,days,month,year such as 14 20 00 1 16 10 23  that represent to 14:20 Sunday,16/16/2023 \r\n");
						state = GET_WRITE_DATA;
					}

					else if (TIME_CONFIG == 2) {
						bsp_printf(demo_mode_string);
						//Alarm Mode 2
						bsp_printf(
								"\r\nEnter value for seconds such as 30 that represent to 30 seconds \r\n");
						state = GET_WRITE_DATA;
					}

					else if (TIME_CONFIG == 3) {
						bsp_printf(
								"Press 0 and enter to back to main menu\r\n");
						bsp_printf("Press 1 and enter to disable Alarm\r\n");
						bsp_printf("Press 2 and enter to reset Alarm\r\n");
						state = GET_WRITE_DATA;
					}

					else if (TIME_CONFIG == 4) {
						bsp_printf("Press 0 for 24hr TimeSystem \r\n");
						bsp_printf("Press 1 for 12hr TimeSystem \r\n");
						state = GET_WRITE_DATA;
					}
				}
				new_line_detected = 0;
				counter = 0;
				break;
			case GET_WRITE_DATA:
				if (new_line_detected) { //Setting up temporary variable for user input value
					time_data temp;
					uint8_t error = 0;
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
					temp.AL_mode = (buffer[9] - UART_DECIMAL_OFFSET);
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
								| (temp.days < 1) | (temp.months < 1)
								| (error)) {
							bsp_printf("Invalid input, please try again\r\n");
							state = GET_WRITE_DATA;
							break;
						} else {
							bsp_printf(
									"\n(24hour System) Time set to %d:%d:%d\r\n",
									temp.hours, temp.minutes, temp.seconds);
							bsp_printf("%s,%d %s 20%d\r\n",
									DayStrings[temp.weekdays - 1], temp.days,
									MonthStrings[temp.months - 1], temp.years);
							bsp_printf("Back to main menu\r\n");
							bsp_printf(SELECT_STRING);
							set_datetime(temp.seconds, temp.minutes, temp.hours,
									temp.weekdays, temp.days, temp.months,
									temp.years);
							TIME_CONFIG = 0;
							state = IDLE;
							break;
						}
					case 2: //Checking input for any error on Alarm Configuration
						if ((temp.hours > 59)) { //Alarm Mode 2
							bsp_printf("Invalid input, please try again\r\n");
							state = GET_WRITE_DATA;
							break;
						} else { //Reset first before enable Alarm again
							getdata(&myConfig);
							alarmClearFlag();
							stopper = 0;
							alarmEnable();
							alarmSet(2, temp.hours, 0, 0, 0); //temp_hours is second for Alarm Mode 2
							alarm_demo_second = temp.hours;
							bsp_printf(
									"\n\nAlarm will trigger when the time is %d:%d:%d \r\n",
									get_hours(&myConfig),
									get_minutes(&myConfig), alarm_demo_second);
							TIME_CONFIG = 0;
							state = IDLE;
							bsp_printf("Back to main menu\r\n");
							bsp_printf(SELECT_STRING);
							break;
						}
					case 3: // Alarm
						if (temp.AL_status) { // Disable alarm
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
					}
					new_line_detected = 0;
					counter = 0;

				}
				break;
			}
		}

	}

}

#else
void main() {
    bsp_init();
    bsp_printf("I2C_CTRL is disabled, please enable it to run this demo. \r\n");
}
#endif

#else
void main()
{
	bsp_init();
	bsp_printf("This example design is supported in Titanium Ti180J484 and Trion T120F576 only.\r\n");
}
#endif

