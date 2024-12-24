////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

/*
 * FreeRTOS+TCP V3.1.0
 * Copyright (C) 2022 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
 *
 * SPDX-License-Identifier: MIT
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
 * http://aws.amazon.com/freertos
 * http://www.FreeRTOS.org
 */

/*****************************************************************************
* Note: This file is Not! to be used as is. The purpose of this file is to provide
* a template for writing a network interface. Each network interface will have to provide
* concrete implementations of the functions in this file.
*
* See the following URL for an explanation of this file and its functions:
* https://freertos.org/FreeRTOS-Plus/FreeRTOS_Plus_TCP/Embedded_Ethernet_Porting.html
*
*****************************************************************************/

/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "list.h"

/* FreeRTOS+TCP includes. */
#include "FreeRTOS_IP.h"

/* Efinix includes. */
#include "userDef.h"
#include "dmasg.h"
#include "efx_tse_mac.h"
#include "efx_tse_phy.h"
#include "plic.h"
#include "riscv.h"

/* If ipconfigETHERNET_DRIVER_FILTERS_FRAME_TYPES is set to 1, then the Ethernet
 * driver will filter incoming packets and only pass the stack those packets it
 * considers need processing. */
#if ( ipconfigETHERNET_DRIVER_FILTERS_FRAME_TYPES == 0 )
    #define ipCONSIDER_FRAME_FOR_PROCESSING( pucEthernetBuffer )    eProcessBuffer
#else
    #define ipCONSIDER_FRAME_FOR_PROCESSING( pucEthernetBuffer )    eConsiderFrameForProcessing( ( pucEthernetBuffer ) )
#endif

#define FRAME_PACKET  	256
#define BUFFER_SIZE 	1514
#define mem ((u32*)0xA00000)

BaseType_t InitialiseNetwork( void );
void SendData(uint8_t *pucEthernetBuffer,size_t xDataLength);
void interrupt_init();
void program_descriptor();
static void prvEMACDeferredInterruptHandlerTask( void *pvParameters );
int Poll_Interrupt( void );
u32 ReceiveSize(void);
void ReceiveData( uint8_t *pucEthernetBuffer , size_t xBytesReceived );
void flush_data_cache();
void freertos_risc_v_application_interrupt_handler();
void userInterrupt();
void crash();

u32 cur_des = 0;
u32 ulPHYLinkStatus = 0;
volatile struct dmasg_descriptor descriptors0[FRAME_PACKET]  __attribute__ ((aligned (64)));

BaseType_t xNetworkInterfaceInitialise( void )
{
	BaseType_t xReturn;

	/*
	 * Perform the hardware specific network initialisation here.  Typically
	 * that will involve using the Ethernet driver library to initialise the
	 * Ethernet (or other network) hardware, initialise DMA descriptors, and
	 * perform a PHY auto-negotiation to obtain a network link.
	 *
	 * This example assumes InitialiseNetwork() is an Ethernet peripheral driver
	 * library function that returns 0 if the initialisation fails.
	 */
	if( InitialiseNetwork() == 0 )
	{
		xReturn = pdFAIL;
	}
	else
	{
		xReturn = pdPASS;
	}

	return xReturn;
}

BaseType_t xNetworkInterfaceOutput( NetworkBufferDescriptor_t * const pxDescriptor,
                                    BaseType_t xReleaseAfterSend )
{
    /* Simple network interfaces (as opposed to more efficient zero copy network
    interfaces) just use Ethernet peripheral driver library functions to copy
    data from the FreeRTOS+TCP buffer into the peripheral driver's own buffer.
    This example assumes SendData() is a peripheral driver library function that
    takes a pointer to the start of the data to be sent and the length of the
    data to be sent as two separate parameters.  The start of the data is located
    by pxDescriptor->pucEthernetBuffer.  The length of the data is located
    by pxDescriptor->xDataLength. */
    SendData( pxDescriptor->pucEthernetBuffer, pxDescriptor->xDataLength );

    /* Call the standard trace macro to log the send event. */
    iptraceNETWORK_INTERFACE_TRANSMIT();

    if( xReleaseAfterSend != pdFALSE )
    {
        /* It is assumed SendData() copies the data out of the FreeRTOS+TCP Ethernet
        buffer.  The Ethernet buffer is therefore no longer needed, and must be
        freed for re-use. */
        vReleaseNetworkBufferAndDescriptor( pxDescriptor );
    }

    return pdTRUE;
}

