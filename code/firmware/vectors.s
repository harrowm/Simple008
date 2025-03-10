    .align 2

    .section .vectors, "a"

    .long 0x100000              | Initial stack pointer - at top of the 1MB SRAM
    .long _start                | Initial program counter 

