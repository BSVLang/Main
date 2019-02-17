###  -*-Makefile-*-
# Copyright (c) 2018-2019 Bluespec, Inc. All Rights Reserved

# ================================================================

include ../Resources/Include_Makefile.mk

# ================================================================
# Copy files used from previous examples

# Directory of your clone of https://github.com/bluespec/Piccolo

PICCOLO_REPO   ?= $(HOME)/GitHub/Piccolo

.PHONY: copy_files
copy_files:
	cp -p  ../Resources/Gen_Mem_Hex/Descending_Mem.hex  ./Mem.hex
	cp -p  ../Eg06a_Mergesort/src/Test_Driver.bs        src/
	cp -p  ../Eg06a_Mergesort/src/Mergesort.bs          src/
	cp -p  ../Eg06a_Mergesort/src/Merge_Engine.bs       src/

	cp -p $(PICCOLO_REPO)/src_Testbench/Fabrics/AXI4/*.bsv    src/
	cp -p $(PICCOLO_REPO)/src_Core/BSV_Additional_Libs/*.bsv  src/
