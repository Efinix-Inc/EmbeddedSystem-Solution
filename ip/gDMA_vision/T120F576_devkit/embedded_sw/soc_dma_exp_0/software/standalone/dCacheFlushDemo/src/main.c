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
#include <stdint.h>
#include "bsp.h"
#include "apb3_cl.h"
#include "vexriscv.h"

#ifdef IO_APB_SLAVE_0_INPUT

    #define APB0    IO_APB_SLAVE_0_INPUT

#endif
#define LOC_MEM ((volatile uint32_t*)0x00100000)
#define NUM 8

void main() {
    struct ctrl_reg2  cfg={0};
    int j=0;
    bsp_init();

#ifdef SYSTEM_DDR_BMB
#ifdef IO_APB_SLAVE_0_INPUT
/*-------------------------------------
//example 1:using known address by user
--------------------------------------- */

    bsp_printf("d-cache clearing demo ! \r\n");
    //reset all mem_start
    cfg.mem_start =0;
    cfg_write(APB0, &cfg);
    // wait for memory checker to complete
    // Bit 1 indicates the memory checker module is busy
    while ((read_u32(APB0+EXAMPLE_APB3_SLV_REG2_OFFSET) & 0x02) == 0x02);

    //write a value to the test location
    for(j=0; j < NUM; j=j+1) {
    	LOC_MEM[j] = 0xaa550000 + j;
    }
    //read the value from location, it should be save to cache as well.
    for(j=0; j < NUM; j=j+1) {
    	bsp_printf("Value at address 0x%x with value of 0x%x \r\n", LOC_MEM+j, LOC_MEM[j]);
    }

    bsp_printf("\r\nOverwrite values using custom logic..\r\n");
    //now write a different value using custom logic through AXI master intf.
    //new value
    cfg_data(APB0, 0xaa001100);
    //targeted location
    cfg_addr(APB0, (u32)LOC_MEM);
    //kick start the write with axi len 0.
    cfg.mem_start =1;
    cfg.ilen = NUM-1;
    cfg_write(APB0, &cfg);
    bsp_printf("Done!!\r\n");

    //read the value again, it should be same as 0x11223344 because CPU takes from cache, not from external mem.
    bsp_printf("\r\nRead same addresses again\r\n");
    for(j=0; j < NUM; j=j+1) {
    	bsp_printf("Value at address 0x%x with value of 0x%x \r\n", LOC_MEM+j, LOC_MEM[j]);
    }
    bsp_printf("Values are still same, CPU took them from cache!\r\n");

    //now clear the cache and read again.
    bsp_printf("\r\nThis time clear the cache before read the same address\r\n");
    bsp_printf("You can clear single line cache or flush the whole D-cache\r\n\n");
// Uncomment the following 3 lines to test out line cache invalidation
//    for(j=0; j<NUM; j=j+1){
//    	data_cache_invalidate_address(LOC_MEM+j);
//    }
// Uncomment the following 1 line to test out full cache invalidation
    data_cache_invalidate_all();
    for(j=0; j < NUM; j=j+1) {
    	bsp_printf("Value at address 0x%x with value of 0x%x \r\n", LOC_MEM+j, LOC_MEM[j]);
    }
    bsp_printf("Now you have updated new values from external memory!! \r\n");

    while(1){}
#else

    bsp_printf("apb3 Slave 0 is disabled, please enable it to run this app. \r\n");

#endif
#else
    bsp_printf("External memory configuration is disabled, please enable it to run this app. \r\n");
#endif
}

