PROJ_NAME=emmcDemo

STANDALONE=../..
CFLAGS+=-DSMP
CFLAGS+=-Isrc

SRCS = 	$(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
        ${STANDALONE}/common/start.S \
        ${STANDALONE}/common/trap.S

CFLAGS+=-Isrc
# Heap grows from _end into the stack region; large DMA test buffers need it big.
# Must precede the includes so --defsym comes before -T.
LDFLAGS += -Wl,--defsym=__stack_size=1024000K

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk

LDSCRIPT = ${BSP_PATH}/linker/default.ld
