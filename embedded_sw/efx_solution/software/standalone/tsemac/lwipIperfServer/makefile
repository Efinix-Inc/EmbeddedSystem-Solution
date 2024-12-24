PROJ_NAME=lwipIperfServer

STANDALONE = ../../
CFLAGS+=-DSMP

SRCS = 	$(wildcard src/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/user/arch/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/api/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/netif/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/netif/ppp/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/netif/ppp/polarssl/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/core/*.c) \
		$(wildcard ${BSP_PATH}/app/lwip/core/ipv4/*.c) \
    	$(wildcard src/*.cpp) \
    	$(wildcard src/*.S) \
        ${STANDALONE}/common/start.S\
        ${STANDALONE}/common/trap.S

CFLAGS += -I${BSP_PATH}/app/lwip
CFLAGS += -I${BSP_PATH}/app/lwip/include
CFLAGS += -I${BSP_PATH}/app/lwip/user/arch
CFLAGS += -I${BSP_PATH}/app/lwip/user/
CFLAGS += -Isrc
CFLAGS += -DportasmHANDLE_INTERRUPT=external_interrupt_handler

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk