#ifndef __METAL_GENERIC_SYS__H__
#error "Include metal/sys.h instead of metal/generic/efinix_ti375_rv32/sys.h"
#endif

#ifndef __METAL_GENERIC_EFINIX_TI375_RV32_SYS__H__
#define __METAL_GENERIC_EFINIX_TI375_RV32_SYS__H__

#ifdef __cplusplus
extern "C" {
#endif

#ifdef METAL_INTERNAL

void sys_irq_enable(unsigned int vector);
void sys_irq_disable(unsigned int vector);

#endif /* METAL_INTERNAL */

#ifdef __cplusplus
}
#endif

#endif /* __METAL_GENERIC_EFINIX_TI375_RV32_SYS__H__ */
