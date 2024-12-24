PROJ_NAME=freertosMqttPlainTextDemo

STANDALONE = ..
CFLAGS+=-DSMP

FREERTOS=${FreeRTOS_KERNEL_SRC}/FreeRTOS/${FreeRTOS_KERNEL_SRC_DIR}
FREERTOS_RISCV=${FREERTOS}/portable/GCC/RISC-V
FREERTOS_TCP=${FreeRTOS_KERNEL_SRC}/FreeRTOS-Plus/Source/FreeRTOS-Plus-TCP/source
FREERTOS_UTILITIES=${FreeRTOS_KERNEL_SRC}/FreeRTOS-Plus/Source/Utilities
FREERTOS_PROTOCOLS=${FreeRTOS_KERNEL_SRC}/FreeRTOS-Plus/Source/Application-Protocols
FREERTOS_MQTT=${FREERTOS_PROTOCOLS}/coreMQTT/source
FREERTOS_BACKOFF=${FREERTOS_UTILITIES}/backoff_algorithm/source
FREERTOS_TRANSPORT=${FREERTOS_PROTOCOLS}/network_transport

SRCS = 	$(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
		$(wildcard ${FREERTOS}/*.c) \
		$(wildcard ${FREERTOS_TCP}/*.c) \
		$(wildcard ${FREERTOS_MQTT}/*.c) \
        ${FREERTOS}/portable/MemMang/heap_4.c \
        ${FREERTOS_TCP}/portable/BufferManagement/BufferAllocation_2.c \
        ${FREERTOS_UTILITIES}/backoff_algorithm/source/backoff_algorithm.c \
        ${FREERTOS_TRANSPORT}/transport_plaintext.c \
        ${FREERTOS_TRANSPORT}/tcp_sockets_wrapper/ports/freertos_plus_tcp/tcp_sockets_wrapper.c \
        ${FREERTOS_RISCV}/port.c \
        ${FREERTOS_RISCV}/portASM.S \
        ${STANDALONE}/common/start.S 
        
CFLAGS += -Isrc
CFLAGS += -I../driver
CFLAGS += -I${FREERTOS}/include
CFLAGS += -I${FREERTOS_TCP}/include
CFLAGS += -I${FREERTOS_TCP}/portable/Compiler/GCC
CFLAGS += -I${FREERTOS_RISCV}
CFLAGS += -I${FREERTOS_UTILITIES}/logging
CFLAGS += -I${FREERTOS_MQTT}/include
CFLAGS += -I${FREERTOS_MQTT}/interface
CFLAGS += -I${FREERTOS_BACKOFF}/include
CFLAGS += -I${FREERTOS_TRANSPORT}
CFLAGS += -I${FREERTOS_TRANSPORT}/tcp_sockets_wrapper/include
CFLAGS += -DportasmHANDLE_INTERRUPT=freertos_risc_v_application_interrupt_handler

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk

LDSCRIPT ?= ${BSP_PATH}/linker/freertos.ld
