////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file peri.h
*
* @brief Header file contain function prototype for interrupt handler and some
*		 parameter that used for TemperatureDriver_C529Demo.
*
*
******************************************************************************/

#include "device_config.h"

#define I2C_CTRL_HZ     		SYSTEM_CLINT_HZ
#ifdef TEMP_SENSOR_I2C_BASE_ADDR
	#define I2C_CTRL       			TEMP_SENSOR_I2C_BASE_ADDR
	#include "device/emc1413.h"
#endif

#define UART_0_SAMPLE_PER_BAUD 	8
#define UART_DECIMAL_OFFSET 	48



/********************************************RULES FOR CONFIGURING PARAMETERS***************************************************
*
* @brief When configuring high/low temperature limit value, here are some of the rules to follow:
*
* -> It will ignored negative defined input with decimal when extended range mode is enabled. eg, defined input of -60.25°C will be recognize as -60°C.
* -> High/Low temp.limit defined input for internal sensor are in integer format, meaning it will simply extract int part from defined input with decimal into reg.
* -> Default value will be set if defined input is invalid.
* -> Default value for low limit temp is 0°C.
* -> Default value for high limit temp is 85°C.
* -> The resolution of limit temp is 0.125°C.
******************************************************************************************************************************/
//User Defined
#define I2C_FREQ          			  		100000 	//100kHz
#define EXTENDED_RANGE_ENABLED  	  		0 //If set to 0, means range of temp measurement from 0°C to +127°C (Default)
								 			  //If set to 1, means range of temp measurement from -64°C to +191°C (Extended Range enabled)
#define HIGH_TEMPERATURE_LIMIT_VALUE_INT  	85 //High limit temp for internal temperature sensor in EMC1413 itself.
#define LOW_TEMPERATURE_LIMIT_VALUE_INT   	0 //Low  limit temp for temperature sensor 1 on Ti375C529.

#define HIGH_TEMPERATURE_LIMIT_VALUE_EXT1 	85 //High limit temp for internal temperature sensor in EMC1413 itself.
#define LOW_TEMPERATURE_LIMIT_VALUE_EXT1   	0  //Low  limit temp for temperature sensor 1 on Ti375C529.

#define HIGH_TEMPERATURE_LIMIT_VALUE_EXT2  	85 //High limit temp for internal temperature sensor in EMC1413 itself.
#define LOW_TEMPERATURE_LIMIT_VALUE_EXT2   	0  //Low  limit temp for temperature sensor 1 on Ti375C529.

//Function prototype
void i2c_init();
void peri_init();
void temp_init();

