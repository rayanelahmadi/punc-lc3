//==============================================================================
// Register File Module for PUnC LC3 Processor
//
// 8-entry, 16-bit wide register file with three asynchronous read ports and
// one synchronous write port.
//
//   Port 0 (r_addr_0 / r_data_0) - datapath read port 0
//   Port 1 (r_addr_1 / r_data_1) - datapath read port 1
//   Port 2 (r_addr_2 / r_data_2) - reserved for the testbench debug probe
//
// Unlike Memory, this module DOES clear on reset: the tests assume every
// register starts at zero when a program image begins executing.
//
// NOTE: the storage array must stay named `rfile` -- PUnC.t.v reaches into it
// by hierarchical path (punc.dpath.rfile.rfile[i]) to dump waveforms.
//==============================================================================

module RegisterFile(
	input  wire        clk,      // Clock
	input  wire        rst,      // Reset

	input  wire [2:0]  r_addr_0, // Read address 0
	input  wire [2:0]  r_addr_1, // Read address 1
	input  wire [2:0]  r_addr_2, // Read address 2 (debug)

	input  wire [2:0]  w_addr,   // Write address
	input  wire [15:0] w_data,   // Write data
	input  wire        w_en,     // Write enable

	output wire [15:0] r_data_0, // Read data 0
	output wire [15:0] r_data_1, // Read data 1
	output wire [15:0] r_data_2  // Read data 2 (debug)
);

	// 8 registers (R0 - R7) of 16 bits each
	reg [15:0] rfile [7:0];

	// Asynchronous (combinational) reads
	assign r_data_0 = rfile[r_addr_0];
	assign r_data_1 = rfile[r_addr_1];
	assign r_data_2 = rfile[r_addr_2];

	// Synchronous write, synchronous reset
	integer i;
	always @(posedge clk) begin
		if (rst) begin
			for (i = 0; i < 8; i = i + 1) begin
				rfile[i] <= 16'd0;
			end
		end
		else if (w_en) begin
			rfile[w_addr] <= w_data;
		end
	end

endmodule
