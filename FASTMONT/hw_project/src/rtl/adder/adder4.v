`timescale 1ns / 1ps

module mpadder4 (
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
    wire [1027:64] sumB;
    wire [1027:64] sumC;
    
    wire [29:0] carryA;
    wire [29:2] carryB;
    wire [29:2] carryC;
        
    assign {carryA[1:0],sumA[63:0]} = in_a[63:0] + MuxB[63:0] + in_c[63:0] + subtract;   
    add64 A2(in_a[127:64], MuxB[127:64], in_c[127:64], sumA[127:64], carryA[3:2], sumB[127:64], carryB[3:2], sumC[127:64], carryC[3:2]);
    add64 A3(in_a[191:128], MuxB[191:128], in_c[191:128], sumA[191:128], carryA[5:4], sumB[191:128], carryB[5:4], sumC[191:128], carryC[5:4]);
    add64 A4(in_a[255:192], MuxB[255:192], in_c[255:192], sumA[255:192], carryA[7:6], sumB[255:192], carryB[7:6], sumC[255:192], carryC[7:6]);
    add64 A5(in_a[319:256], MuxB[319:256], in_c[319:256], sumA[319:256], carryA[9:8], sumB[319:256], carryB[9:8], sumC[319:256], carryC[9:8]);
    add64 A6(in_a[383:320], MuxB[383:320], in_c[383:320], sumA[383:320], carryA[11:10], sumB[383:320], carryB[11:10], sumC[383:320], carryC[11:10]);
    add64 A7(in_a[447:384], MuxB[447:384], in_c[447:384], sumA[447:384], carryA[13:12], sumB[447:384], carryB[13:12], sumC[447:384], carryC[13:12]);
    add64 A8(in_a[511:448], MuxB[511:448], in_c[511:448], sumA[511:448], carryA[15:14], sumB[511:448], carryB[15:14], sumC[511:448], carryC[15:14]);
    add64 A9(in_a[575:512], MuxB[575:512], in_c[575:512], sumA[575:512], carryA[17:16], sumB[575:512], carryB[17:16], sumC[575:512], carryC[17:16]);
    add64 A10(in_a[639:576], MuxB[639:576], in_c[639:576], sumA[639:576], carryA[19:18], sumB[639:576], carryB[19:18], sumC[639:576], carryC[19:18]);
    add64 A11(in_a[703:640], MuxB[703:640], in_c[703:640], sumA[703:640], carryA[21:20], sumB[703:640], carryB[21:20], sumC[703:640], carryC[21:20]);
    add64 A12(in_a[767:704], MuxB[767:704], in_c[767:704], sumA[767:704], carryA[23:22], sumB[767:704], carryB[23:22], sumC[767:704], carryC[23:22]);
    add64 A13(in_a[831:768], MuxB[831:768], in_c[831:768], sumA[831:768], carryA[25:24], sumB[831:768], carryB[25:24], sumC[831:768], carryC[25:24]);
    add64 A14(in_a[895:832], MuxB[895:832], in_c[895:832], sumA[895:832], carryA[27:26], sumB[895:832], carryB[27:26], sumC[895:832], carryC[27:26]);
    add64 A15(in_a[959:896], MuxB[959:896], in_c[959:896], sumA[959:896], carryA[29:28], sumB[959:896], carryB[29:28], sumC[959:896], carryC[29:28]);
    add67 A16(in_a[1026:960], MuxB[1026:960], in_c[1026:960], sumA[1027:960], sumB[1027:960], sumC[1027:960]);
  
  
  reg [1027:0] regA;
  reg [1027:64] regB;
  reg [1027:64] regC;
  reg [29:0] regcA;
  reg [29:2] regcB;
  reg [29:2] regcC;
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
    assign carry[15:14] = carry[13]? (regcC[15:14]): (carry[12]? regcB[15:14]: regcA[15:14]);
    assign carry[17:16] = carry[15]? (regcC[17:16]): (carry[14]? regcB[17:16]: regcA[17:16]);
    assign carry[19:18] = carry[17]? (regcC[19:18]): (carry[16]? regcB[19:18]: regcA[19:18]);
    assign carry[21:20] = carry[19]? (regcC[21:20]): (carry[18]? regcB[21:20]: regcA[21:20]);
    assign carry[23:22] = carry[21]? (regcC[23:22]): (carry[20]? regcB[23:22]: regcA[23:22]);
    assign carry[25:24] = carry[23]? (regcC[25:24]): (carry[22]? regcB[25:24]: regcA[25:24]);
    assign carry[27:26] = carry[25]? (regcC[27:26]): (carry[24]? regcB[27:26]: regcA[27:26]);
    assign carry[29:28] = carry[27]? (regcC[29:28]): (carry[26]? regcB[29:28]: regcA[29:28]);
  
    assign Sum[63:0] = regA[63:0];
    assign Sum[127:64] = carry[1]? (regC[127:64]) : (carry[0]? regB[127:64]: regA[127:64]);
    assign Sum[191:128] = carry[3]? (regC[191:128]) : (carry[2]? regB[191:128]: regA[191:128]);
    assign Sum[255:192] = carry[5]? (regC[255:192]) : (carry[4]? regB[255:192]: regA[255:192]);
    assign Sum[319:256] = carry[7]? (regC[319:256]) : (carry[6]? regB[319:256]: regA[319:256]);
    assign Sum[383:320] = carry[9]? (regC[383:320]) : (carry[8]? regB[383:320]: regA[383:320]);
    assign Sum[447:384] = carry[11]? (regC[447:384]) : (carry[10]? regB[447:384]: regA[447:384]);
    assign Sum[511:448] = carry[13]? (regC[511:448]) : (carry[12]? regB[511:448]: regA[511:448]);
    assign Sum[575:512] = carry[15]? (regC[575:512]) : (carry[14]? regB[575:512]: regA[575:512]);
    assign Sum[639:576] = carry[17]? (regC[639:576]) : (carry[16]? regB[639:576]: regA[639:576]);
    assign Sum[703:640] = carry[19]? (regC[703:640]) : (carry[18]? regB[703:640]: regA[703:640]);
    assign Sum[767:704] = carry[21]? (regC[767:704]) : (carry[20]? regB[767:704]: regA[767:704]);
    assign Sum[831:768] = carry[23]? (regC[831:768]) : (carry[22]? regB[831:768]: regA[831:768]);
    assign Sum[895:832] = carry[25]? (regC[895:832]) : (carry[24]? regB[895:832]: regA[895:832]);
    assign Sum[959:896] = carry[27]? (regC[959:896]) : (carry[26]? regB[959:896]: regA[959:896]);
    assign Sum[1027:960] = carry[29]? (regC[1027:960]) : (carry[28]? regB[1027:960]: regA[1027:960]);

  

  wire carry_out = sub ^ Sum[1027];
  assign result = {carry_out, Sum[1026:0]};


endmodule

module add64(
    input wire [63:0] a,
    input wire [63:0] b,
    input wire [63:0] c,
    output wire [63:0] suma,
    output wire [1:0] carrya,
    output wire [63:0] sumb,
    output wire [1:0] carryb,
    output wire [63:0] sumc,
    output wire [1:0] carryc
    );
    
    assign {carrya, suma} = a+b+c;
    assign {carryb, sumb} = a+b+c+2'b01;
    assign {carryc, sumc} = a+b+c+2'b10;
endmodule

module add67(
    input wire [66:0] a,
    input wire [66:0] b,
    input wire [66:0] c,
    output wire [67:0] suma,
    output wire [67:0] sumb,
    output wire [67:0] sumc
    );
    
    assign suma= a+b+c;
    assign sumb = a+b+c+2'b01;
    assign sumc = a+b+c+2'b10;
endmodule
