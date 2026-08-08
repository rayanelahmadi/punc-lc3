//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // 
	input [15:0]           ir,
	input wire [15:0] pc_w_data,
	input wire canWeLoad,
	//input wire [15:0] MEM_r_addr_0,

	// OUR INPUTS
	output reg PC_ld, 
	output reg PC_clr,
	output reg PC_inc,
	output reg [1:0] PC_w_data_sel,

	//input wire PC_w_data_s0,
	output reg IR_ld,

	
	output reg MEM_w_en,
	output reg [1:0] MEM_r_addr_0_sel,
	output reg [15:0] MEM_r_addr_1,
	output reg MEM_w_addr_sel,
	//input wire [15:0] MEM_w_data,
	//output reg [15:0] MEM_r_data_0,
	output reg [15:0] MEM_r_data_1,

	
	output reg RF_w_en, 
	output reg [1:0] RF_w_data_sel, 
	//input wire RF_w_data_s0,
	output reg RF_w_addr_sel,
	output reg [1:0] RF_r_addr_0_sel,
	output reg [1:0] RF_r_addr_1_sel,
	//input wire RF_r_addr_0_s0,
	//input wire[15:0] RF_r_addr_1,
	//input wire[15:0] RF_r_addr_2,
	//output reg [2:0] RF_r_addr_0,
	//output reg [2:0] RF_r_addr_1,
	//output reg [15:0] RF_r_data_0,
	//output reg [15:0] RF_r_data_1,
	//output reg [15:0] RF_W_data,
	//output reg [2:0] RF_w_addr,


	//input wire SEXT_s0,
	//input wire SEXT_s1,

	output reg ALU_inp2_sel, 
	output reg [2:0] ALU_sel,
	//output reg [15:0] alu_input1,
	//output reg [15:0] alu_input2,
	//output reg [15:0] alu_out,
	//input wire ALU_s0,

	output reg [1:0] ADDER_Inp1_sel,
	//input wire ADDER_Inp1_s0,
	output reg ADDER_Inp2_sel,

	output reg [1:0] COMP_Inp2_sel
	

	// Add more ports here

);

	// FSM States
	// Add your FSM State values as localparams here
	// localparam STATE_FETCH     = X'd0;
	localparam STATE_INIT      = 5'd0;
	localparam STATE_FETCH     = 5'd1;
	localparam STATE_DECODE    = 5'd2;
	//localparam STATE_ADD_SR2     = 5'd3;
	//localparam STATE_ADD_imm5    = 5'd4;
	//localparam STATE_AND_SR2      = 5'd5;
	//localparam STATE_BRND_imm5     = 5'd6;
	//localparam STATE_BR      = 5'd7;
	//localparam STATE_JMP      = 5'd8;
	//localparam STATE_JMPJSRR      = 5'd9; part of execute_I
	//localparam STATE_JSR      = 5'd10; part of execute_I
	//localparam STATE_JSRR      = 5'd11;
	//localparam STATE_LD      = 5'd12;
	//localparam STATE_LDI_1      = 5'd13;
	//localparam STATE_LDI_2      = 5'd14; part of execute_I
	//localparam STATE_LDR      = 5'd15;
	//localparam STATE_LEA      = 5'd16;
	//localparam STATE_NOT      = 5'd17;
	// localparam STATE_RET      = 5'd18; part of jmp
	//localparam STATE_ST      = 5'd19;
	//localparam STATE_STI      = 5'd20;
	//localparam STATE_STR      = 5'd21;
	localparam STATE_HALT      = 5'd22;
	localparam STATE_EXECUTE = 5'd23;
	localparam STATE_EXECUTE_I = 5'd24;
	//wire [15:0] MEM_w_data;
	//reg [15:0] tempVar;

	

	// State, Next State
	// reg [X:0] state, next_state;
	
	reg [4:0] state, next_state;
	

	

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		PC_ld = 1'd0;
		PC_clr = 1'd0;
		PC_inc = 1'd0;
		PC_w_data_sel = 2'd0;// 2 bits
		
		IR_ld = 1'd0;

		MEM_w_en = 1'd0;
		MEM_r_addr_0_sel = 1'd0;
		MEM_r_addr_1 = 16'd0;// 16 bits
		MEM_w_addr_sel = 1'd0;
		//MEM_r_data_0 = 16'd0;// 16 bits
		MEM_r_data_1 = 16'd0;// 16 bits
		
		RF_w_en = 1'd0;
		RF_w_data_sel = 2'd0;// 2bits
		RF_w_addr_sel = 1'd0;
		RF_r_addr_0_sel = 2'd0;// 2bits
		RF_r_addr_1_sel = 2'd0;
		
		//ALU_inp2_sel = 1'd0;
		ALU_sel = 3'd7;// 2bits

		ADDER_Inp1_sel = 2'd0;// 2 bits
		ADDER_Inp2_sel = 1'd0;

		COMP_Inp2_sel = 2'd3;


		case (state)
         STATE_INIT: begin
            PC_clr     = 1'd1;
         end
         STATE_FETCH: begin
			MEM_r_addr_0_sel = `MEM_r_addr_0_PC;
			IR_ld      = 1'd1;
            PC_inc     = 1'd1; // NOTE: In PUnC, this happens after Fetch AND Decode
         end
         STATE_DECODE: begin
		 end
		 STATE_EXECUTE: begin
				//$display("HERE1");

            	case (ir[`OC])
					`OC_ADD : begin
						if (ir[`IMM_BIT_NUM] == 0) begin
							// adding two registers
							//$display("HERE?");

							//RF_r_addr_0_s1 = 0;
							//RF_r_addr_0_s0 = 1;
							RF_r_addr_0_sel = `RF_r_addr_0_bits678sr1;
							RF_r_addr_1_sel = `RF_r_addr_1_SR2;
							ALU_sel = `ALU_Command_ADD_R_DATA;

							//ALU_inp2_sel = `ALU_inp2_r_data_1;
							COMP_Inp2_sel = `COMP_Inp2_alu_out;
							RF_w_addr_sel = `RF_W_addr_dr;
							RF_w_data_sel = `RF_W_data_alu_out;
							RF_w_en = 1;

						end
						else begin
							// adding IMMD
							//$display("HERasdE?");

							//RF_r_addr_0_s1 = 0;
							//RF_r_addr_0_s0 = 1;
							RF_r_addr_0_sel = `RF_r_addr_0_bits678sr1;
							//ALU_inp2_sel = `ALU_inp2_imm5;

							ALU_sel = `ALU_Command_ADD_IMM5;
							COMP_Inp2_sel = `COMP_Inp2_alu_out;
							RF_w_addr_sel = `RF_W_addr_dr;
							RF_w_data_sel = `RF_W_data_alu_out;
							RF_w_en = 1;

						end
					end
					`OC_AND : begin
						if (ir[`IMM_BIT_NUM] == 0) begin
							//RF_r_addr_0_s1 = 0;
							//RF_r_addr_0_s0 = 1;
							RF_r_addr_0_sel = 1;
							RF_r_addr_1_sel = `RF_r_addr_1_SR2;
							//RF_r_addr_1 = 1;
							ALU_inp2_sel = 0;
							ALU_sel = `ALU_Command_AND_R_DATA;
							COMP_Inp2_sel = `COMP_Inp2_alu_out;

							RF_w_addr_sel = `RF_W_addr_dr;
							RF_w_data_sel = `RF_W_data_alu_out;
							RF_w_en = 1;


						end
						else begin
							//RF_r_addr_0_s1 = 0;
							//RF_r_addr_0_s0 = 1;
							RF_r_addr_0_sel = 1;
							ALU_inp2_sel = 1;
							ALU_sel = `ALU_Command_AND_IMM5;
							COMP_Inp2_sel = `COMP_Inp2_alu_out;

							RF_w_addr_sel = `RF_W_addr_dr;
							RF_w_data_sel = `RF_W_data_alu_out;
							RF_w_en = 1;

						end
						
					end
					`OC_BR : begin
						if (canWeLoad) begin
							
							PC_w_data_sel = `PC_w_data_adderout;
							ADDER_Inp1_sel = `ADDER_Inp1_PCoffset9;
							ADDER_Inp2_sel = `ADDER_Inp2_PC;
							PC_ld = 1; // PC = 
						end
						
					end
					`OC_JMP : begin
						// CASE FOR RET, CASE FOR JMP
						if (ir[`SR1] == 3'd7) begin // ret case
							PC_w_data_sel = `PC_w_data_r7;
							RF_r_addr_0_sel = `RF_r_addr_0_r7;
							PC_ld = 1;
							
						end
						else  begin
						// jmp case

							PC_w_data_sel = `PC_w_data_baseR;
							
							RF_r_addr_0_sel = `RF_r_addr_0_bits678sr1;
							PC_ld = 1;
							
						end
					end
					`OC_JSR : begin
						// only do first column -> JSR/JSRR R7 = PC
						RF_w_en = 1;
						RF_w_data_sel = 0;
						RF_w_addr_sel = 0;
					end
					`OC_LD : begin
						MEM_r_addr_0_sel = `MEM_r_addr_0_ADDER_OUT; //g 
						
						ADDER_Inp1_sel = `ADDER_Inp1_PCoffset9; // g pcoffset9
						ADDER_Inp2_sel = `ADDER_Inp2_PC; // g pc
						COMP_Inp2_sel = `COMP_Inp2_adder_out;

						RF_w_en = 1;  //g
						RF_w_addr_sel = `RF_W_addr_dr; // g
						RF_w_data_sel = `RF_W_data_r_data_0;
						//RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr;
					end
					`OC_LDI : begin
						// only do first column ->  LDI Phase1
						MEM_r_addr_0_sel = `MEM_r_addr_0_ADDER_OUT;
						ADDER_Inp1_sel = `ADDER_Inp1_PCoffset9;
						ADDER_Inp2_sel = `ADDER_Inp2_PC;

						//RF_w_data_sel = `
						//tempVar = MEM_r_addr_0;
						RF_w_en = 1;  //g
						RF_w_addr_sel = `RF_W_addr_dr; // g
						RF_w_data_sel = `RF_W_data_r_data_0;
						COMP_Inp2_sel = `COMP_Inp2_adder_out;
						//RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr;


					end
					`OC_LDR : begin
						ADDER_Inp1_sel = `ADDER_Inp1_offset6;
						ADDER_Inp2_sel = `ADDER_Inp2_R_data_0;
						MEM_r_addr_0_sel = `MEM_r_addr_0_ADDER_OUT;

						RF_w_en = 1;
						RF_r_addr_0_sel = `RF_r_addr_0_bits678sr1; // Baser
						// RF_r_data_1?
						RF_w_addr_sel = `RF_W_addr_dr;
						RF_w_data_sel = `RF_W_data_r_data_0;
						COMP_Inp2_sel = `COMP_Inp2_adder_out;
						//RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr;

					end
					`OC_LEA : begin
						RF_w_en = 1;
						RF_w_addr_sel = 1;
						ADDER_Inp1_sel = 0;
						ADDER_Inp2_sel = 0;
						RF_w_data_sel = `RF_W_data_adder_out;
						COMP_Inp2_sel = `COMP_Inp2_adder_out;
						//RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr;

					end
					`OC_NOT : begin
						RF_w_en = 1;
						RF_w_data_sel = 3;
						RF_w_addr_sel = 1;
						RF_r_addr_0_sel = 1;
						ALU_sel = `ALU_Command_NOT;
						//COMP_Inp2_sel = `COMP_Inp2_adder_out;
					end
					`OC_ST : begin
						MEM_w_en = 1;
						MEM_w_addr_sel = `MEM_w_addr_ADDER_OUT;
						ADDER_Inp1_sel = `ADDER_Inp1_PCoffset9;
						ADDER_Inp2_sel = `ADDER_Inp2_PC;
						RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr;
						//ALU_sel = `ALU_Command_PASS_THROUGH;
						
						//MEM_w_data_sel = sr by default
					end
					`OC_STI : begin
						MEM_w_en = 1;
						MEM_w_addr_sel = 1;
						ADDER_Inp1_sel = 0;
						ADDER_Inp2_sel =0;
						RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr;
						RF_r_addr_1_sel =  `RF_r_addr_1_bits678BaseR;
					end
					`OC_STR : begin
						MEM_w_en = 1;
						MEM_w_addr_sel = `MEM_w_addr_ADDER_OUT;
						ADDER_Inp1_sel = `ADDER_Inp1_offset6;
						ADDER_Inp2_sel = `ADDER_Inp2_R_data_1;
						RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr; // RF_r_addr_0_bits678sr1
						RF_r_addr_1_sel = `RF_r_addr_1_bits678BaseR;
					end
					`OC_HLT : begin
						IR_ld = 0;
						PC_ld = 0;
						PC_inc = 0;
						// nothing needed for halt?
						//$display("HALT MYT BRUH");
					end
					default: begin

              		end
				endcase
         end
		  STATE_EXECUTE_I: begin
			//$display("EXECUTING SECOND.");

           case (ir[`OC])
               `OC_JSR: begin
                  // JSR vs JSRR if statement part logic
				  if (ir[`bit11] == 0) begin
					//PC = baseR; JSRR
					PC_ld = 1;
					PC_w_data_sel = 1;
				  end
				  else begin
					// JSR 
					PC_ld = 1;
					PC_w_data_sel = 2;
					ADDER_Inp1_sel = 2;
					ADDER_Inp2_sel = 0;
				  end
               end
			   `OC_LDI: begin
					//MEM_r_addr_0 = tempVar
					MEM_r_addr_0_sel = `MEM_r_addr_0_ALU_OUT;
					RF_r_addr_0_sel = `RF_r_addr_0_bits91011sr;
					ALU_sel = `ALU_Command_PASS_THROUGH;
					RF_w_en = 1;
					RF_w_addr_sel = `RF_W_addr_dr;
					RF_w_data_sel = `RF_W_data_r_data_0;
			   end
            endcase
         end
         STATE_HALT: begin
         end
         default: begin

         end
		endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = state;

		// Add your next-state logic here
		case (state)
         STATE_INIT: begin
            next_state = STATE_FETCH;
         end
		  STATE_FETCH: begin
            next_state = STATE_DECODE;
         end
         STATE_DECODE: begin
			if (ir[`OC] == `OC_HLT) begin
				next_state = STATE_HALT;
			end
            next_state = STATE_EXECUTE;
			//$display("decoding.");

         end
         STATE_EXECUTE: begin
			$display("ExecuteInstruction: %h", ir);
			if (ir[`OC] == `OC_JSR) begin // JMPZ for them..
				next_state = STATE_EXECUTE_I;
            end
            else if (ir[`OC] == `OC_LDI) begin
				next_state = STATE_EXECUTE_I;
			end
			else if (ir[`OC] == `OC_HLT) begin
				next_state = STATE_HALT;
			end
			else begin
               next_state = STATE_FETCH;
			   //$display("ONTO DA NEXT");
            end
         end
         STATE_EXECUTE_I: begin
            next_state = STATE_FETCH;
			if (ir[`OC] == `OC_HLT) begin
				next_state = STATE_HALT;
			end
         end
		 STATE_HALT: begin
            next_state = STATE_HALT;
         end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		 if (rst) begin
         state <= STATE_INIT;
      end
      else begin
         state <= next_state;
      end
	end

endmodule
