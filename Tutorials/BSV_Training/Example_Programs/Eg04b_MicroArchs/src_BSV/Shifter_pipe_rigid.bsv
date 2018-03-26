// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package Shifter;

// Example: rigid, synchronous shifter

// ----------------------------------------------------------------
// From the BSV library

import Vector       :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;

// ----------------------------------------------------------------
// Imports for this project

import Utils :: *;
import Shifter_IFC :: *;

// ----------------------------------------------------------------
// The pipelined shifter

module mkShifter (Shifter_IFC #(n));
   FIFOF #(Tuple2 #(Bit #(n), Bit #(TLog #(n))))  fifo_in_xy <- mkFIFOF;
   FIFOF #(Bit #(n))                              fifo_out_z <- mkFIFOF;

   Vector #(TSub #(TLog #(n), 1), Reg #(Bit #(n)))         vr_x <- replicateM (mkRegU);
   Vector #(TSub #(TLog #(n), 1), Reg #(Bit #(TLog #(n)))) vr_y <- replicateM (mkRegU);

   Integer j_max = valueOf (TLog #(n)) - 1;

   rule rl_all_together;
      // Stage 0
      match { .x0, .y0 } = fifo_in_xy.first;  fifo_in_xy.deq;
      vr_x[0] <= ((y0[0] == 0) ? x0 : (x0 << 1));
      vr_y[0] <= y0;

      // Stage j: 1..j_max-1
      for (Integer j = 1; j < j_max; j = j + 1) begin
	 vr_x[j] <= ((vr_y[j-1][j] == 0) ? vr_x[j-1] : (vr_x[j-1] << (2**j)));
	 vr_y[j] <= vr_y[j-1];
      end

      // Stage j_max
      fifo_out_z.enq (((vr_y[j_max-1][j_max] == 0) ? vr_x[j_max-1] : (vr_x[j_max-1] << (2**j_max))));
   endrule

   return toGPServer (fifo_in_xy, fifo_out_z);
endmodule

// ----------------------------------------------------------------

endpackage: Shifter
