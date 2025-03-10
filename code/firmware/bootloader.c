#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "simple.h"
// #include "sd.h"
// #include "ide.h"
// #include "fat16.h"

#define VERSION "1.0"

#define INPUT_BUFFER_SIZE 32

// void handler_runram();
// void handler_runrom();
// void handler_load(uint32_t addr);
// void handler_boot();
// void handler_zero(uint32_t addr, uint32_t size);
// void handler_ide();
uint8_t readline(char *buffer);
// void command_not_found(char *command);
// void memdump(uint32_t address, uint32_t bytes);
// void print_string_bin(char *str, uint8_t max);

// void memtest(uint8_t *start, uint32_t size);
// void memtest8(uint8_t *start, uint32_t size, uint8_t target);
// void memtest32(uint32_t *start, uint32_t size);

char buffer[INPUT_BUFFER_SIZE];

int main()
{
    printf("\r\n### %s Bootloader v%s ###\r\n###       crmaykish - 2025        ###\r\n", SYSTEM_NAME, VERSION);

    while (true)
    {
        // Present the command prompt and wait for input
        duart_puts("> ");
        readline(buffer);
        duart_puts("\r\n");

        // if (strncmp(buffer, "load", 4) == 0)
        // {
        //     strtok(buffer, " ");
        //     char *param1 = strtok(NULL, " ");
        //     uint32_t addr = strtoul(param1, 0, 16);
        //     handler_load(addr);
        // }
        // else if (strncmp(buffer, "boot", 4) == 0)
        // {
        //     handler_boot();
        // }
        // else if (strncmp(buffer, "ide", 3) == 0)
        // {
        //     handler_ide();
        // }
        // else if (strncmp(buffer, "runrom", 6) == 0)
        // {
        //     handler_runrom();
        // }
        // else if (strncmp(buffer, "run", 3) == 0 || strncmp(buffer, "runram", 6) == 0)
        // {
        //     handler_runram();
        // }
        // else if (strncmp(buffer, "dump", 4) == 0)
        // {
        //     strtok(buffer, " ");
        //     char *param1 = strtok(NULL, " ");
        //     uint32_t addr = strtoul(param1, 0, 16);

        //     memdump(addr, 256);
        // }
        // else if (strncmp(buffer, "peek", 4) == 0)
        // {
        //     strtok(buffer, " ");
        //     char *param1 = strtok(NULL, " ");
        //     uint32_t addr = strtoul(param1, 0, 16);

        //     printf("%02X", MEM(addr));
        // }
        // else if (strncmp(buffer, "poke", 4) == 0)
        // {
        //     strtok(buffer, " ");
        //     char *param1 = strtok(NULL, " ");
        //     char *param2 = strtok(NULL, " ");
        //     uint32_t addr = strtoul(param1, 0, 16);
        //     uint8_t val = (uint8_t)strtoul(param2, 0, 16);

        //     MEM(addr) = val;
        // }
        // else if (strncmp(buffer, "mem8", 4) == 0)
        // {
        //     strtok(buffer, " ");
        //     char *param1 = strtok(NULL, " ");
        //     char *param2 = strtok(NULL, " ");
        //     uint32_t start = strtoul(param1, 0, 16);
        //     uint32_t size = strtoul(param2, 0, 16);
        //     memtest((uint8_t *)start, size);
        // }
        // else if (strncmp(buffer, "mem32", 5) == 0)
        // {
        //     strtok(buffer, " ");
        //     char *param1 = strtok(NULL, " ");
        //     char *param2 = strtok(NULL, " ");
        //     uint32_t start = strtoul(param1, 0, 16);
        //     uint32_t size = strtoul(param2, 0, 16);
        //     memtest32((uint32_t *)start, size);
        // }
        // else if (strncmp(buffer, "zero", 4) == 0)
        // {
        //     strtok(buffer, " ");
        //     char *param1 = strtok(NULL, " ");
        //     char *param2 = strtok(NULL, " ");
        //     uint32_t start = strtoul(param1, 0, 16);
        //     uint32_t size = strtoul(param2, 0, 16);
        //     handler_zero(start, size);
        // }
        // else
        // {
        //     command_not_found(buffer);
        // }

        // duart_puts("\r\n");
    }

    return 0;
}

// void handler_runram()
// {
//     duart_puts("Jumping to 0x400\r\n");
//     asm("jsr 0x400");
// }

// void handler_runrom()
// {
//     duart_puts("Jumping to 0x100000\r\n");
//     asm("jsr 0x100000");
// }

// void handler_boot()
// {
//     printf("Loading Linux from SD card...\n");

//     if (!sd_init())
//         return;

//     unsigned char first[512];
//     unsigned char *mem = (unsigned char *)0x400;

//     // Read the first block of the SD card to determine the Linux image size
//     sd_read(0, first);
//     uint32_t image_size = strtoul((char *)first, 0, 10);
//     printf("Image size: %u\n", image_size);

//     // Read the rest of the SD card to load the Linux image into RAM
//     printf("Loading kernel into 0x%X...\n", (int)mem);

//     uint32_t blocks = (image_size / 512) + 1;

//     for (int block = 1; block <= blocks; block++)
//     {
//         if (block % 10 == 0)
//         {
//             printf("%d/%d\n", block, blocks);
//         }

//         sd_read(block, mem);
//         mem += 512;
//     }

//     printf("Done\n");

//     handler_runram();
// }

// void block_read(uint32_t block_num, uint8_t *block)
// {
//     IDE_read_sector((uint16_t *)block, block_num);
// }

