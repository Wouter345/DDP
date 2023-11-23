`timescale 1ns / 1ps

module mpadder3 (
  input wire clk,
  input wire resetn,
  input wire start,
  input wire subtract,
  input wire [1026:0] in_a,
  input wire [1026:0] in_b,
  output wire [1027:0] result,
  output wire done
);

    wire [1026:0] MuxB = (subtract) ? ~in_b : in_b;
    wire [1027:0] Sum;
    
    
    wire [1027:0] sumA;
    wire [1027:64] sumB;
    
    wire [15:0] carryA;
    wire [15:1] carryB;
    
    wire carry1;
    wire carry2;
    wire carry3;
    wire carry4;
    wire carry5;
    wire carry6;
    wire carry7;
    wire carry8;
    wire carry9;
    wire carry10;
    wire carry11;
    wire carry12;
    wire carry13;
    wire carry14;
    wire carry15;
    wire carry16;
    
  assign {carryA[0],sumA[63:0]} = in_a[63:0] + MuxB[63:0] + subtract;   
  //assign {carryB[0],sumB[63:0]} = 65'b0;
  add64 A2(in_a[127:64], MuxB[127:64],sumA[127:64], carryA[1], sumB[127:64], carryB[1]);
  add64 A3(in_a[191:128], MuxB[191:128],sumA[191:128], carryA[2], sumB[191:128], carryB[2]);
  add64 A4(in_a[255:192], MuxB[255:192],sumA[255:192], carryA[3], sumB[255:192], carryB[3]);
  add64 A5(in_a[319:256], MuxB[319:256],sumA[319:256], carryA[4], sumB[319:256], carryB[4]);
  add64 A6(in_a[383:320], MuxB[383:320],sumA[383:320], carryA[5], sumB[383:320], carryB[5]);
  add64 A7(in_a[447:384], MuxB[447:384],sumA[447:384], carryA[6], sumB[447:384], carryB[6]);
  add64 A8(in_a[511:448], MuxB[511:448],sumA[511:448], carryA[7], sumB[511:448], carryB[7]);
  add64 A9(in_a[575:512], MuxB[575:512],sumA[575:512], carryA[8], sumB[575:512], carryB[8]);
  add64 A10(in_a[639:576], MuxB[639:576],sumA[639:576], carryA[9], sumB[639:576], carryB[9]);
  add64 A11(in_a[703:640], MuxB[703:640],sumA[703:640], carryA[10], sumB[703:640], carryB[10]);
  add64 A12(in_a[767:704], MuxB[767:704],sumA[767:704], carryA[11], sumB[767:704], carryB[11]);
  add64 A13(in_a[831:768], MuxB[831:768],sumA[831:768], carryA[12], sumB[831:768], carryB[12]);
  add64 A14(in_a[895:832], MuxB[895:832],sumA[895:832], carryA[13], sumB[895:832], carryB[13]);
  add64 A15(in_a[959:896], MuxB[959:896],sumA[959:896], carryA[14], sumB[959:896], carryB[14]);
  add64 A16(in_a[1023:960], MuxB[1023:960],sumA[1023:960], carryA[15], sumB[1023:960], carryB[15]);
  add3 A17(in_a[1026:1024], MuxB[1026:1024],sumA[1027:1024], sumB[1027:1024]);
  

    


  reg [1027:0] regA;
  reg [1027:64] regB;
  reg [15:0] regcA;
  reg [15:1] regcB;
  always @(posedge clk) 
  begin
    regA <= sumA;
    regB <= sumB;
    regcA <= carryA;
    regcB <= carryB;
  end  
  
    assign carry1 = regcA[0];
    assign carry2 = carry1? regcB[1]: regcA[1];
    assign carry3 = carry2? regcB[2]: regcA[2];
    assign carry4 = carry3? regcB[3]: regcA[3];
    assign carry5 = carry4? regcB[4]: regcA[4];
    assign carry6 = carry5? regcB[5]: regcA[5];
    assign carry7 = carry6? regcB[6]: regcA[6];
    assign carry8 = carry7? regcB[7]: regcA[7];
    assign carry9 = carry8? regcB[8]: regcA[8];
    assign carry10 = carry9? regcB[9]: regcA[9];
    assign carry11 = carry10? regcB[10]: regcA[10];
    assign carry12 = carry11? regcB[11]: regcA[11];
    assign carry13 = carry12? regcB[12]: regcA[12];
    assign carry14 = carry13? regcB[13]: regcA[13];
    assign carry15 = carry14? regcB[14]: regcA[14];
    assign carry16 = carry15? regcB[15]: regcA[15];
  
    assign Sum[63:0] = regA[63:0];
    assign Sum[127:64] = carry1? regB[127:64]: regA[127:64];
    assign Sum[191:128] = carry2? regB[191:128]: regA[191:128];
    assign Sum[255:192] = carry3? regB[255:192]: regA[255:192];
    assign Sum[319:256] = carry4? regB[319:256]: regA[319:256];
    assign Sum[383:320] = carry5? regB[383:320]: regA[383:320];
    assign Sum[447:384] = carry6? regB[447:384]: regA[447:384];
    assign Sum[511:448] = carry7? regB[511:448]: regA[511:448];
    assign Sum[575:512] = carry8? regB[575:512]: regA[575:512];
    assign Sum[639:576] = carry9? regB[639:576]: regA[639:576];
    assign Sum[703:640] = carry10? regB[703:640]: regA[703:640];
    assign Sum[767:704] = carry11? regB[767:704]: regA[767:704];
    assign Sum[831:768] = carry12? regB[831:768]: regA[831:768];
    assign Sum[895:832] = carry13? regB[895:832]: regA[895:832];
    assign Sum[959:896] = carry14? regB[959:896]: regA[959:896];
    assign Sum[1023:960] = carry15? regB[1023:960]: regA[1023:960];
    assign Sum[1027:1024] = carry16? regB[1027:1024]: regA[1027:1024];
  

  wire carry_out = subtract ^ Sum[1027];
  assign result = {carry_out, Sum[1026:0]};

  reg regDone;
  always @(posedge clk) begin
    if (start)
      regDone <= 1'b1;
    else
      regDone <= 1'b0;
  end

  assign done = regDone;

endmodule

module add64(
    input wire [63:0] a,
    input wire [63:0] b,
    output wire [63:0] suma,
    output wire carrya,
    output wire [63:0] sumb,
    output wire carryb
    );
    
    assign {carrya, suma} = a+b;
    assign {carryb, sumb} = a+b+1'b1;
    
    
endmodule

module add3(
    input wire [2:0] a,
    input wire [2:0] b,
    output wire [3:0] suma,
    output wire [3:0] sumb
    );
    
    assign suma= a+b;
    assign sumb = a+b+1'b1;
    
    
endmodule
