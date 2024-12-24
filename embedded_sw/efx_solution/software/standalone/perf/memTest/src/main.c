////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "bsp.h"
#include "device_config.h"
#include "io.h"

//memory start address
#define mem ((volatile uint32_t*)0x00010000) 
#define MAX_WORDS (4 * 1024 * 1024)

void main() {
	bsp_init();
    bsp_printf("memory test ! \r\n");
    for(int i=0;i<MAX_WORDS;i++) mem[i] = i;

    for(int i=0;i<MAX_WORDS;i++) {
        if (mem[i] != i) {
        bsp_printf("Failed at address 0x%x with value of 0x%x \r\n", i, mem[i]);
        while(1){
            }
        }
    }
    bsp_printf("Passed \r\n");
    while(1){}
}

