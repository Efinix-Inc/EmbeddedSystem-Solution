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

/* FreeRTOS includes. */
#include "FreeRTOS.h"
#include "list.h"

/* FreeRTOS+TCP includes. */
#include "FreeRTOS_IP.h"

/* Efinix includes. */
#include "userDef.h"
#include "dmasg.h"
#include "rtl8211fd.h"
#include "efx_tse_mac.h"
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

#define EMAC_IF_RX_EVENT        1UL
#define EMAC_IF_TX_EVENT        2UL
#define EMAC_IF_ERR_EVENT       4UL
#define EMAC_IF_ALL_EVENT       ( EMAC_IF_RX_EVENT | EMAC_IF_TX_EVENT | EMAC_IF_ERR_EVENT )

typedef struct {
	uint8_t* pucEthernetBuffer;
	size_t xDataLength;
} DMADescriptor_t;
DMADescriptor_t tx_desc;

static BaseType_t InitialiseNetwork( void );
static u32 ReceiveSize(void);
static void interrupt_init();
static void program_descriptor();
static void userInterrupt();
static void crash();
static void prvEMACDeferredInterruptHandlerTask( void *pvParameters );
static void prvNetworkInterfaceInput( void );
static struct dmasg_descriptor* pxGetNextTransmitBuffer(void);
static struct dmasg_descriptor* pxGetNextReceiveBuffer(void);
void freertos_risc_v_application_interrupt_handler();

u32 rx_cur_desc = 0;
u32 tx_cur_desc = 0;
u32 ulPHYLinkStatus = 0;
struct dmasg_descriptor rx_dmasg_desc[FRAME_PACKET]  __attribute__ ((aligned (64)));
struct dmasg_descriptor tx_dmasg_desc[FRAME_PACKET]  __attribute__ ((aligned (64)));

static TaskHandle_t xRxTaskHandle = NULL;

BaseType_t xNetworkInterfaceInitialise( void )
{
	BaseType_t xReturn;

	if( InitialiseNetwork() == 0 ) {
		xReturn = pdFAIL;
	} else {
		xReturn = pdPASS;
	}

	return xReturn;
}

BaseType_t xNetworkInterfaceOutput( NetworkBufferDescriptor_t * const pxDescriptor,
                                    BaseType_t xReleaseAfterSend )
{
	struct dmasg_descriptor *pxTransmitBuffer = pxGetNextTransmitBuffer();

	if(pxTransmitBuffer == NULL) {
		FreeRTOS_debug_printf( ("xNetworkInterfaceOutput: No more TX buffers available\n") );
		if(xReleaseAfterSend != pdFALSE) {
			vReleaseNetworkBufferAndDescriptor(pxDescriptor);
		}
		return pdFAIL;
	}

	uint8_t* previousBuffer = (u8*)(u32)pxTransmitBuffer->from;

	struct dmasg_descriptor newBuffer;

	newBuffer.from = (u32)pxDescriptor->pucEthernetBuffer;
	newBuffer.control = (u32)((pxDescriptor->xDataLength)-1)  | 1 << 30;
	newBuffer.to  = 0;
	newBuffer.next  = 0;
	newBuffer.status  = 0;

	*pxTransmitBuffer = newBuffer;

	dmasg_input_memory (TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH,  pxTransmitBuffer->from, 64);
	dmasg_output_stream(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, 0, 0, 0, 1);
	dmasg_interrupt_config(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, DMASG_CHANNEL_INTERRUPT_DESCRIPTOR_COMPLETION_MASK);
    dmasg_linked_list_start(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, (u32) pxTransmitBuffer);

    iptraceNETWORK_INTERFACE_TRANSMIT();

	if(xReleaseAfterSend != pdFALSE) {
		pxDescriptor->pucEthernetBuffer = NULL;
		vReleaseNetworkBufferAndDescriptor(pxDescriptor);
	}

	if(previousBuffer != NULL) {
		vReleaseNetworkBuffer(previousBuffer);
	}

    return pdTRUE;
}

