PROJ_NAME=sd_bmpStreaming_HDMI

STANDALONE= ../..
CFLAGS+=-DSMP

SRCS =  $(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
		$(wildcard ${FATFS_PATH}/*.c) \
		${STANDALONE}/common/start.S \
        ${STANDALONE}/common/trap.S \
		$(wildcard ${STANDALONE}/driver/vision/*.c) 
		
CFLAGS += -Isrc		
CFLAGS += -I${STANDALONE}/driver/vision

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk	
LDSCRIPT = ${BSP_PATH}/linker/default.ld