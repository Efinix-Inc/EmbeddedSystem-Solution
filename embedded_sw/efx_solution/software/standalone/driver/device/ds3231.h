////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/********************************************************************************************************************
 *										RTCC LIBRARY FOR DS3231												*
 *																													*
 * 										SUPPORTED FEATURES:															*
 *     										* TIMEKEEPING
 *     										* 12/24HR TIME SYSTEM												*
 *     										* TEMPERATURE SENSOR													*
 *     										* ALARMS 													*
 *     										* POWER FAILURE CHECK AND CLEAR											*
 *																													*
 ********************************************************************************************************************
 */
#ifndef DS3231_H_
	#define DS3231_H_

#pragma once
#include <stdint.h>
#include <stdbool.h>
#include "i2c.h"
#include "bsp.h"
#include "device_config.h"

//******************************************* REGISTER-MAP FOR RTC DS3231 MODULE ********************************************//
//ADDRESS FOR I2C RTC Slave Address
#define RTC_ADDR 			0x68<<1

//ADDRESS FOR TIMEKEEPING REGISTER
#define RTC_SECONDS			0X00
#define	RTC_MINUTES			0X01
#define RTC_HOURS			0X02
#define RTC_DAYS			0X03
#define RTC_DATE			0X04
#define RTC_MONTH			0X05
#define RTC_YEAR			0X06

//ADDRESS FOR ALARM REGISTER
#define ALARM1_SECONDS		0X07
#define	ALARM1_MINUTES		0X08
#define ALARM1_HOURS		0X09
#define ALARM1_DAYS			0X0A
#define	ALARM2_MINUTES		0X0B
#define ALARM2_HOURS		0X0C
#define ALARM2_DAYS			0X0D

//ADDRESS FOR CONTROL, TEMP REG
#define CONTROL_ADDR		0X0E
#define STATUS_ADDR			0X0F
#define AGING_ADDR			0X10
#define MSB_TEMP			0X11
#define LSB_TEMP			0X12


//DATA FOR TIMEKEEPING/ALARM IN EACH REG
#define SECONDS_DATA 		0X7F
#define MINUTES_DATA 		0X7F
#define _12HOURS_DATA 		0X1F
#define _24HOURS_DATA 		0X3F   //FOR ALARM_DOW, USE 0X3F INSTEAD OF 0XFF
#define DAYS_DATA 			0XFF
#define DATE_DATA 			0X37
#define MONTH_DATA 			0X1F
#define YEAR_DATA 			0XFF

#define INTERRUPT_FLAG		0X04
#define ALARM1_INT_FLAG		0X01
#define ALARM2_INT_FLAG		0X02
#define OSC_STOP_FLAG		0x80
#define _32K_enabled_FLAG	0x08

//************************************************* ALARM REGISTER ADDRESS *********************************************//
#define ALARM_MODE					0x80

#define RTC_ALARM1_ALL_S 			0x0F //ALARM1 - TRIGGER EVERY SECOND
#define RTC_ALARM1_MATCH_S 			0x0E //ALARM1 - TRIGGER EVERY MINUTE WHENS SECONDS MATCH
#define RTC_ALARM1_MATCH_MS 		0x0C //ALARM1 - TRIGGER EVERY HOUR WHEN MINUTES AND SECONDS MATCH
#define RTC_ALARM1_MATCH_HMS 		0x08 //ALARM1 - TRIGGER EVERY DAY AT WHEN HOURS, MINUTES AND SECONDS MATCH
#define RTC_ALARM1_MATCH_DHMS		0x00 //ALARM1 - TRIGGER Alarm when date (day of month), hours, minutes and seconds match */
#define RTC_ALARM1_MATCH_DOWHMS 	0x10 //ALARM1 - TRIGGER when day (day of week), hours, minutes and seconds match

#define RTC_ALARM2_MATCH_S 			0x70 //ALARM2 - TRIGGER EVERY MINUTE WHENS SECONDS MATCH
#define RTC_ALARM2_MATCH_MS 		0x60 //ALARM2 - TRIGGER EVERY HOUR WHEN MINUTES AND SECONDS MATCH
#define RTC_ALARM2_MATCH_HMS 		0x40 //ALARM2 - TRIGGER EVERY DAY AT WHEN HOURS, MINUTES AND SECONDS MATCH
#define RTC_ALARM2_MATCH_DHMS		0x00 //ALARM2 - TRIGGER Alarm when date (day of month), hours, minutes and seconds match */
#define RTC_ALARM2_MATCH_DOWHMS 	0x80 //ALARM2 - TRIGGER when day (day of week), hours, minutes and seconds match
#define RTC_ALARM_ERROR				0xFF
//**********************************SQUARE-WAVE OUTPUT FREQUENCY SELECTION: ****************************************//