BaseType_t xGetPhyLinkStatus( void )
{
	if(ulPHYLinkStatus) {
		return pdPASS;
	} else {
		return pdFALSE;
	}
}

static BaseType_t InitialiseNetwork( void )
{
    int speed,Value,reg;
    BaseType_t xReturn = pdFAIL;

	ulPHYLinkStatus=0;

	MacRst(1, 1);

	rtl8211_drv_init();
	speed=rtl8211_drv_linkup();

	if((speed == Speed_1000Mhz) || (speed == Speed_100Mhz) || (speed == Speed_10Mhz)) {
		MacNormalInit(speed);

		ulPHYLinkStatus=1;

		interrupt_init();
		program_descriptor();
		dmasg_priority(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, 0, 0);
		dmasg_priority(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, 0, 0);

		xTaskCreate( prvEMACDeferredInterruptHandlerTask,"ETHER_TASK",configMINIMAL_STACK_SIZE*4,NULL,RX_HANDLER_PRIORITY, &xRxTaskHandle);

		xReturn = pdPASS;
	}

	return xReturn;
}

static void interrupt_init()
{
	plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
	plic_set_priority(BSP_PLIC, TSE_RX_INTR, 1);
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, TSE_RX_INTR, 1);
	plic_set_priority(BSP_PLIC, TSE_TX_INTR, 1);
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, TSE_TX_INTR, 1);
    csr_set(mie, MIE_MEIE);
	csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

static void program_descriptor()
{
	size_t uRequestedBytes = BUFFER_SIZE;
	for (int j=0; j<FRAME_PACKET; j++) {
		rx_dmasg_desc[j].control = (u32)((BUFFER_SIZE)-1)  | 1 << 30;
		rx_dmasg_desc[j].from    = 0;
		rx_dmasg_desc[j].to      = (u32)pucGetNetworkBuffer(&uRequestedBytes);
		rx_dmasg_desc[j].next    = (u32) (rx_dmasg_desc + (j+1));
		rx_dmasg_desc[j].status  = 0;
	}

	for (int j=0; j<FRAME_PACKET; j++) {
		tx_dmasg_desc[j].control = (u32)((BUFFER_SIZE)-1)  | 1 << 30;
		tx_dmasg_desc[j].from    = 0;
		tx_dmasg_desc[j].to      = 0;
		tx_dmasg_desc[j].next    = (u32) (tx_dmasg_desc + (j+1));
		tx_dmasg_desc[j].status  = DMASG_DESCRIPTOR_STATUS_COMPLETED;
	}

	rx_dmasg_desc[FRAME_PACKET-1].next = (u32)(rx_dmasg_desc);
	tx_dmasg_desc[FRAME_PACKET-1].next = (u32)(tx_dmasg_desc);

	dmasg_interrupt_pending_clear(TSEMAC_DMASG_BASE,TSE_DMASG_RX_CH,0xFFFFFFFF);
	dmasg_output_memory (TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH,  (u32)mem, 64);
	dmasg_input_stream(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, 0, 1, 1);
	dmasg_interrupt_config(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, DMASG_CHANNEL_INTERRUPT_LINKED_LIST_UPDATE_MASK);
	dmasg_linked_list_start(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, (u32)rx_dmasg_desc);

	dmasg_interrupt_pending_clear(TSEMAC_DMASG_BASE,TSE_DMASG_TX_CH,0xFFFFFFFF);
	dmasg_interrupt_config(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, DMASG_CHANNEL_INTERRUPT_DESCRIPTOR_COMPLETION_MASK);

	rx_cur_desc = 0;
	tx_cur_desc = 0;
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

static void userInterrupt()
{
	uint32_t claim;
	BaseType_t xHigherPriorityTaskWoken = pdFALSE;

	while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) {
		switch(claim){
		case TSE_RX_INTR:
			if( xRxTaskHandle != NULL ) {
		        xTaskNotifyFromISR( xRxTaskHandle, EMAC_IF_RX_EVENT, eSetBits, &( xHigherPriorityTaskWoken ) );
		        portYIELD_FROM_ISR( xHigherPriorityTaskWoken );
		    }
			dmasg_interrupt_config(TSEMAC_DMASG_BASE, TSE_DMASG_RX_CH, DMASG_CHANNEL_INTERRUPT_LINKED_LIST_UPDATE_MASK);
			break;
		case TSE_TX_INTR:
    		tx_dmasg_desc[tx_cur_desc].status  = DMASG_DESCRIPTOR_STATUS_COMPLETED;
    		tx_cur_desc = (tx_cur_desc + 1) & (FRAME_PACKET-1);
			dmasg_interrupt_config(TSEMAC_DMASG_BASE, TSE_DMASG_TX_CH, DMASG_CHANNEL_INTERRUPT_DESCRIPTOR_COMPLETION_MASK);
			break;
		default:
			crash();
			break;
		}
		plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
	}
}

