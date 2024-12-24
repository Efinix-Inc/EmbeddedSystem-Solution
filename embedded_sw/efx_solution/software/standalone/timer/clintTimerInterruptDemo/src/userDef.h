#ifdef SIM
    // Faster timer tick in simulation
    #define TIMER_TICK_DELAY (SYSTEM_CLINT_HZ/200) 
#else
    #define TIMER_TICK_DELAY (SYSTEM_CLINT_HZ)
#endif