#define RTC_SQWG_OFF		0x04  //SQWG IS OFF
#define RTC_SQWG_1HZ  		0x00  //SQWG RUNNING AT 1HZ
#define RTC_SQWG_1024HZ 	0x08  //SQWG RUNNING AT 1.024KHZ
#define RTC_SQWG_4096HZ 	0x10  //SQWG RUNNING AT 4.096KHZ
#define RTC_SQWG_8192HZ 	0x18  //SQWG RUNNING AT 8.192KHZ

//*********************************************	BCD CONVERTER *****************************************************//

#define RTC_DECTOBCD(dec_val) 	((uint8_t) ((dec_val / 10 * 16) + (dec_val % 10))) //CONVERT DECIMAL TO BCD
#define RTC_BCDTODEC(bcd_val) 	((uint8_t) ((bcd_val / 16 * 10) + (bcd_val % 16))) //CONVERT BCD TO DECIMAL


/******************************************************************************
*
* @brief Time-keeping Structure. 
*
* This structure represents real-time data and alarm data from register.
*
******************************************************************************/
typedef struct {
    uint8_t seconds;
    uint8_t minutes;
    uint8_t hours;
	uint8_t PM;
	uint8_t timesystem;
    uint8_t weekdays;
    uint8_t days;
    uint8_t months;
    uint8_t years;
	uint8_t AL_mode;
	uint8_t AL_seconds;
    uint8_t AL_minutes; 
    uint8_t AL_hours;   
    uint8_t AL_days;	  
    uint8_t AL_weekdays;
	uint8_t AL_status;
	float temp;

}time_data;

static uint8_t get_data [17] = {};
static uint8_t sqwg_mode[1]  = {RTC_SQWG_OFF};
static bool osc_lost_power 	 = false;
static bool enabled_32k 	 = false;

static const char* Day_ordinal [] = {
    	"st",
		"nd",
		"rd",
		"th"
};
static const char* const DayStrings[]  = {
		"Sunday",
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday"
};
static const char* const MonthStrings[]  = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July" ,
		"August" ,
		"September" ,
		"October",
		"November" ,
		"December"
};
static const char* const  meridiem[] = {
		"am",
		"pm"
};

static const char* get_days_ordinalno(time_data *config){
	switch(config -> days){
		case 1:
		case 21:
		case 31:
				return Day_ordinal[0];
				break;
		case 2:
		case 22:
				return Day_ordinal[1];
				break;
		case 3:
		case 23:
				return Day_ordinal[2];
		    	break;
		default:
				return Day_ordinal[3];
				break;
	}

}

/********************************************** TimeKeeping Function **************************************************/

/******************************************************************************
*
* @brief This function extract real-time data from RTC Module and save it into
*		 timedata struct. 
*
* @return  none.
*
******************************************************************************/
static void getdata(time_data *config) {

	i2c_readData_b(I2C_CTRL,RTC_ADDR,RTC_SECONDS,get_data,19);
	float LSB;

	//READ TIME FROM RTC
	config->timesystem 	= (get_data[RTC_HOURS]>>6) & 1; //12/24 hour time System
	config->seconds   	= RTC_BCDTODEC((get_data[RTC_SECONDS] & SECONDS_DATA));
	config->minutes   	= RTC_BCDTODEC((get_data[RTC_MINUTES] & MINUTES_DATA));
	config->hours 		= (config->timesystem)?(RTC_BCDTODEC((get_data[RTC_HOURS] & _12HOURS_DATA))):(RTC_BCDTODEC((get_data[RTC_HOURS] & _24HOURS_DATA)));
	config->PM			= ((config->timesystem) && ((get_data[RTC_HOURS]>>5) & 1))?1:0;
	config->weekdays 	= RTC_BCDTODEC((get_data[RTC_DAYS]& DAYS_DATA));
	config->days  	  	= RTC_BCDTODEC((get_data[RTC_DATE])); 
	config->months	  	= RTC_BCDTODEC((get_data[RTC_MONTH] & MONTH_DATA));
	config->years	  	= RTC_BCDTODEC((get_data[RTC_YEAR] & YEAR_DATA));

	//READ SET ALARM TIME
	config -> AL_seconds	= RTC_BCDTODEC((get_data[ALARM1_SECONDS] & SECONDS_DATA));
	config -> AL_minutes	= RTC_BCDTODEC((get_data[ALARM1_MINUTES] & MINUTES_DATA));
	config -> AL_hours	    = RTC_BCDTODEC((get_data[ALARM1_HOURS] & _24HOURS_DATA));
	config -> AL_weekdays  = RTC_BCDTODEC((get_data[ALARM1_DAYS] & _24HOURS_DATA));

	//TEMPERATURE REG AT 0X11 & 0X12H
	LSB = (get_data[LSB_TEMP]>>6)/4;
	// if True, then the value is negative_sign
	config ->temp = (get_data[MSB_TEMP] & 0x80)? (-(128 - get_data[MSB_TEMP]) + LSB):((get_data[MSB_TEMP] & 0x7F) + LSB);


}


/******************************************************************************
*
* @brief This function return temperature from struct of timedata. 
* @return temperature.
*
******************************************************************************/

static float  get_temp(time_data *config){
	return config->temp;
}

/******************************************************************************
*
* @brief This function return seconds from struct of timedata. 
* @return seconds.
*
******************************************************************************/
static uint8_t get_seconds(time_data *config){
	return config->seconds;
}


/******************************************************************************
*
* @brief This function return minutes from struct of timedata. 
* @return minutes.
*
******************************************************************************/
static uint8_t get_minutes(time_data *config){
	return config->minutes;
}

/******************************************************************************
*
* @brief This function return hours from struct of timedata. 
* @return hours.
*
******************************************************************************/
static uint8_t get_hours(time_data *config){
	return config->hours;
}

/******************************************************************************
*
* @brief This function return days from struct of timedata. 
* @return days.
*
******************************************************************************/
static uint8_t get_days(time_data *config){
	return config->days;
}

/******************************************************************************
*
* @brief This function return months from struct of timedata. 
* @return months.
*
******************************************************************************/
static uint8_t get_months(time_data *config){
	return config->months;
}

/******************************************************************************
*
* @brief This function return years from struct of timedata. 
* @return years.
*
******************************************************************************/
static uint8_t get_years(time_data *config){
	return config->years;
}

/******************************************************************************
*
* @brief This function return weekdays from struct of timedata. 
* @return weekdays.
*
******************************************************************************/
static uint8_t get_weekdays(time_data *config){
	return config->weekdays;
}

/******************************************************************************
*
* @brief This function change the current timesystem (12/24hr) for real-time data and alarm.
*
* @param _12hour   If value = 0, means it is set to 24hr timesystem, vice versa.
*
* @return          none.
*
******************************************************************************/
static void set_timesystem (const uint8_t _12hour){
	time_data tempConfig;
	uint8_t status[1];
	i2c_readData_b(I2C_CTRL,RTC_ADDR,RTC_HOURS,status,1);
	if (((status[0]>>6) & 1) == _12hour)
		return ;
	else { //Only Trigger when different TimeSystem is detected
	tempConfig.hours = RTC_BCDTODEC((status[0] & _12HOURS_DATA));
	//Check for current timesystem,if 12hr, then check for AM/PM
	tempConfig.PM = ((status[0]>>5) & 1)?1:0;
	switch (_12hour){
		case 0: //24hours time system
				tempConfig.timesystem = 0;
				if ((tempConfig.hours ==12) && (tempConfig.PM)); // Value remain the same for both TimeSystem
				else if (tempConfig.PM) tempConfig.hours = tempConfig.hours + 12;//If 24hr system, then it will change 2pm to 14:00
				status[0] = 0xBF & RTC_DECTOBCD(tempConfig.hours) ; //Change timesystem bit in 02h_address
				bsp_printf("TimeSystem has change to 24hr TimeSystem\r\n");
				break;

		case 1://12hours time system
				tempConfig.timesystem = 1;
				if (tempConfig.hours == 12) tempConfig.PM =1;
				else if (tempConfig.hours>12 ) //Evening
				{
					tempConfig.PM = 1;
					tempConfig.hours = tempConfig.hours -12;
				}
				else if (((tempConfig.hours>=0) | (tempConfig.hours<=3)) && tempConfig.PM) tempConfig.hours = tempConfig.hours +8;
				else tempConfig.PM = 0;//Morning
				bsp_printf("TimeSystem has change to 12hr TimeSystem\r\n");
				status[0] = (0x40)|(tempConfig.PM <<5)|(RTC_DECTOBCD(tempConfig.hours)); //Change timesystem bit in 02h_address
				break;
		default:
				break;

	}
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,RTC_HOURS,status,1);
	}
}

