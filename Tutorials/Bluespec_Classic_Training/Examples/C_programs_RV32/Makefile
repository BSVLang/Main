# -*- makefile -*-

# RV32IM is default
XLEN		?= 32
ifeq ($(XLEN), 32)
CROSS_COMPILE 	= riscv32-unknown-elf-
ARCH 		= -march=rv32im
ABI 		= -mabi=ilp32
TEST_PREFIX	= rv32-
endif

ifeq ($(XLEN), 64)
CROSS_COMPILE 	= riscv64-unknown-elf-
ARCH 		= -march=rv64imafd
#ABI 		= -mabi=lp64d
TEST_PREFIX	= rv64-
endif

TOPDIR             ?= .
SUBDIRS             = hello \
                      mergesort

# Cross compile programs
AR                  = $(CROSS_COMPILE)ar
CC                  = $(CROSS_COMPILE)gcc
LD                  = $(CROSS_COMPILE)ld
OBJCOPY             = $(CROSS_COMPILE)objcopy
OBJDUMP             = $(CROSS_COMPILE)objdump
STRIP               = $(CROSS_COMPILE)strip

ifneq (,$(findstring s,$(MAKEFLAGS)))
ARFLAGS             = crs
else
ARFLAGS             = crsv
endif

ASFLAGS            += -g $(ARCH) $(ABI)

CFLAGS             += -g -I$(TOPDIR)/lib $(ARCH) $(ABI)
CFLAGS             += -specs=$(TOPDIR)/lib/bare.specs
CFLAGS             += -DCONSOLE_UART -mcmodel=medany

SRC_EXT             = c cpp cxx cc
EXTRA_EXT           = text
CLEAN_EXTRA_EXT     = map

TARGETS_SKIP        =

TARGETS             = $(TOPDIR)/lib/startup.o $(TOPDIR)/lib/syscalls.o $(TOPDIR)/lib/riscv_counters.o $(TOPDIR)/lib/ns16550.o $(filter-out $(TARGETS_SKIP),$(foreach subdir,$(SUBDIRS),$(foreach srcext,$(SRC_EXT),$(patsubst %.$(srcext),%,$(wildcard $(subdir)/*.$(srcext))))))
TARGETS_EXTRA       = $(foreach ext,$(EXTRA_EXT), $(addsuffix .$(ext), $(TARGETS)))
CLEAN_EXTRA         = $(foreach ext,$(CLEAN_EXTRA_EXT), $(addsuffix .$(ext), $(TARGETS)))


ASFLAGS            += -Wa,-Ilegacy

LDLIBS             += -lm

LDFLAGS            += -L$(TOPDIR)/lib
LDFLAGS	           += -Wl,-e,_reset
LDFLAGS            += -Wl,-T$(TOPDIR)/lib/bare.lds
LDFLAGS            += -Wl,-Map,$@.map
LDFLAGS            += -Wl,-Ttext-segment=0x80000000


default:all

all: $(TARGETS) $(TARGETS_EXTRA)

install:
	$(foreach subdir,$(SUBDIRS), cp -r $(subdir)/$(subdir) ./$(TEST_PREFIX)$(subdir);)
	$(foreach subdir,$(SUBDIRS), cp -r $(subdir)/$(subdir).text ./$(TEST_PREFIX)$(subdir).text;)
	$(foreach subdir,$(SUBDIRS), cp -r $(subdir)/$(subdir).map ./$(TEST_PREFIX)$(subdir).map;)

clean:
	$(RM) $(TARGETS) $(TARGETS_EXTRA) $(CLEAN_EXTRA)

full_clean: clean
	$(foreach subdir,$(SUBDIRS), $(RM) ./$(TEST_PREFIX)$(subdir);)
	$(foreach subdir,$(SUBDIRS), $(RM) ./$(TEST_PREFIX)$(subdir).text;)
	$(foreach subdir,$(SUBDIRS), $(RM) ./$(TEST_PREFIX)$(subdir).map;)

%.text: %
	$(OBJDUMP) --all-headers --disassemble --source $^ > $@
#	$(OBJDUMP) --full-contents --disassemble --source $^ > $@

.PHONY: default all clean distclean
