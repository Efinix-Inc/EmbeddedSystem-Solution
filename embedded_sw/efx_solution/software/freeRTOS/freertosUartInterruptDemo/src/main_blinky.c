////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*
 * FreeRTOS Kernel V10.2.1
 * Copyright (C) 2019 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
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
 * http://www.FreeRTOS.org
 * http://aws.amazon.com/freertos
 *
 * 1 tab == 4 spaces!
 */

/******************************************************************************
* 
* @file main_blinky.c
* 
* NOTE 1: This project provides two demo applications.  A simple blinky style project,
*         and a more comprehensive test and demo application.  The
*         mainCREATE_SIMPLE_BLINKY_DEMO_ONLY setting in main.c is used to select
*         between the two.  See the notes on using mainCREATE_SIMPLE_BLINKY_DEMO_ONLY
*         in main.c.  This file implements the simply blinky style version.
*
* NOTE 2: This file only contains the source code that is specific to the basic demo.
*         Generic functions, such FreeRTOS hook functions, and functions required
*         to configure the hardware are defined in main.c.
*
*
* @brief main_blinky() creates one queue, and two tasks. It then starts the
*        scheduler.
*
* @note
* The Queue Send Task:
* The queue send task is implemented by the prvQueueSendTask() function in
* this file.  prvQueueSendTask() sits in a loop that causes it to repeatedly
* block for 1000 milliseconds, before sending the value 100 to the queue that
* was created within main_blinky().  Once the value is sent, the task loops
* back around to block for another 1000 milliseconds...and so on.
*
* The Queue Receive Task:
* The queue receive task is implemented by the prvQueueReceiveTask() function
* in this file.  prvQueueReceiveTask() sits in a loop where it repeatedly
* blocks on attempts to read data from the queue that was created within
* main_blinky().  When data is received, the task checks the value of the
* data, and if the value equals the expected 100, writes 'Blink' to the UART
* (the UART is used in place of the LED to allow easy execution in QEMU).  The
* 'block time' parameter passed to the queue receive function specifies that
* the task should be held in the Blocked state indefinitely to wait for data to
* be available on the queue.  The queue receive task will only leave the
* Blocked state when the queue send task writes to the queue.  As the queue
* send task writes to the queue every 1000 milliseconds, the queue receive
* task leaves the Blocked state every 1000 milliseconds, and therefore toggles
* the LED every 200 milliseconds.
*
******************************************************************************/

/* Standard includes. */
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

/* Priorities used by the tasks. */
#define mainQUEUE_RECEIVE_TASK_PRIORITY        ( tskIDLE_PRIORITY + 2 )
#define    mainQUEUE_SEND_TASK_PRIORITY        ( tskIDLE_PRIORITY + 1 )

/* The rate at which data is sent to the queue.  The 200ms value is converted
to ticks using the pdMS_TO_TICKS() macro. */
#ifdef SPINAL_SIM
#define mainQUEUE_SEND_FREQUENCY_MS            pdMS_TO_TICKS( 4 )
#else
#define mainQUEUE_SEND_FREQUENCY_MS            pdMS_TO_TICKS( 500 )
#endif
/* The maximum number items the queue can hold.  The priority of the receiving
task is above the priority of the sending task, so the receiving task will
preempt the sending task and remove the queue items each time the sending task
writes to the queue.  Therefore the queue will never have more than one item in
it at any time, and even with a queue length of 1, the sending task will never
find the queue full. */
#define mainQUEUE_LENGTH                    ( 1 )

/*
 * Called by main when mainCREATE_SIMPLE_BLINKY_DEMO_ONLY is set to 1 in
 * main.c.
 */
void main_blinky( void );

/*
 * The tasks as described in the comments at the top of this file.
 */
static void prvQueueReceiveTask( void *pvParameters );
static void prvQueueSendTask( void *pvParameters );

/* The queue used by both tasks. */
static QueueHandle_t xQueue = NULL;