// void handler_ide()
// {
//     fat16_boot_sector_t boot_sector;
//     fat16_dir_entry_t files_list[16] = {0};

//     printf("Attempting to load Linux kernel from IDE...\r\n");

//     // Reset the IDE interface
//     uint16_t buf[256];
//     IDE_reset();
//     IDE_device_info(buf);

//     // Initialize FAT16 library with the IDE block read function
//     if (fat16_init(block_read) != 0)
//     {
//         printf("Failed to initialize FAT16 library\r\n");
//         return;
//     }

//     fat16_read_boot_sector(2048, &boot_sector);
//     fat16_print_boot_sector_info(&boot_sector);

//     printf("\r\nReading files on disk...\r\n");
//     fat16_list_files(&boot_sector, files_list);

//     bool kernel_found = false;

//     for (int i = 0; i < 16; i++)
//     {
//         if (files_list[i].file_size > 0)
//         {
//             char filename[13];
//             fat16_get_file_name(&files_list[i], filename);

//             if (strncmp(filename, "IMAGE   .BIN", 12) == 0)
//             {
//                 printf("\r\nFound IMAGE.BIN, reading it into RAM...\r\n");

//                 uint8_t *file = (uint8_t *)0x400;

//                 int bytes_read = fat16_read_file(&boot_sector, files_list[i].first_cluster_low, file, files_list[i].file_size);

//                 printf("\r\n");

//                 printf("Read %d of %d bytes\r\n", bytes_read, files_list[i].file_size);

//                 if (bytes_read != files_list[i].file_size)
//                 {
//                     printf("File read failed\r\n");
//                 }
//                 else
//                 {
//                     printf("File read successfully\r\n");
//                     kernel_found = true;
//                 }

//                 break;
//             }
//         }
//     }

//     if (kernel_found)
//     {
//         handler_runram();
//     }
//     else
//     {
//         printf("ERROR: Could not find IMAGE.BIN on disk\r\n");
//     }
// }

// void handler_load(uint32_t addr)
// {
//     int in_count = 0;
//     int end_count = 0;
//     uint8_t in = 0;

//     if (addr == 0)
//     {
//         addr = 0x400;
//     }

//     printf("Loading from serial into 0x%X...\r\n", addr);

//     while (end_count != 3)
//     {
//         in = duart_getc();

//         MEM(addr + in_count) = in;

//         if (in == 0xDE)
//         {
//             end_count++;
//         }
//         else
//         {
//             end_count = 0;
//         }

//         in_count++;
//     }

//     MEM(addr + in_count - 3) = 0;

//     printf("Done! Transferred %d bytes.\r\n", in_count - 3);
// }

// void handler_zero(uint32_t addr, uint32_t size)
// {
//     for (uint32_t i = addr; i < addr + size; i++)
//     {
//         MEM(i) = 0x00;
//     }
// }

// void command_not_found(char *command_name)
// {
//     duart_puts("Command not found: ");
//     duart_puts(command_name);
// }

uint8_t readline(char *buffer)
{
    uint8_t count = 0;
    uint8_t in = duart_getc();

    while (in != '\n' && in != '\r')
    {
        // Character is printable ASCII
        if (in >= 0x20 && in < 0x7F)
        {
            duart_putc(in);

            buffer[count] = in;
            count++;
        }
        else if (0x08)
        {
            // Backspace
            if (count > 0)
            {
                duart_puts("\e[1D"); // Move cursor to the left
                duart_putc(' ');     // Clear last character
                duart_puts("\e[1D"); // Move cursor to the left again
                count--;             // Move input buffer index back
            }
        }

        in = duart_getc();
    }

    buffer[count] = 0;

    return count;
}

// void memtest(uint8_t *start, uint32_t size)
// {
//     memtest8(start, size, 0x00);
//     memtest8(start, size, 0xAA);
//     memtest8(start, size, 0x55);
//     memtest8(start, size, 0xFF);

//     printf("Test complete\r\n");
// }

// void memtest8(uint8_t *start, uint32_t size, uint8_t target)
// {
//     printf("8-bit Mem Test: %X to %X w/ val %02X\r\n", (uint32_t)start, (uint32_t)(start + size), target);

//     for (uint8_t *i = start; i < (uint8_t *)(start + size); i++)
//     {
//         *i = target;
//     }

//     for (uint8_t *i = start; i < (uint8_t *)(start + size); i++)
//     {
//         if (*i != target)
//         {
//             printf("Error at 0x%X, expected 0x%02X, got 0x%02X\r\n", (uint32_t)i, target, *i);
//         }
//     }

//     printf("\r\n");
// }

// // Write the 32-bit address value to the same address in RAM
// void memtest32(uint32_t *start, uint32_t size)
// {
//     printf("32-bit Mem Test: %X to %X\r\n", (uint32_t)start, (uint32_t)start + (uint32_t)size);

//     printf("Writing...\r\n");
//     for (uint32_t *i = start; i < (uint32_t *)(start + size / 4); i++)
//     {
//         *i = (uint32_t)i;

//         if ((*i % 0x10000) == 0)
//         {
//             duart_putc('.');
//         }
//     }

//     printf("\r\nReading...\r\n");
//     for (uint32_t *i = start; i < (uint32_t *)(start + size / 4); i++)
//     {
//         if (*i != (uint32_t)i)
//         {
//             printf("Error at 0x%X, expected 0x%02X, got 0x%02X\r\n", (uint32_t)i, (uint32_t)i, *i);
//         }

//         if ((*i % 0x10000) == 0)
//         {
//             duart_putc('.');
//         }
//     }

//     printf("\r\nTest complete\r\n");
// }
