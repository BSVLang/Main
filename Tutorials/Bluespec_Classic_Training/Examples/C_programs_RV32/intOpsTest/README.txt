The program in this directory performs a large number of integer ALU
ops to test correct implementation of the ALU ops.


'make test_data'

  This can be done on any machine (i.e., does not have to be a RISC-V machine).
  Uses genTests_c (which is actually a C program) to create a file 'test_data.h'
      which contains a number of 32-bit tests and 64-bit tests.
  Each test also contains the expected result.

  Test data is generated for all combinations of the following. The
  objective is to get corner cases near the minimum and maximum signed
  and unsigned 32b and 64b values:
    - 32b and 64b
    - All opcodes in opcodes.h
    - MSB = 0 and MSB = 1 (pos/neg for signed ops)
    - Remaining 31 bits for 32b tests
        - 31'b0_all_zeros_0
        - 31'b0_all_zeros_1
        - 31'b0_all_ones__1
        - 31'b1_all_zeros_0
        - 31'b1_all_zeros_1
        - 31'b1_all_ones__0
        - 31'b1_all_ones__1
      (and similarly 63'b... for the 64b tests)

The file 'test_data.h' is #include'd by 'intOpsTest.c' which is the
  program run on a RISC-V machine to test if it implements ALU ops
  correctly.

'make'
  Will compile intOpsTest.c for RISC-V using riscv-gcc
  creating the ELF executable 'intOpsTest'

Run the executable ELF file 'intOpsTest' on a RISC-V machine.
It will perform all the tests, quitting as soon as it finds a failure,
    indicating which test failed.

Note: you can of course compile and run intOpsTest.c on any other
    (non-RISC-V) machine just to see what it does, before compiling
    and running it on a RISC-v machine.

Caveat: Although opcodes.h represents the RISC-V ISA ALU ops, there is
    no guarantee that the C compile will actually compile them to
    those opcodes.  Thus, we are only testing whatever opcodes the C
    compiler creates for these C operations.
