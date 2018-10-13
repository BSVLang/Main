// Copyright (c) 2018 Bluespec, Inc.  All Rights Reserved

package Mem;

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
// This memory is implemented directly as combinatorial function

// It'll work (and is synthesizable), but it is only feasible for
// small memories only because it becomes a giant combinatorial mux.

// For a small twist, we also model a response latency.

// ================================================================
// INTERFACE

typedef  MemoryServer #(Addr_Width, Data_Width)   Mem_IFC;

// ================================================================
// Function representing the ROM contents

`include "fn_read_ROM.bsvi"

// ================================================================
// IMPLEMENTATION

module mkMem (Mem_IFC);

   FIFOF #(MemoryRequest #(Addr_Width, Data_Width)) f_memreqs <- mkFIFOF;
   FIFOF #(MemoryResponse #(Data_Width))            f_memrsps <- mkFIFOF;

   Reg #(Bit #(32)) rg_req_addr <- mkReg (0);
   Reg #(Bit #(32)) rg_rsp_addr <- mkReg (0);

   // ----------------------------------------------------------------
   // BEHAVIOR

   rule rl_process_reqs;
      let memreq = f_memreqs.first;
      f_memreqs.deq;

      if (memreq.write) begin
	 $display ("ERROR: 'write' request; this is a ROM\n");
	 $finish (1);
      end

      let memrsp = MemoryResponse { data: fn_read_ROM (memreq.address) };

      f_memrsps.enq (memrsp);
   endrule

   // ----------------------------------------------------------------
   // INTERFACE

   interface Put request  = toPut (f_memreqs);
   interface Get response = toGet (f_memrsps);

endmodule

// ================================================================

endpackage
