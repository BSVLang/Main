package Mergesort;

// ================================================================
// Copyright (c) 2014 Bluespec, Inc. All Rights Reserved.

// This package defines a memory-to-memory binary merge-sort module
// Inputs: A:    the array to sort
//         n:    number of elements in A (each element: 32b signed int)
//         B:    another array, size n, used for intermediate storage
// Repeatedly merges adjacent already-sorted 'spans' of size 1, 2, 4, 8, ...
// back and forth between the two arrays until the span size >= n.
// If the final sorted data is in array B, copies it back to A.
// Each merge is performed by one of N_Mergers mergeEngines

// ================================================================
// Bluespec library imports

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

// ================================================================
// Local names for N_Accel_... types

// Number of merge engines
typedef  N_Accel_Clients      N_Mergers;
// Number of configuration registers (each is 64b)
typedef  N_Accel_Config_Regs  N_Config_Regs;

// ================================================================
// Interface of Mergesort module
// The reset arg 'base_addr' is the base address in an SoC for its config regs

interface Mergesort_IFC;
   method Action reset (Addr base_addr);
   interface Server #(Req_T, Rsp_T) config_bus_ifc;
   interface Vector #(N_Mergers, Client #(Req_I, Rsp_I))  mem_bus_ifc;
endinterface

// ================================================================
// The Mergesort module

