// Copyright (c) 2013-2016 Bluespec, Inc.  All Rights Reserved.

package Testbench;

// ================================================================
// Testbench to drive the sorting module.
// Feed n unsorted inputs to sorter,
// drain n sorted outputs and print
// ================================================================
// BSV lib imports

import LFSR :: *;

// ================================================================
// Project imports

import Utils      :: *;
import Bubblesort :: *;

// ================================================================
// Size of array to be sorted

Int#(32) n = 5;

// ================================================================
// Testbench module

(* synthesize *)
module mkTestbench (Empty);
   Reg #(Int#(32)) rg_j1 <- mkReg (0);
   Reg #(Int#(32)) rg_j2 <- mkReg (0);

   // Instantiate an 8-bit random number generator from BSV lib
   LFSR #(Bit #(8)) lfsr <- mkLFSR_8;

   // Instantiate the parallel sorter
   Sort_IFC sorter <- mkBubblesort;

   rule rl_feed_inputs (rg_j1 < n);
      Bit#(32) v = zeroExtend (lfsr.value ());
      lfsr.next ();
      Int#(32) x = unpack (v);
      sorter.put (x);
      rg_j1 <= rg_j1 + 1;
      $display ("%0d: x_%0d = %0d", cur_cycle, rg_j1, x);
   endrule

   rule rl_drain_outputs (rg_j2 < n);
      let y <- sorter.get ();
      rg_j2 <= rg_j2 + 1;
      $display ("                                %0d: y_%0d = %0d", cur_cycle, rg_j2, y);
      if (rg_j2 == n-1) $finish;
   endrule
endmodule

// ================================================================

endpackage
