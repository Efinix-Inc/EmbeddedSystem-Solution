////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.              
//
// This   document  contains  proprietary information  which   is        
// protected by  copyright. All rights  are reserved.  This notice       
// refers to original work by Efinix, Inc. which may be derivitive       
// of other work distributed under license of the authors.  In the       
// case of derivative work, nothing in this notice overrides the         
// original author's license agreement.  Where applicable, the           
// original license agreement is included in it's original               
// unmodified form immediately below this header.                        
//                                                                       
// WARRANTY DISCLAIMER.                                                  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND        
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH               
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES,  
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF          
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR    
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED       
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.           
//                                                                       
// LIMITATION OF LIABILITY.                                              
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY       
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT    
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY   
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT,      
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY    
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF      
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR   
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN    
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER    
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR            
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT   
//     APPLY TO LICENSEE.                                                
//
////////////////////////////////////////////////////////////////////////////////

#ifndef EFX_SEMIHOSTING_H
#define EFX_SEMIHOSTING_H


#include "bsp.h"
#include "vexriscv.h"


#define RISCV_SEMIHOSTING_CALL_NUMBER 7
enum semihosting_operation_numbers {
    /*
     * ARM semihosting operations, in lexicographic order.
     */
    SEMIHOSTING_ENTER_SVC           = 0x17, /* DEPRECATED */

    SEMIHOSTING_SYS_CLOSE           = 0x02,
    SEMIHOSTING_SYS_CLOCK           = 0x10,
    SEMIHOSTING_SYS_ELAPSED         = 0x30,
    SEMIHOSTING_SYS_ERRNO           = 0x13,
    SEMIHOSTING_SYS_EXIT            = 0x18,
    SEMIHOSTING_SYS_EXIT_EXTENDED   = 0x20,
    SEMIHOSTING_SYS_FLEN            = 0x0C,
    SEMIHOSTING_SYS_GET_CMDLINE     = 0x15,
    SEMIHOSTING_SYS_HEAPINFO        = 0x16,
    SEMIHOSTING_SYS_ISERROR         = 0x08,
    SEMIHOSTING_SYS_ISTTY           = 0x09,
    SEMIHOSTING_SYS_OPEN            = 0x01,
    SEMIHOSTING_SYS_READ            = 0x06,
    SEMIHOSTING_SYS_READC           = 0x07,
    SEMIHOSTING_SYS_REMOVE          = 0x0E,
    SEMIHOSTING_SYS_RENAME          = 0x0F,
    SEMIHOSTING_SYS_SEEK            = 0x0A,
    SEMIHOSTING_SYS_SYSTEM          = 0x12,
    SEMIHOSTING_SYS_TICKFREQ        = 0x31,
    SEMIHOSTING_SYS_TIME            = 0x11,
    SEMIHOSTING_SYS_TMPNAM          = 0x0D,
    SEMIHOSTING_SYS_WRITE           = 0x05,
    SEMIHOSTING_SYS_WRITEC          = 0x03,
    SEMIHOSTING_SYS_WRITE0          = 0x04,
};

static inline int __attribute__ ((always_inline)) call_host(int reason, void* arg) {
    register int value asm ("a0") = reason;
    register void* ptr asm ("a1") = arg;
    asm volatile (
        " .option push \n"
        // Force non-compressed RISC-V instructions
        " .option norvc \n"
        // Force 16-byte alignment to make sure that the 3 instructions fall
        // within the same virtual page.
        // Note: align 4 means, align by 2 to the power of 4!
        " .align 4 \n"
        " slli x0, x0, 0x1f \n"
        " ebreak \n"
        " srai x0, x0, %[swi] \n"
        " .option pop \n"

        : "=r" (value) /* Outputs */
        : "0" (value), "r" (ptr), [swi] "i" (RISCV_SEMIHOSTING_CALL_NUMBER) /* Inputs */
        : "memory" /* Clobbers */
    );
    return value;
}

static void sh_write0(char* buf)
{
    // Print zero-terminated string
    call_host(SEMIHOSTING_SYS_WRITE0, (void*) buf);
}

static void sh_writec(char c)
{
    // Print single character
    call_host(SEMIHOSTING_SYS_WRITEC, (void*)&c);
}

static char sh_readc(void)
{
    // Read character - Blocking operation!
    return call_host(SEMIHOSTING_SYS_READC, (void*)0);
}


#endif // EFX_SEMIHOSTING_H
