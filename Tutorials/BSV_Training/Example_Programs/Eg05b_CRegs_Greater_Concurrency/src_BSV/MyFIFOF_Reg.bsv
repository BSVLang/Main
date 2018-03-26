// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package MyFIFOF;

// This version is our first attempt at implementing our own
// 1-element FIFOs, using ordinary registers.
// (These FIFOs won't pipeline)

// ----------------------------------------------------------------
// From the BSV library

import FIFOF  :: *;    // Using only the FIFOF interface definition

// ----------------------------------------------------------------
// Our first attempt at implementing a 1-element FIFO, using ordinary registers
// (It won't pipeline)

module mkMyFIFOF (FIFOF #(t))
   provisos (Bits #(t, tsz));

   Reg #(t)          rg       <- mkRegU;     // data storage
   Reg #(Bit #(1))   rg_count <- mkReg (0);  // # of items in FIFO (0 or 1)

   method Bool notEmpty = (rg_count == 1);
   method Bool notFull  = (rg_count == 0);

   method Action enq (t x) if (rg_count == 0);  // can enq if not full
      rg <= x;
      rg_count <= 1;
   endmethod

   method t first ()  if (rg_count == 1);  // can see first if not empty
      return rg;
   endmethod

   method Action deq () if (rg_count == 1);  // can deq if not empty
      rg_count <= 0;
   endmethod

   method Action clear;
      rg_count <= 0;
   endmethod
endmodule

// ----------------------------------------------------------------

endpackage: MyFIFOF
