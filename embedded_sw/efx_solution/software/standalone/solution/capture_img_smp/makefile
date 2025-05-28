PROJ_NAME=capture_img_smp

STANDALONE= ../../
CFLAGS+=-DSMP

SRCS =  $(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
        $(wildcard src/platform/*/*.c) \
		$(wildcard ${BSP_PATH}/app/fatfs/*.c) \
		${STANDALONE}/common/start.S \
		${STANDALONE}/common/smpInit.S \
        ${STANDALONE}/common/trap.S \
		$(wildcard ${STANDALONE}/driver/vision/*.c)  

	
LDSCRIPT ?= ${BSP_PATH}/linker/default.ld

CFLAGS += -Isrc
CFLAGS += -Isrc/platform/sd/
CFLAGS += -Isrc/platform/misc/
CFLAGS += -Isrc/platform/vision/
CFLAGS += -Isrc/platform/ethernet/
CFLAGS += -Isrc/platform/interrupt/
CFLAGS += -I${BSP_PATH}/app/fatfs
CFLAGS += -I${STANDALONE}/driver/vision

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk



