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
// This memory is implemented using imported C functions.
// On reset, we call c_init() to:
//    - malloc() a C array for the memory
//    - pre-load it from a specific contents-file
//    - return the malloc'd pointer as an opaque 64b value
// Each 'memory read' becomes a C function call that reads the byte
//     from the C array.

// It'll work in simulation only (Bluesim or Verilog sim)
// since importing C functions is only supported in simulation.

// The C array can be very large (MB or GB in size, anything you can malloc).

// ================================================================
// Declaring imports of C functions

// ----------------

import "BDPI" function ActionValue #(Bit #(64)) c_init (Bit #(32)  mem_size);

// Corresponding C function header:
//      extern uint64_t c_init (uint32_t  mem_size);

// ----------------

import "BDPI" function ActionValue #(Bit #(8)) c_read_byte (Bit #(64) ptr, Bit #(32) address);

// Corresponding C function header:
//     extern uint8_t c_read_byte (uint8_t *ptr,  uint32_t  address);

// ----------------
// Some pragmatic advice:
//
//     Use an 'ActionValue' return type for any imported C function if
//     there is any chance it may have side-effects, or if it has any
//     dependency on other functions.  Here, c_read_byte() seems to be
//     a pure function, but it could have side effects (e.g., the C
//     code could be keeping an internal count of the number of
//     reads).  Further, c_read_byte() depends on c_init(), which must
//     be called first, to do the malloc and obtain the malloc'd
//     pointer (if called with a bad pointer, the C code will crash).
//
//     Without ActionValue types, the bsc compiler may assume the C
//     function is pure; it may apply call optimizations where it is
//     called fewer or more times than expected, and/or they may be
//     called in an unexpected order.
//
//     Summary: be safe: just use ActionValue types.

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

   Reg #(Bool)      rg_initialized <- mkReg (False);
   Reg #(Bit #(64)) rg_C_ptr       <- mkRegU;

   // ----------------------------------------------------------------
   // BEHAVIOR

   rule rl_init (! rg_initialized);
      let c_ptr <- c_init (fromInteger (mem_size));
      rg_C_ptr       <= c_ptr;
      rg_initialized <= True;
   endrule

   rule rl_process_reqs (rg_initialized);

      let memreq = f_memreqs.first;
      f_memreqs.deq;

      if (memreq.write) begin
	 $display ("ERROR: 'write' request; this is a ROM\n");
	 $finish (1);
      end

      let x <- c_read_byte (rg_C_ptr, memreq.address);

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
