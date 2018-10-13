default: compile  link

TOPFILE   ?= src_BSV/Top.bsv
TOPMODULE ?= mkTop
EXEFILE   ?= exe_hw

BSCFLAGS = -keep-fires -aggressive-conditions -no-warn-action-shadowing -no-inline-rwire -show-range-conflict

# ----------------------------------------------------------------
# FOR BLUESIM

BSCDIRS_BSIM  = -simdir build_bsim -bdir build -info-dir build
BSCPATH_BSIM  = -p ./src_BSV:%/Prelude:%/Libraries

build_bsim:
	mkdir -p $@

build:
	mkdir -p $@

.PHONY: compile
compile: build_bsim build
	@echo Compiling...
	bsc -u -sim $(BSCDIRS_BSIM)  $(BSCFLAGS)  $(BSCPATH_BSIM)  $(TOPFILE)
	@echo Compilation finished

.PHONY: link
link:
	@echo Linking...
	bsc  -sim  -parallel-sim-link 8\
		$(BSCDIRS_BSIM)  $(BSCPATH_BSIM) \
		-e $(TOPMODULE) -o ./$(EXEFILE) \
		-keep-fires \
		./src_BSV/C_Imported_Functions.c
	@echo Linking finished

.PHONY: simulate
simulate: ../Macbeth.txt
	@echo Simulation...
	./$(EXEFILE)
	@echo Simulation finished

# ----------------------------------------------------------------
# FOR VERILOG

BSCDIRS_V = -vdir verilog  -bdir build_v  -info-dir build_v
BSCPATH_V = -p ./src_BSV:%/Prelude:%/Libraries
VSIM ?= iverilog

build_v:
	mkdir -p $@

verilog:
	mkdir -p $@

.PHONY: rtl
rtl: build_v verilog
	@echo Verilog generation ...
	bsc -u -elab -verilog  $(BSCDIRS_V)  $(BSCFLAGS)  $(BSCPATH_V)  $(TOPFILE)
	@echo Verilog generation finished

.PHONY: vlink
vlink:
	bsc -verilog -vsim $(VSIM) \
		$(BSCDIRS_V) $(BSCPATH_V) \
		-e $(TOPMODULE) -o ./$(EXEFILE)_v \
		-keep-fires \
		./src_BSV/C_Imported_Functions.c
	@echo Verilog linking finished

.PHONY: vsim
vsim: ../Macbeth.txt
	@echo Simulation...
	./$(EXEFILE)_v
	@echo Simulation finished

# ----------------------------------------------------------------

.PHONY: clean
clean:
	rm -f  *~   src_BSV/*~  src_BSV/*.o  build/*  build_bsim/*

.PHONY: full_clean
full_clean:
	rm -f  *~   src_BSV/*~  src_BSV/*.o  build/*  build_bsim/*  directc_*
	rm -r -f  exe_*  build*  verilog
