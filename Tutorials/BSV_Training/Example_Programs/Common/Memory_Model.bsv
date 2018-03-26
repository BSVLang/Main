package Memory_Model;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

// This package models a Memory serving read/write traffic from a bus.
// It implements two parallel ports into memory.
// (It is quite easy to generalize this to M ports, if needed).

// NOTE: this is just a model, for use in testbench simulation.
// In real hardware (FPGA/ASIC), it will be replaced by BRAMs/SRAMS or
// a connection to external DRAMs.

// ================================================================
// Bluespec libraries

import Vector       :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;
import StmtFSM      :: *;

// ================================================================
// Project imports

import Utils          :: *;
import Req_Rsp        :: *;
import Sys_Configs    :: *;
import C_import_decls :: *;

// ================================================================
// Memory model interface

interface Memory_IFC;
   interface Vector #(N_Mem_Ports, Server #(Req_T, Rsp_T)) bus_ifc;

   // Debug interfaces
   method Action  initialize  (Addr base_addr, Addr n_bytes, Bool init_from_file);
   method ActionValue #(Data)  debug_load  (Addr addr, TLMBSize sz);
   method Action               debug_store (Addr a, Data d, TLMBSize sz);
endinterface

// ================================================================
// Memory model

(* synthesize *)
module mkMemory_Model (Memory_IFC);

   Integer verbosity = 0;

   // Incoming memory requests, outgoing responses
   Vector #(N_Mem_Ports, FIFOF #(Req_T)) vf_reqs <- replicateM (mkFIFOF);
   Vector #(N_Mem_Ports, FIFOF #(Rsp_T)) vf_rsps <- replicateM (mkFIFOF);

   // Memory parameters
   Reg #(Bool) rg_initialized <- mkReg (False);
   Reg #(Addr) rg_base        <- mkRegU;
   Reg #(Addr) rg_limit       <- mkRegU;
   Reg #(Addr) rg_size        <- mkRegU;

   // Pointer to C malloc'd memory
   Reg #(Bit #(64)) rg_p <- mkRegU;

   // ----------------
   // Check for legal addresses (in range [base..limit-3])

   function ActionValue #(Bool) fn_addr_ok (Req_T req);
      actionvalue
	 if (   (req.addr < rg_base)
	     || ((req.addr + extend (reqSz_bytes (req.b_size)) - 1) > rg_limit)) begin
	    $display ("%0d: ERROR: Memory_model [%0h..%0h]: req addr out of bounds",
		      cur_cycle, rg_base, rg_limit);
	    display_Req (req);
	    $display ("");
	    return False;
	 end
	 else
	    return True;
      endactionvalue
   endfunction

   // ----------------
   // RULES

   for (Integer j = 0; j < valueOf (N_Mem_Ports); j = j + 1)
      rule rl_handle_reqs (rg_initialized);
	 let req = vf_reqs[j].first; vf_reqs[j].deq;
	 let addr_ok <- fn_addr_ok (req);
	 let offset = req.addr - rg_base;
	 Bit #(64) p = rg_p + extend (offset);

	 Rsp_T rsp;
	 if (req.command == UNKNOWN)
	    rsp = Rsp {command:req.command, data:extend (req.addr), status: SLVERR, tid:req.tid};
	 else if (addr_ok && (req.command == READ)) begin
	    Bit #(64) x <- c_read (p, extend (reqSz_bytes (req.b_size)));
	    rsp = Rsp {command:READ, data:x, status:OKAY, tid:req.tid};
	 end
	 else if (addr_ok && (req.command == WRITE)) begin
	    c_write (p, extend (req.data), extend (reqSz_bytes (req.b_size)));
	    rsp = Rsp {command:WRITE, data:0, status:OKAY, tid:req.tid};
	 end
	 else
	    rsp = Rsp {command:req.command, data:extend (req.addr), status: DECERR, tid:req.tid};

	 vf_rsps[j].enq (rsp);

	 if (verbosity > 0) begin
	    $display ("%0d: Memory_model, port %0d:", cur_cycle, j);
	    $write   ("    "); display_Req (req); $display ();
	    $write   ("    "); display_Rsp (rsp); $display ();
	 end
      endrule

   // ----------------
   // INTERFACE

   interface bus_ifc = zipWith (toGPServer, vf_reqs, vf_rsps);

   method Action initialize  (Addr base_addr, Addr n_bytes, Bool init_from_file);
      Bit #(64) b64 = extend (pack (init_from_file));
      let p    <- c_malloc_and_init (extend (n_bytes), b64);
      rg_p     <= p;
      rg_base  <= base_addr;
      rg_limit <= base_addr + n_bytes - 1;
      rg_size  <= n_bytes;
      rg_initialized <= True;
   endmethod

   method ActionValue #(Data) debug_load  (Addr addr, TLMBSize sz) if (rg_initialized);
      let offset = addr - rg_base;
      Bit #(64) p = rg_p + extend (offset);
      Bit #(64) x <- c_read (p, extend (reqSz_bytes (sz)));
      return x;
   endmethod

   method Action debug_store (Addr addr, Data d, TLMBSize sz) if (rg_initialized);
      let offset = addr - rg_base;
      Bit #(64) p = rg_p + extend (offset);
      c_write (p, d, extend (reqSz_bytes (sz)));
   endmethod
endmodule

// ================================================================

endpackage: Memory_Model
