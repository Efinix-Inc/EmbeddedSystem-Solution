
#include "type.h"
#include "bsp.h"
#include "dmasg.h"
#include "riscv.h"
#include "base.h"

#define DMASG_BASE		IO_APB_SLAVE_0_INPUT
#define FRAME_RATE		4
#define BUFFER_SIZE		128
#define ST32_IN			1	//WRITE
#define ST32_OUT		0	//READ

#define mem32 ((volatile uint32_t*)0x10000)
volatile struct dmasg_descriptor descriptors0[FRAME_RATE+1]  __attribute__ ((aligned (64)));
volatile struct dmasg_descriptor descriptors1[FRAME_RATE+1]  __attribute__ ((aligned (64)));

#define sb32			0x10000
#define db32			0x20000

u32 data;

void flush_data_cache(){
    asm(".word(0x500F)");
}

void program_descriptor() {
	for (int j=0; j<FRAME_RATE+1; j=j+1 ) {

                        if(j == FRAME_RATE) {

                        	descriptors0[j].status  = DMASG_DESCRIPTOR_STATUS_COMPLETED;
                        	descriptors1[j].status  = DMASG_DESCRIPTOR_STATUS_COMPLETED;

                        } else {
                        	descriptors0[j].control = (u32)((BUFFER_SIZE)-1)  | 1 << 30 ;;
                        	descriptors0[j].from    = 0;
                        	descriptors0[j].to      = (u32)(db32 + (j *(BUFFER_SIZE)) );
                        	descriptors0[j].next    = (u32) (descriptors0 + (j+1));
                        	descriptors0[j].status  = 0;

                        	descriptors1[j].control = (u32)((BUFFER_SIZE)-1)  | 1 << 30 ;;
                        	descriptors1[j].from    = (u32)(sb32 + (j *(BUFFER_SIZE)));
                        	descriptors1[j].to      = 0;
                        	descriptors1[j].next    = (u32) (descriptors1 + (j+1));
                        	descriptors1[j].status  = 0;

                        }
	}
}

void main() {

	u32 value;

    bsp_putString("DMA+SOC TEST\n\r");

    for(int a=0;a<BUFFER_SIZE*FRAME_RATE;a++) mem32[a] = 0x1000+a;

    bsp_putString("Running DMA Direct Mode Loopback Test...\n\r");
    dmasg_priority(DMASG_BASE, ST32_IN, 0, 0);
    dmasg_priority(DMASG_BASE, ST32_OUT, 0, 0);

    dmasg_output_memory (DMASG_BASE, ST32_IN,  db32, 16);
    dmasg_input_stream(DMASG_BASE, ST32_IN, 0, 1, 0);
    dmasg_direct_start(DMASG_BASE, ST32_IN, BUFFER_SIZE*FRAME_RATE, 0);

    dmasg_input_memory (DMASG_BASE, ST32_OUT,  sb32, 16);
    dmasg_output_stream(DMASG_BASE, ST32_OUT, 0, 0, 0, 1);
    dmasg_direct_start(DMASG_BASE, ST32_OUT, BUFFER_SIZE*FRAME_RATE, 0);

    while(dmasg_busy(DMASG_BASE, ST32_OUT));
    flush_data_cache();
    while(dmasg_busy(DMASG_BASE, ST32_IN));
    flush_data_cache();

    bsp_putString("DMA Direct Mode Loopback Test Passed!\n\r");

    bsp_putString("Running DMA SG Mode Loopback Test...\n\r");
    program_descriptor();
    dmasg_output_memory (DMASG_BASE, ST32_IN,  0, 16);
    dmasg_input_stream(DMASG_BASE, ST32_IN, 0, 1, 0);
    dmasg_linked_list_start(DMASG_BASE, ST32_IN, (u32) descriptors0);

    dmasg_input_memory (DMASG_BASE, ST32_OUT,  0, 16);
    dmasg_output_stream(DMASG_BASE, ST32_OUT, 0, 0, 1, 1);
    dmasg_linked_list_start(DMASG_BASE, ST32_OUT, (u32) descriptors1);

    while(dmasg_busy(DMASG_BASE, ST32_OUT));
    flush_data_cache();
    while(dmasg_busy(DMASG_BASE, ST32_IN));
    flush_data_cache();
    bsp_putString("DMA SG Mode Loopback Test Passed\n\r");

}