/*******************************************************************************
*
* @brief This function initializes the FreeRTOS tasks and starts the scheduler. It also
*        creates a queue, and two tasks that use this queue: one to send values to the
*        queue and the other to receive and process these values.
*
* @param   None.
*
* @return  None.
*
* @note    The function first creates a queue using xQueueCreate(). If the queue
*          is created successfully, it then creates two tasks:
*          - prvQueueReceiveTask: A task that receives values from the queue,
*            checks if the received value matches an expected value, and toggles
*            an LED accordingly.
*          - prvQueueSendTask: A task that sends a value to the queue at regular
*            intervals using xQueueSend().
*          After creating the tasks, the scheduler is started using vTaskStartScheduler().
*
******************************************************************************/
void main_blinky( void )
{
    /* Create the queue. */
    xQueue = xQueueCreate( mainQUEUE_LENGTH, sizeof( uint32_t ) );

    if( xQueue != NULL )
    {
        /* Start the two tasks as described in the comments at the top of this
        file. */
        xTaskCreate( prvQueueReceiveTask,                /* The function that implements the task. */
                    "Rx",                                 /* The text name assigned to the task - for debug only as it is not used by the kernel. */
                    configMINIMAL_STACK_SIZE * 2U,             /* The size of the stack to allocate to the task. */
                    NULL,                                 /* The parameter passed to the task - not used in this case. */
                    mainQUEUE_RECEIVE_TASK_PRIORITY,     /* The priority assigned to the task. */
                    NULL );                                /* The task handle is not required, so NULL is passed. */

        xTaskCreate( prvQueueSendTask, "TX", configMINIMAL_STACK_SIZE * 2U, NULL, mainQUEUE_SEND_TASK_PRIORITY, NULL );

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


/*******************************************************************************
*
* @brief This function is a FreeRTOS task that sends a value to a queue at regular intervals.
*        The task uses vTaskDelayUntil() to introduce a delay between sending values.
*
* @param   pvParameters: Pointer to task parameters (unused in this function).
*
* @return  None.
*
* @note    The function initializes xNextWakeTime to the current tick count and then
*          enters a loop. Inside the loop, it delays until it's time to send the
*          next value, and then sends ulValueToSend to the queue using xQueueSend().
*          The function uses a block time of 0U to ensure that the sending operation
*          doesn't block, which is expected since the queue should always be empty
*          at this point in the code.
*
******************************************************************************/
static void prvQueueSendTask( void *pvParameters )
{
TickType_t xNextWakeTime;
const unsigned long ulValueToSend = 100UL;
BaseType_t xReturned;

    /* Remove compiler warning about unused parameter. */
    ( void ) pvParameters;

    /* Initialise xNextWakeTime - this only needs to be done once. */
    xNextWakeTime = xTaskGetTickCount();

    for( ;; )
    {
        /* Place this task in the blocked state until it is time to run again. */
        vTaskDelayUntil( &xNextWakeTime, mainQUEUE_SEND_FREQUENCY_MS );

        /* Send to the queue - causing the queue receive task to unblock and
        toggle the LED.  0 is used as the block time so the sending operation
        will not block - it shouldn't need to block as the queue should always
        be empty at this point in the code. */
        xReturned = xQueueSend( xQueue, &ulValueToSend, 0U );
        configASSERT( xReturned == pdPASS );
    }
}
/*******************************************************************************
*
* @brief This function is a FreeRTOS task that waits for values to be received on a queue.
*        Upon receiving a value, it checks if the received value matches the expected
*        value (100UL). If it matches, it toggles an LED and sends a pass message.
*        Otherwise, it sends a fail message.
*
* @param   pvParameters: Pointer to task parameters (unused in this function).
*
* @return  None.
*
* @note    The function waits indefinitely for data to arrive in the queue using
*          xQueueReceive(). If INCLUDE_vTaskSuspend is set to 1 in FreeRTOSConfig.h,
*          this task will block indefinitely when waiting for data.
*          The expected value is compared with the received value. If they match,
*          the LED is toggled and a pass message is sent. Otherwise, a fail message
*          is sent.
*
******************************************************************************/

static void prvQueueReceiveTask( void *pvParameters )
{
unsigned long ulReceivedValue;
const unsigned long ulExpectedValue = 100UL;
const char * const pcPassMessage = "Blink\r\n";
const char * const pcFailMessage = "Unexpected value received\r\n";
extern void vSendString( const char * const pcString );
extern void vToggleLED( void );

    /* Remove compiler warning about unused parameter. */
    ( void ) pvParameters;

    for( ;; )
    {
        /* Wait until something arrives in the queue - this task will block
        indefinitely provided INCLUDE_vTaskSuspend is set to 1 in
        FreeRTOSConfig.h. */
        xQueueReceive( xQueue, &ulReceivedValue, portMAX_DELAY );

        /*  To get here something must have been received from the queue, but
        is it the expected value?  If it is, toggle the LED. */
        if( ulReceivedValue == ulExpectedValue )
        {
            vSendString( pcPassMessage );
            vToggleLED();
            ulReceivedValue = 0U;
        }
        else
        {
            vSendString( pcFailMessage );
        }
    }
}


