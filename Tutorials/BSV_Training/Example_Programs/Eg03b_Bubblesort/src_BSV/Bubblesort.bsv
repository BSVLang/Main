// Copyright (c) 2013-2016 Bluespec, Inc.  All Rights Reserved.

package Bubblesort;

// ================================================================
// A parallel bubble-sorter

// This example is a warm-up exercise that sorts just 5 'Int#(32)' values.
// The goal here is to understand concurrency of BSV 'rules'.

// We assume that the 'Int#(32)' values to be sorted are strictly
// smaller than the largest 'Int#(32)', so that we can use largest
// 'Int#(32)' as a "special" value.

// Later refinements of this example generalize 5 to 'n', and
// generalize 'Int#(32)' to an arbitrary type 't'.

// ================================================================
// Project imports

import Utils :: *;

// ================================================================
// Interface definition for the sorter.
// Accepts a stream of 5 unsorted inputs via the put method.
// Returns a stream of 5 sorted outputs via the get method.

interface Sort_IFC;
   method Action  put (Int #(32) x);
   method ActionValue #(Int #(32))  get;
endinterface

// ================================================================
// Module definition for the concurrent bubble sorter.

(* synthesize *)
module mkBubblesort (Sort_IFC);

   // Count incoming values (up to 5)
   Reg #(UInt #(3))  rg_inj <- mkReg (0);

   // Five registers to hold the values to be sorted
   // Note: 'maxBound' is largest 'Int#(32)'; we assume none of the
   // actual values to be sorted have this value.
   Reg #(Int #(32)) x0 <- mkReg (maxBound);
   Reg #(Int #(32)) x1 <- mkReg (maxBound);
   Reg #(Int #(32)) x2 <- mkReg (maxBound);
   Reg #(Int #(32)) x3 <- mkReg (maxBound);
   Reg #(Int #(32)) x4 <- mkReg (maxBound);

   rule rl_swap_0_1 (x0 > x1);
      x0 <= x1;
      x1 <= x0;
   endrule

   rule rl_swap_1_2 (x1 > x2);
      x1 <= x2;
      x2 <= x1;
   endrule

   rule rl_swap_2_3 (x2 > x3);
      x2 <= x3;
      x3 <= x2;
   endrule

   (* descending_urgency = "rl_swap_3_4, rl_swap_2_3, rl_swap_1_2, rl_swap_0_1" *)
   rule rl_swap_3_4 (x3 > x4);
      x3 <= x4;
      x4 <= x3;
   endrule

   // Test if array is sorted
   function Bool done ();
      return ((rg_inj == 5) && (x0 <= x1) && (x1 <= x2) && (x2 <= x3) && (x3 <= x4));
   endfunction

   // ----------------
   // INTERFACE

   // Inputs: feed input values into x4
   method Action put (Int#(32) x) if ((rg_inj < 5) && (x4 == maxBound));
      x4 <= x;
      rg_inj <= rg_inj + 1;
   endmethod

   // Outputs: drain by shifting them out of x0
   method ActionValue#(Int#(32)) get () if (done);
      x0 <= x1;
      x1 <= x2;
      x2 <= x3;
      x3 <= x4;
      x4 <= maxBound;
      if (x1 == maxBound) rg_inj <= 0;
      return x0;
   endmethod
endmodule: mkBubblesort

// ================================================================

endpackage: Bubblesort
