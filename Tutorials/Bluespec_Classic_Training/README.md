# Bluespec Classic Tutorial

This is a tutorial for learning the Bluespec Classic.

Bluespec Classic is a High-level Hardware Design Language (HLHDL),
taking its inspirations from Haskell and Term Rewriting Systems.  A
compiler from Bluespec Classic into either natively compiled
simulation or Verilog has been available from Bluespec,
Inc. (www.bluespec.com) since 2004, and has been used for several
industrial-strength hardware designs.  Bluespec, Inc. provides free
licenses for its tools for teaching and research to academia and
research institutions, and commercial licenses to others.

Please start by reading the file <tt>START_HERE.pdf</tt>. Briefly: the
directory <tt>Examples</tt> contains a series of examples starting
from extremely simple ("Hello World") to fairly complex (a concurrent
memory-to-memory Mergesort accelerator driven by a RISC-V CPU core in
an SoC system).  Each example has an accompanying PDF file to explain
it.  All examples can be built and run using the <tt>Makefile</tt> in
each example directory (provided you have an installation of the
Bluespec tools).

The <tt>Reference</tt> directory contains a series of PDF lectures
that explain the language syntax, semantics, libraries and idioms,
organized by topic.
