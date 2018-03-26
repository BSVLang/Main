// Copyright (c) 2014-2016 Bluespec, Inc.  All Rights Reserved.

package Testbench;

// ================================================================
// Project imports

import DeepThought :: *;

// ================================================================

(* synthesize *)
module mkTestbench (Empty);

   DeepThought_IFC deepThought <- mkDeepThought;

   rule rl_ask;
      $display ("Asking the Ultimate Question of Life, The Universe and Everything");
      deepThought.whatIsTheAnswer;
   endrule

   rule rl_print_answer;
      let x <- deepThought.getAnswer;
      $display ("Deep Thought says: Hello, World! The answer is %0d.", x);
      $finish;
   endrule
endmodule

// ================================================================

endpackage
