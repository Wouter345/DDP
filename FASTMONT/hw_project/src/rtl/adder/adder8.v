`timescale 1ns / 1ps

module mpadder8 (
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
    wire [1027:85] sumB;
    wire [1027:85] sumC;
    
    wire [21:0] carryA;
    wire [21:2] carryB;
    wire [21:2] carryC;
        
    assign {carryA[1:0],sumA[84:0]} = in_a[84:0] + MuxB[84:0] + in_c[84:0] + subtract;  
    
    add85 A2(in_a[169:85], MuxB[169:85], in_c[169:85], sumA[169:85], carryA[3:2], sumB[169:85], carryB[3:2], sumC[169:85], carryC[3:2]);
    add85 A3(in_a[254:170], MuxB[254:170], in_c[254:170], sumA[254:170], carryA[5:4], sumB[254:170], carryB[5:4], sumC[254:170], carryC[5:4]);
    add85 A4(in_a[339:255], MuxB[339:255], in_c[339:255], sumA[339:255], carryA[7:6], sumB[339:255], carryB[7:6], sumC[339:255], carryC[7:6]);
    add85 A5(in_a[424:340], MuxB[424:340], in_c[424:340], sumA[424:340], carryA[9:8], sumB[424:340], carryB[9:8], sumC[424:340], carryC[9:8]);
    add85 A6(in_a[509:425], MuxB[509:425], in_c[509:425], sumA[509:425], carryA[11:10], sumB[509:425], carryB[11:10], sumC[509:425], carryC[11:10]);
    add85 A7(in_a[594:510], MuxB[594:510], in_c[594:510], sumA[594:510], carryA[13:12], sumB[594:510], carryB[13:12], sumC[594:510], carryC[13:12]);
    add85 A8(in_a[679:595], MuxB[679:595], in_c[679:595], sumA[679:595], carryA[15:14], sumB[679:595], carryB[15:14], sumC[679:595], carryC[15:14]);
    add85 A9(in_a[764:680], MuxB[764:680], in_c[764:680], sumA[764:680], carryA[17:16], sumB[764:680], carryB[17:16], sumC[764:680], carryC[17:16]);
    add85 A10(in_a[849:765], MuxB[849:765], in_c[849:765], sumA[849:765], carryA[19:18], sumB[849:765], carryB[19:18], sumC[849:765], carryC[19:18]);
    add85 A11(in_a[934:850], MuxB[934:850], in_c[934:850], sumA[934:850], carryA[21:20], sumB[934:850], carryB[21:20], sumC[934:850], carryC[21:20]);
    add92 A12(in_a[1026:935], MuxB[1026:935], in_c[1026:935], sumA[1027:935], sumB[1027:935], sumC[1027:935]);
      
  
  reg [1027:0] regA;
  reg [1027:85] regB;
  reg [1027:85] regC;
  reg [21:0] regcA;
  reg [21:2] regcB;
  reg [21:2] regcC;
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
      
    assign Sum[84:0] = regA[84:0];
    assign Sum[169:85] = carry[1]? (regC[169:85]) : (carry[0]? regB[169:85]: regA[169:85]);
    assign Sum[254:170] = carry[3]? (regC[254:170]) : (carry[2]? regB[254:170]: regA[254:170]);
    assign Sum[339:255] = carry[5]? (regC[339:255]) : (carry[4]? regB[339:255]: regA[339:255]);
    assign Sum[424:340] = carry[7]? (regC[424:340]) : (carry[6]? regB[424:340]: regA[424:340]);
    assign Sum[509:425] = carry[9]? (regC[509:425]) : (carry[8]? regB[509:425]: regA[509:425]);
    assign Sum[594:510] = carry[11]? (regC[594:510]) : (carry[10]? regB[594:510]: regA[594:510]);
    assign Sum[679:595] = carry[13]? (regC[679:595]) : (carry[12]? regB[679:595]: regA[679:595]);
    assign Sum[764:680] = carry[15]? (regC[764:680]) : (carry[14]? regB[764:680]: regA[764:680]);
    assign Sum[849:765] = carry[17]? (regC[849:765]) : (carry[16]? regB[849:765]: regA[849:765]);
    assign Sum[934:850] = carry[19]? (regC[934:850]) : (carry[18]? regB[934:850]: regA[934:850]);
    assign Sum[1027:935] = carry[21]? (regC[1027:935]) : (carry[20]? regB[1027:935]: regA[1027:935]);
    
  wire carry_out = sub ^ Sum[1027];
  assign result = {carry_out, Sum[1026:0]};


endmodule

module add85(
    input wire [84:0] a,
    input wire [84:0] b,
    input wire [84:0] c,
    output wire [84:0] suma,
    output wire [1:0] carrya,
    output wire [84:0] sumb,
    output wire [1:0] carryb,
    output wire [84:0] sumc,
    output wire [1:0] carryc
    );
    
    assign {carrya, suma} = a+b+c;
    assign {carryb, sumb} = a+b+c+2'b01;
    assign {carryc, sumc} = a+b+c+2'b10;
endmodule



module add92(
    input wire [91:0] a,
    input wire [91:0] b,
    input wire [91:0] c,
    output wire [92:0] suma,
    output wire [92:0] sumb,
    output wire [92:0] sumc
    );
    
    assign suma= a+b+c;
    assign sumb = a+b+c+2'b01;
    assign sumc = a+b+c+2'b10;
endmodule
