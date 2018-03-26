package Testbench;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved.

// Testbench for Mergesort module
// Instantiates mergesort, memory.  Programs the mergesort module,
// and waits for it to complete.

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

import Memory_Model   :: *;
import Mergesort      :: *;

// ================================================================
// Testbench module

(* synthesize *)
module mkTestbench (Empty) ;

   Memory_IFC     mem                 <- mkMemory_Model;
   Mergesort_IFC  mergesort           <- mkMergesort;

   Reg #(Bool)    rg_accelerator_busy <- mkRegU;
   Reg #(Addr)    rg_addr             <- mkRegU;

   mkConnection (mergesort.mem_bus_ifc, mem.bus_ifc [0]);

   // Start address and length of vector to be sorted; address of scratch working area
   Addr sort_start_addr   = 'h1000;
   Addr n_words           = 13;
   Addr sort_scratch_addr = 'h1800;

   Reg #(Bit #(64)) rg_data <- mkRegU;

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

	 // Write to accelerator config [8]: addr_A, consume response
	 action
	    Req_T req = Req {command:WRITE, addr:accel_base_addr + 'h08, data:sort_start_addr, b_size:BITS64, tid:?};
	    mergesort.config_bus_ifc.request.put (req);
	 endaction
	 action
	    let rsp <- mergesort.config_bus_ifc.response.get;
	 endaction

	 // Write to accelerator config [16]: addr_B, consume response
	 action
	    Req_T req = Req {command:WRITE, addr:accel_base_addr + 'h10, data:sort_scratch_addr, b_size:BITS64, tid:?};
	    mergesort.config_bus_ifc.request.put (req);
	 endaction
	 action
	    let rsp <- mergesort.config_bus_ifc.response.get;
	 endaction

	 // Write to accelerator config [24]: word count, consume response
	 action
	    Req_T req = Req {command:WRITE, addr:accel_base_addr + 'h18, data:n_words, b_size:BITS64, tid:?};
	    mergesort.config_bus_ifc.request.put (req);
	 endaction
	 action
	    let rsp <- mergesort.config_bus_ifc.response.get;
	 endaction

	 // Write to accelerator config [0]: 'go' command, consume response
	 action
	    Req_T req = Req {command:WRITE, addr:accel_base_addr + 'h00, data:1, b_size:BITS64, tid:?};
	    mergesort.config_bus_ifc.request.put (req);
	 endaction
	 action
	    let rsp <- mergesort.config_bus_ifc.response.get;
	 endaction

	 // Poll for accelerator completion
	 rg_accelerator_busy <= True;
	 while (rg_accelerator_busy) seq
	    delay (100);    // sleep for 100 cycles
	    $display ("%0d: Testbench: polling accelerator for completion", cur_cycle);
	    action
	      Req_T req = Req {command:READ, addr:accel_base_addr, data:?, b_size:BITS64, tid:?};
	      mergesort.config_bus_ifc.request.put (req);
	    endaction
    	    action
	      let rsp <- mergesort.config_bus_ifc.response.get;
	      Bool busy = (rsp.data != 0);
	      rg_accelerator_busy <= busy;
	      if (! busy) $display ("%0d: Testbench: accelerator completed", cur_cycle);
	    endaction
	 endseq

	 dump_mem_range;
      endseq
      );
endmodule

// ================================================================

endpackage: Testbench
