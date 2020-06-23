// Cause yosys to throw an error when we implicitly declare nets
`default_nettype none

// Project entry point
module top_level 
  (
   input  wire CLK,
   input  wire RX,
   output wire TX,
   input  wire BTN_N,
   input  wire BTN1,
   input  wire BTN2,
   input  wire BTN3,
   output wire LED1,
   output wire LED2,
   output wire LED3,
   output wire LED4,
   output wire LED5,
   output wire P1A1,
   output wire P1A2,
   output wire P1A3,
   output wire P1A4,
   output wire P1A7,
   output wire P1A8,
   output wire P1A9,
   output wire P1A10,
   output wire P1B1,
   output wire P1B2,
   output wire P1B3,
   output wire P1B4,
   output wire P1B7,
   output wire P1B8,
   output wire P1B9,
   output wire P1B10);

// 7 segment control line bus
wire [7:0] seven_segment_1;
wire [7:0] seven_segment_2;

// Display value register and increment bus
reg [7:0] display_value = 0;
wire [7:0] display_value_inc;
wire [7:0] uart_rx_value;
reg [7:0] display_value_2 = 'hbd;
// Clock divider and pulse registers
reg [20:0] clkdiv = 0;
reg clkdiv_pulse = 0;
wire m_axis_tvalid;

// Assign 7 segment control line bus to Pmod pins
assign { P1A10, P1A9, P1A8, P1A7, P1A4, P1A3, P1A2, P1A1 } = seven_segment_1;
assign { P1B10, P1B9, P1B8, P1B7, P1B4, P1B3, P1B2, P1B1 } = seven_segment_2;

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

always @(posedge CLK) begin
    if (m_axis_tvalid) begin
        display_value_2 <= uart_rx_value;
    end
end

assign display_value_inc = display_value + 8'b1;

// 7 segment display control Pmod 1A
seven_seg_ctrl seven_segment_ctrl_1 
  (
   .CLK(CLK),
   .din(display_value[7:0]),
   .dout(seven_segment_1));
seven_seg_ctrl seven_segment_ctrl_2 
  (
   .CLK(CLK),
   .din(display_value_2),
   .dout(seven_segment_2));

uart #
  (
   .BAUD(115200),
   .CLK_FREQ(12000000))
uart_inst
  (
   .clk_i(CLK),
   .s_axis_tdata_i('h46),
   .s_axis_tvalid_i(1'b1),
   .s_axis_tready_o(),
   .m_axis_tdata_o(uart_rx_value),
   .m_axis_tvalid_o(m_axis_tvalid),
   .m_axis_tready_i(1'b1),
   .uart_rx_i(RX),
   .uart_tx_o(TX));   


  endmodule

