# Main

---

On January 31, 2020, Bluespec, Inc.  released the _bsc_ compiler for
the BSV and BH High-Level Hardware Design Languages (HL-HDLs) in
_free, open-source_ form.  The language and the compiler are now
maintained actively by a group of enthusiasts and volunteers, and can
be found at
[https://github.com/B-Lang-org/bsc](https://github.com/B-Lang-org/bsc).
That repository contains the full source code of the _bsc_ compiler,
documents defining the BSV and BH languages, the libraries, a user
guide, and more.  It also contains pre-built downloads of the compiler
and documents, available for a number of operating systems (various
recent versions of Linux and MacOS).

This repo contains some auxiliary materials, primarily old tutorials
(slides, exercises) and historical documents.

---

**Also of interest**

* The following repository:
  [https://github.com/rsnikhil/Learn\_Bluespec\_and\_RISCV_Design](https://github.com/rsnikhil/Learn_Bluespec_and_RISCV_Design)

  contains courseware for learning BSV and RISC-V pipelined CPU
  design.  It includes a 300+ page textbook, exercises, and lecture
  slides. It features complete BSV source code for two RISC-V CPUs:

  * *Drum* a simple, reference hardware implementation (not pipelined)
  * *Fife* a 6+ stage mostly in-order pipeline

  All the materials are free and open-source, and the CPUs can be
  compiled with the _bsc_ compiler.


* The CTSRD-CHERI team at U.Cambridge, UK, are very active users of
  BSV/BH, and have many open-source materials on their GitHub site:
  [https://github.com/CTSRD-CHERI](https://github.com/CTSRD-CHERI)
  Their work includes the CHERI "capabilities" extension to the RISC-V
  specification, including a full implementation in BSV in the
  _Toooba_ processor, see below.

* Three older examples of complex designs done in BSV are Bluespec,
  Inc.'s open-source RISC-V CPU designs, at:

  * [Piccolo 3-stage RISC-V CPU](https://github.com/bluespec/Piccolo)
  * [Flute 5-stage RISC-V CPU](https://github.com/bluespec/Flute)
  * [Toooba superscalar, out-of-order, multi-stage RISC-V CPU](https://github.com/bluespec/Toooba)

  All three implement RV64 instruction sets, the AIMFDC RISC-V
  extensions, and Machine, Supervisor and User privilege modes
  (including virtual memory), and are capable of booting Linux.
  Piccolo and Flute can also be compiled for RV32 AIMFDC, and all the
  extensions are optional (including Supervisor mode and virtual
  memory), so can be built in very small configurations for
  Embedded/IoT applications.

  All three can be built out-of-the-box and will run RISC-V binaries.

---

**Some historical notes**

Bluespec BSV and and BH are one High Level Hardware Design Language
(HL-HDL) with two optional syntaxes:

- BSV is "Bluespec SystemVerilog-ish": syntax inspired by SystemVerilog.

- BH is "Bluespec Haskell-ish", (a.k.a. Bluespec Classic): syntax inspired by Haskell.

You can freely mix-and-match syntaxes at the file (package)
granularity.

The language was developed at [Bluespec, Inc.](https://www.bluespec.com) and
previously at Sandburst Corp., with roots in research at MIT in the
1990s.  It draws its primary inspirations from:

- Term Rewriting Systems (to express complex concurrent behavior), and

- Haskell (to express complex, strongly-typed structure).

**Offer to merge into IEEE SystemVerilog**: On Feb 26, 2010, at a
"SystemVerilog Requirements Gathering Meeting" conducted by the IEEE
P1800 SystemVerilog Standards Committee in San Jose, Bluespec,
Inc. offered to donate the entire BSV Language for incorporation into
the next revision of the SystemVerilog standard, but the offer did not
meet the priority threshold of the members present. [See Bluespec's
offer in the
[<tt>Historical/</tt>](Historical/Bluespec_Offer_to_Donate_BSV_to_IEEE_P1800_SystemVerilog.pdf).]
directory here.

In the 20-teens, Bluespec, Inc. offered a product called **emVM**
(suggesting Emulation Virtual Machine) for emulating hardware designs,
pre-ASIC, on PCIe-attached off-the-shelf FPGA boards. It included a
complete implementation of the [Accelera SCE-MI
standard](https://www.accellera.org/downloads/standards/sce-mi),
implemented in BSV.  That IP was sold by Bluespec, Inc. to some of the
EDA majors.  An historical PDF of the emVM User Manual can be found in
the <tt>Historical/</tt> directory.

The <tt>Language_Spec</tt> directory here contains some older versions of:

- the BSV Reference Guide, which is the principal language definition
    and specification of BSV

- the Bluespec Classic language definition

The latest versions are on the _bsc_ GitHub site mentioned earlier.

The <tt>Tutorials</tt> directory here contain training materials, a
PDF book, and example designs, ranging from very simple to complex.
