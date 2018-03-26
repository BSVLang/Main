// Copyright (c) 2014-2016 Bluespec, Inc.  All Rights Reserved.

module mkTestbench (Empty);

   rule rl_print_answer;
      $display ("Deep Thought says: Hello, World! The answer is 42.");
      $finish;
   endrule
endmodule
