`timescale 1ns / 1ps

module mpadder7 (
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
    wire [1027:103] sumB;
    wire [1027:103] sumC;
    
    wire [17:0] carryA;
    wire [17:2] carryB;
    wire [17:2] carryC;
        
    assign {carryA[1:0],sumA[102:0]} = in_a[102:0] + MuxB[102:0] + in_c[102:0] + subtract;  
    
    add103b A2(in_a[205:103], MuxB[205:103], in_c[205:103], sumA[205:103], carryA[3:2], sumB[205:103], carryB[3:2], sumC[205:103], carryC[3:2]);
    add103b A3(in_a[308:206], MuxB[308:206], in_c[308:206], sumA[308:206], carryA[5:4], sumB[308:206], carryB[5:4], sumC[308:206], carryC[5:4]);
    add103b A4(in_a[411:309], MuxB[411:309], in_c[411:309], sumA[411:309], carryA[7:6], sumB[411:309], carryB[7:6], sumC[411:309], carryC[7:6]);
    add103b A5(in_a[514:412], MuxB[514:412], in_c[514:412], sumA[514:412], carryA[9:8], sumB[514:412], carryB[9:8], sumC[514:412], carryC[9:8]);
    add103b A6(in_a[617:515], MuxB[617:515], in_c[617:515], sumA[617:515], carryA[11:10], sumB[617:515], carryB[11:10], sumC[617:515], carryC[11:10]);
    add103b A7(in_a[720:618], MuxB[720:618], in_c[720:618], sumA[720:618], carryA[13:12], sumB[720:618], carryB[13:12], sumC[720:618], carryC[13:12]);
    add103b A8(in_a[823:721], MuxB[823:721], in_c[823:721], sumA[823:721], carryA[15:14], sumB[823:721], carryB[15:14], sumC[823:721], carryC[15:14]);
    add103b A9(in_a[926:824], MuxB[926:824], in_c[926:824], sumA[926:824], carryA[17:16], sumB[926:824], carryB[17:16], sumC[926:824], carryC[17:16]);
    add100b A10(in_a[1026:927], MuxB[1026:927], in_c[1026:927], sumA[1027:927], sumB[1027:927], sumC[1027:927]);
      
  
  reg [1027:0] regA;
  reg [1027:103] regB;
  reg [1027:103] regC;
  reg [17:0] regcA;
  reg [17:2] regcB;
  reg [17:2] regcC;
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
  
    assign Sum[102:0] = regA[102:0];
    assign Sum[205:103] = carry[1]? (regC[205:103]) : (carry[0]? regB[205:103]: regA[205:103]);
    assign Sum[308:206] = carry[3]? (regC[308:206]) : (carry[2]? regB[308:206]: regA[308:206]);
    assign Sum[411:309] = carry[5]? (regC[411:309]) : (carry[4]? regB[411:309]: regA[411:309]);
    assign Sum[514:412] = carry[7]? (regC[514:412]) : (carry[6]? regB[514:412]: regA[514:412]);
    assign Sum[617:515] = carry[9]? (regC[617:515]) : (carry[8]? regB[617:515]: regA[617:515]);
    assign Sum[720:618] = carry[11]? (regC[720:618]) : (carry[10]? regB[720:618]: regA[720:618]);
    assign Sum[823:721] = carry[13]? (regC[823:721]) : (carry[12]? regB[823:721]: regA[823:721]);
    assign Sum[926:824] = carry[15]? (regC[926:824]) : (carry[14]? regB[926:824]: regA[926:824]);
    assign Sum[1027:927] = carry[17]? (regC[1027:927]) : (carry[16]? regB[1027:927]: regA[1027:927]);

  wire carry_out = sub ^ Sum[1027];
  assign result = {carry_out, Sum[1026:0]};


endmodule

module add103b(
    input wire [102:0] a,
    input wire [102:0] b,
    input wire [102:0] c,
    output wire [102:0] suma,
    output wire [1:0] carrya,
    output wire [102:0] sumb,
    output wire [1:0] carryb,
    output wire [102:0] sumc,
    output wire [1:0] carryc
    );
    
    assign {carrya, suma} = a+b+c;
    assign {carryb, sumb} = a+b+c+2'b01;
    assign {carryc, sumc} = a+b+c+2'b10;
endmodule

module add100b(
    input wire [99:0] a,
    input wire [99:0] b,
    input wire [99:0] c,
    output wire [100:0] suma,
    output wire [100:0] sumb,
    output wire [100:0] sumc
    );
    
    assign suma= a+b+c;
    assign sumb = a+b+c+2'b01;
    assign sumc = a+b+c+2'b10;
endmodule