/******************************************************************************
*
* @brief This function change the current timesystem (12/24hr)
*
* @param set_seconds 	Set for current seconds.
* @param set_minutes 	Set for current minutes.
* @param set_hours 		Set for current hours.
* @param set_dayOfWeek 	Set for current dayOfWeek.
* @param set_days 		Set for current days.
* @param set_month 		Set for current month.
* @param set_years 		Set for current years.
*
* @return          none.
*
* @note			   The value is set in 24hr timesystem only.
*
******************************************************************************/
static void set_datetime(const uint8_t set_seconds, const uint8_t set_minutes, const uint8_t set_hours, const uint8_t set_weekdays, const uint8_t set_days, const uint8_t set_month, const uint8_t set_years){

	uint8_t data[7] ={
		RTC_DECTOBCD(set_seconds),
		RTC_DECTOBCD(set_minutes),
		RTC_DECTOBCD(set_hours),
		RTC_DECTOBCD(set_weekdays),
		RTC_DECTOBCD(set_days),
		RTC_DECTOBCD(set_month),
		RTC_DECTOBCD(set_years)
	};
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,RTC_SECONDS,data,7);
}



/************************************** Alarm Function *****************************************************/
//Example Usecase:
/*	alarmEnable();
/*	alarmSet(RTC_ALARM1_ALL_S ,0,30,12,3);
/*	getAlarm1Mode();
/*	checkalarmStatus();
/*	alarmClearFlag();
/*	alarmDisable();
*/

/******************************************************************************
*
* @brief  This function enable Alarm.
* @return true.
*
******************************************************************************/
static bool alarmEnable() {
	uint8_t status[1];
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	status[0] |=  0x05;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	return true;
}


/******************************************************************************
*
* @brief This function enable Alarm and set the value in 24hr timesystem. 
*
* @param minutes 	Set for alarm minutes.
* @param hours 		Set for alarm hours.
* @param day 		Set for alarm day.
* @param weekday 	Set for alarm weekday.
*
* @note				Alarm only triggered when all alarm register match with all
*					time register which generate alarm flag (AF) in CSR1.
*
* @return 			true
*
******************************************************************************/

/* Available Alarm Mode

	RTC_ALARM1_ALL_S 			0x0F //ALARM1 - Trigger every second
	RTC_ALARM1_MATCH_S 			0x0E //ALARM1 - Trigger every minute whens seconds match
	RTC_ALARM1_MATCH_MS 		0x0C //ALARM1 - Trigger every hour when minutes and seeconds match
	RTC_ALARM1_MATCH_HMS 		0x08 //ALARM1 - Trigger once per day when hours, minutes and seconds match
	RTC_ALARM1_MATCH_DHMS		0x00 //ALARM1 - Trigger alarm when date (day of month), hours, minutes and seconds match
	RTC_ALARM1_MATCH_DOWHMS 	0x10 //ALARM1 - Trigger when day (day of week), hours, minutes and seconds match */