static void crash(){
	bsp_printf("\n*** CRASH ***\n");
	while(1);
}

static struct dmasg_descriptor* pxGetNextTransmitBuffer(void) {
	for(BaseType_t x = 0; x < FRAME_PACKET; x++) {
		if(tx_dmasg_desc[x].status == DMASG_DESCRIPTOR_STATUS_COMPLETED) {
			return &tx_dmasg_desc[x];
		}
	}

	return NULL;
}

static void prvEMACDeferredInterruptHandlerTask( void *pvParameters )
{
	uint32_t ulISREvents = 0U;
	BaseType_t xResult;
	size_t xBytesReceived;

	const TickType_t ulMaxBlockTime = pdMS_TO_TICKS( 100UL );

	for( ;; ) {
		xBytesReceived = ReceiveSize();

        if( xBytesReceived <= 0 ) {
			xTaskNotifyWait( 0U, EMAC_IF_ALL_EVENT, &( ulISREvents ), ulMaxBlockTime );
        } else if( ( ulISREvents & EMAC_IF_RX_EVENT ) != 0 ) {
            prvNetworkInterfaceInput();
        	rx_dmasg_desc[rx_cur_desc].status = 0;
        	rx_cur_desc = (rx_cur_desc + 1) & (FRAME_PACKET-1);
        }
  	}
}

static u32 ReceiveSize(void)
{
	u32 dmasg_len;
	dmasg_len = rx_dmasg_desc[rx_cur_desc].status & DMASG_DESCRIPTOR_STATUS_BYTES;;
	return dmasg_len;
}

static void prvNetworkInterfaceInput( void )
{
	struct dmasg_descriptor* pxReceiveBuffer = pxGetNextReceiveBuffer();

	NetworkBufferDescriptor_t* pxDescriptor = pxGetNetworkBufferWithDescriptor(BUFFER_SIZE, 0);

	uint8_t* pucTemp = pxDescriptor->pucEthernetBuffer;

	pxDescriptor->pucEthernetBuffer = (uint8_t*)(u32)(pxReceiveBuffer->to);
	pxDescriptor->xDataLength = ReceiveSize();

	pxReceiveBuffer->to = (u32)pucTemp;

	*((NetworkBufferDescriptor_t **) (pxDescriptor->pucEthernetBuffer - ipBUFFER_PADDING) ) = pxDescriptor;

	if(eConsiderFrameForProcessing(pxDescriptor->pucEthernetBuffer) == eProcessBuffer) {
		IPStackEvent_t xRxEvent;
		xRxEvent.eEventType = eNetworkRxEvent;
		xRxEvent.pvData = (void*) pxDescriptor;

		if(xSendEventStructToIPTask(&xRxEvent, 0) == pdFALSE) {
			vReleaseNetworkBufferAndDescriptor(pxDescriptor);
			iptraceETHERNET_RX_EVENT_LOST();
		} else {
			iptraceNETWORK_INTERFACE_RECEIVE();
		}
	} else {
		vReleaseNetworkBufferAndDescriptor(pxDescriptor);
	}
}

static struct dmasg_descriptor* pxGetNextReceiveBuffer(void) {
	return &rx_dmasg_desc[rx_cur_desc];
}
