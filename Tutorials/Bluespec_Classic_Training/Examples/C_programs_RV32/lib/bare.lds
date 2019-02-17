SECTIONS
{
    .startup 0x80000000: { KEEP(startup.o(.text)) }
}
INSERT AFTER .bss;
INPUT(syscalls.o)
INPUT(riscv_counters.o)
INPUT(ns16550.o)
