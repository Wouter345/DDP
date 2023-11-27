`timescale 1ns / 1ps

module mpadder6 (
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
    wire [1027:114] sumB;
    wire [1027:114] sumC;
    
    wire [15:0] carryA;
    wire [15:2] carryB;
    wire [15:2] carryC;
        
    assign {carryA[1:0],sumA[113:0]} = in_a[113:0] + MuxB[113:0] + in_c[113:0] + subtract;  
    
    add114b A2(in_a[227:114], MuxB[227:114], in_c[227:114], sumA[227:114], carryA[3:2], sumB[227:114], carryB[3:2], sumC[227:114], carryC[3:2]);
    add114b A3(in_a[341:228], MuxB[341:228], in_c[341:228], sumA[341:228], carryA[5:4], sumB[341:228], carryB[5:4], sumC[341:228], carryC[5:4]);
    add114b A4(in_a[455:342], MuxB[455:342], in_c[455:342], sumA[455:342], carryA[7:6], sumB[455:342], carryB[7:6], sumC[455:342], carryC[7:6]);
    add114b A5(in_a[569:456], MuxB[569:456], in_c[569:456], sumA[569:456], carryA[9:8], sumB[569:456], carryB[9:8], sumC[569:456], carryC[9:8]);
    add114b A6(in_a[683:570], MuxB[683:570], in_c[683:570], sumA[683:570], carryA[11:10], sumB[683:570], carryB[11:10], sumC[683:570], carryC[11:10]);
    add114b A7(in_a[797:684], MuxB[797:684], in_c[797:684], sumA[797:684], carryA[13:12], sumB[797:684], carryB[13:12], sumC[797:684], carryC[13:12]);
    add114b A8(in_a[911:798], MuxB[911:798], in_c[911:798], sumA[911:798], carryA[15:14], sumB[911:798], carryB[15:14], sumC[911:798], carryC[15:14]);
    add115b A9(in_a[1026:912], MuxB[1026:912], in_c[1026:912], sumA[1027:912], sumB[1027:912], sumC[1027:912]);
    
      
  
  reg [1027:0] regA;
  reg [1027:114] regB;
  reg [1027:114] regC;
  reg [15:0] regcA;
  reg [15:2] regcB;
  reg [15:2] regcC;
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
  
    assign Sum[113:0] = regA[113:0];
    assign Sum[227:114] = carry[1]? (regC[227:114]) : (carry[0]? regB[227:114]: regA[227:114]);
    assign Sum[341:228] = carry[3]? (regC[341:228]) : (carry[2]? regB[341:228]: regA[341:228]);
    assign Sum[455:342] = carry[5]? (regC[455:342]) : (carry[4]? regB[455:342]: regA[455:342]);
    assign Sum[569:456] = carry[7]? (regC[569:456]) : (carry[6]? regB[569:456]: regA[569:456]);
    assign Sum[683:570] = carry[9]? (regC[683:570]) : (carry[8]? regB[683:570]: regA[683:570]);
    assign Sum[797:684] = carry[11]? (regC[797:684]) : (carry[10]? regB[797:684]: regA[797:684]);
    assign Sum[911:798] = carry[13]? (regC[911:798]) : (carry[12]? regB[911:798]: regA[911:798]);
    assign Sum[1027:912] = carry[15]? (regC[1027:912]) : (carry[14]? regB[1027:912]: regA[1027:912]);

  wire carry_out = sub ^ Sum[1027];
  assign result = {carry_out, Sum[1026:0]};


endmodule

module add114b(
    input wire [113:0] a,
    input wire [113:0] b,
    input wire [113:0] c,
    output wire [113:0] suma,
    output wire [1:0] carrya,
    output wire [113:0] sumb,
    output wire [1:0] carryb,
    output wire [113:0] sumc,
    output wire [1:0] carryc
    );
    
    assign {carrya, suma} = a+b+c;
    assign {carryb, sumb} = a+b+c+2'b01;
    assign {carryc, sumc} = a+b+c+2'b10;
endmodule

module add115b(
    input wire [114:0] a,
    input wire [114:0] b,
    input wire [114:0] c,
    output wire [115:0] suma,
    output wire [115:0] sumb,
    output wire [115:0] sumc
    );
    
    assign suma= a+b+c;
    assign sumb = a+b+c+2'b01;
    assign sumc = a+b+c+2'b10;
endmodule
