// Copyright (c) 2013 Bluespec, Inc.  All Rights Reserved

#pragma once

// ----------------------------------------------------------------
// The following are interfaces to inline RISC-V assembly instructions
//     RDCYCLE, RDTIME, RDINSTRET
// For all of them, the result is left in v0 (= x16) per calling convention

extern uint64_t  read_cycle    (void);    // RDCYCLE
extern uint64_t  read_time     (void);    // RDTIME
extern uint64_t  read_instret  (void);    // RDINSTRET

// ----------------------------------------------------------------
// Pass/Fail macros. This is a temporary place-holder. To be moved to an
// appropriate location under the env directory structure once we can converge
// on a unified build environment for all tests
#define TEST_PASS asm volatile ("li x28, 0x1");
#define TEST_FAIL asm volatile ("li x28, 0x3");
