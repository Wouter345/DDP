`timescale 1ns / 1ps

module montgomery(
  input           clk,
  input           resetn,
  input           start,
  input  [1023:0] in_a,
  input  [1023:0] in_b,
  input  [1023:0] in_m,
  output [1023:0] result,
  output          done
    );

  // Student tasks:
  // 1. Instantiate an Adder
  // 2. Use the Adder to implement the Montgomery multiplier in hardware.
  // 3. Use tb_montgomery.v to simulate your design.
  
  
  // Task 1
    // Describe a 1024-bit register for A
    // It will save the input data when enable signal is high

    reg          regA_en;
    wire [1023:0] regA_in;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 1024'd0;
        else if (regA_en)   regA_out <= regA_in;
    end
    
// Task 2
    // Describe a 1027-bit register for B

    reg          regB_en;
    wire [1023:0] regB_in;
    reg  [1023:0] regB_out;
    always @(posedge clk)
    begin
        if(~resetn)         regB_out <= 1024'd0;
        else if (regB_en)   regB_out <= regB_in;
    end
  
  // Task 3
    // Describe a 1024-bit register for M

    reg          regM_en;
    wire [1023:0] regM_in;
    reg  [1023:0] regM_out;
    always @(posedge clk)
    begin
        if(~resetn)         regM_out <= 1024'd0;
        else if (regM_en)   regM_out <= regM_in;
    end
    
  // Task 4
    // Describe a 1024 bit register for result
    reg          regC_en;
    wire [1027:0]regC_in;
    reg  [1027:0] regC_out;
    always @(posedge clk)
    begin
        if(~resetn)         regC_out <= 1028'd0;
        else if (regC_en)   regC_out <= regC_in;
    end
    
  // Task 5
    // Describe a 2-input 1024-bit Multiplexer for A
    // It should select either of these two:
    //   - the input A
    //   - the output of regA shifted-right by 1
    // Also connect the output of Mux to regA's input
    
    reg          muxA_sel;
    wire [1023:0] muxA_Out;
    assign muxA_Out = (muxA_sel == 0) ? in_a : {1'b0,regA_out[1023:1]};
    assign regA_in = muxA_Out;
   
   // Task 6
    // Describe a 2-input 1024-bit Multiplexer for B

    reg          muxB_sel;
    wire [1023:0] muxB_Out;
    assign muxB_Out = (muxB_sel == 0) ? in_b : {1'b0,regB_out[1023:1]};
    assign regB_in = muxB_Out;
    
    
   // Task 7 
     //If ai = 1 do C+B
    wire [0:0]    operandA;
    wire [1023:0] operandB;
    wire [1026:0] operandC;
    wire [1023:0] operandM;
    wire [1027:0] Sum;
    wire          done2;

     
    mpadder(clk,1'b0,1'b1,1'b0,operandC,{3'b0,muxInput2_Out},Sum,done2);
    
  // Task 8
    // design Multiplexer to choose between adder input B or M;
    reg           muxInput2_sel;
    wire [1023:0] muxInput2_Out;
    assign muxInput2_Out = (muxInput2_sel == 0) ? operandB : operandM;
    
  // Task 9
    // design Multixplexer to choose between C or C>>1  
    reg           muxC_sel;
    wire [1027:0] muxC_Out;
    assign muxC_Out = (muxC_sel == 0) ? Sum : Sum>>1;
    

    assign operandA = regA_out;
    assign operandB = regB_out;
    assign operandC = regC_out;
    assign operandM = regM_out;
    assign regC_in = muxC_Out;
    
    
    
  

endmodule
