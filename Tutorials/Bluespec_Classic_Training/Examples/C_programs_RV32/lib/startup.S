	.text
	.globl	_reset

_reset:
	li	sp, 0x800f0000
	// Place an illegal instruction (0) at the stack pointer
	// so that the program ends if the value is used
#if __riscv_xlen == 64
	sd	zero, 0(sp)
	sd	zero, -8(sp)
#else
	sw	zero, 0(sp)
	sw	zero, -4(sp)
#endif
	// Set MSTATUS
	// Enable MIE and SIE
	// Set FS to 2 = Dirty
	li      s0, 0x600a
	csrw    mstatus, s0
	// Set MTVEC to an address (also to 0x800f0000?)
	// and place an illegal instruction (0) at that location
	// so that the program ends if there is a trap
	li	s0, 0x800f0000
#if __riscv_xlen == 64
	sd	zero, 0xC0(s0)
#else
	sw	zero, 0xC0(s0)
#endif
	csrw	mtvec, s0
#ifdef __riscv_float_abi_double
	// Set MSTATUS
	// Set FS to 1 = Initial
	li	s0, 0x2000
	csrs	mstatus, s0
#endif

	/* zero out the bss */
	/*
	.option push
	.option norelax
        la      t1, __bss_start
        la      t2, __global_pointer$
#if __riscv_xlen == 64
zinit:  sd      zero, 0(t1)
        add     t1, t1, 0x8
        bne     t1, t2, zinit
#else
zinit:  sw      zero, 0(t1)
        add     t1, t1, 0x4
        bne     t1, t2, zinit
#endif
	.option pop
	*/

	// TODO: Use xRET to switch to S or U mode?
	// TODO: (Previous version for v1.7 priv spec set PRV to S
	// TODO: when setting the MSTATUS above.)
	j _start
