////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
*
* @file peri.c

* @brief This file is used for system initialization and interrupt handler.
*
* The available functions are:
* - peri_init        : Initiates the configuration of UART.
* - i2c_init         : Initiates the configuration of I2C.
* - temp_init        : Initiates temperature module.
*
******************************************************************************/

#include "bsp.h"
#include "device_config.h"
#include "io.h"
#include "i2c.h"
#include "peri.h"

#ifdef EMC1413_SUPPORT
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
* @brief This function initiates temperature module.
*
* @return None.
*
******************************************************************************/
void temp_init() {
    temperature_data temp_limit;

	bsp_printf("Welcome to Temperature Demo for Ti375C529\r\n\n");
	bsp_printf("********************START OF CONFIGURATION***********************\r\n\n");

	//Checking control register
	bsp_printf("Checking info of the EMC1413 module! \r\n");
	//bsp_printf("*****************************************\r\n");
	bsp_printf("Product ID of temperature sensor:%x \r\n",readtemp_reg(PRODUCT_ID));
    bsp_printf("Status register:%x \r\n",readtemp_reg(STATUS_REG));
    bsp_printf("Config register:%x \r\n\n",readtemp_reg(CONFIG_REG));

    //Configure range of the temperature measurement
    config_temprange_reg(EXTENDED_RANGE_ENABLED);

    //Set the high/low temperature limit for the sensors.
    bsp_printf("Setting up high/low temperature limit! \r\n");
    //bsp_printf("*****************************************\r\n");
    set_templimit(HIGH_TEMPERATURE_LIMIT_VALUE_INT,LOW_TEMPERATURE_LIMIT_VALUE_INT,0);
    set_templimit(HIGH_TEMPERATURE_LIMIT_VALUE_EXT1,LOW_TEMPERATURE_LIMIT_VALUE_EXT1,1);
    set_templimit(HIGH_TEMPERATURE_LIMIT_VALUE_EXT2,LOW_TEMPERATURE_LIMIT_VALUE_EXT2,2);

    //Checking temperature limit
    get_templimit(&temp_limit);
    bsp_printf("Set High Temperature limit in internal EMC1413 sensor: %f°C \r\n",temp_limit.int_HL_temp);
    bsp_printf("Set High Temperature limit on temperature sensor 1   : %f°C \r\n",temp_limit.ext1_HL_temp);
    bsp_printf("Set High Temperature limit on temperature sensor 2   : %f°C \r\n",temp_limit.ext2_HL_temp);

    bsp_printf("Set Low Temperature limit in internal EMC1413 sensor : %f°C \r\n",temp_limit.int_LL_temp);
    bsp_printf("Set Low Temperature limit on temperature sensor 1    : %f°C \r\n",temp_limit.ext1_LL_temp);
    bsp_printf("Set Low Temperature limit on temperature sensor 2    : %f°C \r\n",temp_limit.ext2_LL_temp);

    if (check_temprange_reg()) bsp_printf("\r\nRange of the temperature measurement: Extended Range (-64°C to +191°C)\r\n");
    else bsp_printf("\r\nRange of the temperature measurement: Default Range (0°C to +127°C)\r\n");
    bsp_printf("\n********************END OF CONFIGURATION***********************\r\n");

}

#endif //EMC1413_SUPPORT

