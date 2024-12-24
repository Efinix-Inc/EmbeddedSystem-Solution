PROJ_NAME=freertosFatDemo

STANDALONE = ..
CFLAGS+=-DSMP

FREERTOS=${FreeRTOS_KERNEL_SRC}/FreeRTOS/${FreeRTOS_KERNEL_SRC_DIR}
FREERTOS_RISCV=${FREERTOS}/portable/GCC/RISC-V
FREERTOS_FAT=${FreeRTOS_KERNEL_SRC}/FreeRTOS-Plus/Source/FreeRTOS-Plus-FAT

SRCS = 	$(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
		$(wildcard ${FREERTOS}/*.c) \
		$(wildcard ${FREERTOS_FAT}/*.c) \
        ${FREERTOS}/portable/MemMang/heap_4.c \
        ${FREERTOS_RISCV}/port.c \
        ${FREERTOS_RISCV}/portASM.S \
        ${STANDALONE}/common/start.S

CFLAGS += -Isrc
CFLAGS += -I../driver
CFLAGS += -I${FREERTOS}/include
CFLAGS += -I${FREERTOS_FAT}/include
CFLAGS += -I${FREERTOS_RISCV}
CFLAGS += -DportasmHANDLE_INTERRUPT=freertos_risc_v_application_interrupt_handler

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk

LDSCRIPT ?= ${BSP_PATH}/linker/freertos.ld