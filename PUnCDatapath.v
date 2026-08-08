//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

//`define RF_W_data_PC 2'd0 


module PUnCDatapath(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// OUR INPUTS
	input wire PC_ld, 
	input wire PC_clr,
	input wire PC_inc,
	input wire [1:0] PC_w_data_sel,
	//input wire PC_w_data_s0,
	input wire IR_ld,

	
	input wire MEM_w_en,
	input wire [1:0] MEM_r_addr_0_sel,
	input wire [15:0] MEM_r_addr_1,
	input wire MEM_w_addr_sel,
	//output wire [15:0] MEM_w_data,
	input wire [15:0] MEM_r_data_1,

	
	input wire RF_w_en, 
	input wire [1:0] RF_w_data_sel, 
	//input wire RF_w_data_s0,
	input wire RF_w_addr_sel,
	input wire [1:0] RF_r_addr_0_sel,
	input wire [1:0] RF_r_addr_1_sel,
	//input wire RF_r_addr_0_s0,
	//input wire[15:0] RF_r_addr_1,
	//input wire[15:0] RF_r_addr_2,

	//input wire SEXT_s0,
	//input wire SEXT_s1,

	//input wire ALU_inp2_sel, 
	input wire [2:0] ALU_sel,
	//input wire ALU_s0,

	input wire [1:0] ADDER_Inp1_sel,
	//input wire ADDER_Inp1_s0,
	input wire ADDER_Inp2_sel,

	input wire [1:0] COMP_Inp2_sel,
	output reg tempVar,

	//input wire [2:0] RF_r_addr_0,
	
	
	

	
	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	
	output wire canWeLoad,
	output reg [15:0] ir,
	output wire [15:0] pc_w_data,

	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data



	// OUR OUTPUTS -> no outputs necessary?

);

	// Local Registers
	reg  [15:0] pc;
	//reg  [15:0] ir;

	// Declare other local wires and registers here
	
	// RF Read/Write Channels
	wire [2:0] RF_r_addr_0;
	/*wire [2:0] RF_r_addr_0;
	wire [2:0] RF_r_addr_1;
	wire [15:0] RF_r_data_0;
	wire [15:0] RF_r_data_1;
	wire [15:0] RF_W_data;
	wire [2:0] RF_w_addr;*/
	wire [2:0] RF_r_addr_1;
	wire [15:0] RF_r_data_0;
	wire [15:0] RF_r_data_1;
	wire [15:0] RF_W_data;
	wire [2:0] RF_w_addr;






	// Memory Read/Write Channels
	wire [15:0] MEM_r_data_0;

	wire [15:0] MEM_r_addr_0;
	wire [15:0] MEM_w_addr;
	wire [15:0] MEM_w_data;


	//wire [15:0] MEM_r_data_0;


	// Adder Input/Output Wires
	wire [15:0] adder_input1;
	wire [15:0] adder_input2;
	wire [15:0] adder_out;


	// ALU Input/Output Wires
	/*wire [15:0] alu_input1;
	wire [15:0] alu_input2;
	wire [15:0] alu_out;*/
	wire [15:0] alu_out;
	//wire [15:0] alu_input1;
	//wire [15:0] alu_input2;


	// Comparator Input/Output Wires
	wire [15:0] COMP_Inp2;
	//wire [15:0] COMP_Inp1;

	// n, z, p flags
	reg neg;
	reg zer;
	reg pos;



	//reg tempSelectBit;


	// Assign PC debug net
	/*always @(*) begin
		$display("MEMDATA %h", MEM_r_data_0);
	end*/


	assign pc_debug_data = pc; //dont touch

	

	//----------------------------------------------------------------------
	// Instruction Register
	//----------------------------------------------------------------------

	always @(posedge clk) begin
		if (rst) begin
			ir <= 16'd0;
		end
		else if (IR_ld) begin
			ir <= MEM_r_data_0;
			//$display("INS %h", MEM_r_data_0);
		end
	end


	//----------------------------------------------------------------------
	// Program Counter
	//----------------------------------------------------------------------

	always @(posedge clk) begin
		if (PC_clr) begin
			pc <= 16'd0;
		end
		else if (PC_ld) begin
			
			// we have different offsets for pc -> conditional?
			pc <= pc_w_data;
		end
		else if (PC_inc) begin
			pc <= pc + 16'd1;
		end
   	end

	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// 1024-entry 16-bit memory (connect other ports)
	Memory mem(
		.clk      (clk),//dont touch
		.rst      (rst),//dont touch
		.r_addr_0 (MEM_r_addr_0),
		.r_addr_1 (mem_debug_addr), //dont touch
		.w_addr   (MEM_w_addr),
		.w_data   (MEM_w_data),
		.w_en     (MEM_w_en),
		.r_data_0 (MEM_r_data_0),
		.r_data_1 (mem_debug_data)//dont touch
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile rfile(
		.clk      (clk),//dont touch
		.rst      (rst),//dont touch
		.r_addr_0 (RF_r_addr_0),
		.r_addr_1 (RF_r_addr_1),
		.r_addr_2 (rf_debug_addr),//dont touch
		.w_addr   (RF_w_addr),
		.w_data   (RF_W_data),
		.w_en     (RF_w_en),
		.r_data_0 (RF_r_data_0),
		.r_data_1 (RF_r_data_1),
		.r_data_2 (rf_debug_data)//dont touch
	);

	//----------------------------------------------------------------------
	// Add all other datapath logic here
	//----------------------------------------------------------------------
	// always @( * ) begin
	
	assign RF_W_data =  (RF_w_data_sel == `RF_W_data_PC) ? pc :
						(RF_w_data_sel == `RF_W_data_r_data_0) ? MEM_r_data_0 :
						(RF_w_data_sel == `RF_W_data_adder_out) ? adder_out :
						(RF_w_data_sel == `RF_W_data_alu_out) ? alu_out : 16'd0;
	
	assign RF_w_addr =  (RF_w_addr_sel == `RF_W_addr_r7) ? 3'b111 :
						(RF_w_addr_sel == `RF_W_addr_dr) ? ir[`DR] : 3'd0;

	assign RF_r_addr_0 = (RF_r_addr_0_sel == `RF_r_addr_0_r7) ? 3'b111 :
						 (RF_r_addr_0_sel == `RF_r_addr_0_bits678sr1) ? ir[`SR1] :
						  (RF_r_addr_0_sel == `RF_r_addr_0_bits91011sr) ? ir[`SR] : 3'd0;
		
	//always @(*) begin
		//$display("RF_R_ADDR_0 %d", RF_r_addr_0);
		//$display("RF_R_ADDR_1 %d", RF_r_addr_1);
		//$display("RF_W_ADDR %d", RF_w_addr);

	//endi
	assign RF_r_addr_1 = (RF_r_addr_1_sel == `RF_r_addr_1_SR2) ? ir[`SR2] :
						 (RF_r_addr_1_sel == `RF_r_addr_1_bits678BaseR) ? ir[`BaseR] : 3'd0;

	//(ir[`SR2]); // may need mux here

	assign MEM_r_addr_0 = (MEM_r_addr_0_sel == `MEM_r_addr_0_ADDER_OUT) ? adder_out :
						  (MEM_r_addr_0_sel == `MEM_r_addr_0_R_Data_0) ? MEM_r_data_0 : 
						  (MEM_r_addr_0_sel == `MEM_r_addr_0_PC) ? pc : 
						  (MEM_r_addr_0_sel == `MEM_r_addr_0_ALU_OUT) ? alu_out :16'd0;

	assign MEM_w_addr = (MEM_w_addr_sel == `MEM_w_addr_ADDER_OUT) ? adder_out :
						(MEM_w_addr_sel == `MEM_w_addr_R_Data_0) ? MEM_r_data_0 : 16'd0;

	//----------------------------------------------------------------------
	// Comparator
	//----------------------------------------------------------------------
	assign COMP_Inp2 = (COMP_Inp2_sel == `COMP_Inp2_adder_out) ? MEM_r_data_0 :
						(COMP_Inp2_sel == `COMP_Inp2_alu_out) ? alu_out : 16'd0;

	//assign COMP_Inp1 = 16'd0;

	assign pc_w_data = (PC_w_data_sel == `PC_w_data_r7) ? RF_r_data_0:
						(PC_w_data_sel == `PC_w_data_baseR) ? RF_r_data_0 :
						(PC_w_data_sel == `PC_w_data_adderout) ? adder_out : 16'd0;

	//assign comp_out = // CAREFUL WITH SIGNED VS UNSIGNED...



	//----------------------------------------------------------------------
	// Adder
	//----------------------------------------------------------------------

	assign adder_input1 = (ADDER_Inp1_sel == `ADDER_Inp1_PCoffset9) ? {{7{ir[8]}}, ir[`PCoffset9]} :
							(ADDER_Inp1_sel == `ADDER_Inp1_ONE) ? 16'd1 :
							(ADDER_Inp1_sel == `ADDER_Inp1_PCoffset11) ? {{5{ir[10]}}, ir[`PCoffset11]} : // SIGN EXTEND HERE!
							(ADDER_Inp1_sel == `ADDER_Inp1_offset6) ? {{10{ir[5]}}, ir[`offset6]} : 16'd0; // SIGN EXTEND HERE!

	
	assign adder_input2 = (ADDER_Inp2_sel == `ADDER_Inp2_PC) ? pc : 
							(ADDER_Inp2_sel == `ADDER_Inp2_R_data_0) ? RF_r_data_0 :
							(ADDER_Inp2_sel == `ADDER_Inp2_R_data_1) ? RF_r_data_1 : 16'd0;
	// rf_r_data_0
	assign adder_out = adder_input1 + adder_input2;
	
	
	//----------------------------------------------------------------------
	// ALU
	//----------------------------------------------------------------------

	//assign alu_input1 = RF_r_data_0;
	//$display("GOT %d", alu_input1);
	//assign alu_input2 = (ALU_inp2_sel == `ALU_inp2_r_data_1) ? RF_r_data_1 : 
	//					(ALU_inp2_sel == `ALU_inp2_imm5) ? {{11{ir[4]}}, ir[`imm5]} : 16'd0; // SIGN EXTEND HERE!

	
	
	//assign comp_out // BE CAREFUL WITH UNSIGNED AND SIGNED HERE

	// subtract and store into temp variable

	// check if zero first

	// check negative by checking MSB bc two's complement

	// check positive 
	
	
	//assign canWeLoad = 1;
	always @(COMP_Inp2_sel) begin
		zer = 0;
		neg = 0;
		pos = 0;
		if (COMP_Inp2 == 16'd0) begin // comp_out
			 zer = 1;
			 neg = 0;
			 pos = 0;
		end 
		else if (COMP_Inp2[15] == 1) begin
			 neg = 1;
			 zer = 0;
			 pos = 0;

		end else if (COMP_Inp2[15] == 0 && COMP_Inp2 != 16'd0) begin
			 pos = 1;
			 neg = 0;
			 zer = 0;

		end
		
	end
	/*always @(*) begin
		$display ("NEG: %d", neg);
		$display ("POS: %d", pos);
		$display ("ZER: %d", zer);
	end*/
	// assign pc_ld and or logic

	assign canWeLoad = (neg & ir[`BR_N]) | (pos & ir[`BR_P]) | (zer & ir[`BR_Z]);

	//end
	assign MEM_w_data = RF_r_data_0; // dereference ir['SR]

	assign alu_out = (ALU_sel == `ALU_Command_ADD_IMM5) ? (RF_r_data_0 + {{11{ir[4]}}, ir[`imm5]}) :  
					(ALU_sel == `ALU_Command_ADD_R_DATA) ? (RF_r_data_0 + RF_r_data_1) :
					(ALU_sel == `ALU_Command_AND_IMM5) ? (RF_r_data_0 & {{11{ir[4]}}, ir[`imm5]}) : // BITWISE operator.
					(ALU_sel == `ALU_Command_AND_R_DATA) ? (RF_r_data_0 & RF_r_data_1) : // BITWISE operator.
					(ALU_sel == `ALU_Command_NOT) ? ~RF_r_data_0 :
					(ALU_sel == `ALU_Command_PASS_THROUGH) ? RF_r_data_0 : 16'd0;
	
	/*always @(*) begin
		$display("ALU_OUT %d WITH %d", alu_out, ALU_sel);
	end*/
	
endmodule
