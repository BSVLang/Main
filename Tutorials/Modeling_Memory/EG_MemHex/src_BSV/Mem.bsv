// Copyright (c) 2018 Bluespec, Inc.  All Rights Reserved

package Mem;

// ================================================================
// BSV library imports

import Memory       :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;
import RegFile      :: *;

// ================================================================
// Project imports

import Project_Params :: *;

// ================================================================
// This memory is implemented as a RegFile that is pre-loaded (at
// start of simulation) from a MemHex file.

// It'll work in simulation only (Bluesim or Verilog sim)
// since loading from memhex files is only supported in simulation.

// The RegFile (and the MemHex loaded data) can be very large (MB or GB in size).

// Note: in Verilog, a MemHex file is of a specific width, i.e., each
// line represents one address in the file.  Thus, a 1-byte-wide
// MemHex file and a 2-byte-wide MemHex file are different, even if
// they are for memories of the same total byte size.
// The former will have twice the number of entries as the latter.
// In the former, each entry is 1 byte; in the latter, each entry is 2 bytes.

// This example uses a 1-byte-wide memory and MemHex file.

// ================================================================
// INTERFACE

typedef  MemoryServer #(Addr_Width, Data_Width)   Mem_IFC;

// ================================================================
// IMPLEMENTATION

module mkMem (Mem_IFC);

   FIFOF #(MemoryRequest #(Addr_Width, Data_Width)) f_memreqs <- mkFIFOF;
   FIFOF #(MemoryResponse #(Data_Width))            f_memrsps <- mkFIFOF;

   Reg #(Bit #(32)) rg_req_addr <- mkReg (0);
   Reg #(Bit #(32)) rg_rsp_addr <- mkReg (0);

   RegFile #(Bit #(32), Bit #(8))  regfile <- mkRegFileLoad ("Mem_Contents.hex", 0, fromInteger (mem_size - 1));

   // ----------------------------------------------------------------
   // BEHAVIOR

   rule rl_process_reqs;
      let memreq = f_memreqs.first;
      f_memreqs.deq;

      if (memreq.write) begin
	 $display ("ERROR: 'write' request; this is a ROM\n");
	 $finish (1);
      end

      let x = regfile.sub (memreq.address);

      let memrsp = MemoryResponse { data: x };

      f_memrsps.enq (memrsp);
   endrule

   // ----------------------------------------------------------------
   // INTERFACE

   interface Put request  = toPut (f_memreqs);
   interface Get response = toGet (f_memrsps);

endmodule

// ================================================================

endpackage