BaseType_t xGetPhyLinkStatus( void )
{
	if(ulPHYLinkStatus)
	{
		return pdPASS;
	}
	else
	{
		return pdFALSE;
	}
}

BaseType_t InitialiseNetwork( void )
{
    int speed,Value,reg;
    int drv_sel,link_speed;
    BaseType_t xReturn = pdFAIL;

	ulPHYLinkStatus=0;
	MacRst(1, 1);
    drv_sel = Phy_identification();
	interrupt_init();
	program_descriptor();
	dmasg_priority(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, 0, 0);
	dmasg_priority(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, 0, 0);

  	if (drv_sel)
  	{
  		rtl8211_drv_init();
  		speed=rtl8211_drv_linkup();
  	}
  	else speed = PhyNormalInit();

	if((speed == Speed_1000Mhz) || (speed == Speed_100Mhz) || (speed == Speed_10Mhz))
	{
		MacNormalInit(speed);

		ulPHYLinkStatus=1;

		xReturn = pdPASS;

	}

	xTaskCreate( prvEMACDeferredInterruptHandlerTask,"ETHER_TASK",configMINIMAL_STACK_SIZE*4,NULL,configMAX_PRIORITIES-5, NULL);

	return xReturn;
}

/* The deferred interrupt handler is a standard RTOS task.  FreeRTOS's centralised
deferred interrupt handling capabilities can also be used. */
static void prvEMACDeferredInterruptHandlerTask( void *pvParameters )
{
	NetworkBufferDescriptor_t *pxBufferDescriptor;
	size_t xBytesReceived;
	/* Used to indicate that xSendEventStructToIPTask() is being called because
    of an Ethernet receive event. */
	IPStackEvent_t xRxEvent;

	for( ;; )
	{
		/* Wait for the Ethernet MAC interrupt to indicate that another packet
        has been received.  The task notification is used in a similar way to a
        counting semaphore to count Rx events, but is a lot more efficient than
        a semaphore. */
		//ulTaskNotifyTake( pdFALSE, portMAX_DELAY );
		while(!(Poll_Interrupt()));

		/* See how much data was received.  Here it is assumed ReceiveSize() is
        a peripheral driver function that returns the number of bytes in the
        received Ethernet frame. */
		xBytesReceived = ReceiveSize();

		if( xBytesReceived > 0 )
		{
			/* Allocate a network buffer descriptor that points to a buffer
            large enough to hold the received frame.  As this is the simple
            rather than efficient example the received data will just be copied
            into this buffer. */
			pxBufferDescriptor = pxGetNetworkBufferWithDescriptor( xBytesReceived, 0 );

			if( pxBufferDescriptor != NULL )
			{
				/* pxBufferDescriptor->pucEthernetBuffer now points to an Ethernet
                buffer large enough to hold the received data.  Copy the
                received data into pcNetworkBuffer->pucEthernetBuffer.  Here it
                is assumed ReceiveData() is a peripheral driver function that
                copies the received data into a buffer passed in as the function's
                parameter.  Remember! While is is a simple robust technique -
                it is not efficient.  An example that uses a zero copy technique
                is provided further down this page. */
				ReceiveData( pxBufferDescriptor->pucEthernetBuffer, xBytesReceived );
				pxBufferDescriptor->xDataLength = xBytesReceived;

				/* See if the data contained in the received Ethernet frame needs
                to be processed.  NOTE! It is preferable to do this in
                the interrupt service routine itself, which would remove the need
                to unblock this task for packets that don't need processing. */
				if( eConsiderFrameForProcessing( pxBufferDescriptor->pucEthernetBuffer )
						== eProcessBuffer )
				{
					/* The event about to be sent to the TCP/IP is an Rx event. */
					xRxEvent.eEventType = eNetworkRxEvent;

					/* pvData is used to point to the network buffer descriptor that
                    now references the received data. */
					xRxEvent.pvData = ( void * ) pxBufferDescriptor;

					/* Send the data to the TCP/IP stack. */
					if( xSendEventStructToIPTask( &xRxEvent, 0 ) == pdFALSE )
					{
						/* The buffer could not be sent to the IP task so the buffer
                        must be released. */
						vReleaseNetworkBufferAndDescriptor( pxBufferDescriptor );

						/* Make a call to the standard trace macro to log the
                        occurrence. */
						iptraceETHERNET_RX_EVENT_LOST();
					}
					else
					{
						/* The message was successfully sent to the TCP/IP stack.
                        Call the standard trace macro to log the occurrence. */
						iptraceNETWORK_INTERFACE_RECEIVE();
					}
				}
				else
				{
					/* The Ethernet frame can be dropped, but the Ethernet buffer
                    must be released. */
					vReleaseNetworkBufferAndDescriptor( pxBufferDescriptor );
				}
			}
			else
			{
				/* The event was lost because a network buffer was not available.
                Call the standard trace macro to log the occurrence. */
				iptraceETHERNET_RX_EVENT_LOST();
			}
		}
	}
}

