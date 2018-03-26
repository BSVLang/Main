// Copyright (c) 2014-2016 Bluespec, Inc., All Rights Reserved

package Counter2;

// This version is our first attempt at implementing our
// Up/Down Counter, using ordinary Regs, with less concurrency

// ----------------------------------------------------------------
// Imports for this project

import Counter2_IFC :: *;

// ----------------------------------------------------------------

(* synthesize *)
module mkCounter2 (Counter2_IFC);

   Reg #(Int #(32)) rg <- mkReg (0);

   method ActionValue #(Int #(32)) count1 (Int #(32) delta);
      rg <= rg + delta;
      return rg;
   endmethod

   method ActionValue #(Int #(32)) count2 (Int #(32) delta);
      rg <= rg + delta;
      return rg;
   endmethod

endmodule: mkCounter2

// ----------------------------------------------------------------

endpackage
