================================================================
The topic-based lecture slide decks in this "Reference/" directory are
intended as a reference, and need not be read sequentially.

However, people learning BSV on their own for the first time may wish
to read them in the following order:

  Lec01_Intro
    General intro to the Bluespec approach, and some comparisons to
    other Hardware Design Languages and High Level Synthesis.

  Lec02_Basic_Syntax
    Gets you familiar with the "look and feel" of BSV code.

  Lec03_Rule_Semantics
  Lec04_CRegs
    These two lectures describe BSV's concurrency semantics (based on
    rules and methods).  This is the KEY feature distinguishing BSV
    from other hardware ands of software languages.

  Lec05_Interfaces_TLM
  Lec06_StmtFSM
    These two lectures describe slightly advanced constructs: more
    abstract interfaces, and more abstract rule-based processes.

  Lec07_Types
  Lec08_Typeclasses
    These two lectures describe BSV's type system, which is
    essentially identical to that of the Haskell functional
    programming language.

  Lec09_BSV_to_Verilog
    Desribes how BSV is translated into Verilog by the bsc tool.  Read
    this only if you are curious about this, or if you need to
    interface to other existing RTL modules.

  Lec10_Interop_RTL
    How to import Verilog/VHDL code into BSV, and how to connect BSV
    into existing Verilog/VHDL

  Lec11_Interop_C
    How to import C code into BSV (for simulation only). How to export
    a BSV subsystem as a SystemC module (for use in a SystemC program).

  Lec12_Multiple_Clock_Domains
    How to create BSV designs that use multiple clocks or resets.

  Lec13_RWires
    Some facilities typically used in interfacing to external RTL.
    These are similar in spirit to CRegs, but lower level.

================================================================
