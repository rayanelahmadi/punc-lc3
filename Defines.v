//==============================================================================
// Global Defines for PUnC LC3 Computer
//==============================================================================

// Add defines here that you'll use in both the datapath and the controller

//------------------------------------------------------------------------------
// Opcodes
//------------------------------------------------------------------------------
`define OC 15:12       // Used to select opcode bits from the IR

`define OC_ADD 4'b0001 // Instruction-specific opcodes
`define OC_AND 4'b0101
`define OC_BR  4'b0000
`define OC_JMP 4'b1100
`define OC_JSR 4'b0100
`define OC_LD  4'b0010
`define OC_LDI 4'b1010
`define OC_LDR 4'b0110
`define OC_LEA 4'b1110
`define OC_NOT 4'b1001
`define OC_ST  4'b0011
`define OC_STI 4'b1011
`define OC_STR 4'b0111
`define OC_HLT 4'b1111

`define IMM_BIT_NUM 5  // Bit for distinguishing ADDR/ADDI and ANDR/ANDI
`define IS_IMM 1'b1
`define JSR_BIT_NUM 11 // Bit for distinguishing JSR/JSRR
`define IS_JSR 1'b1

`define BR_N 11        // Location of special bits in BR instruction
`define BR_Z 10
`define BR_P 9

`define RF_W_data_PC 2'd0
`define RF_W_data_r_data_0 2'd1
`define RF_W_data_adder_out 2'd2
`define RF_W_data_alu_out 2'd3

`define RF_W_addr_r7 2'd0
`define RF_W_addr_dr 2'd1

`define RF_r_addr_0_r7 2'd0
`define RF_r_addr_0_bits678sr1 2'd1
`define RF_r_addr_0_bits91011sr 2'd2

`define RF_r_addr_1_SR2 2'd0
`define RF_r_addr_1_bits678BaseR 2'd1

`define MEM_r_addr_0_ADDER_OUT 2'd0
`define MEM_r_addr_0_R_Data_0 2'd1
`define MEM_r_addr_0_PC 2'd2
`define MEM_r_addr_0_ALU_OUT 2'd3

`define MEM_w_addr_ADDER_OUT 2'd0
`define MEM_w_addr_R_Data_0 2'd1

//`define MEM_W_data ??

//`define 21_s0 16'd0

`define COMP_Inp2_adder_out 2'd0
`define COMP_Inp2_alu_out 2'd1

//`define SEXT_PCoffset9 2'd0
//`define SEXT_imm5 2'd1
//`define SEXT_PCoffset11 2'd2
//`define SEXT_offset6 2'd3

`define ADDER_Inp1_PCoffset9 2'd0
`define ADDER_Inp1_ONE 2'd1
`define ADDER_Inp1_PCoffset11 2'd2
`define ADDER_Inp1_offset6 2'd3
// ADDER_Inp2_s0
`define ADDER_Inp2_PC 2'd0
`define ADDER_Inp2_R_data_0 2'd1
`define ADDER_Inp2_R_data_1 2'd2
// ALU_s1 and ALU_s0
`define ALU_Command_ADD_IMM5 3'd0
`define ALU_Command_ADD_R_DATA 3'd1
`define ALU_Command_AND_IMM5 3'd2
`define ALU_Command_AND_R_DATA 3'd3
`define ALU_Command_NOT 3'd4
`define ALU_Command_PASS_THROUGH 3'd5
// ALU_inp2_s0
`define ALU_inp2_r_data_1 2'd0
`define ALU_inp2_imm5 2'd1

//
`define DR 11:9
`define SR   11:9

`define SR1   8:6
`define BaseR   8:6
`define SR_NOT   8:6

`define PCoffset11   10:0

`define PCoffset9   8:0

`define imm5   4:0
`define offset6   5:0

`define SR2   2:0

`define n   11
`define bit11  11

`define z   10
`define p   9

`define bit5  5

`define PC_w_data_r7 2'd0
`define PC_w_data_baseR 2'd1
`define PC_w_data_adderout 2'd2
