static bool alarmSet(const uint8_t type, const uint8_t second, const uint8_t minute, const uint8_t hour, const uint8_t day_dow){

	time_data config;
	uint8_t status[1] = {};
	uint8_t type_alarm = 0;
	switch (type){
		case 1:
			type_alarm = RTC_ALARM1_ALL_S;
			bsp_printf("ALARM MODE: Trigger every second\r\n");
			break;
		case 2:
			type_alarm  = RTC_ALARM1_MATCH_S ;
			bsp_printf("ALARM MODE: Trigger every minute whens seconds match\r\n");
			break;
		case 3:
			type_alarm  = RTC_ALARM1_MATCH_MS;
			bsp_printf("ALARM MODE: Trigger every hour when minutes and seeconds match\r\n");
			break;
		case 4:
			type_alarm  = RTC_ALARM1_MATCH_HMS;
			bsp_printf("ALARM MODE:  Trigger once per day when hours, minutes and seconds match \r\n\r\n");
			break;
		case 5:
			type_alarm  = RTC_ALARM1_MATCH_DHMS;
			bsp_printf("ALARM MODE: Trigger alarm when date (day of month), hours, minutes and seconds match\r\n");
			break;
		case 6:
			type_alarm  = RTC_ALARM1_MATCH_DOWHMS;
			bsp_printf("ALARM MODE: Trigger when day (day of week), hours, minutes and seconds match\r\n");
			break;
	}
	uint8_t A1M1 = (type_alarm  & 0x01) << 7; // Seconds bit 7.
	uint8_t A1M2 = (type_alarm  & 0x02) << 6; // Minutes bit 7.
	uint8_t A1M3 = (type_alarm  & 0x04) << 5; // Hour bit 7.
	uint8_t A1M4 = (type_alarm  & 0x08) << 4; // Day/Date bit 7.
	uint8_t DY_DT = (type_alarm  & 0x10) << 2;
	uint8_t alarm1_set[4] = {((RTC_DECTOBCD(second) & 0x7F) | A1M1),((RTC_DECTOBCD(minute) & 0x7F) | A1M2),((RTC_DECTOBCD(hour) & 0x3F) | A1M3),((RTC_DECTOBCD(day_dow) & 0x3F) | A1M4 |DY_DT)};
	config.AL_mode     = type_alarm ; 
	config.AL_seconds  = second;
	config.AL_minutes  = minute; 
	config.AL_hours    = hour; 
	config.AL_weekdays = day_dow;

	sqwg_mode[0] = RTC_SQWG_OFF;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,ALARM1_SECONDS,alarm1_set,4);
	return true;

}

/******************************************************************************
*
* @brief  This function disable Alarm. 
* @return true.
*
******************************************************************************/
static bool alarmDisable() {
	uint8_t status[1];
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	status[0] &=  0xF8;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	return true;

}

/******************************************************************************
*
* @brief  This function clear alarmFlag (AF) in CSR1.  
* @return true.
*
******************************************************************************/
static bool alarmClearFlag(){
		uint8_t status[1];
		i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
		status[0] = status[0] & 0xFE;
		i2c_writeData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1);
		return true;

}


/******************************************************************************
*
* @brief  This function check alarm status if true means alarm has triggered.  
* @return 0	Alarm is not triggered.
* @return 1	Alarm is triggered.
*
******************************************************************************/
static bool checkalarmStatus() {
	uint8_t status[1];
	i2c_readData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1); //Check Alarm Flag in control reg

	if (status[0] &  0x01) //Alarm 1 is triggered
	{
		bsp_printf("Alarm 1 is triggered! \r\n"); 
		return 1;
	}
	else {
		bsp_printf("No Alarm is triggered! \r\n");
		return 0;
	}
}


/******************************************************************************
*
* @brief  This function check alarm mode. 
* @return 0	Alarm is disabled.
* @return 1	Alarm is enabled.
*
******************************************************************************/
static bool getAlarmMode() {

	uint8_t status[5] = {0, 0, 0, 0, 0};
	//Check wheter Alarm 1 is enabled by observing INTCN only
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	if (!(status[0] & 0x05)) {
		bsp_printf("ALARM 1 is disabled\r\n");
	    return 0;
		}

	i2c_readData_b(I2C_CTRL,RTC_ADDR,ALARM1_SECONDS,status,4);


	uint8_t alarm_mode = (status[0] & 0x80) >> 7    // A1M1 - Seconds bit
                       | (status[1] & 0x80) >> 6  // A1M2 - Minutes bit
                       | (status[2] & 0x80) >> 5  // A1M3 - Hour bit
                       | (status[3] & 0x80) >> 4  // A1M4 - Day/Date bit
                       | (status[3] & 0x40) >> 2; // DY_DT

    switch (alarm_mode) {

        case RTC_ALARM1_ALL_S:
            bsp_printf("ALARM MODE: Trigger every second\r\n");
            break;
        case RTC_ALARM1_MATCH_S:
        	bsp_printf("ALARM MODE: Trigger every minute whens seconds match\r\n");
            break;
        case RTC_ALARM1_MATCH_MS:
        	bsp_printf("ALARM MODE: Trigger every hour when minutes and seconds match\r\n");
            break;
        case RTC_ALARM1_MATCH_HMS:
        	bsp_printf("ALARM MODE: Trigger once per day when hours, minutes and seconds match\r\n");
            break;
        case RTC_ALARM1_MATCH_DHMS:
        	bsp_printf("ALARM MODE: Trigger alarm when date (day of month), hours, minutes and seconds match\r\n");
            break;
        case RTC_ALARM1_MATCH_DOWHMS:
			bsp_printf("ALARM MODE: Trigger when day (day of week), hours, minutes and seconds match\r\n");
			break;
        case RTC_ALARM_ERROR:
        	bsp_printf("ALARM: ERROR ALARM MODE\r\n");
            break;
        default:
        	bsp_printf("Alarm mode is disabled\r\n");
        	return 0;
    }
    return 1;
}


