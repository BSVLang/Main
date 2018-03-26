package Testbench;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved.

// This package defines the overall system.
// Instantiates initiators, targets and fabric, and connects them.
// Starts the CPU, and waits until it's in a BREAK, prints some memory

// ================================================================
// Bluespec libraries

import Vector       :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;
import Connectable  :: *;
import StmtFSM      :: *;

// ================================================================
// Project imports

import Utils          :: *;
import Req_Rsp        :: *;
import Sys_Configs    :: *;
import C_import_decls :: *;
import Reorder_Buffer :: *;

import CPU            :: *;
import Fabric         :: *;
import Memory_Model   :: *;
import Mergesort      :: *;

// ================================================================
// Interactive commands from the console
// Commands are returned by the imported C function: c_console_command ()
// which returns a Vector #(10, Bit #(64))
// [0] is the arg count (>= 1)
// [1] is the command, see codes below
// [2..9] are the optional arguments (up to 8 args)

Bit #(64) cmd_continue   = 0;
Bit #(64) cmd_dump       = 1;
Bit #(64) cmd_quit       = 2;
Bit #(64) cmd_reset      = 3;
Bit #(64) cmd_step       = 4;
Bit #(64) cmd_step_until = 5;
Bit #(64) cmd_verbosity  = 6;    // arg: verbosity level
Bit #(64) cmd_dump_mem   = 7;

// ================================================================
// Testbench module

(* synthesize *)
module mkTestbench (Empty) ;

   CPU_IFC        cpu       <- mkCPU_Model;
   Memory_IFC     mem       <- mkMemory_Model;
   Fabric_IFC     fabric    <- mkFabric;
   Mergesort_IFC  mergesort <- mkMergesort;

   mkConnection (cpu.dcache_ifc, fabric.v_servers [cpu_d_iNum]);

   for (Integer j = 0; j < valueOf (N_Accel_Clients); j = j + 1) begin
      Reorder_Buffer_IFC reorder_buffer <- mkReorder_Buffer;
      mkConnection (mergesort.mem_bus_ifc [j], reorder_buffer.server);
      mkConnection (reorder_buffer.client, fabric.v_servers [accel_iNums[j]]);
   end

   for (Integer j = 0; j < valueOf (N_Mem_Ports); j = j + 1)
      mkConnection (fabric.v_clients [mem_tNums [j]], mem.bus_ifc [j]);

   mkConnection (fabric.v_clients [accel_tNum], mergesort.config_bus_ifc);

   // ----------------
   // Main behavior: process a queue of interactive commands

   Reg #(Vector #(10, Bit #(64))) rg_console_command <- mkRegU;
   Bit #(64) console_argc     = rg_console_command [0];
   Bit #(64) console_command  = rg_console_command [1];
   Bit #(64) console_arg_1    = rg_console_command [2];
   Bit #(64) console_arg_2    = rg_console_command [3];
   Bit #(64) console_arg_3    = rg_console_command [4];
   Bit #(64) console_arg_4    = rg_console_command [5];
   Bit #(64) console_arg_5    = rg_console_command [6];
   Bit #(64) console_arg_6    = rg_console_command [7];
   Bit #(64) console_arg_7    = rg_console_command [8];
   Bit #(64) console_arg_8    = rg_console_command [9];

   Reg #(Bit #(64)) rg_addr <- mkRegU;
   Reg #(Bit #(64)) rg_data <- mkRegU;

   // Start address and length of vector to be sorted; address of scratch working area
   Addr sort_start_addr   = 'h1000;
   Addr n_words           = 13;
   Addr sort_scratch_addr = 'h1800;

   Stmt dump_mem_range =
   seq
      $display ("%0d: dumping memory region", cur_cycle);
      for (rg_addr <= sort_start_addr; rg_addr < sort_start_addr + (n_words << 2); rg_addr <= rg_addr + 4) seq
	 action
	    let d <- mem.debug_load (rg_addr, BITS32);
            rg_data <= d;
	 endaction
	 $display ("%016h: %8h", rg_addr, rg_data);
      endseq
   endseq;

   mkAutoFSM (
      seq
	 // Allocate memory, reset the mergesort module
	 action
	    $display ("Testbench: Allocating memory [%0h..%0h]", mem_base_addr, mem_max_addr);
	    Bool init_from_file = True;
	    mem.initialize (mem_base_addr, mem_size, init_from_file);
	    mergesort.reset (accel_base_addr);
	 endaction

	 dump_mem_range;

	 // Run
	 while (True) seq
	    action
	       let cmd <- c_get_console_command;
	       rg_console_command <= cmd;
	    endaction

	    if (console_command == cmd_continue) seq
	       // GDB 'continue' action: ('run' the CPU program)
	       cpu.run_continue;
	       // GDB waits for CPU to stop, and retrieves the 'stop reason'
	       display_stop_reason ("Stop: reason: ", cpu.stop_reason, "\n");

	       // Show final state of memory
	       dump_mem_range;
	    endseq

	    else if (console_command == cmd_quit)
	       break;

	    else if (console_command == cmd_dump_mem)
	       for (rg_addr <= (console_arg_1 & 64'hFFFF_FFFF_FFFF_FFFC);
		    rg_addr < console_arg_2;
		    rg_addr <= rg_addr + 4)
	       seq
		  cpu.req_read_memW (rg_addr);
		  action
		     let d <- cpu.rsp_read_memW;
		     $display ("%016h: %08h", rg_addr, d);
		  endaction
	       endseq

	    else
	       $display ("Ignored unknown command: %0d", console_command);
	 endseq
      endseq
      );
endmodule

// ================================================================

endpackage: Testbench
