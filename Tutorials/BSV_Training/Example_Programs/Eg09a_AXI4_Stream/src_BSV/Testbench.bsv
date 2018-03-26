// Copyright (c) 2013-2016 Bluespec, Inc.  All Rights Reserved

package Testbench;

// ================================================================
// BSV library imports

import Vector      :: *;
import FIFOF       :: *;
import GetPut      :: *;
import Connectable :: *;

// ================================================================
// Project imports

import AXI4_Stream :: *;

// ================================================================

(* synthesize *)
module mkTestbench (Empty);
   AXI4_Stream_Master_Xactor_IFC #(2,4,4,1) m_xactor <- mkAXI4_Stream_Master_Xactor_2_4_4_1;
   AXI4_Stream_Slave_Xactor_IFC #(2,4,4,1)  s_xactor <- mkAXI4_Stream_Slave_Xactor_2_4_4_1;

   Reg #(Bit #(32)) rg_cycle <- mkReg (0);
   Reg #(Bit #(32)) rg_x     <- mkReg (0);

   mkConnection (m_xactor.axi_side, s_xactor.axi_side);

   rule rl_count_cycles;
      rg_cycle <= rg_cycle + 1;
   endrule

   rule rl_gen ((rg_cycle & 'h7) < 4);
      AXI4_Stream_Payload #(2,4,4,1) payload = AXI4_Stream_Payload {tDATA: replicate (truncate (rg_x)),
								    tSTRB: '1,
								    tKEEP: '1,
								    tLAST: True,
								    tID:   1,
								    tDEST: 1,
								    tUSER: 1};
      m_xactor.bsv_side.put (payload);
      if (rg_x == 16)
	 $finish (0);
      else
	 rg_x <= rg_x + 1;

      // $display ("%0d: Gen:", rg_cycle, fshow (payload));
      $display ("%0d: Gen:", rg_cycle, fshow (payload.tDATA));
   endrule

   rule rl_drain (3 < (rg_cycle & 'h7));
      let payload <- s_xactor.bsv_side.get;

      $display ("%0d:         Drain:", rg_cycle, fshow (payload.tDATA));
   endrule
endmodule

// ================================================================

(* synthesize *)
module mkAXI4_Stream_Master_Xactor_2_4_4_1 (AXI4_Stream_Master_Xactor_IFC #(2,4,4,1));
   let ifc <- mkAXI4_Stream_Master_Xactor;
   return ifc;
endmodule

(* synthesize *)
module mkAXI4_Stream_Slave_Xactor_2_4_4_1 (AXI4_Stream_Slave_Xactor_IFC #(2,4,4,1));
   let ifc <- mkAXI4_Stream_Slave_Xactor;
   return ifc;
endmodule

// ================================================================

endpackage
