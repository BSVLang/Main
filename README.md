# Main

---

**January 31 2020 bulletin:** On January 31, 2020, Bluespec, Inc.
released the _bsc_ compiler for
[BSV/BH](https://github.com/B-Lang-org/bsc) in free, open-source form.

The contents of this repository will move there soon (a month or so).

---

**Work-in-progress note (Jan 31, 2020):** This repo was created quite
some time ago as an open-source resource for BSV/BH language artefacts
(language manuals, tutorials, etc.).  This was because (a) the
_languages_ have long been open (others were/are free to create their
own implementations if they wish), and (b) the _bsc_ compiler has
always been free for academic teaching and research.

Now that _bsc_ has also been open-sourced, the content of this repo
will be moved to [that repo](https://github.com/B-Lang-org/bsc) in Q1 2020.

At the moment the BH ("Bluespec Classic") content here is quite
sketchy (`Language_Spec/Bluespec_Classic.pdf` and
`Tutorials/Bluespec_Classic_Training`).  This is because for many
years, everybody only used BSV, not BH.  Recently there has been a
renewed interest in BH, and we plan to support BSV and BH as equal
partners, we plan to bring the BH material up to par with the BSV
material (Q1 2020).  In the meanwhile, if you are using BH, you may be
able to answer any question you have by looking at corresponding the
BSV material (it's the same language, just a different syntax).

Thank you for your patience.

---

This is a repository for open source Bluespec BSV and BH.

Bluespec BSV and and BH are one High Level Hardware Design Language
(HL-HDL) with two optional syntaxes:

- BSV is "Bluespec SystemVerilog-ish": syntax inspired by SystemVerilog.

- BH is "Bluespec Haskell-ish", (a.k.a. Bluespec Classic): syntax inspired by Haskell.

You can freely mix-and-match syntaxes at the file (package)
granularity.

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

The <tt>Tutorials</tt> directory contain training materials, a PDF book, and
example designs, ranging from very simple to complex.

---

**Also of interest**

Three examples of complex designs done in BSV are Bluespec, Inc.'s
open-source RISC-V CPU designs, at:

- [Piccolo 3-stage RISC-V CPU](https://github.com/bluespec/Piccolo)

- [Flute 5-stage RISC-V CPU](https://github.com/bluespec/Flute)

- [Toooba superscalar, out-of-order, multi-stage RISC-V CPU](https://github.com/bluespec/Toooba)

All three implement RV64 instruction sets, the AIMFDC RISC-V
extensions, and Machine, Supervisor and User privilege modes
(including virtual memory), and are capable of booting Linux.  Piccolo
and Flute can also be compiled for RV32, and all the extensions are
optional (including Supervisor mode and virtual memory), so can be
built in very small configurations for Embedded/IoT applications.

All three can be built out-of-the-box and will run RISC-V binaries.
