package Sys_Configs;

// ================================================================
// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

// This package defines the SoC configuration, such as # of initiators
// and targets, their address ranges, etc.

// ================================================================
// Project imports

import Req_Rsp :: *;

// ================================================================
// Addresses, Data for this SoC

typedef 64  ASZ;
typedef 64  DSZ;

typedef Bit #(ASZ)  Addr;
typedef Bit #(DSZ)  Data;

// ================================================================
// # of initiators, # of targets, transaction ids

// Transaction Ids for targets have log(N) more bits than transaction
// ids for initiators, where N is the number of initiators, because
// the fabric must tack on log(N) bits to remember which initiator
// must get the corresponding response.

typedef  1  N_Mem_Ports;

// Transaction ids at initiators
typedef  1  TID_SZ_I;

// Transaction ids at targets
typedef  1  TID_SZ_T;

typedef Bit #(TID_SZ_I)  TID_I;
typedef Bit #(TID_SZ_T)  TID_T;

// ================================================================
// Initiator numbers, initiator request and response types

typedef Req #(TID_SZ_I, ASZ, DSZ) Req_I;
typedef Rsp #(TID_SZ_I, DSZ)      Rsp_I;

// ================================================================
// Target numbers and addresses, target requests and response types

// Memory
Addr mem_base_addr = 0;
Addr mem_size      = 'h10_0000;
Addr mem_max_addr  = mem_base_addr + mem_size - 1;

// Accelerator
Addr accel_base_addr = 'h80_0000;
typedef 4 N_Accel_Config_Regs;    // # of config registers
Addr accel_size      = fromInteger (valueOf (N_Accel_Config_Regs) * 8);    // 8 bytes per config reg
Addr accel_max_addr  = accel_base_addr + accel_size - 1;

// Request and Response types at targets
typedef Req #(TID_SZ_T, ASZ, DSZ) Req_T;
typedef Rsp #(TID_SZ_T, DSZ)      Rsp_T;

// ================================================================

endpackage: Sys_Configs
