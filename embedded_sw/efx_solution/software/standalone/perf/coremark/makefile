PROJ_NAME=coremark

STANDALONE = ../..
CFLAGS+=-DSMP

DEBUG=no
BENCH=yes
CFLAGS += -DITERATIONS=24000

SRCS = 	$(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
		${STANDALONE}/common/start.S 


include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk
