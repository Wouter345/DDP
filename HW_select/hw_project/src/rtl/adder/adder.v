`timescale 1ns / 1ps

module mpadder (
  input wire clk,
  input wire resetn,
  input wire start,
  input wire subtract,
  input wire [1026:0] in_a,
  input wire [1026:0] in_b,
  output wire [1027:0] result,
  output wire done
);

  wire [1026:0] MuxB = (subtract == 0) ? in_b : ~in_b;
  wire carry_in = subtract;



  wire [1027:0] Sum;
  wire carry[15:0];
  
  
  wire [63:0] operandA1;
  wire [63:0] operandB1;
  wire [63:0] Sum1;
  assign operandA1 = in_a[63:0];
  assign operandB1 = MuxB[63:0];
  
  assign {carry[0], Sum1} = operandA1 + operandB1 + carry_in;
  assign Sum[63:0] = Sum1;


  
  generate
    for (genvar i = 1; i < 15; i = i + 1) begin : adder_block
      wire [63:0] operandA;
      wire [63:0] operandB;
      wire [63:0] Sum_a;
      wire [63:0] Sum_b;
      wire carry_a;
      wire carry_b;

      assign operandA = in_a[63+64*i : 64*i];
      assign operandB = MuxB[63+64*i : 64*i];
      assign {carry_a, Sum_a} = operandA + operandB;
      assign {carry_b, Sum_b} = operandA + operandB + 1'b1;

      assign Sum[63+64*i : 64*i] = (carry[i-1]) ? Sum_b : Sum_a;
      assign carry[i] = (carry[i-1]) ? carry_b : carry_a;
    end
  endgenerate
  
    
    wire [67:0] operandA16;
    wire [67:0] operandB16;
    wire [68:0] Sum16a;
    wire [68:0] Sum16b;
    assign operandA16 = in_a[1026:960];
    assign operandB16 = MuxB[1026:960];
    assign Sum16a = operandA16 + operandB16;
    assign Sum16b = operandA16 + operandB16 + 1'b1;
    assign Sum[1027:960] = (carry[14]) ? Sum16b : Sum16a;
  

  reg [1027:0] regSum;
  always @(posedge clk or negedge resetn) begin
    if (~resetn)
      regSum <= 1028'b0;
    else if (start)
      regSum <= Sum;
  end

  wire carry_out = subtract ^ regSum[1027];
  assign result = {carry_out, regSum[1026:0]};

  reg regDone;
  always @(posedge clk or negedge resetn) begin
    if (~resetn)
      regDone <= 1'b0;
    else if (start)
      regDone <= 1'b1;
    else
      regDone <= 1'b0;
  end

  assign done = regDone;

endmodule
