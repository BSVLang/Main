# Directory of your clone of https://github.com/bluespec/Piccolo

PICCOLO_REPO   ?= $(HOME)/GitHub/Piccolo

all: copy_files  copy_Piccolo_files  mk_Mem.hex

# ================================================================
# Create Mem.hex from ELF file

.PHONY: mk_Mem.hex
mk_Mem.hex:
	../Resources/elf_to_hex/elf_to_hex  ../C_programs_RV32/mergesort/mergesort  Mem.hex

# ================================================================
# Copy files used from previous examples

.PHONY: copy_files
copy_files:
	cp -p  ../Eg06a_Mergesort/src/Mergesort.bs     src/
	cp -p  ../Eg06a_Mergesort/src/Merge_Engine.bs  src/
	cp -p  ../Eg06b_Mergesort/src/SoC_Fabric.bs    src/

# ================================================================
# Copy relevant files from Piccolo

.PHONY: copy_Piccolo_files
copy_Piccolo_files:
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
	ls  src_Piccolo

# ================================================================
