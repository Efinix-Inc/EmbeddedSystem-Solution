////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "intc.h"
#include "vision/dmasg_config.h"


IntStruct IntPtr;
struct sd_ctrl_dev *dev;
char		new_line_detected	= 0;
uint32_t	counter				= 0;
uint8_t		buffer [20];
/************************** Function Definitions *****************************/
void trap_entry();

/********************************* Function **********************************/
void externalInterrupt()
{
	u32 int_status;
	sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS1+4,0x00);

	int_status = sd_ctrl_read(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0);

	if(int_status&INT_COMMAND_COMPLETE) {
		IntPtr.command_complete = 0x1;

		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_COMMAND_COMPLETE);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : COMMAND_COMPLETE\n\r");
#endif //(DEBUG_PRINTF_EN == 1)
	}

	if(int_status&INT_TRANSFER_COMPLETE) {
		IntPtr.transfer_complete = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_TRANSFER_COMPLETE);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : TRANSFER_COMPLETE\n\r");
#endif //(DEBUG_PRINTF_EN == 1)
	}

	if(int_status&INT_BLOCK_GAP_EVENT) {
		IntPtr.block_gap_event = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_BLOCK_GAP_EVENT);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : BLOCK_GAP_EVENT\n\r");
#endif //(DEBUG_PRINTF_EN == 1)
	}

	if(int_status&INT_BUFFER_WRITE_READY) {
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_BUFFER_WRITE_READY);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : BUFFER_WRITE_READY\n\r");
#endif //(DEBUG_PRINTF_EN == 1)
	}

	if(int_status&INT_BUFFER_READ_READY) {
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_BUFFER_READ_READY);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : BUFFER_READ_READY\n\r");
#endif //(DEBUG_PRINTF_EN == 1)

	}

	if(int_status&INT_CARD_INSERTION) {
		IntPtr.card_insertion = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_CARD_INSERTION);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : CARD_INSERTION\n\r");
#endif //(DEBUG_PRINTF_EN == 1)
	}

	if(int_status&INT_CARD_REMOVAL) {
		IntPtr.card_removal = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_CARD_REMOVAL);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : CARD_REMOVAL\n\r");
#endif //(DEBUG_PRINTF_EN == 1)

	}

	if(int_status&INT_COMMAND_TIMEOUT_ERROR) {
		IntPtr.command_timeout_error = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_COMMAND_TIMEOUT_ERROR);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : COMMAND_TIMEOUT_ERROR\n\r");
#endif //(DEBUG_PRINTF_EN == 1)

	}

	if(int_status&INT_COMMAND_CRC_ERROR) {
		IntPtr.command_crc_error = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_COMMAND_CRC_ERROR);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : COMMAND_CRC_ERROR\n\r");
#endif //(DEBUG_PRINTF_EN == 1)

	}

	if(int_status&INT_COMMAND_END_BIT_ERROR) {
		IntPtr.command_end_bit_error = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_COMMAND_END_BIT_ERROR);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : COMMAND_END_BIT_ERROR\n\r");
#endif //(DEBUG_PRINTF_EN == 1)

	}

	if(int_status&INT_COMMAND_INDEX_ERROR) {
		IntPtr.command_index_error = 0x1;
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_COMMAND_INDEX_ERROR);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : COMMAND_INDEX_ERROR\n\r");
#endif //(DEBUG_PRINTF_EN == 1)
	}

	if(int_status&INT_DATA_CRC_ERROR) {
		sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS0,INT_DATA_CRC_ERROR);
#if(DEBUG_PRINTF_EN == 1)
			bsp_printf("INT : DATA_CRC_ERROR\n\r");
#endif //(DEBUG_PRINTF_EN == 1)

	}

	sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS1+4,INT_ENABLE);
}


/********************************* Function **********************************/

void userInterrupt(){
	uint32_t claim;
	//While there is pending interrupts
	while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
		switch(claim){
		case SDHC_INTERRUPT:externalInterrupt(); break;
	    case PLIC_DMASG_CHANNEL:
	         if(display_mm2s_active && !(dmasg_busy(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL))) {
	            dmasg_input_memory(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, IMG_START_ADDR, 16);
	            dmasg_output_stream(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, DMASG_DISPLAY_MM2S_PORT, 0, 0, 1);
	            dmasg_interrupt_config(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, DMASG_CHANNEL_INTERRUPT_CHANNEL_COMPLETION_MASK);
	            dmasg_direct_start(DMASG_BASE, DMASG_DISPLAY_MM2S_CHANNEL, (FRAME_WIDTH*FRAME_HEIGHT)*4, 0);  //Without self restart
	         }
	         break;
		default: crash(); break;
		}
		//unmask the claimed interrupt
		plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim); 
	}
}

//Called by trap_entry on both exceptions and interrupts events
void trap(){
	int32_t mcause = csr_read(mcause);
	//Interrupt if true, exception if false
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



void IntcInitialize(struct mmc *mmc)
{
	dev=mmc->priv;

	//configure PLIC
	//cpu 0 accept all interrupts with priority above 0
	plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0); 
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, SDHC_INTERRUPT, 1);
	plic_set_priority(BSP_PLIC, SDHC_INTERRUPT, 1);

	//enable riscV interrupts
	//Set the machine trap vector (../common/trap.S)
	csr_write(mtvec, trap_entry); 
	//Enable external interrupts
	csr_set(mie, MIE_MEIE); 
	csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);

	//enable User interrupts
	sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS1,0x00);				//Clean All Interrupts Status
	sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS1,INT_ENABLE);		//Enable All Interrupts Status
	sd_ctrl_write(dev,SDHC_ADDR+REG_NORMAL_INTERRUPT_STATUS1+4,INT_ENABLE);		//Open All Interrupts Signal
}
