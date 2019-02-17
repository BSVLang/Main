// Copyright (c) 2013 Bluespec, Inc.  All Rights Reserved

#include <stdio.h>
#include <stdint.h>

// ----------------------------------------------------------------
// The following are interfaces to inline RISC-V assembly instructions
//     RDCYCLE, RDTIME, RDINSTRET
// For all of them, the result is left in v0 (= x2) per calling convention

uint64_t  read_cycle (void)
{
    uint64_t result;

    asm volatile ("RDCYCLE %0" : "=r" (result));
    return result;
}

uint64_t  read_time (void)
{
    uint64_t result;

    asm volatile ("RDTIME %0" : "=r" (result));
    return result;
}

uint64_t  read_instret (void)
{
    uint64_t result;

    asm volatile ("RDINSTRET %0" : "=r" (result));
    return result;
}

// ----------------------------------------------------------------
