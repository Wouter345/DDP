`timescale 1ns / 1ps

module mpadder8 (
  input wire clk,
  input wire leftshift,
  input wire [1026:0] in_a,
  input wire [1026:0] in_b,
  output wire [1027:0] result
);

    wire [1026:0] MuxB = leftshift? {in_b,1'b0} :in_b;
    wire [1027:0] Sum;
    
    
    wire [1027:0] sumA;
    wire [1027:93] sumB;
    
    wire [9:0] carryA;
    wire [9:1] carryB;
    
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
    
    
  assign {carryA[0],sumA[92:0]} = in_a[92:0] + MuxB[92:0];   
    add93 A2(in_a[185:93], MuxB[185:93], sumA[185:93], carryA[1], sumB[185:93], carryB[1]);
    add93 A3(in_a[278:186], MuxB[278:186], sumA[278:186], carryA[2], sumB[278:186], carryB[2]);
    add93 A4(in_a[371:279], MuxB[371:279], sumA[371:279], carryA[3], sumB[371:279], carryB[3]);
    add93 A5(in_a[464:372], MuxB[464:372], sumA[464:372], carryA[4], sumB[464:372], carryB[4]);
    add93 A6(in_a[557:465], MuxB[557:465], sumA[557:465], carryA[5], sumB[557:465], carryB[5]);
    add93 A7(in_a[650:558], MuxB[650:558], sumA[650:558], carryA[6], sumB[650:558], carryB[6]);
    add93 A8(in_a[743:651], MuxB[743:651], sumA[743:651], carryA[7], sumB[743:651], carryB[7]);
    add93 A9(in_a[836:744], MuxB[836:744], sumA[836:744], carryA[8], sumB[836:744], carryB[8]);
    add93 A10(in_a[929:837], MuxB[929:837], sumA[929:837], carryA[9], sumB[929:837], carryB[9]);
    add97 A11(in_a[1026:930], MuxB[1026:930], sumA[1027:930], sumB[1027:930]);
  

  reg [1027:0] regA;
  reg [1027:93] regB;
  reg [9:0] regcA;
  reg [9:1] regcB;
  always @(posedge clk) 
  begin
    regA <= sumA;
    regB <= sumB;
    regcA <= carryA;
    regcB <= carryB;
  end  
  
    assign carry1 = regcA[0];
    assign carry2 = carry1? regcA[1]: regcB[1];
    assign carry3 = carry2? regcA[2]: regcB[2];
    assign carry4 = carry3? regcA[3]: regcB[3];
    assign carry5 = carry4? regcA[4]: regcB[4];
    assign carry6 = carry5? regcA[5]: regcB[5];
    assign carry7 = carry6? regcA[6]: regcB[6];
    assign carry8 = carry7? regcA[7]: regcB[7];
    assign carry9 = carry8? regcA[8]: regcB[8];
    assign carry10 = carry9? regcA[9]: regcB[9];

  
    assign Sum[92:0] = regA[92:0];
    assign Sum[185:93] = carry1? regB[185:93]: regA[185:93];
    assign Sum[278:186] = carry2? regB[278:186]: regA[278:186];
    assign Sum[371:279] = carry3? regB[371:279]: regA[371:279];
    assign Sum[464:372] = carry4? regB[464:372]: regA[464:372];
    assign Sum[557:465] = carry5? regB[557:465]: regA[557:465];
    assign Sum[650:558] = carry6? regB[650:558]: regA[650:558];
    assign Sum[743:651] = carry7? regB[743:651]: regA[743:651];
    assign Sum[836:744] = carry8? regB[836:744]: regA[836:744];
    assign Sum[929:837] = carry9? regB[929:837]: regA[929:837];
    assign Sum[1027:930] = carry10? regB[1027:930]: regA[1027:930];
  

  assign result = Sum;

endmodule

module add93(
    input wire [92:0] a,
    input wire [92:0] b,
    output wire [92:0] suma,
    output wire carrya,
    output wire [92:0] sumb,
    output wire carryb
    );
    
    assign {carrya, suma} = a+b;
    assign {carryb, sumb} = a+b+1'b1;
    
    
endmodule

module add97(
    input wire [96:0] a,
    input wire [96:0] b,
    output wire [97:0] suma,
    output wire [97:0] sumb
    );
    
    assign suma= a+b;
    assign sumb = a+b+1'b1;
    
    
endmodule
