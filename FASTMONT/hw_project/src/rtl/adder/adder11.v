module mpadder11 (
  input wire clk,
  input wire [1026:0] in_a,
  input wire [1026:0] in_b,
  output wire [1027:0] result
);

    wire [1026:0] MuxB = in_b;
    wire [1027:0] Sum;
    
    
    wire [1027:0] sumA;
    wire [1027:103] sumB;
    
    wire [8:0] carryA;
    wire [8:1] carryB;
    
    wire carry1;
    wire carry2;
    wire carry3;
    wire carry4;
    wire carry5;
    wire carry6;
    wire carry7;
    wire carry8;
    wire carry9;

  assign {carryA[0],sumA[102:0]} = in_a[102:0] + MuxB[102:0];   
  //assign {carryB[0],sumB[63:0]} = 65'b0;
    add103 A2(in_a[205:103], MuxB[205:103], sumA[205:103], carryA[1], sumB[205:103], carryB[1]);
    add103 A3(in_a[308:206], MuxB[308:206], sumA[308:206], carryA[2], sumB[308:206], carryB[2]);
    add103 A4(in_a[411:309], MuxB[411:309], sumA[411:309], carryA[3], sumB[411:309], carryB[3]);
    add103 A5(in_a[514:412], MuxB[514:412], sumA[514:412], carryA[4], sumB[514:412], carryB[4]);
    add103 A6(in_a[617:515], MuxB[617:515], sumA[617:515], carryA[5], sumB[617:515], carryB[5]);
    add103 A7(in_a[720:618], MuxB[720:618], sumA[720:618], carryA[6], sumB[720:618], carryB[6]);
    add103 A8(in_a[823:721], MuxB[823:721], sumA[823:721], carryA[7], sumB[823:721], carryB[7]);
    add103 A9(in_a[926:824], MuxB[926:824], sumA[926:824], carryA[8], sumB[926:824], carryB[8]);
    add100 A10(in_a[1026:927], MuxB[1026:927], sumA[1027:927], sumB[1027:927]);
  

    


  reg [1027:0] regA;
  reg [1027:103] regB;
  reg [8:0] regcA;
  reg [8:1] regcB;
  reg sub;
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
  
    assign Sum[102:0] = regA[102:0];
    assign Sum[205:103] = carry1? regB[205:103]: regA[205:103];
    assign Sum[308:206] = carry2? regB[308:206]: regA[308:206];
    assign Sum[411:309] = carry3? regB[411:309]: regA[411:309];
    assign Sum[514:412] = carry4? regB[514:412]: regA[514:412];
    assign Sum[617:515] = carry5? regB[617:515]: regA[617:515];
    assign Sum[720:618] = carry6? regB[720:618]: regA[720:618];
    assign Sum[823:721] = carry7? regB[823:721]: regA[823:721];
    assign Sum[926:824] = carry8? regB[926:824]: regA[926:824];
    assign Sum[1027:927] = carry9? regB[1027:927]: regA[1027:927];
  

  assign result = Sum;


endmodule

module add103(
    input wire [102:0] a,
    input wire [102:0] b,
    output wire [102:0] suma,
    output wire carrya,
    output wire [102:0] sumb,
    output wire carryb
    );
    
    assign {carrya, suma} = a+b;
    assign {carryb, sumb} = a+b+1'b1;
    
    
endmodule

module add100(
    input wire [99:0] a,
    input wire [99:0] b,
    output wire [100:0] suma,
    output wire [100:0] sumb
    );
    
    assign suma= a+b;
    assign sumb = a+b+1'b1;
    
    
endmodule
