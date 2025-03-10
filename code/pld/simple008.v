GAL22V10
ADDR_DEC

BOOT AS IACK A13 A14 A15 A16 A17 A18 A19 A20 GND
A21 EXP RAM6 RAM5 RAM4 RAM3 RAM2 RAM1 RAM0 ROM DUART VCC

/RAM0 = BOOT * /AS * IACK * /A21 * /A20 * /A19
/RAM1 = BOOT * /AS * IACK * /A21 * /A20 *  A19
/RAM2 = BOOT * /AS * IACK * /A21 *  A20 * /A19
/RAM3 = BOOT * /AS * IACK * /A21 *  A20 *  A19
/RAM4 = BOOT * /AS * IACK *  A21 * /A20 * /A19
/RAM5 = BOOT * /AS * IACK *  A21 * /A20 *  A19
/RAM6 = BOOT * /AS * IACK *  A21 *  A20 * /A19

/DUART = BOOT * /AS * IACK * A21 * A20 * A19 *  A18 *  A17 *  A16 *  A15 * A14 * /A13

/EXP = BOOT * /AS * IACK * A21 * A20 * A19 *  A18 *  A17 *  A16 *  A15 * A14 * A13

/ROM = /BOOT * /AS * IACK
     + BOOT * /AS * IACK * A21 * A20 * A19 *  A18 *  A17 *  A16 *  A15 * /A14
     + BOOT * /AS * IACK * A21 * A20 * A19 *  A18 *  A17 *  A16 * /A15
     + BOOT * /AS * IACK * A21 * A20 * A19 *  A18 *  A17 * /A16
     + BOOT * /AS * IACK * A21 * A20 * A19 *  A18 * /A17
     + BOOT * /AS * IACK * A21 * A20 * A19 * /A18

DESCRIPTION
Mackerel-08 v1 - Address Decoder

RAM0-6 is mapped 0x000000 - 0x380000 (3.5MB total) after BOOT
ROM is mapped 0x380000 - 0x3FC000 (496/512 KB usable) (mapped to 0x000000 at BOOT)
DUART is mapped 0x3FC000 - 0x3FE000 (8KB)
EXP is mapped 0x3FE000 - 0x400000 (8KB)
-------
GAL22V10
DTAK_DEC

NAS ROM DUART NC EXP DTKDUART DTKEXP IACKEXP IACKDUAR NC NC GND
NC NC NC NC NC NC NC NC NC NC DTKCPU VCC

/DTKCPU = /DUART * /DTKDUART
        + /EXP * /DTKEXP
        + /IACKDUAR * /DTKDUART
        + /IACKEXP * /DTKEXP
        + DUART * EXP

DESCRIPTION
Mackerel-08 v1 - DTACK Logic

When either the DUART or the expansion bus are selected, pass their DTACK signals to the CPU,
otherwise, assert /DTACK all the time

When either the DUART or expansion bus IACK signals are asserted, pass their DTACK signal to the CPU
-----
GAL22V10
INTR_DEC

FC0 FC1 FC2 AS IRQDUART IRQEXP NC NC NC A1 A2 GND
A3 NC NC NC NAS IACKEXP IACKDUAR IPL2 IPL1 IPL0 IACK VCC

NAS = /AS

/IACK = FC0 * FC1 * FC2

/IPL0 = /IRQDUART * IRQEXP
/IPL1 = /IRQEXP
IPL2 = VCC

/IACKDUAR = /AS * FC0 * FC1 * FC2 * /A3 * /A2 * A1
/IACKEXP = /AS * FC0 * FC1 * FC2 * /A3 * A2 * /A1

DESCRIPTION
Mackerel-08 v1 - Interrupt Logic

NAS is an inverted /AS pin

/IACK is active when FC pins are all high

DUART interrupt is mapped to IRQ level 1
EXP interrupt is mapped to IRQ level 2

Return IACK signals match the input IRQ levels
----
module simple008(
	input CLK,
	input RST_n, // aka HALT
	
	input [21:18] ADDR_H,
    input [16:6] ADDR_M,    
	input [3:0] ADDR_L,
	
	input AS_n, DS_n, RW,
	
	input FC0, FC1, FC2,

    input IRQ2, IRQ3, IRQ5, IRQ6,	
	output IPL0_n, IPL1_n, IPL2_n,

	output DTACK_n,
    output BERR, // might be internal
	
	output ROMSEL_n, RAMSEL1_n,
    output IOSEL_n, // might be internal

    input  DUAIRQ_n,
    output DUASEL,
    output DUAIACK_n,

	inout [7:0] GPIO
);


// Source oscillator frequency
localparam OSC_FREQ_HZ = 20000000;
// CPU frequency (half the oscillator frequency)
localparam CPU_FREQ_HZ = OSC_FREQ_HZ / 2;
// Frequency of the periodic timer interrupt
localparam TIMER_FREQ_HZ = 50;
// CPU cycles between timer interrupts
localparam TIMER_DELAY_CYCLES = CPU_FREQ_HZ / TIMER_FREQ_HZ;

// Unused signals
assign IACK_EXP_n = 1;
assign CS_EXP_n = 1'b1;

