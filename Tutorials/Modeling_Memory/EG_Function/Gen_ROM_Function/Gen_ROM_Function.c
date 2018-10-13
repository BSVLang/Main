// Copyright (c) 2018 Bluespec, Inc.  All Rights Reserved

// Program to generate BSV ROM function containing first N chars of input text file.

#include <stdio.h>
#include <stdlib.h>

#define MEM_SIZE  64

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
    fprintf (stdout, "containing BSV ROM function with %d locations, byte-wide\n", MEM_SIZE);
    fprintf (stdout, "populated with ASCII codes of prefix of input file\n");

    fprintf (fo, "// ***** DO NOT EDIT *****\n");
    fprintf (fo, "// ***** This file was generated from a script *****\n");
    fprintf (fo, "\n");
    fprintf (fo, "\n");
    fprintf (fo, "// This file is a BSV 'include' file\n");
    fprintf (fo, "// The function below represents byte-addressed ROM of 64 bytes\n");
    fprintf (fo, "\n");
    fprintf (fo, "\n");
    fprintf (fo, "function Bit #(8) fn_read_ROM (Bit #(32) addr);\n");
    fprintf (fo, "   return\n");
    fprintf (fo, "      case (addr)\n");

    int ch;
    for (int addr = 0; addr < 64; addr++) {
	if (feof (fi))
	    ch = 0;
	else
	    ch = fgetc (fi);
	fprintf (fo, "         32'h_%0x : 8'h_%0x;\n", addr, ch);
    }

    fprintf (fo, "         default: 8'hFF;\n");    // Default value 0xFF
    fprintf (fo, "      endcase;\n");
    fprintf (fo, "endfunction: fn_read_ROM\n");
}
