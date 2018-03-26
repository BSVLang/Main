// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package MyFIFOF;

// This version is our second attempt at implementing our own
// 1-element FIFOs, using CRegs
// (These FIFOs will pipeline)

// ----------------------------------------------------------------
// From the BSV library

import FIFOF  :: *;    // Using only the FIFOF interface definition

// ----------------------------------------------------------------
// Our second attempt at implementing a 1-element FIFO, using CRegs
// (It will pipeline)

module mkMyFIFOF (FIFOF #(t))
   provisos (Bits #(t, tsz));

   Reg #(t)         crg[3]       <- mkCRegU (3);     // data storage
   Reg #(Bit #(1))  crg_count[3] <- mkCReg (3, 0);   // # of items in FIFO

   method Bool notEmpty = (crg_count[0] == 1);
   method Bool notFull  = (crg_count[1] == 0);

   method Action enq (t x) if (crg_count[1] == 0);
      crg[1] <= x;
      crg_count[1] <= 1;
   endmethod

   method t first ()  if (crg_count[0] == 1);
      return crg[0];
   endmethod

   method Action deq () if (crg_count[0] == 1);
      crg_count[0] <= 0;
   endmethod

   method Action clear;
      crg_count[2] <= 0;
   endmethod
endmodule

// ----------------------------------------------------------------

endpackage: MyFIFOF
