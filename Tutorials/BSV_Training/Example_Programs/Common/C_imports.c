// Copyright (c) 2013-2016 Bluespec, Inc. All Rights Reserved

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <limits.h>
#include <string.h>
#include <ctype.h>

#define __USE_XOPEN
#include <poll.h>

// ================================================================
// Union to convert between between uint64_t and other types

static
union {
    uint64_t   u64;
    int64_t    i64;
    uint32_t   u32;
    int32_t    i32;
    uint16_t   u16;
    int16_t    i16;
    uint8_t    u8;
    int8_t     i8;
    char       ch;
    void      *xp;
} U;

// ================================================================

#define LINESIZE 256

static
uint64_t min_addr = 0xFFFFFFFFFFFFFFFFllu;
static
uint64_t max_addr = 0x0000000000000000llu;

static
uint64_t min_text_addr = 0xFFFFFFFFFFFFFFFFllu;
static
uint64_t max_text_addr = 0x0000000000000000llu;

static
const char objdump_filename[] = "objdump";

// ----------------------------------------------------------------

static
int bad_addr (uint64_t addr, uint64_t n_bytes)
{
    int err = 0;

    if ((addr + 4) > n_bytes) {
	fprintf (stderr,
		 "ERROR: load_objdump: addr+4 %0" PRIx64 " > n_bytes %0" PRIx64 "\n",
		 addr, n_bytes);
	err = 1;
    }
    return err;
}

// ----------------------------------------------------------------

static uint64_t pc_boot_main;

static
void load_objdump (uint64_t n_bytes, void *memp)
{
    FILE *fpi;
    char line [LINESIZE], *p;
    int line_num, n, n_initialized, is_text_start = 0;
    uint64_t  addr_exp = 0, addr;
    uint8_t  *p1 = memp;    // Byte pointer
    uint32_t *p4;           // Word pointer
    uint32_t  instr;

    fpi = fopen (objdump_filename, "r");
    if (fpi == NULL) {
	fprintf (stderr, "ERROR: load_objdump: could not open objdump input file: %s\n",
		 objdump_filename);
	exit (1);
    }

    line_num  = 0;
    n_initialized = 0;
    while (1) {
	p = fgets (line, LINESIZE, fpi);
	if (p == NULL) break;
	line_num++;

	// Address lines, like:
	//     0000000000010000 <_start>:
	p = strstr (line, ">:");
	if (p != NULL) {
	    sscanf (line, "%" SCNx64, & addr);
	    if (addr < addr_exp) {
		fprintf (stderr,
			 "WARNING: load_objdump: expecting addr >= %0" PRIx64 ", but this line has addr %0" PRIx64 "\n",
			 addr_exp, addr);
	    }
	    addr_exp = addr;

	    // printf ("@%0" PRIx64 "    // L%0d: %s", addr_exp, line_num, line);

	    if (bad_addr (addr_exp, n_bytes)) goto err_exit;

	    if (addr_exp < min_addr) min_addr = addr_exp;
	    if (max_addr < addr_exp) max_addr = addr_exp;

	    // Execution should begin at 'boot_main'
	    p = strstr (line, "<boot_main>");
	    if (p != NULL) {
		printf ("INFO: load_objdump: 0x%0" PRIx64 "    L%0d: %s", addr_exp, line_num, line);
		pc_boot_main = addr_exp;
	    }

	    continue;
	}

	// Regular instruction lines, like:
	//     10000:    f7bf0013    add    sp,sp,-64
	n = sscanf (line, "%" SCNx64 ":%x", & addr, & instr);
	if (n == 2) {
	    // printf ("%08x    // L%0d: %s", instr, line_num, line);
	    if (bad_addr (addr, n_bytes)) goto err_exit;

	    if (addr_exp != addr) {
		fprintf (stderr,
			 "ERROR: load_objdump: expecting addr %0" PRIx64 ", but this line has addr %0" PRIx64 "\n",
			 addr_exp, addr);
		goto err_exit;
	    }

	    if (addr < min_addr) min_addr = addr;
	    if (max_addr < addr) max_addr = addr;
	    if (is_text_start) {
		min_text_addr = addr;
		printf ("INFO: load_objdump: Section .text starts at 0x%0" PRIx64 "\n", addr);
		is_text_start = 0;
	    }

	    p4 = (uint32_t *) (p1 + addr);
	    *p4 = instr;
	    n_initialized++;

	    addr_exp += 4;
	    continue;
	}

	// Detect start of text section
	p = strstr (line, "section .text:");
	if (p != NULL) {
	    is_text_start = 1;
	    continue;
	}

	// Detect end of text section (start of .rodata)
	p = strstr (line, "section .rodata:");
	if (p != NULL) {
	    printf ("INFO: load_objdump: Section .rodata starts at 0x%0" PRIx64 "\n", addr_exp);
	    printf ("      Setting .text end to 0x%0" PRIx64 "\n", addr_exp - 4);
	    max_text_addr = addr_exp - 4;
	    continue;
	}

	// Detect start of other necessary sections: .data, .bss
	p = strstr (line, "section .data:");
	if (p != NULL) {
	    printf ("INFO: load_objdump: Section .data found at 0x%0" PRIx64 "\n", addr_exp);
	    continue;
	}

	p = strstr (line, "section .bss:");
	if (p != NULL) {
	    printf ("INFO: load_objdump: Section .bss found at 0x%0" PRIx64 "\n", addr_exp);
	    continue;
	}

	// Quit at any other section
	p = strstr (line, "section");
	if (p != NULL) {
	    printf ("INFO: load_objdump: Quitting at: %s", line);
	    break;
	}

	// Ignore all other lines
	// printf ("// L%0d: %s", line_num, line);
    }

    printf ("INFO: load_objdump: %0d lines, %0d locations initialized\n", line_num, n_initialized);
    printf ("INFO: load_objdump: Min addr: 0x%0" PRIx64 "\n", min_addr);
    printf ("INFO: load_objdump: Max addr: 0x%0" PRIx64 "\n", max_addr);
    fclose (fpi);
    return;

  err_exit:
    fprintf (stderr, "    in line %0d: %s", line_num, line);
    exit (1);
}

