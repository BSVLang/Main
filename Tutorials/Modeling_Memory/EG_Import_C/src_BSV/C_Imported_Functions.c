// These C functions are imported into BSV

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>

// ================================================================

const char input_file [] =  "../Macbeth.txt";

// ================================================================

uint64_t c_init (const uint32_t  mem_size)
{
    // Open the input file (initial memory contents)
    FILE *fi = fopen (input_file, "r");
    if (fi == NULL) {
	fprintf (stderr, "ERROR: c_init(): unable to open input file '%s'\n", input_file);
	exit (1);
    }

    // Malloc the memory array
    uint8_t *ptr = (uint8_t *) malloc (mem_size);
    if (ptr == NULL) {
	fprintf (stderr, "ERROR: c_init(): unable to malloc mem array of size '%d' bytes\n", mem_size);
	exit (1);
    }

    // Initialize the memory to the default value
    memset (ptr, 0xFF, mem_size);

    // Load the memory array from the initial-memory-contents file
    uint32_t addr = 0;
    while (true) {
	int ch = fgetc (fi);
	if (ch == EOF) break;

	ptr [addr] = ch;
	addr++;
    }
    fprintf (stdout, "c_init(): initialized memory of size %0d bytes; %0d bytes pre-loaded from text file '%s'\n",
	     mem_size, addr, input_file);

    return (uint64_t) ptr;
}

// ================================================================

uint8_t c_read_byte (const uint8_t *ptr,  const uint32_t  address)
{
    return ptr [address];
}

// ================================================================
