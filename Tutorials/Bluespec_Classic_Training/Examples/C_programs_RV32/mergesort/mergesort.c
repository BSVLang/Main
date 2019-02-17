#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include "riscv_counters.h"

#define min(x,y)  (((x) < (y)) ? (x) : (y))

// ================================================================
// merge_engine()
// Merge p1[i0 .. i0+span-1] and p1[i0+span .. i0+2*span-1]
// into  p2[i0 .. i0+2*span]

void merge_engine (int *p1, int *p2, int i0, int span, int n)
{
    int i1 = i0 + span;
    int i0_lim = min (i1, n);
    int i1_lim = min (i1 + span, n);
    int j = i0;
    while (true) {
	if ((i0 < i0_lim) && (i1 < i1_lim))
	    if (p1 [i0] < p1 [i1])
		p2 [j++] = p1 [i0++];
	    else
		p2 [j++] = p1 [i1++];
	else if (i0 < i0_lim)
	    p2 [j++] = p1 [i0++];
	else if (i1 < i1_lim)
	    p2 [j++] = p1 [i1++];
	else
	    break;
    }
}

// ================================================================
// mergesort()
// Repeatedly merge longer and longer spans (length 1, 2, 4, 8, ...)
// back and forth between pA and pB until span length > n.
// If final array is in pB, copy it back to pA.

void mergesort (int *pA, int *pB, int n)
{
    int span = 1;
    int *p1 = pA;
    int *p2 = pB;

    while (span < n) {
	for (int i0 = 0; i0 < n; i0 += 2 * span) {
	    merge_engine (p1, p2, i0, span, n);
	}
	int *tmp = p1;
	p1 = p2;
	p2 = tmp;
	span = span * 2;
    }
    // If final result is in pB; copy it back to pA
    if (p1 == pB)
	merge_engine (p1, p2, 0, n, n);
}

// ================================================================
// Since the accelerator IP block reads/writes directly to memory we
// use 'fence' to ensure that caches are empty, i.e., memory contains
// definitive data and caches will be reloaded.

static void fence (void)
{
    asm volatile ("fence");
}

// ================================================================

uint32_t *accel_0_addr_base = (uint32_t *) 0xC0000100l;

void mergesort_accelerated (int *pA, int *pB, int n)
{
    fence ();

    // Write configs into accelerator
    accel_0_addr_base [1] = (uint32_t)  pA;
    accel_0_addr_base [2] = (uint32_t)  pB;
    accel_0_addr_base [3] = (uint32_t)  n;
    // "Go!"
    accel_0_addr_base [0] = (uint32_t)  1;

    // Wait for completion
    while (true) {
	uint32_t status = accel_0_addr_base [0];
	if (status == 0) break;
    }

    fence ();
}

// ================================================================

void dump_array (int *p, int n, char *title)
{
    fprintf (stdout, "%s\n", title);
    for (int j = 0; j < n; j++)
	fprintf (stdout, "%0d: %0d\n", j, p [j]);
}

void run (bool accelerated, int *pA, int *pB, int n)
{
    // Load array in descending order, to be sorted
    for (int j = 0; j < n; j++)
	pA [j] = n - 1 - j;

    if (n < 32)
	dump_array (pA, n, "Unsorted array");


    uint32_t c0 = read_cycle();

    if (! accelerated)
	mergesort (pA, pB, n);
    else
	mergesort_accelerated (pA, pB, n);

    uint32_t c1 = read_cycle();

    if (n < 32)
	dump_array (pA, n, "Sorted array");

    // Verify that it's sorted
    bool sorted = true;
    for (int j = 0; j < (n-1); j++)
	if (pA [j] > pA [j+1]) {
	    fprintf (stdout, "ERROR: elements not in sorted order\n", j, j+1);
	    fprintf (stdout, "    A [%0d] = %0d", j,   pA [j]);
	    fprintf (stdout, "    A [%0d] = %0d", j+1, pA [j+1]);
	    sorted = false;
	}
    if (sorted)
	fprintf (stdout, "Verified %0d words sorted\n", n);

    fprintf (stdout, " Sorting took %8d cycles\n", c1 - c0);
}

// ================================================================

int A [4096], B [4096];
// int n = 29;
int n = 3000;

int main (int argc, char *argv[])
{
    bool accelerated = true;

    fprintf (stdout, "Running C function for mergesort\n");
    run (! accelerated, A, B, n);
    fprintf (stdout, "Done\n");

    fprintf (stdout, "Running hardware-accelerated mergesort\n");
    run (accelerated, A, B, n);
    fprintf (stdout, "Done\n");
}
