#ifndef AMP_TRAP_H
#define AMP_TRAP_H

/*
 * S-mode trap handling for the remote hart. trap_entry is provided in assembly
 * (common/trap.S).
 */
void trap(void);
void trap_entry(void);

#endif /* AMP_TRAP_H */
