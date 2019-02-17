// Copyright (c) 2013 Bluespec, Inc.  All Rights Reserved

// Library for testing the C_tests with ordinary CC

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

#include "tmp_lib.h"

// ----------------------------------------------------------------

void printChar (char c)
{
    putchar (c);
}

// ----------------------------------------------------------------

void printStr (char* x)
{
    printf ("%s", x);
}

// ----------------------------------------------------------------

void printInt  (int64_t x)
{
    printf ("%0" PRId64, x);
}


// ----------------------------------------------------------------

uint64_t read_cycle (void)
{

    return 0;
}


// ----------------------------------------------------------------

uint64_t read_instret (void)
{
    return 0;
}


// ----------------------------------------------------------------
