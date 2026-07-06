OPENAMP_ROOT  ?= $(OPENAMP_DIR)/lib/open-amp
LIBMETAL_ROOT ?= $(OPENAMP_DIR)/lib/libmetal

OPENAMP_CONFIG_DIR ?= $(OPENAMP_DIR)/port

# ---- auto-fetch (only when the source tree is missing) ----
OPENAMP_GIT   ?= https://github.com/OpenAMP/open-amp.git
LIBMETAL_GIT  ?= https://github.com/OpenAMP/libmetal.git
OPENAMP_REF   ?= v2023.10.0
LIBMETAL_REF  ?= v2023.10.0

ifeq ($(wildcard $(LIBMETAL_ROOT)/lib/*.c),)
  $(info [openamp] libmetal not present -- cloning $(LIBMETAL_REF))
  $(shell mkdir -p $(dir $(LIBMETAL_ROOT)) && \
          git clone --depth 1 --branch $(LIBMETAL_REF) $(LIBMETAL_GIT) $(LIBMETAL_ROOT) 1>&2)
endif
ifeq ($(wildcard $(OPENAMP_ROOT)/lib/*.c),)
  $(info [openamp] open-amp not present -- cloning $(OPENAMP_REF))
  $(shell mkdir -p $(dir $(OPENAMP_ROOT)) && \
          git clone --depth 1 --branch $(OPENAMP_REF) $(OPENAMP_GIT) $(OPENAMP_ROOT) 1>&2)
endif

ifeq ($(wildcard $(LIBMETAL_ROOT)/lib/*.c),)
  $(error [openamp] libmetal missing at $(LIBMETAL_ROOT) after fetch -- check git/network or git clone it manually)
endif
ifeq ($(wildcard $(OPENAMP_ROOT)/lib/*.c),)
  $(error [openamp] open-amp missing at $(OPENAMP_ROOT) after fetch -- check git/network or git clone it manually)
endif

RISCV_AR ?= $(RISCV_BIN)ar

STAGED_INC := $(OBJDIR)/openamp/staged-include

LIBMETAL_HDRS_TOP   := $(wildcard $(LIBMETAL_ROOT)/lib/*.h)

LIBMETAL_HDRS_TREE  := $(shell find $(LIBMETAL_ROOT)/lib/compiler \
                                    $(LIBMETAL_ROOT)/lib/processor \
                                    $(LIBMETAL_ROOT)/lib/system \
                                    -name '*.h' 2>/dev/null)

STAGED_LIBMETAL_TOP  := $(patsubst $(LIBMETAL_ROOT)/lib/%, \
                           $(STAGED_INC)/metal/%, $(LIBMETAL_HDRS_TOP))
STAGED_LIBMETAL_TREE := $(patsubst $(LIBMETAL_ROOT)/lib/%, \
                           $(STAGED_INC)/metal/%, $(LIBMETAL_HDRS_TREE))

LIBMETAL_SYSTEM    := generic
LIBMETAL_PROCESSOR := riscv
LIBMETAL_MACHINE   := efinix_ti375_rv32
LIBMETAL_VER_MAJOR := 1
LIBMETAL_VER_MINOR := 5
LIBMETAL_VER_PATCH := 0
LIBMETAL_VER       := $(LIBMETAL_VER_MAJOR).$(LIBMETAL_VER_MINOR).$(LIBMETAL_VER_PATCH)

LIBMETAL_SYSTEM_U    := $(shell echo $(LIBMETAL_SYSTEM)    | tr a-z A-Z)
LIBMETAL_PROCESSOR_U := $(shell echo $(LIBMETAL_PROCESSOR) | tr a-z A-Z)
LIBMETAL_MACHINE_U   := $(shell echo $(LIBMETAL_MACHINE)   | tr a-z A-Z)

STAGED_OVERRIDES := \
	$(STAGED_INC)/metal/system/generic/efinix_ti375_rv32/sys.h \
	$(STAGED_INC)/openamp/version_def.h

define STAGE_LIBMETAL_HEADER
	@mkdir -p $(dir $@)
	@sed \
	    -e 's/@PROJECT_SYSTEM@/$(LIBMETAL_SYSTEM)/g' \
	    -e 's/@PROJECT_PROCESSOR@/$(LIBMETAL_PROCESSOR)/g' \
	    -e 's/@PROJECT_MACHINE@/$(LIBMETAL_MACHINE)/g' \
	    -e 's/@PROJECT_SYSTEM_UPPER@/$(LIBMETAL_SYSTEM_U)/g'         \
        -e 's/@PROJECT_PROCESSOR_UPPER@/$(LIBMETAL_PROCESSOR_U)/g'   \
        -e 's/@PROJECT_MACHINE_UPPER@/$(LIBMETAL_MACHINE_U)/g'       \
	    -e 's/@PROJECT_VERSION_MAJOR@/$(LIBMETAL_VER_MAJOR)/g' \
	    -e 's/@PROJECT_VERSION_MINOR@/$(LIBMETAL_VER_MINOR)/g' \
	    -e 's/@PROJECT_VERSION_PATCH@/$(LIBMETAL_VER_PATCH)/g' \
	    -e 's/@PROJECT_VERSION@/$(LIBMETAL_VER)/g' \
	    -e 's|^\#cmakedefine HAVE_STDATOMIC_H.*|\#define HAVE_STDATOMIC_H|' \
        -e 's|^\#cmakedefine HAVE_FUTEX_H.*|/* \#undef HAVE_FUTEX_H */|' \
	    $< > $@
endef

$(STAGED_INC)/metal/%.h: $(LIBMETAL_ROOT)/lib/%.h
	$(STAGE_LIBMETAL_HEADER)

$(STAGED_INC)/metal/system/generic/efinix_ti375_rv32/sys.h: \
	$(OPENAMP_CONFIG_DIR)/metal/system/generic/efinix_ti375_rv32/sys.h
	@mkdir -p $(dir $@)
	@cp $< $@

$(STAGED_INC)/openamp/version_def.h: $(OPENAMP_ROOT)/lib/version.h.in
	@mkdir -p $(@D)
	$(STAGE_LIBMETAL_HEADER)

STAGED_HEADERS := $(STAGED_LIBMETAL_TOP) $(STAGED_LIBMETAL_TREE) $(STAGED_OVERRIDES)

LIBMETAL_SRCS := \
    $(wildcard $(LIBMETAL_ROOT)/lib/*.c) \
    $(wildcard $(LIBMETAL_ROOT)/lib/system/generic/*.c) \
    $(OPENAMP_CONFIG_DIR)/metal/system/generic/efinix_ti375_rv32/sys.c

OPENAMP_SRCS := \
    $(wildcard $(OPENAMP_ROOT)/lib/rpmsg/*.c) \
    $(wildcard $(OPENAMP_ROOT)/lib/virtio/*.c) \
    $(wildcard $(OPENAMP_ROOT)/lib/remoteproc/*.c) \
    $(OPENAMP_ROOT)/lib/version.c

LIBMETAL_INCS := -I$(STAGED_INC)

OPENAMP_INCS := -I$(STAGED_INC) \
                -I$(STAGED_INC)/openamp \
                -I$(OPENAMP_ROOT)/lib/include

OPENAMP_LIB_CFLAGS = $(CFLAGS) \
    -DMETAL_INTERNAL \
    -fno-pic

LIBMETAL_OBJDIR := $(OBJDIR)/openamp/libmetal
OPENAMP_OBJDIR  := $(OBJDIR)/openamp/open-amp

LIBMETAL_OBJS := $(patsubst %.c,$(LIBMETAL_OBJDIR)/%.o,$(LIBMETAL_SRCS))
OPENAMP_OBJS  := $(patsubst %.c,$(OPENAMP_OBJDIR)/%.o,$(OPENAMP_SRCS))

LIBMETAL_A := $(OBJDIR)/openamp/libmetal.a
OPENAMP_A  := $(OBJDIR)/openamp/libopen_amp.a

$(LIBMETAL_OBJS): $(LIBMETAL_OBJDIR)/%.o: %.c $(STAGED_HEADERS)
	@mkdir -p $(dir $@)
	@echo "CC [metal]   $<"
	@$(RISCV_CC) -c $(OPENAMP_LIB_CFLAGS) $(LIBMETAL_INCS) -o $@ $<

$(OPENAMP_OBJS): $(OPENAMP_OBJDIR)/%.o: %.c $(STAGED_HEADERS)
	@mkdir -p $(dir $@)
	@echo "CC [openamp] $<"
	@$(RISCV_CC) -c $(OPENAMP_LIB_CFLAGS) $(OPENAMP_INCS) -o $@ $<

$(LIBMETAL_A): $(LIBMETAL_OBJS)
	@mkdir -p $(dir $@)
	@echo "AR $@"
	@$(RISCV_AR) rcs $@ $^

$(OPENAMP_A): $(OPENAMP_OBJS)
	@mkdir -p $(dir $@)
	@echo "AR $@"
	@$(RISCV_AR) rcs $@ $^

.PHONY: openamp-libs
openamp-libs: $(LIBMETAL_A) $(OPENAMP_A)

OPENAMP_ARCHIVES := $(OPENAMP_A) $(LIBMETAL_A)
OPENAMP_APP_INCS := -I$(STAGED_INC) -I$(OPENAMP_ROOT)/lib/include
