PROJ_NAME=fatFSDemo

STANDALONE= ../../
CFLAGS+=-DSMP

SRCS =  $(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
		$(wildcard ${BSP_PATH}/app/fatfs/*.c) \
        ${STANDALONE}/common/start.S \
        ${STANDALONE}/common/trap.S
	
LDSCRIPT ?= ${BSP_PATH}/linker/default.ld

CFLAGS += -Isrc
CFLAGS += -I${BSP_PATH}/app/fatfs

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk

