// Copyright (c) 2014-2016 Bluespec, Inc., All Rights Reserved

package Counter2;

// This version is our second attempt at implementing our
// Up/Down Counter, using CRegs, with greater concurrency

// ----------------------------------------------------------------
// Imports for this project

import Counter2_IFC :: *;

// ----------------------------------------------------------------

(* synthesize *)
module mkCounter2 (Counter2_IFC);

   Reg #(Int #(32)) crg [2] <- mkCReg (2, 0);

   method ActionValue #(Int #(32)) count1 (Int #(32) delta);
      crg[0] <= crg[0] + delta;
      return crg[0];
   endmethod

   method ActionValue #(Int #(32)) count2 (Int #(32) delta);
      crg[1] <= crg[1] + delta;
      return crg[1];
   endmethod

endmodule: mkCounter2

// ----------------------------------------------------------------

endpackage
