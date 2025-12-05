    .section .init
    .globl _start
    .type _start,@function


_start:
#ifdef USE_GP
.option push					// Saves the current assembler options onto a stack.
.option norelax                 // This prevent assmebler from optimizing la gp, into pc-relative instructions.
	la gp, __global_pointer$    // Load address of global pointer base into gp register.
.option pop						// Restores the previously saved assembler options from the stack.
#endif

#ifdef SMP
.global smp_lottery_target      // Entry point for slave cores
.global smp_lottery_lock		// Spinlock for synchronization
.global smp_slave


  sw x0, smp_lottery_lock, a1     // Store zero into smp_lottery_lock + a1 , ensures only hart 0 runs init, 
  								  // ... while other harts park in a loop (smp_slave) until released. 


smp_tyranny:
  csrr a0, mhartid  		      // read hart ID.
  beqz a0, init     		      // if hart 0 -> go init.

smp_slave:
	lw a0, smp_lottery_lock    	  // Load the value of smp_lottery_lock into register a0.
	beqz a0, smp_slave 		   	  // Spinlock loop, the slave core keeps looping until the lock becomes non-zero.
	fence r, r				   	  // All loads before this fence are guaranteed to complete before any loads after the fence.
	//li a1, -1
	//amoadd.w x0, a1,(a0)
	.word(0x100F) 				  // i$ flush
	lw a5, smp_lottery_target  	  // Load entry point for slave CPU into a5.
	li a0, 0				   	  // Load value 0 into a0.
	li a1, 0				   	  // Load value 0 into a1.
	li a2, 0				   	  // Load value 0 into a2.
	jr a5					   	  // Jump to slave entry point stored in a5.

.global   smp_unlock              // Treat smp_unlock globally visible.
.type    smp_unlock,%function     // Treat smp_unlock as Function symbol
smp_unlock:
	sw a0, smp_lottery_target, a1 // Write the value in a0 (slave entry point) to the memory location smp_lottery_target + a1, 
								  // ...  so the slave CPU can see where it should start executing. 
	fence w, w                    // All stores before this fence are visible to other cores before any stores after the fence.
	li a0, 1					  // Loads value 1 into a0.
	sw a0, smp_lottery_lock, a1   // Stores 1 into smp_lottery_lock + a1 , to release lock that all slave core waiting in smp_slave.
    ret
#endif

init:
	la sp, _sp					  // Load the address of _sp into the stack pointer register sp.

	/* Load data section */
	la a0, _data_lma    		  // Source in flash (LMA = Load Memory Address)
	la a1, _data        		  // Destination in RAM (VMA = Virtual Memory Address)
	la a2, _edata       		  // End of data section in RAM
	bgeu a1, a2, 2f     		  // If start >= end, skip copying
1:
    lw t0, (a0)      			  // Load 32-bit word from flash
    sw t0, (a1)      			  // Store to RAM
    addi a0, a0, 4   			  // Move to next word in flash
    addi a1, a1, 4   			  // Move to next word in RAM
    bltu a1, a2, 1b  			  // Loop until a1 reaches end
2:

	/* Clear bss section */
	la a0, __bss_start   		  // Start of uninitialized data
	la a1, _end          		  // End of BSS (stack bottom / end of RAM)
	bgeu a0, a1, 2f      		  // Skip if already done
1:
    sw zero, (a0)    			  // Store 0 to RAM
    addi a0, a0, 4   			  // Move to next word
    bltu a0, a1, 1b  			  // Loop until end
2:

#ifndef NO_LIBC_INIT_ARRAY
	call __libc_init_array        // This runs global C++ constructors, included if not defined. 
#endif

	call main
mainDone:
    j mainDone


	.globl _init
_init:
    ret

#ifdef SMP
.bss
.align 2
  smp_lottery_target: .word 0
  smp_lottery_lock:   .word 0
#endif