/******************************************************************************
*
* @brief This function return alarm seconds from struct of timedata. 
* @return alarm seconds.
*
******************************************************************************/
static uint8_t alarmSeconds(time_data *config){
	return config->AL_seconds;
}


/******************************************************************************
*
* @brief This function return alarm minutes from struct of timedata. 
* @return alarm minutes.
*
******************************************************************************/
static uint8_t alarmMinutes(time_data *config){
	return config->AL_minutes;
}

/******************************************************************************
*
* @brief This function return alarm Hours from struct of timedata. 
* @return alarm hours.
*
******************************************************************************/
static uint8_t alarmHours(time_data *config){
	return config->AL_hours;
}

/******************************************************************************
*
* @brief This function return alarm days from struct of timedata. 
* @return alarm days.
*
******************************************************************************/
static uint8_t alarmDays(time_data *config){
	return config->AL_days;
}

/******************************************************************************
*
* @brief This function return alarm weekdays from struct of timedata. 
* @return alarm weekdays.
*
******************************************************************************/
static uint8_t alarmWeekdays(time_data *config){
	return config->AL_weekdays;
}

/********************************************** Square Wave Generator **************************************************/
//Example Usage:
/*	sqwgSetMode(RTC_SQWG_1024HZ);
/*	read=sqwgReadMode;

/*
 * Changes SQWG mode, including turning it off
 *
 * @param mode SQWG mode:
 * 	RTC_SQWG_OFF		0x04  //SQWG IS OFF
 *	RTC_SQWG_1HZ  		0x00  //SQWG RUNNING AT 1HZ
 *	RTC_SQWG_1024HZ 	0x08  //SQWG RUNNING AT 1.024KHZ
 *	RTC_SQWG_4096HZ 	0x10  //SQWG RUNNING AT 4.096KHZ
 *	RTC_SQWG_8192HZ 	0x18  //SQWG RUNNING AT 8.192KHZ
 *
 * @return wrong parameters
 */
static bool sqwgSetMode(const uint8_t mode) {
	uint8_t status[1];
	uint8_t sqwg_mode [1];
	int mode_swg;

	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);

	switch (mode) {
		case 1:{
			sqwg_mode [0] = (status[0]|RTC_SQWG_OFF);
			i2c_writeData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,sqwg_mode,1);
			return true;
			break;
		}
		case 2:
			mode_swg =RTC_SQWG_1HZ;
			bsp_printf("SQWG MODE SELECTED: RUNNING AT 1HZ\r\n");
			break;

		case 3:
			mode_swg =RTC_SQWG_1024HZ;
			bsp_printf("SQWG MODE SELECTED: RUNNING AT 1.024KHZ\r\n");
			break;
		case 4:
			mode_swg =RTC_SQWG_4096HZ;
			bsp_printf("SQWG MODE SELECTED: RUNNING AT 4.096KHZ\r\n");
			break;
		case 5:
			mode_swg =RTC_SQWG_8192HZ;
			bsp_printf("SQWG MODE SELECTED: RUNNING AT 8.192KHZ\r\n");
			break;

	}
	alarmDisable();
	status[0] &= ~0x04; // turn off INTCON to activate SQWG
	status[0] &= ~0x18; // set freq bits to 0 for frequency mode
	sqwg_mode [0] = (status[0]|mode_swg);
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,sqwg_mode,1);

	return true;


}

// Reads current SQWG mode
static uint8_t sqwgReadMode() {
	return sqwg_mode[0];
}