// ================================================================

uint64_t  c_malloc_and_init (uint64_t n_bytes, uint64_t init_from_file)
{
    FILE      *fp;
    uint32_t  *p32, j, u32;
    void      *p;
    int        n;

    fprintf (stdout, "INFO: c_malloc_and_init (n_bytes %0" PRId64 " (0x%0" PRIx64 "), init_from_file %0" PRId64 ")\n",
	     n_bytes, n_bytes, init_from_file);

    p = malloc (n_bytes);
    if (p == NULL) {
	fprintf (stderr, "ERROR: c_malloc_and_init: could not malloc %0" PRId64 " bytes\n", n_bytes);
	exit (1);
    }

    // ----------------
    // Initialize memory from file


    if (init_from_file) {
	load_objdump (n_bytes, p);
    }

    // ----------------
    U.u64 = 0;
    U.xp = p;
    // printf ("c_malloc_and_init: p = %p, return 0x%0lx\n", p, U.u64);
    return U.u64;
}

// ================================================================

uint64_t c_get_start_pc (void)
{
    return pc_boot_main;
}

// ================================================================

uint64_t c_get_min_addr (void)
{
    return min_addr;
}

// ================================================================

uint64_t c_get_max_addr (void)
{
    return max_addr;
}

// ================================================================

uint64_t c_get_min_text_addr (void)
{
    return min_text_addr;
}

// ================================================================

uint64_t c_get_max_text_addr (void)
{
    return max_text_addr;
}

// ================================================================

uint64_t  c_read (uint64_t addr, uint64_t n_bytes)
{
    uint8_t  *p1;
    uint16_t *p2;
    uint32_t *p4;
    uint64_t *p8, result = 0;

    U.u64 = addr;
    switch (n_bytes) {
      case 1: p1 = U.xp; result = *p1; break;
      case 2: p2 = U.xp; result = *p2; break;
      case 4: p4 = U.xp; result = *p4; break;
      case 8: p8 = U.xp; result = *p8; break;
      default: fprintf (stderr,
			"ERROR: c_read: n_bytes %0" PRId64 " should be 1, 2, 4 or 8\n",
			n_bytes);
    }
    // printf ("c_read (%0" PRIx64 ", %0" PRIx64 ") => %0" PRIx64 "\n", addr, n_bytes, result);
    return result;
}

