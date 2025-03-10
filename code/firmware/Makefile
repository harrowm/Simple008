BASEDIR = /Users/malcolm/simple/cross
CC = ${BASEDIR}/bin/m68k-elf-gcc
AS = $BASEDIR}/bin/m68k-elf-as
LD = ${BASEDIR}/bin/m68k-elf-ld
OBJCOPY = ${BASEDIR}/bin/m68k-elf-objcopy

MEMORY_MAP_ROM = linker_rom.scr
MEMORY_MAP_RAM = linker_ram.scr
VECTORS = vectors.s
CFLAGS = -m68000 -I${BASEDIR}/m68k-elf
AFLAGS = -m68000

#LDFLAGS="-L${BREWPREFIX}/lib"
#CPPFLAGS="-I${~/simple/cross/m68k-elf}/include"

COMMON_OBJS_ROM = $(VECTORS) start.o glue.o simple.o term.o
COMMON_OBJS_RAM = start_ram.o glue.o simple.o term.o

#BASE_BINS = bootloader.bin hello.bin kernel.bin fatfs_demo.bin
BASE_BINS = bootloader.bin kernel.bin

BINS = $(BASE_BINS)

.SECONDARY: *.elf *.bin

all: $(BINS)

%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -g -Wall -c $< -o $@ -O

%.o: %.s
	$(AS) $(AFLAGS) $< -o $@

%.bin: %.elf
	$(OBJCOPY) $< -O binary $@

#bootloader.elf: $(COMMON_OBJS_ROM) bootloader.o sd.o spi.o ide.o fat16.o
bootloader.elf: $(COMMON_OBJS_ROM) bootloader.o
	$(CC) $(CFLAGS) $(CPPFLAGS) -Wl,--build-id=none -T $(MEMORY_MAP_ROM) -nostartfiles $^ -o $@

hello.elf: $(COMMON_OBJS_RAM) hello.o ide.o
	$(CC) $(CFLAGS) $(CPPFLAGS) -Wl,--build-id=none -T $(MEMORY_MAP_RAM) -nostartfiles $^ -o $@

fatfs_demo.elf: $(COMMON_OBJS_RAM) fatfs_demo.o fat16.o sd.o spi.o ide.o
	$(CC) $(CFLAGS) $(CPPFLAGS) -Wl,--build-id=none -T $(MEMORY_MAP_RAM) -nostartfiles $^ -o $@

kernel.elf: $(COMMON_OBJS_RAM) kernel.o
	$(CC) $(CFLAGS) $(CPPFLAGS) -Wl,--build-id=none -T $(MEMORY_MAP_RAM) -nostartfiles $^ -o $@
	
clean:
	rm -f *.o *.elf *.bin

burn:
	truncate -s%512K bootloader.bin
	minipro -p SST39SF040 -w bootloader.bin
