////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file main.c: temperatureSensorDemo 
*
* @brief This demo uses the I2C peripheral to communicate with on-board EMC1413 Temperature
* 		 module on Ti375C529. It print out the temperature of the device on terminal every 
*		 few seconds and alerts user if the temperature of the device exceed above the high
*		 temperature limit. 
*
* @note To run this example design, please make sure the following requirements are fulfilled:
* 		1. Ti375C529 Dev Board
* 		2. Enable UART0 and I2C0
*
*		User are allowed to configure certain parameters in peri.h (User defined Section)
*		1. I2C_FREQ 		=> Frequency of I2C, default set to 100kHz
*		2. DEBUG_MODE		=> Print detail info if enabled.
*		3. EXTENDED_RANGE_ENABLED  	=>If set to 0, means range of temp measurement from 0°C to +127°C (Default)
*								 	=>If set to 1, means range of temp measurement from -64°C to +191°C (Extended Range enabled)
*
* 		4. HIGH_TEMPERATURE_LIMIT_VALUE_INT  	=> High limit temp for internal temperature sensor in EMC1413 itself.
* 		5. LOW_TEMPERATURE_LIMIT_VALUE_INT   	=> Low  limit temp for temperature sensor 1 on Ti375C529.
*		6. HIGH_TEMPERATURE_LIMIT_VALUE_EXT1 	=> High limit temp for internal temperature sensor in EMC1413 itself.
*		7. LOW_TEMPERATURE_LIMIT_VALUE_EXT1   	=> Low  limit temp for temperature sensor 1 on Ti375C529.
*		8. HIGH_TEMPERATURE_LIMIT_VALUE_EXT2  	=> High limit temp for internal temperature sensor in EMC1413 itself.
*		9. LOW_TEMPERATURE_LIMIT_VALUE_EXT2   	=> Low  limit temp for temperature sensor 1 on Ti375C529.
*
*
******************************************************************************/

#include <stdint.h>
#include "bsp.h"
#include "device_config.h"
#include "io.h"
#include <stdlib.h>
#include "stdbool.h"
#include "i2c.h"

#ifdef EMC1413_SUPPORT
//Temperature Driver
#include "peri.h"

void main() 
{
    //System Initialization
    peri_init();
    i2c_init();
    temp_init();
    temperature_data temp;

    while(1){

    	get_tempdata(&temp);
		bsp_printf("\r\n");
        bsp_printf("Internal temperature in EMC1413 module   : %f°C\r\n", temp.int_HL_temp);
        bsp_printf("Temperature sensor 1 on Ti375C529 dev kit: %f°C\r\n", temp.ext1_HL_temp);
        bsp_printf("Temperature sensor 2 on Ti375C529 dev kit: %f°C\r\n", temp.ext2_HL_temp);
		if (check_lowtemp_alert()) bsp_printf("[WARNING]:Temperature of the device dropped below low limit temperature !!!\r\n");
		if (check_hightemp_alert()) bsp_printf("[WARNING]:Temperature of the device exceed the high limit temperature !!!\r\n");
		for (uint32_t i = 0; i < SYSTEM_CLINT_HZ; i++)
			asm("nop"); //Show data every few seconds
    };
    
}

#else
void main() {
    bsp_printf("This example design supported in Ti375C529 only!!!\r\n");
}
#endif

