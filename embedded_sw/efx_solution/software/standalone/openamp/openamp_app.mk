OPENAMP_DIR ?= $(STANDALONE)/openamp

include $(OPENAMP_DIR)/openamp_libs.mk

OPENAMP_SHARED_DIR := $(OPENAMP_DIR)/shared

OPENAMP_SHARED_SRCS := \
    $(OPENAMP_SHARED_DIR)/openamp_transport.c \
    $(OPENAMP_SHARED_DIR)/amp_rsc_table.c \
    $(OPENAMP_SHARED_DIR)/amp_trap.c \
    $(OPENAMP_SHARED_DIR)/amp_remote.c

OPENAMP_APP_INCS += -I$(OPENAMP_SHARED_DIR)
