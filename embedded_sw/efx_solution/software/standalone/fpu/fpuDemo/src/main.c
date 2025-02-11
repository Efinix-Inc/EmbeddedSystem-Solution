////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
////////////////////////////////////////////////////////////////////////////////

#include <stdlib.h>
#include <stdint.h>
#include "bsp.h"
#include "device_config.h"
#include "riscv.h"
#include "clint.h"
#include "soc.h"
#include <math.h>
#include "print.h"

void printPTime(uint64_t ts1, uint64_t ts2, char *s) {
    uint64_t rts;
    rts=ts2-ts1;
    bsp_printf("%s %d \n\n\r",s, rts );
}

void main() {
    double i,j,k,l;
    double x,y,z;
    uint64_t timerCmp0, timerCmp1;

    bsp_init();
    bsp_printf("fpu demo ! \r\n");
#if (SYSTEM_CORES_0_FPU == 0)
    bsp_printf("FPU is disabled, more processing time required for following calculation \r\n");
    bsp_printf("FPU is disabled, please expect bigger size compiled binary \r\n");
#endif

    i=0.5820;      

    timerCmp0 = clint_getTime(BSP_CLINT);
    j=sin(i);
    timerCmp1 = clint_getTime(BSP_CLINT);
    printPTime(timerCmp0,timerCmp1,"sine processing clock cycles:");

    timerCmp0 = clint_getTime(BSP_CLINT);
    k=cos(i);
    timerCmp1 = clint_getTime(BSP_CLINT);
    printPTime(timerCmp0,timerCmp1,"cosine processing clock cycles:");

    timerCmp0 = clint_getTime(BSP_CLINT);
    l=tan(i);
    timerCmp1 = clint_getTime(BSP_CLINT);
    printPTime(timerCmp0,timerCmp1,"tangent processing clock cycles:");

    timerCmp0 = clint_getTime(BSP_CLINT);
    x=3828.1234;
    y=sqrt(x);
    timerCmp1 = clint_getTime(BSP_CLINT);
    printPTime(timerCmp0,timerCmp1,"square root processing clock cycles:");

    timerCmp0 = clint_getTime(BSP_CLINT);
    z=x/3.6789;
    timerCmp1 = clint_getTime(BSP_CLINT);
    printPTime(timerCmp0,timerCmp1,"division processing clock cycles:");
    bsp_printf("\r\n");
    bsp_printf("Input i (in rad): %f \r\n", i);
    bsp_printf("Sine result: %f \r\n", j);
    bsp_printf("Cosine result: %f \r\n", k);
    bsp_printf("Tangent result: %f \r\n", l);
    bsp_printf("Input x: %f \r\n", x);
    bsp_printf("Square root result: %f \r\n", y);
    bsp_printf("Divsion result: %f \r\n", z);
}
