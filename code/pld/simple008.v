module simple008(
	input CLK,
	input RST_n, // aka HALT
	
	input [21:10] ADDR_H,  // Forced to add A17
	input [2:0] ADDR_L,
	
	input AS_n, DS_n, 
    
    input RW,
    output WR,
	
	input FC0, FC1, FC2,

    input IRQ2_n, IRQ3_n, 	
	output IPL0_n, IPL1_n, IPL2_n,

	output DTACK_n,
    output BERR_n, 
	
	output ROMSEL_n, RAMSEL1_n,
    output IOSEL_n,

    input  DUAIRQ_n,
    output DUASEL_n,
    output DUAIACK_n,

    input  EXPIRQ_n,
    output EXPSEL_n,
    output EXPIACK_n,

    output reg VPA_n, // Forced to add VPA_n

	inout [7:0] GPIO
);

// CPU cycles between timer interrupts, 10MHz clock and 50x a second
localparam TIMER_DELAY_CYCLES = 20000000 / 50;

assign WR = !RW;

assign GPIO = 7'b0;

// Default for now
assign BERR_n = 1'b1;
assign EXPSEL_n = 1'b1;
assign EXPIACK_n = 1'b1;

// HACK: we dont have A4 or A5 .. so we need to add them?
// Reconstruct the full address bus
wire [21:0] ADDR_FULL = {ADDR_H, 7'b0, ADDR_L};

// CPU is responding to an interrupt request
wire IACK_n = !(FC0 && FC1 && FC2);
assign DUAIACK_n = !(!IACK_n && !AS_n && ADDR_L[2:0] == 3'd5);

// DTACK - is this too simple, should we hold DTACK Low ?
// DTACK and VPA cannot be low at the same time
assign DTACK_n = !EXPSEL_n || !DUASEL_n || !RAMSEL1_n || !ROMSEL_n || !VPA_n;

// BOOT signal generation
wire BOOT;
boot_signal bs1(RST_n, AS_n, BOOT);

// Encode interrupt sources to the CPU's IPL pins
irq_encoder ie1(
	.irq1(0),
	.irq2(!IRQ2_n),
	.irq3(!IRQ3_n),
	.irq4(!EXPIRQ_n),
	.irq5(!DUAIRQ_n),
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
	
	if (!RST_n) begin
		clock_cycles <= 24'b0;
	end
	else if (clock_cycles == TIMER_DELAY_CYCLES) begin
		IRQ_TIMER <= 1;
		clock_cycles <= 24'b0;
	end
	
	// Autovector the non-DUART interrupts
	if (!IACK_n && DUAIACK_n && !AS_n) begin
		VPA_n <= 1'b0;
		IRQ_TIMER <= 0;
	end
	else VPA_n <= 1'b1;
end

//================================//
// Address Decoding
//================================//

// RAM0 is mapped 0x000000 - 0x100000 (1MB total) after BOOT
// ROM is mapped 0x380000 - 0x3FC000 (496/512 KB usable) (mapped to 0x000000 at BOOT)
// DUART is mapped 0x3FC000 - 0x3FE000 (8KB)
// EXP is mapped 0x3FE000 - 0x400000 (8KB)

// ROM at 0xF00000 - 0xFF4000 (0x000000 on BOOT)
wire ROM_EN = !BOOT || (IACK_n && ADDR_FULL >= 24'h380000 && ADDR_FULL < 24'h3FC000);
assign ROMSEL_n = !(!AS_n && !DS_n && ROM_EN);

// SRAM enabled at 0x000000 - 0x100000 (1 MB)
wire RAM_EN = BOOT && IACK_n && ADDR_FULL >= 24'h000000 && ADDR_FULL < 24'h100000;
assign RAMSEL1_n = !(!AS_n && !DS_n && RAM_EN);

// DUART at 0xFF8000
assign DUASEL_n = !(BOOT && IACK_n && !DS_n && ADDR_FULL >= 24'h3FC000 && ADDR_FULL < 24'h3FE000);

// Expansion at 0xFFE000
assign EXPSEL_n = !(BOOT && IACK_n && !DS_n && ADDR_FULL >= 24'h3FE000 && ADDR_FULL < 24'h400000);

// Not sure we will use this 
assign IOSEL_n = !DUASEL_n || !EXPSEL_n;

endmodule


// missing a3 a4 a5 a17 vpa_n, dont need A4 and a5 but maybe add for consistency ?
// footprint of DS1233 isnt correct
// expansion bus is too close to the CPLD
// Need D0-8 on expansion bus if we are going to do SDCARD In CPLD etc

// -----------------------------------------------------
// Chip and pin assignments
// -----------------------------------------------------
//PIN: CHIP "simple008" ASSIGNED TO A PLCC84
//PIN: RST_n : 1
//PIN: ADDR_H_2 : 4
//  above is A[19]
//PIN: ADDR_H_7 : 5
// above is A[14]
//PIN: ADDR_H_0 : 6
// above is A[21]
//PIN: ADDR_H_5 : 8
// above is A[16]
//PIN: ADDR_H_1 : 9
// above is A[20]
//PIN: ADDR_H_4 :  10
// above is A[17]
// Added above
//PIN: ADDR_H_6 : 16 
// above is A[15]
//PIN: ADDR_H_8 : 17
// above is A[13]   
//PIN: ADDR_H_3 :   18 
// above is A[18]

//PIN: ADDR_L_0 : 27
// A[2] above
//PIN: ADDR_L_1 : 28
// A[1] above
//PIN: ADDR_L_2 : 29
// A[0] above
//PIN: IRQ2_n : 30
//PIN: IRQ3_n : 31
//PIN: GPIO_0 : 35
//PIN: GPIO_1 : 36
//PIN: GPIO_2 : 37
//PIN: GPIO_3 : 39
//PIN: GPIO_4 : 40  
//PIN: GPIO_5 : 41
//PIN: ROMSEL_n : 44
//PIN: RAMSEL1_n : 45
//PIN: IOSEL_n : 50
//PIN: WR : 51
//PIN: GPIO_6 : 52
//PIN: DUASEL_n : 54
//PIN: DUAIRQ_n : 55
//PIN: DTACK_n : 56
//PIN: GPIO_7 : 57
//PIN: VPA_n : 60
// Added above
//PIN: DS_n : 61
//PIN: DUAIACK_n : 65
//PIN: BERR_n : 70
//PIN: FC0 : 73
//PIN: FC1 : 74 
//PIN: FC2 : 75
//PIN: RW : 76 
//PIN: AS_n : 77
//PIN: IPL2_n : 79
//PIN: IPL1_n : 80 
//PIN: IPL0_n : 81
//PIN: CLK : 83
