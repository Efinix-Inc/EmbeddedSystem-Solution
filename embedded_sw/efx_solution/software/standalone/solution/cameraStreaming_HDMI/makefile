PROJ_NAME=cameraStreaming_HDMI

STANDALONE = ../../

SRCS = $(wildcard src/*.c) \
       $(wildcard src/*.cpp) \
       $(wildcard src/*.S) \
       $(wildcard ${STANDALONE}/driver/vision/*.c) \
       ${STANDALONE}/common/start.S  \
       ${STANDALONE}/common/trap.S

CFLAGS +=-DSMP
CFLAGS += -Isrc       
CFLAGS += -I${STANDALONE}/driver/vision

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk
LDSCRIPT = ${BSP_PATH}/linker/default.ld