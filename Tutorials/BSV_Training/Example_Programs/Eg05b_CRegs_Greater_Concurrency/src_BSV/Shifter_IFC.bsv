// Copyright (c) 2013-2016 Bluespec, Inc., All Rights Reserved

package Shifter_IFC;

// Common interface for a shifter module (with various implementations)

// ----------------------------------------------------------------
// From the BSV library

import GetPut       :: *;
import ClientServer :: *;

// ----------------------------------------------------------------
// Interface definition

typedef Server #(Tuple2 #(Bit #(8), Bit #(3)),
		 Bit #(8))
        Shifter_IFC;

// The above uses the standard 'Server' interface,
// which is defined in BSV's ClientServer library as follows,
// and fixing t1 as Tuple2 #(Bit #(8), Bit #(3))
// and        t2 as Bit #(8)
//
// interface Server #(t1, t2);
//    interface Put #(t1) request;
//    interface Get #(t2) response;
// endinterface
//
// 'Server', in turn, uses the standard 'Put' and 'Get' interfaces,
// which are defined in BSV's GetPut library as follows:
//
// interface Put #(t1);
//    method Action put (t1 x);
// endinterface
//
// interface Get #(t2);
//    method ActionValue #(t2) get ();
// endinterface

// ----------------------------------------------------------------

endpackage: Shifter_IFC
