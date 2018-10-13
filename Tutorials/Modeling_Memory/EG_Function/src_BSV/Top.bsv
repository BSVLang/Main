// Copyright (c) 2018 Bluespec, Inc.  All Rights Reserved

package Top;

// ================================================================
// BSV library imports

import Connectable :: *;

// ================================================================
// Project imports

import Project_Params :: *;
import DUT            :: *;
import Mem            :: *;

// ================================================================

(* synthesize *)
module mkTop ();

   DUT_IFC  dut <- mkDUT;
   Mem_IFC  mem <- mkMem;

   mkConnection (dut, mem);

endmodule

endpackage
