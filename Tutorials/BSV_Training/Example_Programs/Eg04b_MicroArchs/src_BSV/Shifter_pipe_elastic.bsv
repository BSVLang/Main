// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package Shifter;

// Example: elastic shifter
//  (and allows data to flow without garbage, bubbles or stranding)
// This version uses the BSV library mkFIFOF for its FIFOs.

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

   Vector #(TSub #(TLog #(n), 1),
	    FIFOF #(Tuple2 #(Bit #(n),
			     Bit #(TLog #(n))))) vf_xy <- replicateM (mkFIFOF);

   Integer j_max = valueOf (TLog #(n)) - 1;

   rule rl_0;
      match { .x0, .y0 } = fifo_in_xy.first;  fifo_in_xy.deq;
      vf_xy[0].enq (tuple2 (((y0[0] == 0) ? x0 : (x0 << 1)), y0));
   endrule

   for (Integer j = 1; j < j_max; j = j + 1)
      rule rl_j;
	 match { .x1, .y1 } = vf_xy[j-1].first;  vf_xy[j-1].deq;
	 vf_xy[j].enq (tuple2 (((y1[j] == 0) ? x1 : (x1 << (2**j))), y1));
      endrule

   rule rl_j_max;
      match { .x2, .y2 } = vf_xy[j_max-1].first;  vf_xy[j_max-1].deq;
      fifo_out_z.enq ((y2[j_max] == 0) ? x2 : (x2 << (2**j_max)));
   endrule

   return toGPServer (fifo_in_xy, fifo_out_z);
endmodule

// ----------------------------------------------------------------

endpackage: Shifter
