###  -*-Makefile-*-
# Copyright (c) 2018-2019 Bluespec, Inc. All Rights Reserved

# ================================================================
# Flags to be included in BSC_COMP_FLAGS for Piccolo compilation

BSC_COMP_FLAG1 = \
	-D RV32 \
	-D ISA_PRIV_M  -D ISA_PRIV_U  \
	-D ISA_I  -D ISA_M  -D ISA_A  \
	-D SHIFT_BARREL    \
	-D MULT_SYNTH    \
	-D Near_Mem_Caches    \
	-D FABRIC32

# Path component to be included in BSC_PATHS for Piccolo files (see 'copy_Piccolo_files' below)

BSC_PATH1 = src_Piccolo:

# ================================================================

include ../Resources/Include_Makefile.mk

# ================================================================

.PHONY: b_sim_hello
b_sim_hello:
	@echo "Running b_sim on 'Hello World!' C program"
	cp -p  ../C_programs_RV32/hello/hello_Mem.hex  ./Mem.hex
	make b_sim

.PHONY: b_sim_hello
b_sim_mergesort:
	@echo "Running b_sim on 'mergesort' C program"
	cp -p  ../C_programs_RV32/mergesort/mergesort_Mem.hex  ./Mem.hex
	make b_sim

# ================================================================
# Copy files used from previous examples

.PHONY: copy_files
copy_files:
	cp -p  ../Eg06a_Mergesort/src/Mergesort.bs     src/
	cp -p  ../Eg06a_Mergesort/src/Merge_Engine.bs  src/

# ================================================================
# Copy relevant files from Piccolo

# Directory of your clone of https://github.com/bluespec/Piccolo

PICCOLO_REPO   ?= $(HOME)/GitHub/Piccolo

.PHONY: copy_Piccolo_files
copy_Piccolo_files:
	@echo "Piccolo repository is: $(PICCOLO_REPO)"
	@echo "Copying Piccolo files into src_Piccolo/"
	mkdir -p  src_Piccolo
	cp -p $(PICCOLO_REPO)/src_Core/ISA/ISA_Decls.bsv          src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/ISA/ISA_Decls_C.bsv        src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/ISA/ISA_Decls_Priv_S.bsv   src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/ISA/ISA_Decls_Priv_M.bsv   src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/ISA/TV_Info.bsv            src_Piccolo/
#
	cp -p $(PICCOLO_REPO)/src_Core/RegFiles/GPR_RegFile.bsv      src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/RegFiles/CSR_RegFile.bsv      src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/RegFiles/CSR_RegFile_MSU.bsv  src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/RegFiles/CSR_MSTATUS.bsv      src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/RegFiles/CSR_MIP.bsv          src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/RegFiles/CSR_MIE.bsv          src_Piccolo/
#
	cp -p $(PICCOLO_REPO)/src_Core/Core/Core_IFC.bsv          src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/Core.bsv              src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/CPU_IFC.bsv           src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/CPU_Globals.bsv       src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/CPU.bsv               src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/CPU_Stage1.bsv        src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/CPU_Stage2.bsv        src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/CPU_Stage3.bsv        src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/EX_ALU_functions.bsv  src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/RISCV_MBox.bsv        src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/IntMulDiv.bsv         src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Core/Fabric_Defs.bsv       src_Piccolo/
#
	cp -p $(PICCOLO_REPO)/src_Core/Near_Mem_VM/Near_Mem_IFC.bsv      src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Near_Mem_VM/Cache_Decls_RV32.bsv  src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Near_Mem_VM/Near_Mem_Caches.bsv   src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Near_Mem_VM/MMU_Cache.bsv         src_Piccolo/
	cp -p $(PICCOLO_REPO)/src_Core/Near_Mem_VM/Near_Mem_IO.bsv       src_Piccolo/
#
	cp -p $(PICCOLO_REPO)/src_Core/BSV_Additional_Libs/*.bsv  src_Piccolo/
#
	cp -p $(PICCOLO_REPO)/src_Testbench/Fabrics/AXI4/*.bsv  src_Piccolo/
#
	cp -p $(PICCOLO_REPO)/src_Testbench/SoC/UART_Model.bsv  src_Piccolo/
#
	@echo "Copied Piccolo files into src_Piccolo/; contents:"
	ls  src_Piccolo

# ================================================================
