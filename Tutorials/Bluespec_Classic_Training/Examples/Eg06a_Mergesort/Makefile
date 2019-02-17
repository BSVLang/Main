###  -*-Makefile-*-
# Copyright (c) 2018-2019 Bluespec, Inc. All Rights Reserved

# ================================================================

include ../Resources/Include_Makefile.mk

# ================================================================
# Copy needed files

# Directory of your clone of https://github.com/bluespec/Piccolo

PICCOLO_REPO   ?= $(HOME)/GitHub/Piccolo

.PHONY: copy_files
copy_files:
	cp -p  ../Resources/Gen_Mem_Hex/Descending_Mem.hex  ./Mem.hex
	cp -p $(PICCOLO_REPO)/src_Core/BSV_Additional_Libs/GetPut_Aux.bsv  src/

# ================================================================
