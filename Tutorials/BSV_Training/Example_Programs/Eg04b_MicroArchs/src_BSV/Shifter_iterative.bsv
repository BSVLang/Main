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

module mkShifter (Shifter_IFC #(n));
   FIFOF #(Tuple2 #(Bit #(n), Bit #(TLog #(n))))  fifo_in_xy <- mkFIFOF;
   FIFOF #(Bit #(n))                              fifo_out_z <- mkFIFOF;

   Reg #(Bit #(n))         rg_x     <- mkRegU;
   Reg #(Bit #(TLog #(n))) rg_y     <- mkRegU;
   Reg #(Bit #(TLog #(TLog #(n)))) rg_j <- mkReg (0);

   Integer j_max = valueOf (TLog #(n)) - 1;

   rule rl_0 (rg_j == 0);
      match { .x, .y } = fifo_in_xy.first;  fifo_in_xy.deq;
      rg_x <= ((y[0] == 0) ? x : (x << 1));
      rg_y <= y;
      rg_j <= 1;
   endrule

   for (Integer j = 1; j < j_max; j = j + 1)
      rule rl_j (rg_j == fromInteger (j));
	 rg_x <= ((rg_y[j] == 0) ? rg_x : (rg_x << (2**j)));
	 rg_j <= rg_j + 1;
      endrule

   rule rl_2 (rg_j == fromInteger (j_max));
      let x = ((rg_y[j_max] == 0) ? rg_x : (rg_x << (2**j_max)));
      fifo_out_z.enq (x);
      rg_j <= 0;
   endrule

   return toGPServer (fifo_in_xy, fifo_out_z);
endmodule

// ----------------------------------------------------------------

endpackage: Shifter
