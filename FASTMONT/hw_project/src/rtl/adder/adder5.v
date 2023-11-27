`timescale 1ns / 1ps

module mpadder5 (
  input wire clk,
  input wire subtract,
  input wire [1026:0] in_a,
  input wire [1026:0] in_b,
  input wire [1026:0] in_c,
  output wire [1027:0] result
);

    wire [1026:0] MuxB = (subtract) ? ~in_b : in_b;
    wire [1027:0] Sum;
    
    
    wire [1027:0] sumA;
    wire [1027:128] sumB;
    wire [1027:128] sumC;
    
    wire [13:0] carryA;
    wire [13:2] carryB;
    wire [13:2] carryC;
        
    assign {carryA[1:0],sumA[127:0]} = in_a[127:0] + MuxB[127:0] + in_c[127:0] + subtract;   
    add128b A2(in_a[255:128], MuxB[255:128], in_c[255:128], sumA[255:128], carryA[3:2], sumB[255:128], carryB[3:2], sumC[255:128], carryC[3:2]);
    add128b A3(in_a[383:256], MuxB[383:256], in_c[383:256], sumA[383:256], carryA[5:4], sumB[383:256], carryB[5:4], sumC[383:256], carryC[5:4]);
    add128b A4(in_a[511:384], MuxB[511:384], in_c[511:384], sumA[511:384], carryA[7:6], sumB[511:384], carryB[7:6], sumC[511:384], carryC[7:6]);
    add128b A5(in_a[639:512], MuxB[639:512], in_c[639:512], sumA[639:512], carryA[9:8], sumB[639:512], carryB[9:8], sumC[639:512], carryC[9:8]);
    add128b A6(in_a[767:640], MuxB[767:640], in_c[767:640], sumA[767:640], carryA[11:10], sumB[767:640], carryB[11:10], sumC[767:640], carryC[11:10]);
    add128b A7(in_a[895:768], MuxB[895:768], in_c[895:768], sumA[895:768], carryA[13:12], sumB[895:768], carryB[13:12], sumC[895:768], carryC[13:12]);
    add131b A8(in_a[1026:896], MuxB[1026:896], in_c[1026:896], sumA[1027:896], sumB[1027:896], sumC[1027:896]);
      
  
  reg [1027:0] regA;
  reg [1027:128] regB;
  reg [1027:128] regC;
  reg [13:0] regcA;
  reg [13:2] regcB;
  reg [13:2] regcC;
  reg sub;
  always @(posedge clk) 
  begin
    regA <= sumA;
    regB <= sumB;
    regC <= sumC;
    regcA <= carryA;
    regcB <= carryB;
    regcC <= carryC;
    sub <= subtract;
  end  
  
  wire [29:0] carry;
  
    assign carry[1:0] = regcA[1:0];
    assign carry[3:2] = carry[1]? (regcC[3:2]): (carry[0]? regcB[3:2]: regcA[3:2]);
    assign carry[5:4] = carry[3]? (regcC[5:4]): (carry[2]? regcB[5:4]: regcA[5:4]);
    assign carry[7:6] = carry[5]? (regcC[7:6]): (carry[4]? regcB[7:6]: regcA[7:6]);
    assign carry[9:8] = carry[7]? (regcC[9:8]): (carry[6]? regcB[9:8]: regcA[9:8]);
    assign carry[11:10] = carry[9]? (regcC[11:10]): (carry[8]? regcB[11:10]: regcA[11:10]);
    assign carry[13:12] = carry[11]? (regcC[13:12]): (carry[10]? regcB[13:12]: regcA[13:12]);
  
    assign Sum[127:0] = regA[127:0];
    assign Sum[255:128] = carry[1]? (regC[255:128]) : (carry[0]? regB[255:128]: regA[255:128]);
    assign Sum[383:256] = carry[3]? (regC[383:256]) : (carry[2]? regB[383:256]: regA[383:256]);
    assign Sum[511:384] = carry[5]? (regC[511:384]) : (carry[4]? regB[511:384]: regA[511:384]);
    assign Sum[639:512] = carry[7]? (regC[639:512]) : (carry[6]? regB[639:512]: regA[639:512]);
    assign Sum[767:640] = carry[9]? (regC[767:640]) : (carry[8]? regB[767:640]: regA[767:640]);
    assign Sum[895:768] = carry[11]? (regC[895:768]) : (carry[10]? regB[895:768]: regA[895:768]);
    assign Sum[1027:896] = carry[13]? (regC[1027:896]) : (carry[12]? regB[1027:896]: regA[1027:896]);

  wire carry_out = sub ^ Sum[1027];
  assign result = {carry_out, Sum[1026:0]};


endmodule

module add128b(
    input wire [127:0] a,
    input wire [127:0] b,
    input wire [127:0] c,
    output wire [127:0] suma,
    output wire [1:0] carrya,
    output wire [127:0] sumb,
    output wire [1:0] carryb,
    output wire [127:0] sumc,
    output wire [1:0] carryc
    );
    
    assign {carrya, suma} = a+b+c;
    assign {carryb, sumb} = a+b+c+2'b01;
    assign {carryc, sumc} = a+b+c+2'b10;
endmodule

module add131b(
    input wire [130:0] a,
    input wire [130:0] b,
    input wire [130:0] c,
    output wire [131:0] suma,
    output wire [131:0] sumb,
    output wire [131:0] sumc
    );
    
    assign suma= a+b+c;
    assign sumb = a+b+c+2'b01;
    assign sumc = a+b+c+2'b10;
endmodule
