PROJ_NAME=sd_bmpStreaming_HDMI

STANDALONE= ../../
CFLAGS+=-DSMP

SRCS =  $(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
		$(wildcard ${BSP_PATH}/app/fatfs/*.c) \
		${STANDALONE}/common/start.S \
        ${STANDALONE}/common/trap.S \
		$(wildcard ${STANDALONE}/driver/vision/*.c) 

	
LDSCRIPT ?= ${BSP_PATH}/linker/default.ld

CFLAGS += -Isrc
CFLAGS += -I${BSP_PATH}/app/fatfs
CFLAGS += -I${STANDALONE}/driver/vision

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk


LDSCRIPT ?= ${BSP_PATH}/linker/default.ld