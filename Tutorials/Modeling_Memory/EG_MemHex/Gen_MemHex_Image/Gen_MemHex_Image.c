// Copyright (c) 2018 Bluespec, Inc.  All Rights Reserved

// Program to generate Mem Hex file for loading a BSV/Verilog memory/regfile,
// containing first N chars of input text file.

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main (int argc, char *argv [])
{
    if (argc != 3) {
	fprintf (stderr, "Usage:    %s  <input text file>  <output BSV file for ROM function>\n", argv [0]);
	exit (1);
    }

    FILE *fi = fopen (argv [1], "r");
    if (fi == NULL) {
	fprintf (stderr, "ERROR: unable to open input file '%s'\n", argv [1]);
	exit (1);
    }

    FILE *fo = fopen (argv [2], "w");
    if (fi == NULL) {
	fprintf (stderr, "ERROR: unable to open output file '%s'\n", argv [2]);
	exit (1);
    }

    fprintf (stdout, "Reading input file: '%s'\n", argv [1]);
    fprintf (stdout, "Writing output file: '%s'\n", argv [2]);
    fprintf (stdout, "containing byte-wide Mem Hex values\n");
    fprintf (stdout, "representing ASCII codes of input file\n");

    int n = 0;
    int ch;
    while (true) {
	ch = fgetc (fi);

	if (ch == EOF) break;

	fprintf (fo, "%0x\n", ch);
	n++;
    }
    // Write a final '0xFF' sentinel value
    fprintf (fo, "FF\n");
    n++;

    fprintf (stdout, "Wrote Mem Hex file with %0d bytes\n", n);
}