(* synthesize *)
module mkMergesort (Mergesort_IFC);

   Integer verbosity = 0;    // Increase this to get more $display debugging outputs

   Reg #(Addr) rg_base_addr <- mkRegU;

   // ----------------------------------------------------------------
   // Section: Configuration

   // FIFOs for config requests and responses
   FIFOF #(Req_T)  f_configReqs <- mkFIFOF;    // from CPU
   FIFOF #(Rsp_T)  f_configRsps <- mkFIFOF;    // to CPU

   // Config regs, and their symbolic names
   Vector #(N_Config_Regs, Reg #(Data)) vrg_configs;

   // Symbolic names for config reg numbers
   Integer run    = 0;
   Integer addr_A = 1;
   Integer addr_B = 2;
   Integer n      = 3;

   vrg_configs [run]    <- mkReg (0);    // 0:stop, 1:run
   vrg_configs [addr_A] <- mkRegU;
   vrg_configs [addr_B] <- mkRegU;
   vrg_configs [n]      <- mkRegU;

   rule rl_handle_configReq;
      Req_T req = f_configReqs.first; f_configReqs.deq;
      Rsp_T rsp;
      let offset = (req.addr - rg_base_addr) >> 3;    // byte offset to regnum offset
      if (offset >= fromInteger (valueOf (N_Config_Regs)))
	 rsp = Rsp {command:req.command, data:extend (req.addr), status:DECERR, tid:req.tid};
      else if (f_configReqs.first.command == READ)
	 rsp = Rsp {command:req.command, data:vrg_configs [offset], status:OKAY, tid:req.tid};
      else begin // (f_configReqs.first.command == WRITE)
	 vrg_configs [offset] <= req.data;
	 rsp = Rsp {command:req.command, data:extend (req.addr), status:OKAY, tid:req.tid};
      end

      f_configRsps.enq (rsp);

      // For debugging
      if (verbosity >= 1) begin
	 $write ("%0d: Mergesort: rl_handle_configReq: ", cur_cycle); display_Req (req); $display ("");
	 $write ("%0d: Mergesort: rl_handle_configReq: ", cur_cycle); display_Rsp (rsp); $display ("");
      end
   endrule

   // ----------------------------------------------------------------
   // Section: Merge sort behavior

   // Other local state
   Vector #(N_Mergers, MergeEngine_IFC) mergeEngines <- replicateM (mkMergeEngine);

   // 'span' starts at 1, and doubles on each merge pass
   Reg #(Addr)       rg_span     <- mkRegU;

   // p1 and p2 point at the two vectors, alternating between A and B after each pass
   Reg #(Addr)       rg_p1       <- mkRegU;
   Reg #(Addr)       rg_p2       <- mkRegU;
   // On each pass, i is index of next pair of spans to be merged
   Reg #(Addr)       rg_i        <- mkRegU;

   FIFOF #(Tuple4 #(Addr, Addr, Addr, Addr)) f_tasks <- mkFIFOF;

   mkAutoFSM (
      seq
	 while (True) seq
	    action
	       await (vrg_configs [run] != 0);
	       rg_span <= 1;
	       rg_p1 <= vrg_configs [addr_A];
	       rg_p2 <= vrg_configs [addr_B];
	    endaction
	    // For span = 1, 2, 4, ... until >= n
	    while (rg_span < vrg_configs [n]) seq
	       action
		  if (verbosity >= 1) $display ("%0d: Mergesort: span = %0d", cur_cycle, rg_span);
		  rg_i <= 0;
	       endaction
	       // Generate tasks to merge p1[i..i+span-1], p1[i+span..i+2*span-1] into p2[i..i+2*span-1]
	       while (rg_i < vrg_configs [n]) action
		  f_tasks.enq (tuple4 (rg_i, rg_span, rg_p1, rg_p2));
		  rg_i <= rg_i + (rg_span << 1);
	       endaction
	       action // Exchange p1 and p2, double the span
		  rg_p1 <= rg_p2;
		  rg_p2 <= rg_p1;
		  rg_span <= rg_span << 1;
	       endaction
	    endseq
	    // If final sorted array is in B, copy it back to A
	    if (rg_p1 == vrg_configs [addr_B]) action
		  if (verbosity >= 1) $display ("%0d: Mergesort: Final copy back to original array", cur_cycle);
		  f_tasks.enq (tuple4 (0, vrg_configs [n], rg_p1, rg_p2));
	    endaction
	    else
	       if (verbosity >= 1) $display ("%0d: Mergesort: No final copy to original array necessary", cur_cycle);

	    // Wait until task queue is empty and all merge engines are done
	    action
	       await (! f_tasks.notEmpty);
	       for (Integer j = 0; j < valueOf (N_Mergers); j = j + 1)
		  await (mergeEngines [j].done);
	       vrg_configs [run] <= 0;
	    endaction
	 endseq
      endseq);

   // Feed merge tasks into merge engines
   for (Integer j = 0; j < valueOf (N_Mergers); j = j + 1)
      rule rl_exec_task;
	 match { .i, .span, .p1, .p2 } = f_tasks.first; f_tasks.deq;
	 mergeEngines[j].start (fromInteger (j), i, span, p1, p2, vrg_configs [n]);
	 if (verbosity > 1)
	    $display ("%0d: Mergesort: dispatching task i %0d, span %0d, to engine %0d", cur_cycle,
		      i, span, j);
      endrule

   // ----------------------------------------------------------------
   // INTERFACE

   function Client #(Req_I, Rsp_I) mem_ifc_of (Integer j);
      return mergeEngines [j].mem_bus_ifc;
   endfunction

   method Action reset (Addr base_addr);
      rg_base_addr <= base_addr;
      vrg_configs [run] <= 0;
      f_configReqs.clear;
      f_configRsps.clear;
      f_tasks.clear;
      for (Integer j = 0; j < valueOf (N_Mergers); j = j + 1) mergeEngines [j].reset;
   endmethod

   interface config_bus_ifc = toGPServer (f_configReqs, f_configRsps);

   interface mem_bus_ifc = genWith (mem_ifc_of);
endmodule: mkMergesort

// ================================================================
// Merge Engine
// Merges two already sorted segments:
//      p1 [i0..i0+span-1] and [i0+span..i0+2*span-1]
// into p2 [i0..                         i0+2*span-1]
// Note: below, i0_lim = i0+span, i1 = i0+span, i1lim = i0+2*span

