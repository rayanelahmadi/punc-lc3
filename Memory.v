//==============================================================================
// Memory Module for PUnC LC3 Processor
//
// 1024-entry, 16-bit wide memory with two asynchronous read ports and one
// synchronous write port.
//
//   Port 0 (r_addr_0 / r_data_0) - used by the datapath
//   Port 1 (r_addr_1 / r_data_1) - reserved for the testbench debug probe
//
// NOTE: `rst` deliberately does NOT clear the memory array. The testbench
// loads a program image with $readmemh *before* pulsing reset, so wiping the
// array here would erase the program before it ever executes. The port is
// kept for interface compatibility.
//
// NOTE: the storage array must stay named `mem` -- PUnC.t.v reaches into it
// by hierarchical path (punc.dpath.mem.mem[i]) to load images and to dump
// waveforms.
//==============================================================================

module Memory(
	input  wire        clk,      // Clock
	input  wire        rst,      // Reset (intentionally unused, see above)

	input  wire [15:0] r_addr_0, // Read address 0
	input  wire [15:0] r_addr_1, // Read address 1 (debug)
	input  wire [15:0] w_addr,   // Write address

	input  wire [15:0] w_data,   // Write data
	input  wire        w_en,     // Write enable

	output wire [15:0] r_data_0, // Read data 0
	output wire [15:0] r_data_1  // Read data 1 (debug)
);

	// 1024 entries of 16 bits each
	reg [15:0] mem [1023:0];

	// Asynchronous (combinational) reads.
	// Only the low 10 address bits are decoded, so accesses above 1023 wrap
	// rather than returning x.
	assign r_data_0 = mem[r_addr_0[9:0]];
	assign r_data_1 = mem[r_addr_1[9:0]];

	// Synchronous write
	always @(posedge clk) begin
		if (w_en) begin
			mem[w_addr[9:0]] <= w_data;
		end
	end

endmodule
