// Copyright (c) 2013-2016 Bluespec, Inc.  All Rights Reserved.

package Bubblesort;

// ================================================================
// A parallel bubble-sorter

// Previous versions:
//     Eg01a_Bubblesort: Sorts exactly 5 'Int#(32)' values.
//
// This version:
//     Eg01b_Bubblesort: Generalizes from '5' to 'n'.

// Later versions:
//     Eg01c_Bubblesort: Generalizes 'Int#(32)' to 't', i.e., makes it polymorphic

// ================================================================
// BSV lib imports

import Vector :: *;

// ================================================================
// Project imports

import Utils :: *;

// ================================================================
// Interface definition for the parallel sorter
// Accepts a stream of n_t unsorted inputs via the put method
// Returns a stream of n_t sorted outputs via the get method

interface Sort_IFC #(numeric type n_t);
   method Action  put (Int #(32) x);
   method ActionValue #(Int #(32))  get;
endinterface

// ================================================================
// Module def for the parallel sorter

module mkBubblesort (Sort_IFC #(n_t));

   // Constant values derived from the type n_t
   Integer n    = valueOf (n_t);
   Integer jMax = n-1;

   // Count incoming values (up to n)
   Reg #(UInt #(16))  rg_inj  <- mkReg (0);

   // A vector of registers to hold the values being sorted
   // Note: 'maxBound' is largest 'Int#(32)'; we assume none of the
   // actual values to be sorted have this value.
   Vector #(n_t, Reg #(Int #(32))) xs <- replicateM (mkReg (maxBound));

   // Generate n-1 rules (concurrent) to swap xs[i] and xs[i+1] if unordered
   for (Integer i = 0; i < n-1; i = i+1)
      rule rl_swap_i (xs [i] > xs [i+1]);
         xs [i]   <= xs [i+1];
         xs [i+1] <= xs [i];
      endrule

   // Test if array is sorted
   function Bool done ();
      Bool b = (rg_inj == fromInteger (n));
      for (Integer i = 0; i < n-1; i = i+1)
	 b = b && (xs[i] <= xs[i+1]);
      return b;
   endfunction

   // ----------------
   // INTERFACE

   // Inputs: feed input values into xs[jMax]
   method Action put (Int #(32) x) if ((rg_inj < fromInteger(n)) && xs[jMax] == maxBound);
      xs[jMax] <= x;
      rg_inj <= rg_inj + 1;
   endmethod

   // Outputs: drain by shifting them out of x0
   method ActionValue#(Int #(32)) get () if (done);
      writeVReg (xs, shiftInAtN (readVReg (xs), maxBound));
      if (xs[1] == maxBound) rg_inj <= 0;
      return xs[0];
   endmethod
endmodule: mkBubblesort

// ================================================================

endpackage: Bubblesort
