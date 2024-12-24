////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*
 * FreeRTOS+FAT V2.3.3
 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * https://www.FreeRTOS.org
 * https://github.com/FreeRTOS
 *
 */

/* Standard includes. */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <userDef.h>

/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

#include "ff_headers.h"
#include "ff_sddisk.h"
#include "ff_stdio.h"

#include "mmc.h"
#include "efx_mmc_driver.h"
#include "intc.h"
#include "i2c.h"


/* The maximum number items the queue can hold.  The priority of the receiving
task is above the priority of the sending task, so the receiving task will
preempt the sending task and remove the queue items each time the sending task
writes to the queue.  Therefore the queue will never have more than one item in
it at any time, and even with a queue length of 1, the sending task will never
find the queue full. */
#define mainQUEUE_LENGTH                    ( 1 )
#define I2C_CTRL_HZ 			SYSTEM_CLINT_HZ

/*-----------------------------------------------------------*/

void main_sd( void );
static void prvFatSetupTask( void *pvParameters );
extern int disk_initialize ();
static void init();
/*-----------------------------------------------------------*/

/* The queue used by both tasks. */
static QueueHandle_t xQueue = NULL;
struct mmc *mmc;
struct mmc_cmd *xmmc_cmd;
struct mmc_data *data;
struct mmc_config *cfg;
struct mmc_ops *ops;

/*-----------------------------------------------------------*/

void main_sd( void )
{
    /* Create the queue. */
    xQueue = xQueueCreate( mainQUEUE_LENGTH, sizeof( uint32_t ) );

    if( xQueue != NULL )
    {
        /* Start the two tasks as described in the comments at the top of this
        file. */
        xTaskCreate( prvFatSetupTask,                /* The function that implements the task. */
                    "FAT",                                 /* The text name assigned to the task - for debug only as it is not used by the kernel. */
                    configMINIMAL_STACK_SIZE * 2U,             /* The size of the stack to allocate to the task. */
                    NULL,                                 /* The parameter passed to the task - not used in this case. */
					tskIDLE_PRIORITY + 2,     /* The priority assigned to the task. */
                    NULL );                                /* The task handle is not required, so NULL is passed. */

        /* Start the tasks and timer running. */
        vTaskStartScheduler();
    }

    /* If all is well, the scheduler will now be running, and the following
    line will never be reached.  If the following line does execute, then
    there was insufficient FreeRTOS heap memory available for the Idle and/or
    timer tasks to be created.  See the memory management section on the
    FreeRTOS web site for more details on the FreeRTOS heap
    http://www.freertos.org/a00111.html. */
    for( ;; );
}
/*-----------------------------------------------------------*/

static void prvFatSetupTask( void *pvParameters )
{
TickType_t xNextWakeTime;
const unsigned long ulValueToSend = 100UL;
BaseType_t xReturned;
FF_Disk_t * pxDisk;

    /* Remove compiler warning about unused parameter. */
    ( void ) pvParameters;

    /* Initialise xNextWakeTime - this only needs to be done once. */
    xNextWakeTime = xTaskGetTickCount();

    init();

	mmc=malloc(sizeof(struct mmc));
	cfg=malloc(sizeof(struct mmc_config));
	ops=malloc(sizeof(struct mmc_ops));
	xmmc_cmd=malloc(sizeof(struct mmc_cmd));
	data=malloc(sizeof(struct mmc_data));

	bsp_printf("\n\r--- FreeRTOS Demo Start ---\n\r");
	bsp_printf("\r\nInitialize...");

	//Allocation Struct Space

	memset(mmc, 0, sizeof(struct mmc));
	memset(cfg, 0, sizeof(struct mmc_config));
	memset(ops, 0, sizeof(struct mmc_ops));
	memset(xmmc_cmd, 0, sizeof(struct mmc_cmd));
	memset(data, 0, sizeof(struct mmc_data));

	mmc->cfg = cfg;		//pass the pointer after malloc in struct
	mmc->cfg->ops = ops;//pass the pointer after malloc in struct

	sd_ctrl_mmc_probe(mmc,SDHC_BASE); //init SD Card driver

	IntcInitialize(mmc);	// init interrupt

	disk_initialize();

	pxDisk = FF_SDDiskInit("/sd0");

    FF_FILE *pxFile = ff_fopen("/sd0/freertos.txt", "a");
    if (!pxFile) {
        FF_PRINTF("ff_fopen failed: %s (%d)\r\n", strerror(stdioGET_ERRNO()),
                  stdioGET_ERRNO());
    }
    if (ff_fprintf(pxFile, "Write from FreeRTOS\n") < 0) {
        FF_PRINTF("ff_fprintf failed: %s (%d)\r\n", strerror(stdioGET_ERRNO()),
                  stdioGET_ERRNO());
    }
    if (-1 == ff_fclose(pxFile)) {
        FF_PRINTF("ff_fclose failed: %s (%d)\r\n", strerror(stdioGET_ERRNO()),
                  stdioGET_ERRNO());
    }
    FF_FS_Remove("/sd0");
    FF_Unmount(pxDisk);
    FF_SDDiskDelete(pxDisk);
    bsp_printf("\n\r--- FreeRTOS Demo Finish ---\n\r");

    vTaskDelete(NULL);
}
/*-----------------------------------------------------------*/

static void init(){
    // Initial I2C Protocol
	// Data Hold Time - Standard mode/Fast mode: 0.9us
	// SCL Clock Frequency: 100 - 400kHz
	// Start setup time: 4.7us

	// Data Setup Time - Standard mode: 250ns, Fast mode: 100ns
	// Low Period of SCL clock - Standard mode: 4.7us, Fast mode: 1.3us
	// High Period of SCL clock - Standard mode: 4.0us, Fast mode: 0.6us
	// Bus Free Time Between STOP and START Conditions - Standard mode: 4.7us, Fast mode: 1.3us

    I2c_Config i2c;
    i2c.samplingClockDivider    = 3;                        // Sampling rate = (FCLK/(samplingClockDivider + 1). Controls the rate at which the I2C controller samples SCL and SDA.
    i2c.timeout                 = 0;//I2C_CTRL_HZ/1000;     // Set to 0 in order to avoid timeout // Inactive timeout clock cycle. The controller will drop the transfer when the value of the timeout is reached or exceeded. Setting the timeout value to zero will disable the timeout feature.
    i2c.tsuDat                  = I2C_CTRL_HZ/10000000;  	// Data setup time. The number of clock cycles should SDA hold its state before the rising edge of SCL. Refer to your I2C slave datasheet.
    i2c.tLow                    = I2C_CTRL_HZ/666667;  		// The number of clock cycles of SCL in LOW state.
    i2c.tHigh                   = I2C_CTRL_HZ/1250000;  		// The number of clock cycles of SCL in HIGH state.
    i2c.tBuf                    = I2C_CTRL_HZ/666667;   	// The number of clock cycles delay before master can initiate a START bit after a STOP bit is issued. Refer to your I2C slave datasheet.

    i2c_applyConfig(I2C_CTRL, &i2c);

    bsp_init();
}
