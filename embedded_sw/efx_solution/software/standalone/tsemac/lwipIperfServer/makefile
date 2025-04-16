PROJ_NAME=lwipIperfServer

STANDALONE = ../..

CFLAGS+=-DSMP

DEBUG?=yes
BENCH?=yes

SRCS = $(wildcard src/*.c) \
	$(wildcard ${LWIP_PATH}/*.c) \
	$(wildcard ${LWIP_PATH}/user/arch/*.c) \
	$(wildcard ${LWIP_PATH}/api/*.c) \
	$(wildcard ${LWIP_PATH}/netif/*.c) \
	$(wildcard ${LWIP_PATH}/netif/ppp/*.c) \
	$(wildcard ${LWIP_PATH}/netif/ppp/polarssl/*.c) \
	$(wildcard ${LWIP_PATH}/core/*.c) \
	$(wildcard ${LWIP_PATH}/core/ipv4/*.c) \
    $(wildcard src/*.cpp) \
    $(wildcard src/*.S) \
    ${STANDALONE}/common/start.S  \
    ${STANDALONE}/common/trap.S

CFLAGS += -Isrc
CFLAGS += -I${LWIP_PATH}
CFLAGS += -I${LWIP_PATH}/include
CFLAGS += -I${LWIP_PATH}/user/arch
CFLAGS += -I${LWIP_PATH}/user/

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk

LDSCRIPT = ${BSP_PATH}/linker/default.ld
