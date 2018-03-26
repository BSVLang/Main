// Copyright (c) 2013-2016 Bluespec, Inc.  All Rights Reserved.

package Testbench;

// Common testbench for variants of simple pipelines

// ----------------------------------------------------------------
// Imports from the BSV library

import GetPut       :: *;
import ClientServer :: *;

// Imports for this project

import Utils       :: *;
import Shifter_IFC :: *;
import Shifter     :: *;

// ----------------------------------------------------------------

(* synthesize *)
module mkTestbench (Empty);
   Shifter_IFC  shifter <- mkShifter;

   Reg #(Bit #(4)) rg_y <- mkReg (0);

   rule rl_gen (rg_y < 8);
      shifter.request.put (tuple2 (8'h01, truncate (rg_y)));  // or rg_y[2:0]
      rg_y <= rg_y + 1;
      $display ("%0d: Input 0x0000_0001 %0d", cur_cycle, rg_y);
   endrule

   rule rl_drain;
      let z <- shifter.response.get ();
      $display ("                                %0d: Output %8b", cur_cycle, z);
      if (z == 8'h80) $finish ();
   endrule
endmodule: mkTestbench

endpackage: Testbench
