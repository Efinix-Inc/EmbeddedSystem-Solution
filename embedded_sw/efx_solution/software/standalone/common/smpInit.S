#include "smp.h"            // Include SMP definitions (e.g., hartStack, STACK_PER_HART, etc.)

.global smpInit             // Make smpInit globally visible (callable from other files)

smpInit:                    // Initialise the stack of the current hart (core)
    la sp, hartStack        // Load the base address of the hart stack array into sp
    csrr a0, mhartid        // Read the hart ID (core number) into register a0
    li a1, STACK_PER_HART   // Load the size of stack per hart into a1
    addi a0, a0, 1          // Increment hart ID by 1 
    mul a0, a0, a1          // Multiply hart index by stack size → offset for this hart’s stack
    add sp, sp, a0          // Add offset to base stack address → sets sp for this hart
    call mainSmp            // Jump to mainSmp function (slave core main function)

smpDone:
    j smpDone               // Infinite loop after mainSmp returns (should never happen)
