package CPU;

// ================================================================
// Copyright (c) Bluespec, Inc., 2006-2016 All Rights Reserved

// This package models a CPU driving read/write traffic onto a bus

// ================================================================
// Bluespec libraries

import RegFile      :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;
import StmtFSM      :: *;

// ================================================================
// Project imports

import Utils        :: *;
import Req_Rsp      :: *;
import Sys_Configs  :: *;

// ================================================================
// Reasons why the CPU is currently stopped

typedef enum { CPU_STOP_EXIT } CPU_Stop_Reason
   deriving (Eq, Bits);

function Action display_stop_reason (String pre, CPU_Stop_Reason reason, String post);
   action
      $write (pre);
      case (reason)
	 CPU_STOP_EXIT:            $write ("CPU_STOP_EXIT");
      endcase
      $write (post);
   endaction
endfunction

// ================================================================
// CPU interface

interface CPU_IFC;
   // Interface to Data Memory
   interface Client #(Req_I, Rsp_I)  dcache_ifc;

   // GDB handling
   method Action           run_continue ();
   method CPU_Stop_Reason  stop_reason;
   method Action           req_read_memW (Addr addr);
   method ActionValue #(Data) rsp_read_memW ();
   method Action           write_memW (Addr addr, Data d);
endinterface

// ================================================================
// CPU model

(* synthesize *)
module mkCPU_Model (CPU_IFC);

   FIFOF #(Req_I) f_reqs <- mkFIFOF;
   FIFOF #(Rsp_I) f_rsps <- mkFIFOF;

   Reg #(Bool)  rg_accelerator_busy <- mkRegU;

   // ----------------
   // BEHAVIOR

   FSM fsm <-mkFSM
   (seq
       par
	  seq
	     action // Write to accelerator config [4]: addr_A
		Req_I req = Req {command:WRITE, addr:accel_base_addr + 'h08, data:'h1000, b_size:BITS64, tid:?};
		f_reqs.enq (req);
	     endaction
	     action // Write to accelerator config [8]: addr_B
		Req_I req = Req {command:WRITE, addr:accel_base_addr + 'h10, data:'h1800, b_size:BITS64, tid:?};
		f_reqs.enq (req);
	     endaction
	     action // Write to accelerator config [0xC]: word count
		Req_I req = Req {command:WRITE, addr:accel_base_addr + 'h18, data:13, b_size:BITS64, tid:?};
		f_reqs.enq (req);
	     endaction
	     action // Write to accelerator config [0x0]: 'go' command
		Req_I req = Req {command:WRITE, addr:accel_base_addr + 'h00, data:1, b_size:BITS64, tid:?};
		f_reqs.enq (req);
	     endaction
	  endseq
	  seq    // Drain write responses from ACCELERATOR
	     f_rsps.deq;
	     f_rsps.deq;
	     f_rsps.deq;
	     f_rsps.deq;
	  endseq
       endpar

       // Poll the ACCELERATOR to check for completion
       rg_accelerator_busy <= True;
       while (rg_accelerator_busy) seq
	  delay (100);
	  $display ("%0d: CPU: polling accelerator for completion", cur_cycle);
	  action
	     Req_I req = Req {command:READ, addr:accel_base_addr, data:?, b_size:BITS64, tid:?};
	     f_reqs.enq (req);
	  endaction
    	  action
	     let rsp = f_rsps.first; f_rsps.deq;
	     Bool busy = (rsp.data != 0);
	     rg_accelerator_busy <= busy;
	     if (! busy) $display ("%0d: CPU: accelerator completed", cur_cycle);
	  endaction
       endseq
    endseq
    );

   // ----------------
   // INTERFACE
   interface dcache_ifc = toGPClient (f_reqs, f_rsps);

   // GDB handling
   method Action run_continue () if (fsm.done);
      fsm.start;
   endmethod

   method CPU_Stop_Reason  stop_reason () if (fsm.done);
      return CPU_STOP_EXIT;
   endmethod

   method Action req_read_memW (Addr addr) if (fsm.done);
      Req_I req = Req {command:READ, addr:addr, data:?, b_size:BITS32, tid:?};
      f_reqs.enq (req);
   endmethod

   method ActionValue #(Data) rsp_read_memW () if (fsm.done);
      Data d = f_rsps.first.data; f_rsps.deq;
      return d;
   endmethod

   method Action write_memW (Addr addr, Data d) if (fsm.done);
      Req_I req = Req {command:WRITE, addr:addr, data:d, b_size:BITS32, tid:?};
      f_reqs.enq (req);
   endmethod
endmodule

// ================================================================

endpackage: CPU
