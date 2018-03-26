package Reorder_Buffer;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved.

// This package defines a module that can be placed between an
// initiator and the fabric whenever targets may provide out-of-order
// responses, but the initiator assumes in-order responses.  This
// module re-orders the responses, for the initiator.

// ================================================================
// Bluespec library imports

import FIFOF            :: *;
import GetPut           :: *;
import ClientServer     :: *;
import CompletionBuffer :: *;
import Connectable      :: *;

// ================================================================
// Project imports

import Utils       :: *;
import Req_Rsp     :: *;
import Sys_Configs :: *;

// ================================================================
// Interface

interface Reorder_Buffer_IFC;
   interface Server #(Req_I, Rsp_I) server;
   interface Client #(Req_I, Rsp_I) client;
endinterface

// ================================================================

(* synthesize *)
module mkReorder_Buffer (Reorder_Buffer_IFC);

   FIFOF #(Req_I) f_reqs_in  <- mkFIFOF;
   FIFOF #(Req_I) f_reqs_out <- mkFIFOF;
   FIFOF #(Rsp_I) f_rsps_in  <- mkFIFOF;
   FIFOF #(Rsp_I) f_rsps_out <- mkFIFOF;

   CompletionBuffer #(Round_Trip_Latency_t, Rsp_I) cb <- mkCompletionBuffer;

   // ----------------
   // BEHAVIOR

   rule rl_reqs;
      let token <- cb.reserve.get;
      let req_in = f_reqs_in.first; f_reqs_in.deq;
      // TODO: check that we don't lose significant bits of req_in.tid
      TID_I new_tid = truncate ({ req_in.tid, pack (token) });
      Req_I req_out = Req {command:req_in.command,
			   addr:req_in.addr,
			   data:req_in.data,
			   b_size:req_in.b_size,
			   tid:new_tid};
      f_reqs_out.enq (req_out);
   endrule

   rule rl_rsps;
      let rsp_in = f_rsps_in.first; f_rsps_in.deq;
      let token = unpack (truncate (rsp_in.tid));
      let orig_tid = (rsp_in.tid >> valueOf (SizeOf #(CBToken #(Round_Trip_Latency_t))));
      Rsp_I rsp_out = Rsp {command:rsp_in.command, data:rsp_in.data, status:rsp_in.status, tid:orig_tid};
      cb.complete.put (tuple2 (token, rsp_out));
   endrule

   mkConnection (cb.drain, toPut (f_rsps_out));

   // ----------------
   // INTERFACE

   interface server = toGPServer (f_reqs_in,  f_rsps_out);
   interface client = toGPClient (f_reqs_out, f_rsps_in);
endmodule

// ================================================================

endpackage: Reorder_Buffer
