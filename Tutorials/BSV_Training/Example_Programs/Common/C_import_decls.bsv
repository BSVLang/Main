package C_import_decls;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

// import BDPI declarations for C functions used in BSV modeling of memory

// ================================================================
		 
import Vector       :: *;

// ================================================================

import "BDPI" function ActionValue #(Bit #(64)) c_malloc_and_init (Bit #(64) n_bytes,
								   Bit #(64) init_from_file);

import "BDPI" function ActionValue #(Bit #(64)) c_read  (Bit #(64) addr, Bit #(64) n_bytes);

import "BDPI" function ActionValue #(Bit #(64)) c_get_start_pc ();

import "BDPI" function Action c_write (Bit #(64) addr, Bit #(64) x, Bit #(64) n_bytes);

import "BDPI" function ActionValue #(Vector #(10, Bit #(64))) c_get_console_command ();

// ================================================================

endpackage: C_import_decls
