package Req_Rsp;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

// This package defines Requests and Responses between Initiators
// and Targets on the interconnect fabric

// ================================================================
// Requests

// Request ops: Write/Read

typedef enum { READ, WRITE, UNKNOWN } TLMCommand
   deriving (Bits, Eq);

// Request sizes

typedef enum { BITS8, BITS16, BITS32, BITS64, BITS128, BITS256, BITS512, BITS1024} TLMBSize
   deriving (Bits, Eq);

function Bit #(8) reqSz_bytes (TLMBSize sz);
   return (1 << pack (sz));
endfunction

typedef struct {
   TLMCommand      command;
   Bit #(addr_sz)  addr;
   Bit #(data_sz)  data;    // Only for write requests
   TLMBSize        b_size;
   Bit #(tid_sz)   tid;
} Req #(type tid_sz, type addr_sz, type data_sz)
  deriving (Bits);

// ----------------
// Help functions to display requests
// [NOTE: these will be removed in 2013 because bsc will support 'deriving (FShow)']

function Action display_TLMCommand (TLMCommand cmd);
   case (cmd)
      READ:    $write ("READ");
      WRITE:   $write ("WRITE");
      UNKNOWN: $write ("UNKNOWN");
   endcase
endfunction

function Action display_TLMBSize (TLMBSize sz);
   case (sz)
      BITS8    : $write ("8b");
      BITS16   : $write ("16b");
      BITS32   : $write ("32b");
      BITS64   : $write ("64b");
      BITS128  : $write ("128b");
      BITS256  : $write ("256b");
      BITS512  : $write ("512b");
      BITS1024 : $write ("1024b");
   endcase
endfunction

function Action display_Req (Req #(idsz, asz, dsz) req);
   action
      $write ("Req{");
      display_TLMCommand (req.command);
      $write (" %h %h ", req.addr, req.data);
      display_TLMBSize (req.b_size);
      $write (" %h}", req.tid);
   endaction
endfunction

// ================================================================
// Responses

typedef enum {OKAY, EXOKAY, SLVERR, DECERR} TLMStatus
   deriving (Eq, Bits);

typedef struct {
   TLMCommand      command;
   Bit #(data_sz)  data;
   TLMStatus       status;
   Bit #(tid_sz)   tid;
} Rsp #(type tid_sz, type data_sz)
  deriving (Bits);

// ----------------
// Help functions to display requests
// [NOTE: these will be removed in 2013 because bsc will support 'deriving (FShow)']

function Action display_TLMStatus (TLMStatus status);
   case (status)
      OKAY   : $write ("OKAY");
      EXOKAY : $write ("EXOKAY");
      SLVERR : $write ("SLVERR");
      DECERR : $write ("DECERR");
   endcase
endfunction

function Action display_Rsp (Rsp #(idsz, asz) rsp);
   action
      $write ("Rsp{");
      display_TLMCommand (rsp.command);
      $write (" %h ", rsp.data);
      display_TLMStatus (rsp.status);
      $write (" %h}", rsp.tid);
   endaction
endfunction

// ================================================================

endpackage: Req_Rsp
