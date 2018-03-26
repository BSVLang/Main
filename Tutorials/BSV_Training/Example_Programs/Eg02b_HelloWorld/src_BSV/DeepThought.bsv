// Copyright (c) 2014-2016 Bluespec, Inc.  All Rights Reserved.

package DeepThought;

// ================================================================
// Interface declaration

interface DeepThought_IFC;
   method ActionValue #(int)  getAnswer;
endinterface

// ================================================================
// Module definition

(* synthesize *)
module mkDeepThought (DeepThought_IFC);

   method ActionValue#(int) getAnswer;
      return 42;
   endmethod
endmodule

// ================================================================

endpackage
