////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.
//
// This   document  contains  proprietary information  which   is
// protected by  copyright. All rights  are reserved.  This notice
// refers to original work by Efinix, Inc. which may be derivitive
// of other work distributed under license of the authors.  In the
// case of derivative work, nothing in this notice overrides the
// original author's license agreement.  Where applicable, the
// original license agreement is included in it's original
// unmodified form immediately below this header.
//
// WARRANTY DISCLAIMER.
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.
//
// LIMITATION OF LIABILITY.
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT
//     APPLY TO LICENSEE.
//
////////////////////////////////////////////////////////////////////////////////
/*
*  This demo demonstrate how to communicate as a I2C master through I2C Protocol
*  by reading single and multiple bytes of data to I2C slave that can be emulated
*  with I2CSlaveDemo.
*  It assume it is the single master on the bus, and send frame in a blocking manner.
*/

#include <stdint.h>
#include "bsp.h"
#include "i2c.h"
#include "i2cDemo.h" 

#define I2C_MASTER_ADDR 0x67    // Slave device address
#define WORD_REG_ADDR   0       // Set 0 if master only expect to send 1-byte of register address, else set 1.
#define I2C_FREQUENCY   100000  // Set your I2C Frequency here
#ifdef SYSTEM_I2C_0_IO_CTRL

void init(){
    //I2C init
    I2c_Config i2c;
    i2c.samplingClockDivider    = 3;                            // Sampling rate = (FCLK/(samplingClockDivider + 1). Controls the rate at which the I2C controller samples SCL and SDA.
    i2c.timeout                 = I2C_CTRL_HZ/10;               // 100 ms; // Inactive timeout clock cycle. The controller will drop the transfer when the value of the timeout is reached or exceeded. Setting the timeout value to zero will disable the timeout feature.
    i2c.tsuDat                  = I2C_CTRL_HZ/I2C_FREQUENCY/3;  // Data setup time. The number of clock cycles should SDA hold its state before the rising edge of SCL. Refer to your I2C slave datasheet.
    i2c.tLow                    = I2C_CTRL_HZ/I2C_FREQUENCY/2;  // The number of clock cycles of SCL in LOW state.
    i2c.tHigh                   = I2C_CTRL_HZ/I2C_FREQUENCY/2;  // The number of clock cycles of SCL in HIGH state.
    i2c.tBuf                    = I2C_CTRL_HZ/I2C_FREQUENCY;    // The number of clock cycles delay before master can initiate a START bit after a STOP bit is issued. Refer to your I2C slave datasheet.

    i2c_applyConfig(I2C_CTRL, &i2c);                            // Apply the configs from i2c structure into the I2C controller.
}

void main() {
    bsp_init();
    init(); // Initiatize
    bsp_printf("I2C Master Demo! \r\n Please ensure you've either connect to a compatible I2C Slave or running the i2cSlaveDemo with I2C ports connected.\r\n");
    bsp_printf("TEST STARTED ! \r\n");
    u8 dacValue[20];
    u8 readData[20];
    // Set default value for dacValue variable.
    for (int i = 0; i < 20; i++){
        dacValue[i] = i;
    }
    u8 slaveAddr = (I2C_MASTER_ADDR << 1) & 0xFF; // The slave address is shifted left by 1 bit to allocate the bit for rw bit
    while(1){ // Forever loop
        uint32_t ready;

#if ( WORD_REG_ADDR == 1) // 2-Byte Register Address
        //single byte write and read
        i2c_writeData_w(I2C_CTRL, slaveAddr, 0x00, dacValue, 0x01); // Write a byte of dacValue array to address 0x00 with 2-byte of register address
        i2c_readData_w(I2C_CTRL, slaveAddr, 0x00, readData , 0x01); // Read a byte of data from address 0x00 with 2-byte of register address
        // Make sure the data write and read are tally.
        if (dacValue[0] != readData[0]){
            bsp_printf("I2C single data write and read test failed. \r\n");
            while(1){};
        }

        //Multiple bytes write and read
        i2c_writeData_w(I2C_CTRL, slaveAddr, 0x00, dacValue, 20); // Write 20 bytes of dacValue array to address 0x00 with 2-byte of register address
        i2c_readData_w(I2C_CTRL, slaveAddr, 0x00, readData , 20); // Read 20 bytes of data from address 0x00 with 2-byte of register address
        // Make sure the data write and read are tally.
        for (int i = 0; i < 20; i++){
            if (dacValue[i] != readData[i]){
                bsp_printf("I2C multi data write and read test failed at data #%i \r\n", i);
                while(1){};
            }
        }
#else // 1-Byte Register Address
        //single byte write and read
        i2c_writeData_b(I2C_CTRL, slaveAddr, 0x00, dacValue, 0x01); // Write a byte of dacValue array to address 0x00 with 1-byte of register address
        i2c_readData_b(I2C_CTRL, slaveAddr, 0x00, readData , 0x01); // Read a byte of data from address 0x00 with 1-byte of register address
        // Make sure the data write and read are tally.
        if (dacValue[0] != readData[0]){
            bsp_printf("I2C single data write and read test failed. \r\n");
            while(1){};
        }

        //Multiple bytes write and read
        i2c_writeData_b(I2C_CTRL, slaveAddr, 0x00, dacValue, 20); // Write 20 bytes of dacValue array to address 0x00 with 1-byte of register address
        i2c_readData_b(I2C_CTRL, slaveAddr, 0x00, readData , 20); // Read 20 bytes of data from address 0x00 with 1-byte of register address
        // Make sure the data write and read are tally.
        for (int i = 0; i < 20; i++){
            if (dacValue[i] != readData[i]){
                bsp_printf("I2C multi data write and read test failed at data #%i \r\n", i);
                while(1){};
            }
        }
#endif
        bsp_printf("I2C Master Demo completed. \r\n");
        bsp_printf("TEST PASSED! \r\n");
        while(1){};
    }
}
#else
void main() {
    bsp_init();
    bsp_printf("i2c 0 is disabled, please enable it to run this app. \r\n");
}
#endif





