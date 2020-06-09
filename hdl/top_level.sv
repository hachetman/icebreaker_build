// Cause yosys to throw an error when we implicitly declare nets
`default_nettype none

// Project entry point
module top_level (
	input  CLK,
	input  BTN_N, BTN1, BTN2, BTN3,
	output LED1, LED2, LED3, LED4, LED5,
	output P1A1, P1A2, P1A3, P1A4, P1A7, P1A8, P1A9, P1A10,
	output P1B1, P1B2, P1B3, P1B4, P1B7, P1B8, P1B9, P1B10,
);
	// 7 segment control line bus
	wire [7:0] seven_segment_1;
	wire [7:0] seven_segment_2;

	// Assign 7 segment control line bus to Pmod pins
	assign { P1A10, P1A9, P1A8, P1A7, P1A4, P1A3, P1A2, P1A1 } = seven_segment_1;
	assign { P1B10, P1B9, P1B8, P1B7, P1B4, P1B3, P1B2, P1B1 } = seven_segment_2;

	// Display value register and increment bus
	reg [7:0] display_value = 0;
	wire [7:0] display_value_inc;

	// Clock divider and pulse registers
	reg [20:0] clkdiv = 0;
	reg clkdiv_pulse = 0;

	// Combinatorial logic
	assign LED1 = !BTN_N;                            // Not operator example
	assign LED2 = BTN1 || BTN2;                      // Or operator example
	assign LED3 = BTN2 ^ BTN3;                       // Xor operator example
	assign LED4 = BTN3 && !BTN_N;                    // And operator example
	assign LED5 = (BTN1 + BTN2 + BTN3 + 2'b00) >> 1; // Addition and shift example

	// Synchronous logic
	always @(posedge CLK) begin
		// Clock divider pulse generator
		if (clkdiv == 20'hfffff) begin
			clkdiv <= 0;
			clkdiv_pulse <= 1;
		end else begin
			clkdiv <= clkdiv + 1;
			clkdiv_pulse <= 0;
		end

		// Timer counter
		if (clkdiv_pulse) begin
			display_value <= display_value_inc;
		end

	end

	assign display_value_inc = display_value + 8'b1;

	// 7 segment display control Pmod 1A
	seven_seg_ctrl seven_segment_ctrl_1 (
		.CLK(CLK),
		.din(display_value[7:0]),
		.dout(seven_segment_1)
	);
	seven_seg_ctrl seven_segment_ctrl_2 (
		.CLK(CLK),
		.din(display_value[7:0]),
		.dout(seven_segment_2)
	);

endmodule