assign GPIO = 7'b0;

// Reconstruct the full address bus
wire [21:0] ADDR_FULL = {ADDR_H, 1'b0, ADDR_M, 2'b0, ADDR_L};

// CPU is responding to an interrupt request
wire IACK_n = ~(FC0 && FC1 && FC2);

assign DUAIACK_n = ~(~IACK_n && ~AS_n && ADDR_L[3:1] == 3'd5);

// DTACK from DUART
//wire DTACK0 = ((~CS_DUART_n || ~IACK_DUART_n) && DTACK_DUART_n);
wire DTACK0 = 1'b0;	// DUART DTACK is always low anyway?
// DTACK from DRAM
wire DTACK1 = (~CS_DRAM_n && DTACK_DRAM_n);
// DTACK to CPU
assign DTACK_n = DTACK0 || DTACK1 || ~VPA_n;	// NOTE: DTACK and VPA cannot be LOW at the same time

// BOOT signal generation
wire BOOT;
boot_signal bs1(RST_n, AS_n, BOOT);

// Encode interrupt sources to the CPU's IPL pins
irq_encoder ie1(
	.irq1(0),
	.irq2(0),
	.irq3(0),
	.irq4(0),
	.irq5(~DUAIRQ_n),
	.irq6(IRQ_TIMER),
	.irq7(0),
	.ipl0_n(IPL0_n),
	.ipl1_n(IPL1_n),
	.ipl2_n(IPL2_n)
);

reg[23:0] clock_cycles = 0;
reg IRQ_TIMER = 0;

always @(posedge CLK) begin
	clock_cycles <= clock_cycles + 1'b1;
	
	if (~RST_n) begin
		clock_cycles <= 24'b0;
	end
	else if (clock_cycles == TIMER_DELAY_CYCLES) begin
		IRQ_TIMER <= 1;
		clock_cycles <= 24'b0;
	end
	
	// Autovector the non-DUART interrupts
	if (~IACK_n && DUAIACK_n && ~AS_n) begin
		VPA_n <= 1'b0;
		IRQ_TIMER <= 0;
	end
	else VPA_n <= 1'b1;
end

//================================//
// Address Decoding
//================================//

// ROM at 0xF00000 - 0xFF4000 (0x000000 on BOOT)
wire ROM_EN = ~BOOT || (IACK_n && ADDR_FULL >= 24'hF00000 && ADDR_FULL < 24'hFF4000);
assign CS_ROM0_n = ~(~AS_n && ~LDS_n && ROM_EN);
assign CS_ROM1_n = ~(~AS_n && ~UDS_n && ROM_EN);

// SRAM enabled at 0xE00000 - 0xF00000 (1 MB)
wire RAM_EN = BOOT && IACK_n && ADDR_FULL >= 24'hE00000 && ADDR_FULL < 24'hF00000;
assign CS_SRAM0_n = ~(~AS_n && ~LDS_n && RAM_EN);
assign CS_SRAM1_n = ~(~AS_n && ~UDS_n && RAM_EN);


// DUART at 0xFF8000
assign CS_DUART_n = ~(BOOT && IACK_n && ~LDS_n && ADDR_FULL >= 24'hFF8000 && ADDR_FULL < 24'hFFC000);

endmodule

// missing a4 a5 a17 vpa_n

// -----------------------------------------------------
// Chip and pin assignments
// -----------------------------------------------------
//PIN: CHIP "simple008" ASSIGNED TO A PLCC84
//PIN: 1  HALT
//PIN: 2  A[12]
//PIN: 4  A[19]
//PIN: 5  A[14]
//PIN: 6  A[21]
//PIN: 8  A[16]
//PIN: 9  A[20]
//PIN: 12 A[8]
//PIN: 15 A[10]
//PIN: 16 A[15]
//PIN: 17 A[13]
//PIN: 18 A[18]
//PIN: 20 A[7]
//PIN: 21 A[11]
//PIN: 22 A[9]
//PIN: 24 A[6]
//PIN: 25 A[3]
//PIN: 27 A[2]
//PIN: 28 A[1]
//PIN: 29 A[0]
//PIN: 30 IRQ2
//PIN: 31 IRQ3
//PIN: 33 IRQ5
//PIN: 34 IRQ6
//PIN: 35 GPIO0
//PIN: 36 GPIO1
//PIN: 37 GPIO2
//PIN: 39 GPIO3
//PIN: 40 GPIO4
//PIN: 41 GPIO5
//PIN: 44 ROMSEL
//PIN: 45 RAMSEL1
//PIN: 50 IOSEL
//PIN: 51 WR
//PIN: 52 GPIO6
//PIN: 54 DUASEL
//PIN: 55 DUAIRQ
//PIN: 56 DTACK
//PIN: 57 GPIO7
//PIN: 61 DS
//PIN: 65 DUAIACK
//PIN: 70 BERR
//PIN: 73 FC0
//PIN: 74 FC1
//PIN: 75 FC2
//PIN: 76 RW
//PIN: 77 AS
//PIN: 79 IPL2
//PIN: 80 IPL1
//PIN: 81 IPL0
//PIN: 83 CLK
