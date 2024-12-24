////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
// donut.c by Andy Sloane (@a1k0n)
// https://gist.github.com/a1k0n/8ea6516b4946ab36348fb61703dc3194
////////////////////////////////////////////////////////////////////////////////
#include "bsp.h"
#include "userDef.h"
#include "riscv.h"
#include "start.h"
#include "gpio.h"
#include "clint.h"
#include "plic.h"

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <math.h>


void trap();
void crash();
void trap_entry();
void gpioIsr();
void isrRoutine();
void isrInit();

// Encryption count for single core processing
#define ENCRYPT_COUNT HART_COUNT
// Stack space used by smpInit.S to provide stack to secondary harts
u8 hartStack[STACK_PER_HART*HART_COUNT] __attribute__((aligned(16)));

// Used as a syncronization barrier between all threads
volatile u32 hartCounter = 0;
// Flag used by hart 0 to notify the other harts that the "value" variable is loaded
volatile u32 h0_ready = 0;

#define WITH_RV32M
#define debug(...)

//Store the count of interrupt happened
u8 dir=0;

// torus radii and distance from camera
// these are pretty baked-in to other constants now, so it probably won't work
// if you change them too much.
const int dz = 5, r1 = 1, r2 = 2;

// "Magic circle algorithm"? DDA? I've seen this formulation in a few places;
// first in Hal Chamberlain's Musical Applications of Microprocessors, but not
// sure what to call it, or how to justify it theoretically. It seems to
// correctly rotate around a point "near" the origin, without losing magnitude
// over long periods of time, as long as there are enough bits of precision in x
// and y. I use 14 bits here.
#define R(s,x,y) x-=(y>>s); y+=(x>>s)

// CORDIC algorithm to find magnitude of |x,y| by rotating the x,y vector onto
// the x axis. This also brings vector (x2,y2) along for the ride, and writes
// back to x2 -- this is used to rotate the lighting vector from the normal of
// the torus surface towards the camera, and thus determine the lighting amount.
// We only need to keep one of the two lighting normal coordinates.
int length_cordic(int16_t x, int16_t y, int16_t *x2_, int16_t y2) {
  int x2 = *x2_;
  if (x < 0) { // start in right half-plane
    x = -x;
    x2 = -x2;
  }
  for (int i = 0; i < 8; i++) {
    int t = x;
    int t2 = x2;
    if (y < 0) {
      x -= y >> i;
      y += t >> i;
      x2 -= y2 >> i;
      y2 += t2 >> i;
    } else {
      x += y >> i;
      y -= t >> i;
      x2 += y2 >> i;
      y2 -= t2 >> i;
    }
  }
  // divide by 0.625 as a cheap approximation to the 0.607 scaling factor factor
  // introduced by this algorithm (see https://en.wikipedia.org/wiki/CORDIC)
  *x2_ = (x2 >> 1) + (x2 >> 3);
  return (x >> 1) + (x >> 3);
}