// ================================================================

void c_write (uint64_t addr, uint64_t x, uint64_t n_bytes)
{
    uint8_t  *p1;
    uint16_t *p2;
    uint32_t *p4;
    uint64_t *p8;

    U.u64 = addr;
    switch (n_bytes) {
      case 1: p1 = U.xp; *p1 = x; break;
      case 2: p2 = U.xp; *p2 = x; break;
      case 4: p4 = U.xp; *p4 = x; break;
      case 8: p8 = U.xp; *p8 = x; break;
      default: fprintf (stderr,
			"ERROR: c_write: n_bytes %0" PRId64 " should be 1, 2, 4 or 8\n",
			n_bytes);
    }
}

// ================================================================
// TODO: this is a parser for commands from the console
// It's not a very robust parser (assumes no leading whitespace, etc.)
// Can be improved in the future

uint64_t cmd_bogus      = 0xfFFFfFFFfFFFfFFFllu;

uint64_t cmd_continue   = 0;
uint64_t cmd_dump       = 1;
uint64_t cmd_quit       = 2;
uint64_t cmd_reset      = 3;
uint64_t cmd_step       = 4;
uint64_t cmd_step_until = 5;
uint64_t cmd_verbosity  = 6;    // arg: verbosity level
uint64_t cmd_dump_mem   = 7;

static
void print_console_menu (void)
{
    printf ("Commands:\n");
    printf ("    h, H, ?           Print this help menu\n");
    printf ("    c                 continue\n");
    printf ("    d                 dump architectural state\n");
    printf ("    q                 quit\n");
    printf ("    r                 reset\n");
    printf ("    s                 step\n");
    printf ("    S  n              step until n retired\n");
    printf ("    v  n              set verbosity to n\n");
    printf ("    m  addr1 addr2    Display memory range as 32b words\n");
    printf ("\n");
    printf ("    Args can be written as decimal integers, or in hex if preceded with '0x'\n");
}			 

void c_get_console_command (uint64_t *cmd_vec)
{
    char line [256], *p;
    int status, arg1, arg2;

    cmd_vec [0] = 1;
    cmd_vec [1] = cmd_bogus;

    while (cmd_vec [1] == cmd_bogus) {
	printf ("Command? [type 'h' for help]: ");
	fflush (stdout);

	p = fgets (line, 256, stdin);
	if (p == NULL)
	    line [0] = 'q';    // EOF => quit

	switch (line [0]) {
	case '?':
	case 'h':
	case 'H': print_console_menu (); break;

	case 'c': cmd_vec [1] = cmd_continue; break;

	case 'd': cmd_vec [1] = cmd_dump; break;

	case 'q': cmd_vec [1] = cmd_quit; break;

	case 'r': cmd_vec [1] = cmd_reset; break;

	case '\n':
	case 's': cmd_vec [1] = cmd_step; break;

	case 'S':
	  status = sscanf (& (line [1]), "%i", & arg1);
	  if (status == 1) {
	      cmd_vec [0] = 2;
	      cmd_vec [1] = cmd_step_until;
	      cmd_vec [2] = ( (arg1 == 0) ? UINT64_MAX : arg1 );
	  }
	  break;

	case 'v':
	  status = sscanf (& (line [1]), "%i", & arg1);
	  if (status == 1) {
	      cmd_vec [0] = 2;
	      cmd_vec [1] = cmd_verbosity;
	      cmd_vec [2] = arg1;
	  }
	  break;

	case 'm':
	  status = sscanf (& (line [1]), "%x %x", & arg1, & arg2);
	  if (status == 2) {
	      cmd_vec [0] = 3;
	      cmd_vec [1] = cmd_dump_mem;
	      cmd_vec [2] = arg1;
	      cmd_vec [3] = arg2;
	  }
	  break;

	default:
	    fprintf (stderr, "ERROR: unrecognized command");
	}
    }
}

// ================================================================
