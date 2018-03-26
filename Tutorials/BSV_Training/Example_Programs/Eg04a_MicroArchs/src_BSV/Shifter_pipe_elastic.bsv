// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package Shifter;

// Example: elastic shifter
//  (and allows data to flow without garbage, bubbles or stranding)
// This version uses the BSV library mkFIFOF for its FIFOs.

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

   FIFOF #(Tuple2 #(Bit #(8), Bit #(3))) fifo_xy1 <- mkFIFOF;
   FIFOF #(Tuple2 #(Bit #(8), Bit #(3))) fifo_xy2 <- mkFIFOF;

   rule rl_0;
      match { .x0, .y0 } = fifo_in_xy.first;  fifo_in_xy.deq;
      fifo_xy1.enq (tuple2 (((y0[0] == 0) ? x0 : (x0 << 1)), y0));
   endrule

   rule rl_1;
      match { .x1, .y1 } = fifo_xy1.first;  fifo_xy1.deq;
      fifo_xy2.enq (tuple2 (((y1[1] == 0) ? x1 : (x1 << 2)), y1));
   endrule

   rule rl_2;
      match { .x2, .y2 } = fifo_xy2.first;  fifo_xy2.deq;
      fifo_out_z.enq ((y2[2] == 0) ? x2 : (x2 << 4));
   endrule

   return toGPServer (fifo_in_xy, fifo_out_z);
endmodule

// ----------------------------------------------------------------

endpackage: Shifter
