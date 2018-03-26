// Copyright (c) 2014-2016 Bluespec, Inc.  All Rights Reserved.

package DeepThought;

// ================================================================
// Interface definition

interface DeepThought_IFC;
   method Action whatIsTheAnswer;
   method ActionValue #(int)  getAnswer;
endinterface

// ================================================================
// Module definition

typedef enum { IDLE, THINKING, ANSWER_READY } State_DT
deriving (Eq, Bits, FShow);

(* synthesize *)
module mkDeepThought (DeepThought_IFC);

   Reg #(State_DT) rg_state_dt <- mkReg (IDLE);

   Reg #(Bit #(4)) rg_half_millenia <- mkReg (0);

   let millenia = rg_half_millenia [3:1];
   let half_millenium = rg_half_millenia [0];

   rule rl_think (rg_state_dt == THINKING);
      $write ("        DeepThought: ... thinking ... (%0d", millenia);
      if (half_millenium == 1) $write (".5");
      $display (" million years)");

      if (rg_half_millenia == 15)
	 rg_state_dt <= ANSWER_READY;
      else
	 rg_half_millenia <= rg_half_millenia + 1;
   endrule

   method Action whatIsTheAnswer if (rg_state_dt == IDLE);
      rg_state_dt <= THINKING;
   endmethod

   method ActionValue#(int) getAnswer if (rg_state_dt == ANSWER_READY);
      rg_state_dt <= IDLE;
      rg_half_millenia <= 0;
      return 42;
   endmethod
endmodule

// ================================================================

endpackage
