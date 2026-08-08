//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here
	wire PC_ld;
	wire PC_clr;
	wire PC_inc;
	wire [1:0] PC_w_data_sel;
	wire [15:0] pc_w_data;
	//input wire PC_w_data_s0,
	wire IR_ld;
	wire [15:0] instruction;

	
	wire MEM_w_en;
	wire [1:0] MEM_r_addr_0_sel;
	wire [15:0] MEM_r_addr_1;
	wire MEM_w_addr_sel;
	//input wire [15:0] MEM_w_data,
	wire [15:0] MEM_r_data_0;
	wire [15:0] MEM_r_data_1;

	
	wire RF_w_en;
	wire [1:0] RF_w_data_sel;
	//input wire RF_w_data_s0,
	wire RF_w_addr_sel;
	wire [1:0] RF_r_addr_0_sel;
	wire [1:0] RF_r_addr_1_sel;

	//input wire RF_r_addr_0_s0,
	//input wire[15:0] RF_r_addr_1,
	//input wire[15:0] RF_r_addr_2,

	//input wire SEXT_s0,
	//input wire SEXT_s1,

	//wire ALU_inp2_sel;
	wire [2:0] ALU_sel;
	//input wire ALU_s0,

	wire [1:0] ADDER_Inp1_sel;
	//input wire ADDER_Inp1_s0,
	wire ADDER_Inp2_sel;

	wire [1:0] COMP_Inp2_sel;

	wire [2:0] RF_r_addr_0;
	wire [2:0] RF_r_addr_1;
	wire [15:0] RF_r_data_0;
	wire [15:0] RF_r_data_1;
	wire [15:0] RF_W_data;
	wire [2:0] RF_w_addr;

	wire [15:0] alu_input1;
	wire [15:0] alu_input2;
	wire [15:0] alu_out;

	wire canWeLoad;			


	

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),
		.canWeLoad(canWeLoad),
		.ir(instruction),

		.PC_ld(PC_ld),
		.PC_clr(PC_clr),
		.PC_inc(PC_inc),
		.PC_w_data_sel(PC_w_data_sel),
		.pc_w_data(pc_w_data),
		

		.IR_ld(IR_ld),

		.MEM_w_en(MEM_w_en),
		.MEM_r_addr_0_sel(MEM_r_addr_0_sel),
		.MEM_r_addr_1(MEM_r_addr_1),
		.MEM_w_addr_sel(MEM_w_addr_sel),
		//.MEM_r_data_0(MEM_r_data_0),
		.MEM_r_data_1(MEM_r_data_1),

		.RF_w_en(RF_w_en),
		.RF_w_data_sel(RF_w_data_sel),
		.RF_w_addr_sel(RF_w_addr_sel),
		.RF_r_addr_0_sel(RF_r_addr_0_sel),
		.RF_r_addr_1_sel(RF_r_addr_1_sel),

		//.RF_r_addr_0(RF_r_addr_0),
		//.RF_r_addr_1(RF_r_addr_1),
		//.RF_r_data_0(RF_r_data_0),
		//.RF_r_data_1(RF_r_data_1),
		//.RF_W_data(RF_W_data),
		//.RF_w_addr(RF_w_addr),

		//.ALU_inp2_sel(ALU_inp2_sel),
		.ALU_sel(ALU_sel),
		//.alu_input1(alu_input1),
		//.alu_input2(alu_input2),
		

		.ADDER_Inp1_sel(ADDER_Inp1_sel),
		.ADDER_Inp2_sel(ADDER_Inp2_sel),

		.COMP_Inp2_sel(COMP_Inp2_sel)

		

		// Add more ports here
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),
		.canWeLoad(canWeLoad),
		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		.PC_ld(PC_ld),
		.PC_clr(PC_clr),
		.PC_inc(PC_inc),
		.PC_w_data_sel(PC_w_data_sel),
		.pc_w_data(pc_w_data),
		.IR_ld(IR_ld),
 
		.MEM_w_en(MEM_w_en),
		.MEM_r_addr_0_sel(MEM_r_addr_0_sel),
		.MEM_r_addr_1(MEM_r_addr_1),
		.MEM_w_addr_sel(MEM_w_addr_sel),

		//.MEM_r_data_0(MEM_r_data_0),
		.MEM_r_data_1(MEM_r_data_1),

		.RF_w_en(RF_w_en),
		.RF_w_data_sel(RF_w_data_sel),
		.RF_w_addr_sel(RF_w_addr_sel),
		.RF_r_addr_0_sel(RF_r_addr_0_sel),
		.RF_r_addr_1_sel(RF_r_addr_1_sel),
		
		//.ALU_inp2_sel(ALU_inp2_sel),
		.ALU_sel(ALU_sel),

		.ADDER_Inp1_sel(ADDER_Inp1_sel),
		.ADDER_Inp2_sel(ADDER_Inp2_sel),

		.COMP_Inp2_sel(COMP_Inp2_sel),

		//.RF_r_addr_0(RF_r_addr_0),
		//.RF_r_addr_1(RF_r_addr_1),
		//.RF_r_data_0(RF_r_data_0),
		//.RF_r_data_1(RF_r_data_1),
		//.RF_W_data(RF_W_data),
		//.RF_w_addr(RF_w_addr),

		//.alu_input1(alu_input1),
		//.alu_input2(alu_input2),

		.ir(instruction)

		// Add more ports here
	);

endmodule
