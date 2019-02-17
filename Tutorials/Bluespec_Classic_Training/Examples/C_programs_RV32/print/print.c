//--------------------------------------------------------------------------
// Original: from MIT, for SMIPS tests
// This version: modified at Bluespec, for RISC-V tests

// ----------------------------------------------------------------

#include <stdio.h>
#include <stdint.h>
#include "riscv_counters.h"

// ----------------------------------------------------------------

void print()
{
    int i;
    char *c = "Hello world!\n\n";
    char d[15];

    printf("1: %c\n", 'c');
    printf("2: %s\n", c);

    for(i = 0; i < 15; i++)
	d[i] = c[i];

    printf("3: %c\n", 'd');
    printf("4: %s\n", d);
    printf("5: %0d\n", 25);
    printf("6: Done\n");
    printf("7: 1234\n\n");
}

int main()
{
    print();
    TEST_PASS
    return 0;
}
