    
// The code is pretty simple. It sets up a timer interrupt to fire every 200ms and a DUART interrupt to fire when a character is received or the timer counter overflows. The timer interrupt prints a dot to the console and the DUART interrupt echos the received character back to the console. 
// The code is compiled with the following command: 
// m68k-elf-gcc -m68000 -nostartfiles -nostdlib -T mackerel.ld -o kernel.o kernel.c

// The  mackerel.ld  file is a linker script that specifies the memory layout of the Mackerel board. 
// MEMORY
// {
//     rom (rx) : ORIGIN = 0x00000000, LENGTH = 0x00010000
//     ram (rwx) : ORIGIN = 0x00010000, LENGTH = 0x00010000
// }
    
    
#include <stdio.h>
#include <stdbool.h>
#include "simple.h"

void __attribute__((interrupt)) duart1_isr()
{
    // Determine the type of interrupt
    uint8_t misr = MEM(DUART1_MISR);

    if (misr & DUART_INTR_RXRDY)
    {
        // RX character available
        uint8_t a = MEM(DUART1_RBB); // Read the available byte. This clears the interrupt
        duart_putc(a);               // Print the character back out
    }
    else if (misr & DUART_INTR_COUNTER)
    {
        MEM(DUART1_OPR_RESET);
        duart_putc('y');
    }
}

void __attribute__((interrupt)) timer_isr()
{
    duart_putc('.');
}

int main()
{
    uint32_t i = 0;

    printf("Starting Mackerel kernel...\n");

    set_exception_handler(EXCEPTION_AUTOVECTOR + IRQ_NUM_TIMER, &timer_isr);
    set_exception_handler(EXCEPTION_USER + IRQ_NUM_DUART, &duart1_isr);

    // Setup DUART 1
    MEM(DUART1_IVR) = EXCEPTION_USER + IRQ_NUM_DUART; // Set interrupt base register

    // Setup DUART 1 timer as 5 Hz interrupt
    MEM(DUART1_ACR) = 0xF0;       // Set timer mode X/16
    MEM(DUART1_CUR) = 0x5A;       // Counter upper byte, (3.6864MHz / 2 / 16 / 0x5A00) = 5 Hz
    MEM(DUART1_CLR) = 0x00;       // Counter lower byte
    MEM(DUART1_OPR);              // Start counter

    MEM(DUART1_IMR) = DUART_INTR_RXRDY | DUART_INTR_COUNTER; // Unmask interrupts

    printf("Starting kernel...%X\r\n", 0xC0FFEE);

    // Turn interrupts on
    set_interrupts(true);

    while (true)
    {
        printf("Loop: %X\r\n", i);

        i++;

        delay(50000);
    }

    return 0;
}