interface MergeEngine_IFC;
   method Action reset;
   method Action start (UInt #(16) engineId, Addr i0, Addr span, Addr p1, Addr p2, Addr n);
   method Bool done;

   interface Client #(Req_I, Rsp_I)  mem_bus_ifc;
endinterface

// The following constant limits how many mem requests can be in
// flight between rl_req0 and rl_rsp0, and between rl_req1 and
// rl_rsp1.  The FIFOs f_data0 and f_data1 are sized accordingly.  If
// not so limited, one can have head-of-line blocking in the shared
// FIFO f_memRsps.  The CRegs crg_credits0 and crg_credits1 are
// initialized to this value (and must be large enough to hold this
// value).

Integer max_n_reqs_in_flight = 8;

(* synthesize *)
module mkMergeEngine (MergeEngine_IFC);

   Integer verbosity = 0;

   Reg #(UInt #(16)) rg_engineId <- mkRegU;
   Reg #(Addr) rg_span    <- mkRegU;
   Reg #(Addr) rg_p1      <- mkRegU;
   Reg #(Addr) rg_p2      <- mkRegU;
   Reg #(Addr) rg_n       <- mkRegU;
   Reg #(Addr) rg_i0req   <- mkRegU;
   Reg #(Addr) rg_i0rsp   <- mkRegU;
   Reg #(Addr) rg_i0_lim  <- mkRegU;
   Reg #(Addr) rg_i1req   <- mkRegU;
   Reg #(Addr) rg_i1rsp   <- mkRegU;
   Reg #(Addr) rg_i1_lim  <- mkRegU;
   Reg #(Addr) rg_j       <- mkRegU;    // index of next output item

   Reg #(Bool) rg_running <- mkReg (False);

   FIFOF #(Req_I)  f_memReqs <- mkFIFOF;    // to Mem
   FIFOF #(Rsp_I)  f_memRsps <- mkFIFOF;    // from Mem

   Reg #(UInt #(8)) crg_credits0 [2] <- mkCRegU (2);
   Reg #(UInt #(8)) crg_credits1 [2] <- mkCRegU (2);

   FIFOF #(Data) f_data0 <- mkSizedFIFOF (max_n_reqs_in_flight);
   FIFOF #(Data) f_data1 <- mkSizedFIFOF (max_n_reqs_in_flight);

   Rsp_I next_rsp = f_memRsps.first;

   // ----------------
   // BEHAVIOR

   // Generate read reqs for segment 0
   rule rl_req0 (rg_running && (rg_i0req < rg_i0_lim) && (crg_credits0[0] != 0));
      Req_I req = Req {command:READ, addr:rg_p1 + (rg_i0req << 2), data:?, b_size:BITS32, tid:0};
      f_memReqs.enq (req);
      rg_i0req <= rg_i0req + 1;
      crg_credits0[0] <= crg_credits0[0] - 1;
      if (verbosity >= 2) $display ("%0d: Merge Engine %0d: requesting [i0req = %0d]; credits0 %0d",
				    cur_cycle, rg_engineId, rg_i0req, crg_credits0[0]);
   endrule

   // Receive read rsps for segment 0
   rule rl_rsp0 ((next_rsp.command == READ) && (next_rsp.tid == 0));
      f_memRsps.deq;
      crg_credits0[1] <= crg_credits0[1] + 1;
      if (verbosity >= 2) $display ("%0d: Merge Engine %0d: response [i0rsp] = %0h, credits0 %0d",
				    cur_cycle, rg_engineId, next_rsp.data, crg_credits0[1]);
      f_data0.enq (next_rsp.data);
   endrule

   // Generate read reqs for segment 1
   rule rl_req1 (rg_running && (rg_i1req < rg_i1_lim) && (crg_credits1[0] != 0));
      Req_I req = Req {command:READ, addr:rg_p1 + (rg_i1req << 2), data:?, b_size:BITS32, tid:1};
      f_memReqs.enq (req);
      rg_i1req <= rg_i1req + 1;
      crg_credits1[0] <= crg_credits1[0] - 1;
      if (verbosity >= 2) $display ("%0d: Merge Engine %0d: requesting [i1req = %0d]; credits1 %0d",
				    cur_cycle, rg_engineId, rg_i1req, crg_credits1[0]);
   endrule

   // Receive read rsps for segment 1
   rule rl_rsp1 ((next_rsp.command == READ) && (next_rsp.tid == 1));
      f_memRsps.deq;
      crg_credits1[1] <= crg_credits1[1] + 1;
      if (verbosity >= 2) $display ("%0d: Merge Engine %0d: response [i1rsp] = %0h, credits1 %0d",
				    cur_cycle, rg_engineId, next_rsp.data, crg_credits1[1]);
      f_data1.enq (next_rsp.data);
   endrule

   // Merge responses into output
   rule rl_merge (rg_running && ((rg_i0rsp < rg_i0_lim) || (rg_i1rsp < rg_i1_lim)));
      Data y = ?;
      Bool take0 = ?;
      if ((rg_i0rsp < rg_i0_lim) && (rg_i1rsp < rg_i1_lim))
	 take0 = (f_data0.first <= f_data1.first);
      else
	 take0 = (rg_i0rsp < rg_i0_lim);
      if (take0) begin
	 y = f_data0.first;
	 f_data0.deq;
	 rg_i0rsp <= rg_i0rsp + 1;
      end
      else begin
	 y = f_data1.first;
	 f_data1.deq;
	 rg_i1rsp <= rg_i1rsp + 1;
      end
      Req_I req = Req {command:WRITE, addr:rg_p2 + (rg_j << 2), data:y, b_size:BITS32, tid:?};
      f_memReqs.enq (req);
      if (verbosity >= 1) $display ("%0d: Merge Engine %0d: writing [%0d] <= %0h", cur_cycle, rg_engineId, rg_j, y);
      rg_j <= rg_j + 1;
   endrule

   rule rl_drain_write_rsps (next_rsp.command == WRITE);
      f_memRsps.deq;
   endrule

   rule rl_finish (rg_running && (rg_i0rsp >= rg_i0_lim) && (rg_i1rsp >= rg_i1_lim));
      rg_running <= False;
   endrule

   // ----------------
   // INTERFACE

   method Action reset;
      rg_running <= False;
      f_memReqs.clear;
      f_memRsps.clear;
      f_data0.clear;
      f_data1.clear;
   endmethod

   method Action start (UInt #(16) engineId, Addr i0, Addr span, Addr p1, Addr p2, Addr n) if (! rg_running);
      rg_engineId <= engineId;
      rg_span <= span;
      rg_p1   <= p1;
      rg_p2   <= p2;
      rg_n    <= n;

      rg_i0req <= i0;
      rg_i0rsp <= i0;

      let i1 = min (i0 + span, n);
      rg_i0_lim <= i1;
      rg_i1req  <= i1;
      rg_i1rsp  <= i1;
      let i1_lim = min (i0 + (span << 1), n);
      rg_i1_lim <= i1_lim;

      rg_j    <= i0;

      crg_credits0[1] <= fromInteger (max_n_reqs_in_flight);
      crg_credits1[1] <= fromInteger (max_n_reqs_in_flight);

      rg_running <= True;
      if (verbosity >= 1) $display ("%0d: Merge Engine %0d: [%0d..%0d][%0d..%0d]",
				    cur_cycle, engineId, i0, i1-1, i1, i1_lim-1);
   endmethod

   method Bool done;
      return (! rg_running);
   endmethod

   interface mem_bus_ifc = toGPClient (f_memReqs, f_memRsps);
endmodule: mkMergeEngine

// ================================================================

endpackage: Mergesort
