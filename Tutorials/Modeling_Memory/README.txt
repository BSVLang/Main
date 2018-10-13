PRE-LOADING MEMORY CONTENTS IN BSV DESIGNS

Copyright (c) 2018 Bluespec, Inc.  All Rights Reserved
Author: Rishiyur S. Nikhil

>================================================================
INTRODUCTION

This application note shows three techniques for modeling memory in
BSV, including intializing its contents.

Technique (1) below is synthesizable into hardware and can thus be
used in simulation (Bluesim or Verilog sim) and in synthesized
hardware.  But it is really only feasible for small memories, since it
can create very large combinatorial circuits.  It is typically only
used for small initial-boot ROMS.

Techniques (2) and (3) are only used in simulation (Bluesim or Verilog
sim) but are feasible for large memories (MB/GB size).

We provide example code for each of the three techniques.  The BSV
source code for the examples differ only in the files 'Mem.bsv', which
implements different initialization techniques.  In all of them, the
memory is initialized with ASCII text from the file 'Macbeth.txt'
(Shakespeare's play, provided in the top-level directory), and the DUT
simply reads memory and prints out the text.  Uninitialized memory
contains the special value 0xFF, and the DUT stops if it sees this
value.

>================================================================
Compiling, linking and running each example.

Each example can be built and run as follows

    $ cd    EG_Function                // and similarly the other directories
    $ make  compile  link  simulate    // for Bluesim simulation
    $ make  rtl  vlink  vsim           // for Icarus Verilog (IVerilog) simulation
    $ make  full_clean                 // to restore directory to original state

Prerequisite: Bluepec bsc compiler and Bluesim installation.

In example for Technique 1, since it is not scalable, it is only
pre-loaded with the first 64 characters of Macbeth.txt.  In the
examples for the other techniques, the complete play is pre-loaded
(about a 100 KB, but they can handle much larger initializations).

>================================================================
TECHNIQUE 1. WRITE A FUNCTIONAL EQUIVALENT OF A MEMORY

- Can be used in simulation, and is synthesizable as-is to HW
- Is not scalable (so, small memories only, such as small Initial-boot ROMs)

Example is in directory:    EG_Function

The sub-directory 'Gen_ROM_Function/' contains a C program that
generates a file 'fn_read_ROM.bsvi', which is BSV code corresponding
to the ROM function (just a giant combinatorial mux).  That file is
"`include"d into 'Mem.bsv'.

>================================================================
TECHNIQUE 2. USE 'mkRegFileLoad' TO LOAD CONTENTS FROM A MEM HEX FILE ON START OF SIMULATION

- Simulation only (cannot be synthesized to HW)
- Scalable: the memory can be MB or GB in size

Example is in directory:    EG_MemHex

The sub-directory 'Gen_MemHex_Image/' contains a C program that
generates a standard MemHex file containing the initial memory
contents.  These contents are pre-loaded during the instantiation of
module 'mkRegFileLoad' in 'Mem.bsv'.

>================================================================
TECHNIQUE 3. USE BSV's 'import "BDPI"' TO IMPORT C FUNCTIONS THAT MODEL MEMORY

- Simulation only (cannot be synthesized to HW)
- Scalable: the memory can be MB or GB in size

Example is in directory:    EG_Import_C

Has a file 'src_BSV/C_Imported_Functions.c' that contains functions
that are imported into 'Mem.bsv' that models memory as a malloc'd C
array, and which is intialized in C by reading 'Macbeth.txt' into the
array.

>================================================================
ACTUAL HARDWARE MEMORIES AND PRE-LOADING

This is target and tool specific.  In each of the following cases, you
can use one of the above techniques to provde a memory model during
simulation.

- BRAMs in FPGAs
    See BRAM libraries in BSV Reference Guide for instantiating
    memories that get mapped to BRAMs on FPGAs.

    Pre-loading: See Xilinx/Altera/vendor tool flow for how to
    pre-load BRAM initial contents in the bitfile.

- Static ROMs in ASICs
    See vendor tool flow for memory compilers to create ROMs with
    pre-loaded contents.

    See BSV Reference Guide for how to 'import Verilog' to create a
    BSV wrapper so they can be used in BSV designs.

- DRAMs in FPGAs or ASICs
    The basic memory interfaces are provided by vendors, in Verilog.
    See BSV Reference Guide for how to 'import Verilog' to create a
    BSV wrapper so they can be used in BSV designs.
    
    Pre-loading: There is no concept of 'pre-loading' (contents
    available on reset).  You will have to code a state machine in
    your design that reads initial contents from somewhere else (host
    machine, Flash memory, etc.), and writes it into the DRAM.

    Bluespec RISC-V SoCs, for example, contain infrastructure to
    connect to GDB on a host, from where a memory image can be loaded
    using GDB commands.

>================================================================
