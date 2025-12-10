////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include "bsp.h"
#include "intc.h"
#include "efx_emmc_driver.h"
#include "userDef.h"
#include "device_config.h"

volatile IntStruct IntPtr;
struct sd_ctrl_dev *dev;

/************************** Function Definitions *****************************/
void trap_entry();

/********************************* Function **********************************/
void UserInterruptAIsr()
{
	u32 int_status;
	reg_write(0x00, REG_INTERRUPT_SIGNAL_ENABLE);

	int_status = reg_read(REG_INTERRUPT_STATUS);

	if(int_status&INT_COMMAND_COMPLETE) {
		IntPtr.command_complete = 0x1;
		reg_write(INT_COMMAND_COMPLETE, REG_INTERRUPT_STATUS);
	//	bsp_printf_full("INT : COMMAND_COMPLETE\n\r");
	}

	if(int_status&INT_TRANSFER_COMPLETE) {
		IntPtr.transfer_complete = 0x1;
		reg_write(INT_TRANSFER_COMPLETE, REG_INTERRUPT_STATUS);
//		bsp_printf_full("INT : TRANSFER_COMPLETE\n\r");
	}

	if(int_status&INT_BLOCK_GAP_EVENT) {
		IntPtr.block_gap_event = 0x1;
		reg_write(INT_BLOCK_GAP_EVENT, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : BLOCK_GAP_EVENT\n\r");
	}

	if(int_status&INT_BUFFER_WRITE_READY) {
		//IntPtr.buffer_write_ready = 0x1;
		reg_write(INT_BUFFER_WRITE_READY, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : BUFFER_WRITE_READY\n\r");
	}

	if(int_status&INT_BUFFER_READ_READY) {
		//IntPtr.buffer_read_ready = 0x1;
		reg_write(INT_BUFFER_READ_READY, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : BUFFER_READ_READY\n\r");
	}

	if(int_status&INT_COMMAND_TIMEOUT_ERROR) {
		IntPtr.command_timeout_error = 0x1;
		reg_write(INT_COMMAND_TIMEOUT_ERROR, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : COMMAND_TIMEOUT_ERROR\n\r");
	}

	if(int_status&INT_COMMAND_CRC_ERROR) {
		IntPtr.command_crc_error = 0x1;
		reg_write(INT_COMMAND_CRC_ERROR, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : COMMAND_CRC_ERROR\n\r");
	}

	if(int_status&INT_COMMAND_END_BIT_ERROR) {
		IntPtr.command_end_bit_error = 0x1;
		reg_write(INT_COMMAND_END_BIT_ERROR, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : COMMAND_END_BIT_ERROR\n\r");
	}

	if(int_status&INT_COMMAND_INDEX_ERROR) {
		IntPtr.command_index_error = 0x1;
		reg_write(INT_COMMAND_INDEX_ERROR, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : COMMAND_INDEX_ERROR\n\r");
	}

	if(int_status&INT_DATA_CRC_ERROR) {
		IntPtr.data_crc_error = 0x1;
		reg_write(INT_DATA_CRC_ERROR, REG_INTERRUPT_STATUS);
		bsp_printf_full("INT : DATA_CRC_ERROR\n\r");
	}

	reg_write(INT_ENABLE, REG_INTERRUPT_SIGNAL_ENABLE);
}


/********************************* Function **********************************/
//Used on unexpected trap/interrupt codes
void crash(){
	bsp_printf("\n*** CRASH ***\n");
	while(1);
}

void userInterrupt(){
	//struct example_apb3_ctrl_reg cfg={0};
	uint32_t claim;
	//While there is pending interrupts
	while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
		switch(claim){
		case EMMC_INTERRUPT:
			UserInterruptAIsr(); break;
		default: crash(); break;
		}
		plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim); //unmask the claimed interrupt
	}
}

//Called by trap_entry on both exceptions and interrupts events
void trap(){
	int32_t mcause = csr_read(mcause);
	int32_t interrupt = mcause < 0;    //Interrupt if true, exception if false
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
	plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0); //cpu 0 accept all interrupts with priority above 0

	//enable SYSTEM_PLIC_USER_INTERRUPT_A_INTERRUPT rising edge interrupt
	plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, EMMC_INTERRUPT, 1);
	plic_set_priority(BSP_PLIC, EMMC_INTERRUPT, 1);

	//enable riscV interrupts
	csr_write(mtvec, trap_entry); //Set the machine trap vector (../common/trap.S)
//	csr_set(mie, MIE_MTIE | MIE_MEIE); //Enable machine timer and external interrupts
	csr_set(mie, MIE_MEIE); //Enable machine timer and external interrupts
	csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);

	//enable User interrupts
	reg_write(0x00, REG_INTERRUPT_STATUS_ENABLE);		//Clean All Interrupts Status
	reg_write(INT_ENABLE, REG_INTERRUPT_STATUS_ENABLE);		//Enable All Interrupts Status
	reg_write(INT_ENABLE, REG_INTERRUPT_SIGNAL_ENABLE);		//Open All Interrupts Signal
}
