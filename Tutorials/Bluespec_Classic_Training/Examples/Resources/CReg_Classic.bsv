// Copyright (c) 2019 Bluespec, Inc. All Rights Reserved.

// ================================================================
// This is a BSV package that is just a simple wrapper for CReg that
// can be imported into a Bluespec Classic package because BSV's '[]'
// syntax for indexing into CReg's array of Reg interfaces is not
// available in Bluespec Classic.

// ================================================================

package CReg_Classic;

function Reg #(t) select_CReg (Array #(Reg #(t)) creg, Integer j) = creg [j];
function t        read_CReg   (Array #(Reg #(t)) creg, Integer j) = creg [j];

endpackage
