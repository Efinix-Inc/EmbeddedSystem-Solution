PROJ_NAME=openampEcho
STANDALONE = ..
OPENAMP_DIR = $(STANDALONE)/openamp

SRCS = $(wildcard src/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
		${STANDALONE}/common/start.S \
		${STANDALONE}/common/trap.S

INCLUDE_DIRS += -I ./ -I include -I src
CFLAGS += -DVIRTIO_DEVICE_ONLY -g $(INCLUDE_DIRS) -USMP
OBJDIR ?= build

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk

include $(OPENAMP_DIR)/openamp_app.mk

.DEFAULT_GOAL := all
CFLAGS += $(OPENAMP_APP_INCS)
SRCS   += $(OPENAMP_SHARED_SRCS)
LIBS   += $(OPENAMP_ARCHIVES)

include ${STANDALONE}/common/standalone.mk

$(OBJDIR)/$(PROJ_NAME).elf: $(OPENAMP_ARCHIVES)

LDSCRIPT := $(CURDIR)/src/linker.ld
