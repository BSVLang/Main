// Copyright (c) 2013-2016 Bluespec, Inc.  All Rights Reserved

package AXI4_Stream;

// ================================================================
// Transactors for converting from BSV Get/Put to AXI4-Stream Protocol interfaces

// Ref: ARM document "AMBA 4 AXI4-Stream Protocol", AXRM IHI 0051A (ID030510)
// ================================================================
// BSV library imports

import Vector      :: *;
import FIFOF       :: *;
import GetPut      :: *;
import Connectable :: *;

// ================================================================
// This struct is used inside BSV code, and describes the payload
// transferred on an AX4 Stream clock

typedef struct {
   Vector #(n, Bit #(8))  tDATA;
   Bit #(n)               tSTRB;
   Bit #(n)               tKEEP;
   Bool                   tLAST;
   Bit #(i)               tID;
   Bit #(d)               tDEST;
   Bit #(u)               tUSER;
   } AXI4_Stream_Payload #(numeric type n,    // width of TDATA (# of bytes)
			   numeric type i,    // width of TID (# of bits)
			   numeric type d,    // width of TDEST (# of bits)
			   numeric type u)    // width of TUSER (# of bits)
   deriving (Bits, FShow);

// ================================================================
// These are the signal-level interfaces for an AXI4 Stream master and slave, respectively.
// The (*..*) attributes ensure that when bsc compiles this to Verilog,
// we get exactly the signals specified in the ARM spec.

interface AXI4_Stream_Master_IFC #(numeric type n,
				   numeric type i,
				   numeric type d,
				   numeric type u);
   (* prefix="" *)
   (* always_ready, always_enabled  *) method Action put ((* port="TREADY" *) Bool tREADY);

   (* always_ready, result="TVALID" *) method Bool                  tVALID;
   (* always_ready, result="TDATA"  *) method Vector #(n, Bit #(8)) tDATA;
   (* always_ready, result="TSTRB"  *) method Bit #(n)              tSTRB;
   (* always_ready, result="TKEEP"  *) method Bit #(n)              tKEEP;
   (* always_ready, result="TLAST"  *) method Bool                  tLAST;
   (* always_ready, result="TID"    *) method Bit #(i)              tID;
   (* always_ready, result="TDEST"  *) method Bit #(d)              tDEST;
   (* always_ready, result="TUSER"  *) method Bit #(u)              tUSER;
endinterface

interface AXI4_Stream_Slave_IFC #(numeric type n,
				  numeric type i,
				  numeric type d,
				  numeric type u);
   (* prefix="", always_ready, result = "TREADY" *)
   method Bool tREADY;

   (* prefix="", always_ready, always_enabled *)
   method Action put ((* port="TVALID" *) Bool                   tVALID,
		      (* port="TDATA" *)  Vector #(n, Bit #(8))  tDATA,
		      (* port="TSTRB" *)  Bit #(n)               tSTRB,
		      (* port="TKEEP" *)  Bit #(n)               tKEEP,
		      (* port="TLAST" *)  Bool                   tLAST,
		      (* port="TID" *)    Bit #(i)               tID,
		      (* port="TDEST" *)  Bit #(d)               tDEST,
		      (* port="TUSER" *)  Bit #(u)               tUSER);
endinterface

instance Connectable #(AXI4_Stream_Master_IFC #(n,i,d,u),
		       AXI4_Stream_Slave_IFC #(n,i,d,u));
   module mkConnection #(AXI4_Stream_Master_IFC #(n,i,d,u) axim,
			 AXI4_Stream_Slave_IFC #(n,i,d,u) axis)
		       (Empty);
      (* fire_when_enabled, no_implicit_conditions *)
      rule rl_every_clock;
	 axim.put (axis.tREADY);
	 axis.put (axim.tVALID, axim.tDATA, axim.tSTRB, axim.tKEEP, axim.tLAST, axim.tID, axim.tDEST, axim.tUSER);
      endrule
   endmodule
endinstance

// ================================================================
// Master transactor

interface AXI4_Stream_Master_Xactor_IFC #(numeric type n, numeric type i, numeric type d, numeric type u);
   (* prefix="" *)
   interface AXI4_Stream_Master_IFC #(n,i,d,u)      axi_side;
   interface Put #(AXI4_Stream_Payload #(n,i,d,u))  bsv_side;
endinterface

module mkAXI4_Stream_Master_Xactor (AXI4_Stream_Master_Xactor_IFC #(n,i,d,u));

   // This FIFO is guarded on BSV side (enq), unguarded on AXI side (first/deq)
   FIFOF #(AXI4_Stream_Payload #(n,i,d,u)) fifo <- mkGFIFOF (False, True);

   // ----------------------------------------------------------------
   // INTERFACE

   interface axi_side = interface AXI4_Stream_Master_IFC;
			   // Slave drives tREADY
			   method Action put (Bool tREADY);
			      if (fifo.notEmpty && tREADY) fifo.deq;
			   endmethod

			   // We drive all the signals below
			   method Bool                  tVALID = fifo.notEmpty;
			   method Vector #(n, Bit #(8)) tDATA  = fifo.first.tDATA;
			   method Bit #(n)              tSTRB  = fifo.first.tSTRB;
			   method Bit #(n)              tKEEP  = fifo.first.tKEEP;
			   method Bool                  tLAST  = fifo.first.tLAST;
			   method Bit #(i)              tID    = fifo.first.tID;
			   method Bit #(d)              tDEST  = fifo.first.tDEST;
			   method Bit #(u)              tUSER  = fifo.first.tUSER;
			endinterface;

   interface bsv_side = toPut (fifo);
endmodule

// ================================================================
// Slave transactor

interface AXI4_Stream_Slave_Xactor_IFC #(numeric type n, numeric type i, numeric type d, numeric type u);
   (* prefix="" *)
   interface AXI4_Stream_Slave_IFC #(n,i,d,u)       axi_side;
   interface Get #(AXI4_Stream_Payload #(n,i,d,u))  bsv_side;
endinterface

module mkAXI4_Stream_Slave_Xactor (AXI4_Stream_Slave_Xactor_IFC #(n,i,d,u));

   // This FIFO is guarded on BSV side (first/deq), unguarded on AXI side (enq)
   FIFOF #(AXI4_Stream_Payload #(n,i,d,u)) fifo <- mkGFIFOF (True, False);

   // ----------------------------------------------------------------
   // INTERFACE

   interface axi_side = interface AXI4_Stream_Slave_IFC;
			   // We driver TREADY when FIFO can accept more data
			   method Bool tREADY = fifo.notFull;

			   // We accept data whenever TVALID is true and FIFO can accept more data
			   method Action put (Bool                   tVALID,
					      Vector #(n, Bit #(8))  tDATA,
					      Bit #(n)               tSTRB,
					      Bit #(n)               tKEEP,
					      Bool                   tLAST,
					      Bit #(i)               tID,
					      Bit #(d)               tDEST,
					      Bit #(u)               tUSER);
			      let s = AXI4_Stream_Payload {tDATA:tDATA, tSTRB:tSTRB, tKEEP:tKEEP,
							   tLAST:tLAST, tID:tID, tDEST:tDEST, tUSER:tUSER};
			      if (tVALID && fifo.notFull)
				 fifo.enq (s);
			   endmethod

			endinterface;

   interface bsv_side = toGet (fifo);
endmodule

// ================================================================

endpackage
