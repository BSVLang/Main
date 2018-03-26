// Copyright (c) 2014-2016 Bluespec, Inc.  All Rights Reserved.

package Testbench;

// Common testbench for variants of up/down counter

// ----------------------------------------------------------------
// Imports from the BSV library

// Imports for this project

import Counter2_IFC :: *;
import Counter2     :: *;

// ----------------------------------------------------------------

(* synthesize *)
module mkTestbench (Empty);

   Counter2_IFC ctr <- mkCounter2;

   Reg #(int) step <- mkReg (0);

   rule rl_step;
      step <= step + 1;
      if (step == 10) $finish;
   endrule

   rule rl_1 (step <= 6);
      let delta_1 = step + 10;
      let old_v_1 <- ctr.count1 (delta_1);
      $display ("%2d: rl_1: delta_1 %2d  old_v_1 %2d", step, delta_1, old_v_1);
   endrule

   rule rl_2 (step >= 4);
      let delta_2 = 5 - step;
      let old_v_2 <- ctr.count2 (delta_2);
      $display ("%2d:                                rl_2: delta_2 %2d    old_v_2 %2d", step, delta_2, old_v_2);
   endrule

endmodule: mkTestbench

endpackage: Testbench
