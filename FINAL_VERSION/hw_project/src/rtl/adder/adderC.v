module mpadderC (
  input wire clk,
  input wire reset,
  input wire [1028:0] in_a,         //1029bits
  input wire [1028:0] in_b,         //1029bits
  output wire [1029:0] result,       //1030bits
  output wire [19:0] prediction
);   
    
    wire [1028:0] MuxB = in_b;
    wire [1029:0] Sum;
    
    
    wire [1029:0] sumA;
    wire [1029:128] sumB;
    
    wire [6:0] carryA;
    wire [6:1] carryB;
    
    wire carry1;
    wire carry2;
    wire carry3;
    wire carry4;
    wire carry5;
    wire carry6;
    wire carry7;
  assign prediction = reset? 20'b0: sumA[19:0];  
  assign {carryA[0],sumA[127:0]} = in_a[127:0] + MuxB[127:0];   
  //assign {carryB[0],sumB[63:0]} = 65'b0;
    add128 A2(in_a[255:128], MuxB[255:128],sumA[255:128], carryA[1], sumB[255:128], carryB[1]);
    add128 A3(in_a[383:256], MuxB[383:256],sumA[383:256], carryA[2], sumB[383:256], carryB[2]);
    add128 A4(in_a[511:384], MuxB[511:384],sumA[511:384], carryA[3], sumB[511:384], carryB[3]);
    add128 A5(in_a[639:512], MuxB[639:512],sumA[639:512], carryA[4], sumB[639:512], carryB[4]);
    add128 A6(in_a[767:640], MuxB[767:640],sumA[767:640], carryA[5], sumB[767:640], carryB[5]);
    add128 A7(in_a[895:768], MuxB[895:768],sumA[895:768], carryA[6], sumB[895:768], carryB[6]);
    add133 A8(in_a[1028:896], MuxB[1028:896],sumA[1029:896], sumB[1029:896]);
  

    


  reg [1029:0] regA;
  reg [1029:128] regB;
  reg [6:0] regcA;
  reg [6:1] regcB;
  always @(posedge clk) 
  begin
    if (reset) begin
        regA <= 1030'b0;
        regB <= 1030'b0;
        regcA <= 7'b0;
        regcB <= 7'b0;
   end else begin
        regA <= sumA;
        regB <= sumB;
        regcA <= carryA;
        regcB <= carryB; end
  end  
  
    assign carry1 = regcA[0];
    assign carry2 = carry1? regcB[1]: regcA[1];
    assign carry3 = carry2? regcB[2]: regcA[2];
    assign carry4 = carry3? regcB[3]: regcA[3];
    assign carry5 = carry4? regcB[4]: regcA[4];
    assign carry6 = carry5? regcB[5]: regcA[5];
    assign carry7 = carry6? regcB[6]: regcA[6];

  
    assign Sum[127:0] = regA[127:0];
    assign Sum[255:128] = carry1? regB[255:128]: regA[255:128];
    assign Sum[383:256] = carry2? regB[383:256]: regA[383:256];
    assign Sum[511:384] = carry3? regB[511:384]: regA[511:384];
    assign Sum[639:512] = carry4? regB[639:512]: regA[639:512];
    assign Sum[767:640] = carry5? regB[767:640]: regA[767:640];
    assign Sum[895:768] = carry6? regB[895:768]: regA[895:768];
    assign Sum[1029:896] = carry7? regB[1029:896]: regA[1029:896];
  

  assign result = Sum;

endmodule

module add128(
    input wire [127:0] a,
    input wire [127:0] b,
    output wire [127:0] suma,
    output wire carrya,
    output wire [127:0] sumb,
    output wire carryb
    );
    
    assign {carrya, suma} = a+b;
    assign {carryb, sumb} = a+b+1'b1;
    
    
endmodule

module add133(
    input wire [132:0] a,
    input wire [132:0] b,
    output wire [133:0] suma,
    output wire [133:0] sumb
    );
    
    assign suma= a+b;
    assign sumb = a+b+1'b1;
    
    
endmodule
