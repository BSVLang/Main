// Copyright (c) 2014 Bluespec, Inc. All Rights Reserved

// Performs all the tests in 'test_data.h'
// Each test is some combination of:
//     int ALU op, 32b v 64b, signed vs unsigned

#include <stdio.h>
#include <stdint.h>
//--------------------------------------------------------------------------
// BRF definitions
#include "riscv_counters.h"
//--------------------------------------------------------------------------

#include "opcodes.h"
#include "test_data.h"

int main (int argc, char *argv[])
{
    uint32_t verify_32_ok = 0;
    uint32_t verify_64_ok = 0;
    uint32_t j, op, shamt, noop;
    uint32_t u32a, u32b, result32, exp32;
    uint64_t u64a, u64b, result64, exp64;

    for (j = 0; j < N; j++) {
	op    = test_data32 [j][0];
	u32a  = test_data32 [j][1];
	u32b  = test_data32 [j][2];
	exp32 = test_data32 [j][3];
	shamt = u32b;
	noop = False;

	compute32 (op, shamt, u32a, u32b, & noop, & result32);

	if ((! noop) && (result32 != exp32)) {
	    printf ("ERROR: test_data32 [%0d]: %s, 0x%016llx, 0x%016llx\n",
		    j, opcode_names [op], u32a, u32b);
	    printf ("Actual result32:   0x%016llx\n", result32);
	    printf ("Expected result32: 0x%016llx\n", exp32);
	    break;
	}
    }
    if (j == N) {
	printf ("Verify: all %0d 32-bit tests ok\n", N);
        verify_32_ok = 1;
    }

    for (j = 0; j < N; j++) {
	op    = test_data64 [j][0];
	u64a  = test_data64 [j][1];
	u64b  = test_data64 [j][2];
	exp64 = test_data64 [j][3];
	shamt = u64b;
	noop = False;

	compute64 (op, shamt, u64a, u64b, & noop, & result64);

	if ((! noop) && (result64 != exp64)) {
	    printf ("ERROR: test_data64 [%0d]: %s, 0x%016llx, 0x%016llx\n",
		    j, opcode_names [op], u64a, u64b);
	    printf ("Actual result64:   0x%016llx\n", result64);
	    printf ("Expected result64: 0x%016llx\n", exp64);
	    break;
	}
    }
    if (j == N) {
	printf ("Verify: all %0d 64-bit tests ok\n", N);
        verify_64_ok = 1;
    }

    if ((verify_32_ok == 1) && (verify_64_ok == 1)) {
        TEST_PASS
    } else {
	TEST_FAIL
    }
}
