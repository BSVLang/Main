// Copyright (c) 2019 Bluespec, Inc. All Rights Reserved

// Ad hoc program to generate a 32-bit-wide mem hex file

#include  <stdio.h>
#include  <stdlib.h>
#include  <stdint.h>
#include  <string.h>

int main (int argc, char *argv [])
{
    if ((argc != 2)
	|| (strcmp (argv [1], "-h") == 0)
	|| (strcmp (argv [1], "--help") == 0)) {
	fprintf (stdout, "Usage:    %s  <int address limit>\n", argv [0]);
	fprintf (stdout, "    Writes a 32b Mem.hex file\n");
	return 1;
    }

    uint32_t lim = atol (argv [1]);

    FILE *fd = fopen ("Mem.hex", "w");
    if (fd == NULL) {
	fprintf (stdout, "ERROR: could not open Mem.hex for output\n");
	return 1;
    }

    // Decreasing contents (so sorting in ascending order has to do some work)
    for (uint32_t addr = 0; addr < lim; addr += 4) {
        fprintf (fd, "%08x\n", lim - addr - 4);
    }
    fclose (fd);
    return 0;
}