/********************************************** 32k frequency Mode **************************************************/
//Example Usage:
/*	enable32KOut();
/*	status32KOut();
/*	disable32KOut();
*/

//Enables 32K pin output
static bool enable32KOut() {
	uint8_t status[1];
	enabled_32k = true;
	i2c_readData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1);
	status[0] |= 0b00001000;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1);
	return enabled_32k;

}

//Disable 32K pin output
static bool disable32KOut() {
	uint8_t status[1];
	enabled_32k = false;
	i2c_readData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1);
	status[0] &= 0b11110111;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1);
	return !enabled_32k;
}


//Checks 32K pin output status
static bool status32KOut() {
	return enabled_32k;
}

/********************************************** Battery Mode **************************************************/

//When OSF is set, it experience power loss
static bool lostPower(){
	return osc_lost_power;
}

static void lostPowerClear(){ //Pending
	uint8_t status[1];
	osc_lost_power = false;
	i2c_readData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1);
	status[1] &= 0x7F;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,STATUS_ADDR,status,1);
}

static bool enableBattery(){ //Pending
	uint8_t status[1];
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	status[1] &= 0x0F;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	return (status[1] &= 0x00);
}

static bool disableBattery(){ //Pending
	uint8_t status[1];
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	status[1] |= 0x80;
	i2c_writeData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	return (status[1] &= 0x80);
}

/********************************************** Checking Function **************************************************/
//Check Leap Year
static uint8_t isLeapYear(uint8_t temp_year) {
    // If the year is in the '00' to '99' range, assume it's in the 21st century
	int year = temp_year;
    if (year >= 0 && year <= 99) {
        year = year + 2000;  // Convert two-digit year to four-digit year
        bsp_printf("year:%d\r\n",year);
    }

    // Leap year is divisible by 4
    if (year % 4 == 0) {
        // If divisible by 100, it should also be divisible by 400 to be a leap year
        if (year % 100 == 0 && year % 400 != 0) {
            return 0;  // Not a leap year
        } else {
            return 1;  // Leap year
        }
    } else {
        return 0;  // Not a leap year
    }
}

//Checking error
static uint8_t check_month_error(uint8_t temp_month,uint8_t temp_day,uint8_t temp_year){
	uint8_t leap_year = 8;
	switch(temp_month)
	{
		case 1:
		case 3:
		case 5:
		case 7:
		case 8:
		case 10:
		case 12:
				return (temp_day>31)?1:0;
				break;
		case 2:
			leap_year = isLeapYear(temp_year);
			bsp_printf("Is Leap Year: %s \r\n",leap_year?("Yes"):("No"));


			if((temp_day <30) && (leap_year))
			{
				return 0;
			}

			return (temp_day>28)?1:0;

			break;

		default:
			return (temp_day>30)?1:0;
			break;
	}

	return 0;
}

//Check Alarm
static bool check_alarm ()
{
	uint8_t status[1] = {};
	//Check wheter Alarm 1 is enabled by observing INTCN only
	i2c_readData_b(I2C_CTRL,RTC_ADDR,CONTROL_ADDR,status,1);
	if (!(status[0] & 0x04) && !(status[0] & 0x01) ) {
	return false;
	}
	else
		return true;
}


static bool i2c_checkFlag(u32 reg, u8 slaveAddr, u8 regAddr){
	uint8_t data[1] = {};
    i2c_masterStartBlocking(reg);               // Send start sequence
    i2c_txByte(reg, slaveAddr|I2C_WRITE);       // write device address byte with write bit
    i2c_txNackBlocking(reg);                    // send nack bit
    i2c_txByte(reg, (regAddr & 0xFF));          // write second byte address
    i2c_txNackBlocking(reg);                    // send nack bit
    i2c_masterRestartBlocking(reg);             // send restart sequence and wait for it to complete
    i2c_txByte(reg, slaveAddr|I2C_READ);        // write device address byt ewith read bit
    i2c_txNackBlocking(reg);                    // send nack bit
    i2c_txByte(reg, 0xFF);                      // send 0xFF (Release SDA line) to the slave while generate 8-bit SCL pulses
    i2c_txNackBlocking(reg);                    // send nack bit
    data[0] = i2c_rxData(reg);           		// read the data from rx data register and place it into last data array
    i2c_masterStopBlocking(reg);                // send stop sequence
    if (data[0] & 0x01) return 1;
    else return 0;

}


#endif /*DS3231_H_ */