void SendData(uint8_t *pucEthernetBuffer,size_t xDataLength)
{
	dmasg_input_memory(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, ((u32)pucEthernetBuffer), 64);
    dmasg_output_stream(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, 0, 0, 0, 1);
    dmasg_direct_start(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, xDataLength, 0);
    while(dmasg_busy(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH));
}

void interrupt_init()
{
	plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
	plic_set_priority(BSP_PLIC, TSE_TX_INTR, 1);
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, TSE_TX_INTR, 1);
    csr_set(mie, MIE_MEIE);
	csr_write(mstatus, csr_read(mstatus) |  MSTATUS_MPP | MSTATUS_MIE);
}

void program_descriptor()
{

	for (int j=0; j<FRAME_PACKET; j++)
	{
		descriptors0[j].control = (u32)((BUFFER_SIZE)-1)  | 1 << 30;;
		descriptors0[j].from    = 0;
		descriptors0[j].to      = (u32)(mem + (j *(BUFFER_SIZE)) );
		descriptors0[j].next    = (u32) (descriptors0 + (j+1));
		descriptors0[j].status  = 0;
	}

	descriptors0[FRAME_PACKET-1].next = (u32)(descriptors0);	//last descriptors point to first descriptors

	dmasg_interrupt_pending_clear(TSEMAC_DMASG_BASE,TSE_DMASG_TX_CH,0xFFFFFFFF);
	dmasg_output_memory (TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH,  (u32)mem, 64);
	dmasg_input_stream(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, 0, 1, 1);
	dmasg_interrupt_config(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, DMASG_CHANNEL_INTERRUPT_LINKED_LIST_UPDATE_MASK);
	dmasg_linked_list_start(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, (u32)descriptors0);

	cur_des = 0;
}

int Poll_Interrupt( void )
{
	if(descriptors0[cur_des].status & 0x3FFFFFFF) {
		return 1;
	} else {
		return 0;
	}
}

u32 ReceiveSize(void)
{
	u32 dmasg_len;
	dmasg_len = descriptors0[cur_des].status & DMASG_DESCRIPTOR_STATUS_BYTES;;
	return dmasg_len;
}

void ReceiveData( uint8_t *pucEthernetBuffer , size_t xBytesReceived )
{
	descriptors0[cur_des].status = 0;
	memcpy(pucEthernetBuffer, (u8*)(mem + (cur_des * BUFFER_SIZE)), xBytesReceived);
	cur_des = (cur_des + 1) & (FRAME_PACKET-1);
}

void flush_data_cache()
{
    asm(".word(0x500F)");
}

void freertos_risc_v_application_interrupt_handler(){
	int32_t mcause = csr_read(mcause);
	int32_t interrupt = mcause < 0;
	int32_t cause     = mcause & 0xF;
	if(interrupt){
		switch(cause){
		case CAUSE_MACHINE_EXTERNAL: userInterrupt(); break;
		default: crash(); break;
		}
	} else {
		crash();
	}
}

void userInterrupt()
{
	uint32_t claim;

	while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) {
		switch(claim){
		case TSE_TX_INTR:
			dmasg_interrupt_config(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, DMASG_CHANNEL_INTERRUPT_LINKED_LIST_UPDATE_MASK);
			flush_data_cache();
			break;
		default:
			crash();
			break;
		}
		plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
	}
}

void crash(){
	bsp_printf("\n*** CRASH ***\n");
	while(1);
}
