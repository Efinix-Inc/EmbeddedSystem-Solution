PROJ_NAME=cameraStreaming_HDMI

STANDALONE = ../../
CFLAGS+=-DSMP

SRCS = $(wildcard src/*.c) \
       $(wildcard src/*.cpp) \
       $(wildcard src/*.S) \
       $(wildcard ${STANDALONE}/driver/vision/*.c) \
       ${STANDALONE}/common/start.S  \
       ${STANDALONE}/common/trap.S
       
CFLAGS += -I${STANDALONE}/driver/vision

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk
