// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package Shifter;

// Example: rigid, synchronous shifter

// ----------------------------------------------------------------
// From the BSV library

import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;

// ----------------------------------------------------------------
// Imports for this project

import Utils :: *;
import Shifter_IFC :: *;

// ----------------------------------------------------------------
// The pipelined shifter

(* synthesize *)
module mkShifter (Shifter_IFC);
   FIFOF #(Tuple2 #(Bit #(8), Bit #(3)))  fifo_in_xy <- mkFIFOF;
   FIFOF #(Bit #(8))                      fifo_out_z <- mkFIFOF;

   Reg #(Bit #(8)) rg_x1 <- mkRegU;
   Reg #(Bit #(3)) rg_y1 <- mkRegU;

   Reg #(Bit #(8)) rg_x2 <- mkRegU;
   Reg #(Bit #(3)) rg_y2 <- mkRegU;

   rule rl_all_together;
      // Stage 0
      match { .x0, .y0 } = fifo_in_xy.first;  fifo_in_xy.deq;
      rg_x1 <= ((y0[0] == 0) ? x0 : (x0 << 1));
      rg_y1 <= y0;

      // Stage 1
      rg_x2 <= ((rg_y1[1] == 0) ? rg_x1 : (rg_x1 << 2));
      rg_y2 <= rg_y1;

      // Stage 2
      fifo_out_z.enq (((rg_y2[2] == 0) ? rg_x2 : (rg_x2 << 4)));
   endrule

   return toGPServer (fifo_in_xy, fifo_out_z);
endmodule

// ----------------------------------------------------------------

endpackage: Shifter
