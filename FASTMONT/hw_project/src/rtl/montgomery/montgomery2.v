`timescale 1ns / 1ps

module montgomery7(
  input           clk,
  input           resetn,
  input           start,
  input  [1023:0] in_a,
  input  [1023:0] in_b,
  input  [1023:0] in_m,
  output [1023:0] result,
  output          done
    );
    
    // In this implementation we do 4 iterations at a time, taking 1 clock cycles to complete.
    
    reg           regA_en;
    reg           shiftA;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if (regA_en)   regA_out <= in_a;
        else if (shiftA) regA_out <= regA_out >> 4; //shift four times
    end
    
    // This reg will save The value B+M and in state 6 the value C-M
    reg           regBM_en;
    reg  [1027:0] regBM_out;
    always @(posedge clk)
    begin
        if (regBM_en)   regBM_out <= Sum1;
    end
    
    reg           regC_en;
    wire [1027:0] regC_in;
    reg  [1027:0] regC_out;
    always @(posedge clk)
    begin
        if (reset)     regC_out <= 1028'd0;
        else if (regC_en)   regC_out <= regC_in; 
    end
    
    // select operand1/2/3/4
    wire [1026:0] operand1;
    wire [1:0] operand1_sel;
    assign operand1 = operand1_sel[1]? (operand1_sel[0]? regBM_out : {3'b0,in_b}) : (operand1_sel[0]? {3'b0,in_m} : 1027'b0); //Adder selection for first iteration
    
    wire [1026:0] operand2;
    wire [1:0] operand2_sel;
    reg leftshift;
    assign operand2 = leftshift? (operand2_sel[1]? (operand2_sel[0]? {regBM_out,1'b0} : {3'b0,in_b,1'b0}) : (operand2_sel[0]? {3'b0,in_m,1'b0} : 1027'b0)): in_m; //Adder selection for second iteration 
    
    wire [1027:0] operand3;//1028bits
    wire [1:0] operand3_sel;
    assign operand3 = operand3_sel[1]? (operand3_sel[0]? {regBM_out,2'b0} : {2'b0,in_b,2'b0}) : (operand3_sel[0]? {2'b0,in_m,2'b0} : 1028'b0); //Adder selection for first iteration

    wire [1027:0] operand4;//1028bits
    wire [1:0] operand4_sel;
    assign operand4 = operand4_sel[1]? (operand4_sel[0]? {regBM_out,3'b0} : {1'b0,in_b,3'b0}) : (operand4_sel[0]? {1'b0,in_m,3'b0} : 1028'b0); //Adder selection for first iteration

    wire [1027:0] Sum1;
    wire [1028:0] Sum2;
    reg reset_adder1;
    reg reset_adder2;
    mpadder11 adder1(clk, reset_adder1,  operand1,operand2,Sum1); 
    mpadder12 adder2(clk, reset_adder2, operand3,operand4,Sum2);
    
    wire [1028:0] Sum3;
    reg reset_adder3;
    mpadder13 adder3(clk, reset_adder3,  Sum1,Sum2,Sum3);
    
    wire [1028:0] Sum4;
    wire [1027:0] Res1;
    reg subtract;
    reg reset_adder4;
    mpadder14 adder4(clk, reset_adder4, subtract, Res1, Sum3, Sum4); //feed the output shifted 4 times directly back, use reset_adder to make output 0
    
    assign Res1 = Sum4 >> 4; //Actual new value of C after 2 iterations
    
    reg p;
    assign regC_in = p? Sum2 : Res1; 
     
    ////////Logic to figure out regoperand 12 iterations down the line
    wire [7:0] int;
    assign int = (Sum1[11:0] + Sum2[11:0] + (Sum3[15:0] + Res1[15:0])>>4)>>4;
    
    wire [7:0] C1; //8 bits after +b first iteration
    assign C1 = int[11:0]+ (in_b[11:0] & {regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0]});
    
    wire[6:0] C2; //7 bits after +b 2th iteration
    assign C2 = ((C1 + (in_m[7:0] & {C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0]})) >> 1) + (in_b[6:0] & {regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1]});
    
    wire[5:0] C3; //6 bits after +b 3th iteration
    assign C3 = ((C2 + (in_m[6:0] & {C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0]})) >> 1) + (in_b[5:0] & {regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2]});
    
    wire[4:0] C4; //5 bits after +b 4th iteration
    assign C4 = ((C3 + (in_m[5:0] & {C3[0], C3[0], C3[0], C3[0], C3[0], C3[0], C3[0], C3[0], C3[0], C3[0], C3[0], C3[0]})) >> 1) + (in_b[4:0] & {regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3], regA_out[3]});
    
    wire[3:0] C5; //4 bits after +b 5th iteration
    assign C5 = ((C4 + (in_m[4:0] & {C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0]})) >> 1) + (in_b[3:0] & {regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4], regA_out[4]});
    
    wire[2:0] C6; //3 bits after +b 6th iteration
    assign C6 = ((C5 + (in_m[3:0] & {C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0]})) >> 1) + (in_b[2:0] & {regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5], regA_out[5]});
    
    wire[1:0] C7; //2 bits after +b 7th iteration
    assign C7 = ((C6 + (in_m[2:0] & {C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0]})) >> 1) + (in_b[1:0] & {regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6], regA_out[6]});
    
    wire C8; //1 bits after +b 8th iteration
    assign C8 = ((C7 + (in_m[1:0] & {C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0]})) >> 1) + (in_b[0] & {regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7], regA_out[7]});
    
    
    

    reg [1:0] regoperand1;
    reg [1:0] regoperand2;
    reg [1:0] regoperand3;
    reg [1:0] regoperand4;
    always @(posedge clk)
    begin
        if (count == 9'd253) begin //M+0 for subtraction of C-M
            regoperand1<=2'b01;
            regoperand2<=2'b00; 
            regoperand3<=2'b00;
            regoperand4<=2'b00; end
            
        else begin case(state)
                    3'd0: begin //B+M
                        regoperand1<=2'b10;
                        regoperand2<=2'b01; 
                        regoperand3<=2'b00;
                        regoperand4<=2'b00; end
                    3'd1: begin //0+0
                        regoperand1<=2'b00;
                        regoperand2<=2'b00; 
                        regoperand3<=2'b00;
                        regoperand4<=2'b00;end  
                    3'd2: begin //save 1/2/3/4 iteration operands_sel
                        regoperand1<={regA_out[0], C1[0]};
                        regoperand2<={regA_out[1], C2[0]}; 
                        regoperand3<={regA_out[2], C3[0]};
                        regoperand4<={regA_out[3], C4[0]}; end
                    default: begin //save next operands_sel
                        regoperand1<={regA_out[4], C5[0]};
                        regoperand2<={regA_out[5], C6[0]}; 
                        regoperand3<={regA_out[6], C7[0]};
                        regoperand4<={regA_out[7], C8}; end
                 endcase end
    end
    
    assign operand1_sel = regoperand1;
    assign operand2_sel = regoperand2;
    assign operand3_sel = regoperand3;
    assign operand4_sel = regoperand4;

    assign result = regC_out; //if bit 1028 is 0 then C-M>0 so C=C-M
    
    reg [9:0] count;
    reg count_en; 
    reg reset;
    always @(posedge clk) begin
      if (reset) count <= 10'b0;
      else if (count_en)  count <= count +1;
    end
    
  // Task 11
    // Describe state machine registers
    reg [2:0] state, nextstate;

    always @(posedge clk)
    begin
        if(~resetn)	state <= 3'd0;
        else        state <= nextstate;
    end

    
// Task 12
    // Define your states
    // Describe your signals at each state
    always @(*)
    begin
        case(state)

            // Idle state; Here the FSM waits for the start signal
            3'd0: begin
                regA_en <= 1'b1;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_adder1<=1'b1;
                reset_adder2<=1'b1;
                reset_adder3<=1'b1;
                reset_adder4<=1'b1;
            end
            
            3'd1: begin //Do B+M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b1;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_adder1<=1'b1;
                reset_adder2<=1'b1;
                reset_adder3<=1'b1;
                reset_adder4<=1'b1;
            end
            
            3'd2: begin //Save B+M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b1;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder1<=1'b1;
                reset_adder2<=1'b1;
                reset_adder3<=1'b1;
                reset_adder4<=1'b1;
            end
            
            3'd3: begin // ADD 1/2/3/4 iteration
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder1<=1'b0;
                reset_adder2<=1'b0;
                reset_adder3<=1'b1;
                reset_adder4<=1'b1;
            end    
            
            3'd4: begin // ADD 5/6/7/8 iteration
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder1<=1'b0;
                reset_adder2<=1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b1;
            end         
            
            4'd5: begin //Loop
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder1<=1'b0;
                reset_adder2<=1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end
            
            4'd6: begin //C-M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1; //Save final value of C before subtraction
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_adder1<=1'b0;
                reset_adder2<=1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end
            
            4'd7: begin //Write C-M if ~Sum2[1027]
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= ~Sum2[1027];
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b1;      //Save Sum2 instead of Res1=Sum2>>2
                reset_adder1<=1'b0;
                reset_adder2<=1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end
            

            default: begin
                regA_en <= 1'b1;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_adder1<=1'b1;
                reset_adder2<=1'b1;
                reset_adder3<=1'b1;
                reset_adder4<=1'b1;
            end
        endcase
    end
    

// Task 13
    // Describe next_state logic
    always @(*)
    begin
        case(state)
            3'd0: begin
                if(start) nextstate <= 3'd1;
                else      nextstate <= 3'd0; end
            3'd1: nextstate <= 3'd2;
            3'd2: nextstate <= 3'd3;
            3'd3: nextstate <= 3'd4;
            3'd4: nextstate <= 3'd5;
            4'd5:begin
                if (count == 10'd255) nextstate <= 4'd6;
                else nextstate <= 4'd5; end
            4'd6: nextstate <= 4'd7;    
            4'd7: nextstate <= 3'd0;

            default: nextstate <= 3'd0;
        endcase
    end
    

    // Task 14
    // Describe done signal
    // It should be high at the same clock cycle when the output is ready

                reg regDone;
                always @(posedge clk)
                begin
                    if(~resetn) regDone <= 1'd0;
                    else        regDone <= (state==4'd7) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
    
    
  

endmodule