void donut() {
  // high-precision rotation directions, sines and cosines and their products
  int16_t sB = 0, cB = 16384;
  int16_t sA = 11583, cA = 11583;
  int16_t sAsB = 0, cAsB = 0;
  int16_t sAcB = 11583, cAcB = 11583;

  for (;;) {
    int x1_16 = cAcB << 2;

    // yes this is a multiply but dz is 5 so it's (sb + (sb<<2)) >> 6 effectively
    int p0x = dz * sB >> 6;
    int p0y = dz * sAcB >> 6;
    int p0z = -dz * cAcB >> 6;

    const int r1i = r1*256;
    const int r2i = r2*256;

    int niters = 0;
    int nnormals = 0;
    int16_t yincC = (cA >> 6) + (cA >> 5);      // 12*cA >> 8;
    int16_t yincS = (sA >> 6) + (sA >> 5);      // 12*sA >> 8;
    int16_t xincX = (cB >> 7) + (cB >> 6);      // 6*cB >> 8;
    int16_t xincY = (sAsB >> 7) + (sAsB >> 6);  // 6*sAsB >> 8;
    int16_t xincZ = (cAsB >> 7) + (cAsB >> 6);  // 6*cAsB >> 8;
    int16_t ycA = -((cA >> 1) + (cA >> 4));     // -12 * yinc1 = -9*cA >> 4;
    int16_t ysA = -((sA >> 1) + (sA >> 4));     // -12 * yinc2 = -9*sA >> 4;
    //int dmin = INT_MAX, dmax = -INT_MAX;
    for (int j = 0; j < 23; j++, ycA += yincC, ysA += yincS) {
      int xsAsB = (sAsB >> 4) - sAsB;  // -40*xincY
      int xcAsB = (cAsB >> 4) - cAsB;  // -40*xincZ;

      int16_t vxi14 = (cB >> 4) - cB - sB; // -40*xincX - sB;
      int16_t vyi14 = ycA - xsAsB - sAcB;
      int16_t vzi14 = ysA + xcAsB + cAcB;

      for (int i = 0; i < 79; i++, vxi14 += xincX, vyi14 -= xincY, vzi14 += xincZ) {
        int t = 512; // (256 * dz) - r2i - r1i;

        int16_t px = p0x + (vxi14 >> 5); // assuming t = 512, t*vxi>>8 == vxi<<1
        int16_t py = p0y + (vyi14 >> 5);
        int16_t pz = p0z + (vzi14 >> 5);
        debug("pxyz (%+4d,%+4d,%+4d)\n", px, py, pz);
        int16_t lx0 = sB >> 2;
        int16_t ly0 = sAcB - cA >> 2;
        int16_t lz0 = -cAcB - sA >> 2;
        for (;;) {
          int t0, t1, t2, d;
          int16_t lx = lx0, ly = ly0, lz = lz0;
          debug("[%2d,%2d] (px, py) = (%d, %d), (lx, ly) = (%d, %d) -> ", j, i, px, py, lx, ly);
          t0 = length_cordic(px, py, &lx, ly);
          debug("t0=%d (lx', ly') = (%d, %d)\n", t0, lx, ly);
          t1 = t0 - r2i;
          t2 = length_cordic(pz, t1, &lz, lx);
          d = t2 - r1i;
          t += d;

          if (t > 8*256) {
        	  bsp_printf_c(' ');
            break;
          } else if (d < 2) {
            int N = lz >> 9;
            bsp_printf_c(".,-~:;!*=#$@"[N > 0 ? N < 12 ? N : 11 : 0]);
            nnormals++;
            break;
          }
          // todo: shift and add version of this


          /*
            if (d < dmin) dmin = d;
            if (d > dmax) dmax = d;
	   */

#ifdef WITH_RV32M
            px += d*vxi14 >> 14;
            py += d*vyi14 >> 14;
            pz += d*vzi14 >> 14;
#else
          {
            // 11x1.14 fixed point 3x parallel multiply
            // only 16 bit registers needed; starts from highest bit to lowest
            // d is about 2..1100, so 11 bits are sufficient
            int16_t dx = 0, dy = 0, dz = 0;
            int16_t a = vxi14, b = vyi14, c = vzi14;
            while (d) {
              if (d&1024) {
                dx += a;
                dy += b;
                dz += c;
              }
              d = (d&1023) << 1;
              a >>= 1;
              b >>= 1;
              c >>= 1;
            }
            // we already shifted down 10 bits, so get the last four
            px += dx >> 4;
            py += dy >> 4;
            pz += dz >> 4;
          }
#endif
          niters++;
        }
      }
      bsp_printf_s("");
    }
    bsp_printf("%d iterations %d lit pixels\x1b[K", niters, nnormals);
//    fflush(stdout);

    // rotate sines, cosines, and products thereof
    // this animates the torus rotation about two axes
    R(5, cA, sA);
    R(5, cAsB, sAsB);
    R(5, cAcB, sAcB);
    R(6, cB, sB);
    R(6, cAcB, cAsB);
    R(6, sAcB, sAsB);

//    usleep(15000);
    bsp_printf("\r\x1b[23A");
  }
}

// Used on unexpected trap/interrupt codes
void crash(){
    bsp_printf("\r\n*** CRASH ***\r\n");
    while(1);
}

