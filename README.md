# Main

This is a repository for open source Bluespec BSV and Bluespec Classic.

Bluespec BSV and Bluespec Classic are one High Level Hardware Design
Language (HL-HDL) with two optional syntaxes.

- BSV is SystemVerilog-ish in syntactic style.

- Classic is Haskell-ish in syntactic style.

The language was developed at Bluespec, Inc. (www.bluespec.com) and
previously at Sandburst Corp., with roots in research at MIT in the
1990s.  It draws its primary inspirations from:

- Term Rewriting Systems (to express complex concurrent behavior), and

- Haskell (to express complex, strongly-typed structure).

The language specification (included here) is open, i.e., people are
free to create their own implementations (simulators, synthesis tools,
etc.).

On Feb 26, 2010, at a "SystemVerilog Requirements
Gathering Meeting" conducted by the IEEE P1800 SystemVerilog Standards
Committee in San Jose, Bluespec, Inc. offered to donate the entire BSV
Language for incorporation into the next revision of the SystemVerilog
standard, but the offer did not meet the priority threshold of the
members present. [See Bluespec's offer
[here](Historical/Bluespec_Offer_to_Donate_BSV_to_IEEE_P1800_SystemVerilog.pdf).]

The <tt>Language_Spec</tt> directory contains

- the BSV Reference Guide, which is the principal language definition
    and specification of BSV

- the Bluespec Classic language definition

The <tt>Tutorials</tt> directory contain training materials, a PDC book, and
example designs, ranging from very simple to complex.

Two examples of complex designs done in BSV are Bluespec, Inc.'s
open-source RISC-V CPU designs, at:

- [Piccolo 3-stage RISC-V CPU](https://github.com/bluespec/Piccolo)

- [Flute 5-stage RISC-V CPU](https://github.com/bluespec/Flute)

These designs implement both RV32 and RV64 instruction sets, the
AIMFDC extensions, and Machine, Supervisor and User privilege modes
(including virtual memory), and are capable of booting Linux.
