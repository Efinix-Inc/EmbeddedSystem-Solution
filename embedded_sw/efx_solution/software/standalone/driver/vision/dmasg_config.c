#include "bsp.h"
#include "plic.h"
#include "device_config.h"
#include "dmasg_config.h"
#include "dmasg.h"

void dma_init(){
   //configure PLIC
   plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0); //cpu 0 accept all interrupts with priority above 0
   
   //enable PLIC DMASG channel 0 interrupt listening (But for the demo, we enable the DMASG internal interrupts later)
   plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, PLIC_DMASG_CHANNEL, 1);
   plic_set_priority(BSP_PLIC, PLIC_DMASG_CHANNEL, 1);
   
   //enable interrupts
   csr_write(mtvec, trap_entry); //Set the machine trap vector (../common/trap.S)
   csr_set(mie, MIE_MEIE); //Enable external interrupts
   csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

//Used on unexpected trap/interrupt codes
void crash(){
   bsp_printf("\n*** CRASH ***\n");
   while(1);
}