// Called by trap_entry on both exceptions and interrupts events
void trap(){
    int32_t mcause = csr_read(mcause);
    int32_t interrupt = mcause < 0;    //Interrupt if true, exception if false
    int32_t cause     = mcause & 0xF;
    if(interrupt){
        switch(cause){
        case CAUSE_MACHINE_EXTERNAL: isrRoutine(); break;
        default: crash(); break;
        }
    } else {
        crash();
    }
}

void gpioIsr(){
    //bsp_printf("Entering gpio interrupt routine .. \r\n");
	//count++;
    //bsp_printf("Count:%d .. Done \r\n",count);
	bsp_uDelay(500);
	dir = 1 - dir;
}

void isrRoutine(){
    uint32_t claim;
    // While there is pending interrupts
    while(claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)){
        switch(claim){
        case SYSTEM_PLIC_SYSTEM_GPIO_0_IO_INTERRUPTS_0: gpioIsr(); break;
        default: crash(); break;
        }
        // Unmask the claimed interrupt
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
    }
}

void isrInit(){
    // Configure PLIC
    // Cpu 0 accept all interrupts with priority above 0
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0, SYSTEM_PLIC_SYSTEM_GPIO_0_IO_INTERRUPTS_0, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_GPIO_0_IO_INTERRUPTS_0, 1);
    // Enable rising edge interrupts
    gpio_setInterruptRiseEnable(GPIO0, 1);
    // Enable interrupts
    // Set the machine trap vector (../common/trap.S)
    csr_write(mtvec, trap_entry);
    //Enable external interrupts
    csr_set(mie, MIE_MEIE);
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

extern void smpInit();
void mainSmp();

__inline__ __attribute__((always_inline)) s32 atomicAdd(s32 *a, u32 increment) {
    s32 old;
    __asm__ volatile(
          "amoadd.w %[old], %[increment], (%[atomic])"
        : [old] "=r"(old)
        : [increment] "r"(increment), [atomic] "r"(a)
        : "memory"
    );
    return old;
}

void mainSmp(){
    u32 hartId = csr_read(mhartid);
    atomicAdd((s32*)&hartCounter, 1);

    while(hartCounter != HART_COUNT);
    // Hart 0 will provide a value to the other harts, other harts wait on it by pulling the "ready" variable
    if(hartId == 0) {
        bsp_printf("synced! \r\n");

        asm("fence w,w");
        h0_ready = 1;
        isrInit();
        gpio_setOutputEnable(GPIO0, 0xe);
        gpio_setOutput(GPIO0, 0x0);
        while(1) {

        	if(dir == 0 ){
            gpio_setOutput(GPIO0, gpio_getOutput(GPIO0) ^ 0x2);
            bsp_uDelay(LOOP_UDELAY);
            gpio_setOutput(GPIO0, gpio_getOutput(GPIO0) ^ 0x4);
            bsp_uDelay(LOOP_UDELAY);
            gpio_setOutput(GPIO0, gpio_getOutput(GPIO0) ^ 0x8);
            bsp_uDelay(LOOP_UDELAY);
        	}
        	else {
                gpio_setOutput(GPIO0, gpio_getOutput(GPIO0) ^ 0x8);
                bsp_uDelay(LOOP_UDELAY);
                gpio_setOutput(GPIO0, gpio_getOutput(GPIO0) ^ 0x4);
                bsp_uDelay(LOOP_UDELAY);
                gpio_setOutput(GPIO0, gpio_getOutput(GPIO0) ^ 0x2);
                bsp_uDelay(LOOP_UDELAY);
        	}
        }

    }
    else if(hartId == 1){
        while(!dir);
        asm("fence r,r");

        donut();

    }
    else if(hartId == 2){
    	while(1){}
    }
    else if(hartId == 3){
    	while(1){}
    }
}

void main() {
    bsp_init();
    bsp_printf("***Starting SMP Demo*** \r\n");
    smp_unlock(smpInit);
    mainSmp();
    bsp_printf("***Succesfully Ran Demo*** \r\n");
}
