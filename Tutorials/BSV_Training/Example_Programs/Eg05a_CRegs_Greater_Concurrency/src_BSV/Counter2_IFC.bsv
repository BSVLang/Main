// Copyright (c) 2014-2016 Bluespec, Inc., All Rights Reserved

package Counter2_IFC;

// ----------------------------------------------------------------

interface Counter2_IFC;
   method ActionValue #(Int #(32)) count1 (Int #(32) delta);
   method ActionValue #(Int #(32)) count2 (Int #(32) delta);
endinterface

// ----------------------------------------------------------------

endpackage
