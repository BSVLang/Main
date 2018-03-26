package Fabric;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

// This package defines a fabric connecting CPUs, Memories and DMAs

// ================================================================
// Bluespec library imports

import Vector       :: *;
import FIFOF        :: *;
import GetPut       :: *;
import ClientServer :: *;

// ================================================================
// Project imports

import Utils       :: *;
import Req_Rsp     :: *;
import Sys_Configs :: *;

// ================================================================
// The interface for fabric module
// It has Server ports for CPU instruction and data mem ports, and DMA data mover
// It has Client ports for memory and DMA config

interface Fabric_IFC;
   interface Vector #(Max_Initiators, Server #(Req_I, Rsp_I))  v_servers;
   interface Vector #(Max_Targets,    Client #(Req_T, Rsp_T))  v_clients;
endinterface  

// ================================================================
// The Fabric module
// Requests from initiators are routed to targets based on address.
//     Additionally, the fabric extends the requests's tid field by
//     concatenating the inum of the initiator from which the request
//     came, so that, later, the corresponding response can routed back
//     to the correct initiator.
// Responses from targets are routed back to initiators based on the
//     inum bits of the response tid field, which were added to the request.
//     These bits are stripped off the tid field before returning the
//     response to the initiator

(* synthesize *)
module mkFabric (Fabric_IFC);
   // FIFOs for the initiator server ports
   Vector #(Max_Initiators, FIFOF #(Req_I)) v_f_i_reqs <- replicateM (mkFIFOF);
   Vector #(Max_Initiators, FIFOF #(Rsp_I)) v_f_i_rsps <- replicateM (mkFIFOF);

   // FIFOs for the target client ports
   Vector #(Max_Targets, FIFOF #(Req_T)) v_f_t_reqs <- replicateM (mkFIFOF);
   Vector #(Max_Targets, FIFOF #(Rsp_T)) v_f_t_rsps <- replicateM (mkFIFOF);

   Addr_decoder  addr_decoder <- mkAddr_decoder;

   // ----------------------------------------------------------------
   // BEHAVIOR (request and response routing and arbitration)
   // Note: this implementation is essentially a simple crossbar switch,
   // which is ok for a small # of initiators and targets (say < 4).
   // For larger scales, replace it with a bus or a multi-stage switch

   for (Integer j_initiator = 0; j_initiator < valueOf (Max_Initiators); j_initiator = j_initiator + 1)
      rule rl_initiators_to_targets;
	 Req_I req_i = v_f_i_reqs [j_initiator].first; v_f_i_reqs [j_initiator].deq;
	 if (addr_decoder.decode (req_i.addr) matches tagged Valid .tNum) begin
	    Req_T req_t = Req {command:req_i.command,
			       addr:req_i.addr,
			       data:req_i.data,
			       b_size:req_i.b_size,
			       tid:{req_i.tid,fromInteger (j_initiator)}};
	    v_f_t_reqs [tNum].enq (req_t);
	 end
	 else begin
	    $write ("%0d: ERROR: Fabric: no such target address for request: ", cur_cycle);
	    display_Req (req_i);
	    $display ("");
	    Rsp_I rsp_i = Rsp {command:req_i.command,data:req_i.data,status:DECERR,tid:req_i.tid};
	    v_f_i_rsps [j_initiator].enq (rsp_i);
	 end
      endrule

   for (Integer j_target = 0; j_target < valueOf (Max_Targets); j_target = j_target + 1)
      rule rl_targets_to_initiators;
	 Rsp_T rsp_t = v_f_t_rsps [j_target].first; v_f_t_rsps [j_target].deq;
	 INum iNum = truncate (rsp_t.tid);
	 if (iNum <= fromInteger (valueOf (Max_Initiators) - 1)) begin
	    Rsp_I rsp_i = Rsp {command:rsp_t.command,
			       data:rsp_t.data,
			       status:rsp_t.status,
			       tid:truncateLSB (rsp_t.tid)};
	    v_f_i_rsps [iNum].enq (rsp_i);
	 end
	 else begin
	    $write ("%0d: ERROR: Fabric: no such initiator for response: ", cur_cycle);
	    display_Rsp (rsp_t);
	    $display ("");
	 end
      endrule

   // ----------------------------------------------------------------
   // INTERFACE

   interface v_servers = zipWith (toGPServer, v_f_i_reqs, v_f_i_rsps);
   interface v_clients = zipWith (toGPClient, v_f_t_reqs, v_f_t_rsps);

endmodule

// ================================================================

endpackage: Fabric
