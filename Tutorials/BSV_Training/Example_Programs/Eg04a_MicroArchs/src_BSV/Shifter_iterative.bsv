// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package Shifter;

// Example: iterative shifter

// ----------------------------------------------------------------
// Imports from the BSV library

import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;

// ----------------------------------------------------------------
// Imports for this project

import Utils :: *;
import Shifter_IFC :: *;

// ----------------------------------------------------------------
// The iterative shifter

(* synthesize *)
module mkShifter (Shifter_IFC);
   FIFOF #(Tuple2 #(Bit #(8), Bit #(3)))  fifo_in_xy <- mkFIFOF;
   FIFOF #(Bit #(8))                      fifo_out_z <- mkFIFOF;

   Reg #(Bit #(8)) rg_x <- mkRegU;
   Reg #(Bit #(3)) rg_y <- mkRegU;
   Reg #(Bit #(2)) rg_j <- mkReg (0);

   rule rl_0 (rg_j == 0);
      match { .x, .y } = fifo_in_xy.first;  fifo_in_xy.deq;
      rg_x <= ((y[0] == 0) ? x : (x << 1));
      rg_y <= y;
      rg_j <= 1;
   endrule

   rule rl_1 (rg_j == 1);
      rg_x <= ((rg_y[1] == 0) ? rg_x : (rg_x << 2));
      rg_j <= 2;
   endrule

   rule rl_2 (rg_j == 2);
      let x = ((rg_y[2] == 0) ? rg_x : (rg_x << 4));
      fifo_out_z.enq (x);
      rg_j <= 0;
   endrule

   return toGPServer (fifo_in_xy, fifo_out_z);
endmodule

// ----------------------------------------------------------------

endpackage: Shifter
