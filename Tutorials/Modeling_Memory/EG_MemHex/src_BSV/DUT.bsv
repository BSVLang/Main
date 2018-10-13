// Copyright (c) 2018 Bluespec, Inc.  All Rights Reserved

package DUT;

// ================================================================
// BSV library imports

import Memory       :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;

// ================================================================
// Project imports

import Project_Params :: *;

// ================================================================
// INTERFACE

typedef MemoryClient #(Addr_Width, Data_Width)  DUT_IFC;

// ================================================================
// IMPLEMENTATION
// The DUT simply reads memory and $displays the contents ('dumps' memory)

module mkDUT (DUT_IFC);

   // STATE

   FIFOF #(MemoryRequest #(Addr_Width, Data_Width)) f_memreqs <- mkFIFOF;
   FIFOF #(MemoryResponse #(Data_Width))            f_memrsps <- mkFIFOF;

   Reg #(Bit #(32)) rg_req_addr <- mkReg (0);
   Reg #(Bit #(32)) rg_rsp_addr <- mkReg (0);

   // ----------------------------------------------------------------
   // BEHAVIOR

   rule rl_gen_reqs (rg_req_addr <= fromInteger (mem_size - 1));
      let memreq = MemoryRequest {write: False,
				  address: rg_req_addr,
				  byteen: ?,                // irrelevant for reads
				  data: ?};                 // irrelevant for reads
      f_memreqs.enq (memreq);
      rg_req_addr <= rg_req_addr + 1;
   endrule

   rule rl_handle_rsps;
      // Get the mem response
      let memrsp = f_memrsps.first;
      f_memrsps.deq;

      Bit #(8) ch = memrsp.data;

      // Terminate if special value 'h_FF
      if (ch == 'h_FF) begin
	 $display ("|FF END");    // print a final newline
	 $finish (0);
      end

      // Display directly if printable, line-feed or carriage-return; display hex otherwise
      if ((('h20 <= ch) && (ch <= 'h7F)) || (ch == 'hA) || (ch == 'hD))
	 $write ("%c", ch);
      else
	 $write ("[0x%0h]", ch);

      // Terminate if reached last address
      if (rg_rsp_addr == fromInteger (mem_size - 1)) begin
	 $display ("|EOM END");    // print a final newline
	 $finish (0);
      end

      rg_rsp_addr <= rg_rsp_addr + 1;
   endrule

   // ----------------------------------------------------------------
   // INTERFACE

   interface Get request  = toGet (f_memreqs);
   interface Put response = toPut (f_memrsps);

endmodule

// ================================================================

endpackage
