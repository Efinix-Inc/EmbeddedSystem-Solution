#include "soc.h"

#ifdef SYSTEM_GPIO_0_IO_CTRL
    #define GPIO0   SYSTEM_GPIO_0_IO_CTRL
#else
    #error "GPIO required in soft logic block .."
#endif
#ifdef SIM
    #define LOOP_UDELAY 100
#else
    #define LOOP_UDELAY 100000
#endif

