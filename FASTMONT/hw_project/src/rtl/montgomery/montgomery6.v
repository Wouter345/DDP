`timescale 1ns / 1ps

module montgomery6(
  input           clk,
  input           resetn,
  input           start,
  input  [1023:0] in_a,
  input  [1023:0] in_b,
  input  [1023:0] in_m,
  output [1023:0] result,
  output          done
    );
    
    // In this implementation we do 2 iterations at a time, taking 1 clock cycles to complete.
    
    reg           regA_en;
    reg           shiftA;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if (regA_en)   regA_out <= in_a;
        else if (shiftA) regA_out <= regA_out >> 2; //shift once
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
    
    // select operand1 and operand2
    wire [1026:0] operand1;
    wire [1:0] operand1_sel;
    assign operand1 = operand1_sel[1]? (operand1_sel[0]? regBM_out : {3'b0,in_b}) : (operand1_sel[0]? {3'b0,in_m} : 1027'b0); //Adder selection for first iteration
    
    wire [1026:0] operand2;
    wire [1:0] operand2_sel;
    reg leftshift;
    assign operand2 = leftshift? (operand2_sel[1]? (operand2_sel[0]? {regBM_out,1'b0} : {3'b0,in_b,1'b0}) : (operand2_sel[0]? {3'b0,in_m,1'b0} : 1027'b0)): in_m; //Adder selection for second iteration 
    
    wire [1027:0] Sum1;
    
    mpadder9 adder1(clk, operand1,operand2,Sum1); 
    
    reg [1027:0] Sum1int;
    reg reset_sumint;
    always @(posedge clk)
    begin
        if (reset_sumint) Sum1int <= 1028'b0;
        else Sum1int <= Sum1;
    end
    
    wire [1027:0] Sum2;
    wire [1027:0] Res1;
    reg subtract;
    reg reset_adder2;
    mpadder6 adder2(clk, reset_adder2, subtract, Res1, Sum1int, Sum2); //feed the output shifted 2 times directly back, use reset_adder to make output 0
    
    assign Res1 = Sum2 >> 2; //Actual new value of C after 2 iterations
    
    reg p;
    assign regC_in = p? Sum2 : Res1; 
     
    ////////Logic to figure out regoperand 8 iterations down the line
    wire [7:0] C_new; // calculate sum of 10LSB in one clock cycles --> more time (2 cycles) for logic below to finish
    assign C_new = (Res1[9:0]+Sum1int[9:0])>>2;
    
    wire [7:0] C1; //8 bits after +b first iteration
    assign C1 = C_new[7:0]+ (in_b[7:0] & {regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0]});
    
    wire [6:0] C2; //7 bits after +b second iteration
    assign C2 = ((C1 + (in_m[7:0] & {C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0]}))>>1) + (in_b[6:0] & {regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1]});
    
    wire [5:0] C3; //6 bits after +b third iteration
    assign C3 = ((C2 + (in_m[6:0] & {C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0]}))>>1) + (in_b[5:0] & {regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2]});
    
    reg [5:0] reg_C3;
    reg [2:0] reg_selectbits1;
    reg [7:0] reg_A_bits1;
    always @(posedge clk)
    begin
        reg_C3 <= C3;
        reg_selectbits1 <= {C3[0], C2[0], C1[0]};
        reg_A_bits1 <= regA_out[7:0];
    end
    
    wire [4:0] C4; //5 bits after +b fourth iteration
    assign C4 = ((reg_C3 + (in_m[5:0] & {reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0]}))>>1) + (in_b[4:0] & {reg_A_bits1[3], reg_A_bits1[3], reg_A_bits1[3], reg_A_bits1[3], reg_A_bits1[3]});
    
    wire [3:0] C5; //4 bits after +b fifth iteration
    assign C5 = ((C4 + (in_m[4:0] & {C4[0], C4[0], C4[0], C4[0], C4[0]}))>>1) + (in_b[3:0] & {reg_A_bits1[4], reg_A_bits1[4], reg_A_bits1[4], reg_A_bits1[4]});
    
    wire [2:0] C6; //3 bits after +b sixth iteration
    assign C6 = ((C5 + (in_m[3:0] & {C5[0], C5[0], C5[0], C5[0]}))>>1) + (in_b[2:0] & {reg_A_bits1[5], reg_A_bits1[5], reg_A_bits1[5]});
    
    wire [1:0] C7; //2 bits after +b seventh iteration
    assign C7 = ((C6 + (in_m[2:0] & {C6[0], C6[0], C6[0]}))>>1) + (in_b[1:0] & {reg_A_bits1[6], reg_A_bits1[6]});

    wire C8; //1 bits after +b eigth iteration
    assign C8 = ((C7 + (in_m[1:0] & {C7[0], C7[0]}))>>1) + (in_b[0] & {reg_A_bits1[7]});


    reg [1:0] regoperand1;
    reg [1:0] regoperand2;
    always @(posedge clk)
    begin
        if (count == 9'd508) begin //M+0 for subtraction of C-M
            regoperand1<=2'b01;
            regoperand2<=2'b00; end
            
        else begin case(state)
                    3'd0: begin //B+M
                        regoperand1<=2'b10;
                        regoperand2<=2'b01; end 
                    3'd1: begin //0+0
                        regoperand1<=2'b00;
                        regoperand2<=2'b00; end  
                    3'd2: begin //save first and second iteration operands_sel
                        regoperand1<={reg_A_bits1[0], reg_selectbits1[0]};
                        regoperand2<={reg_A_bits1[1], reg_selectbits1[1]}; end
                    3'd3: begin //save third and fourth iteration operands_sel
                        regoperand1<={reg_A_bits1[2], reg_selectbits1[2]};
                        regoperand2<={reg_A_bits1[3], C4[0]}; end
                    3'd4: begin //save fifth and sixth iteration operands_sel
                        regoperand1<={reg_A_bits1[4], C5[0]};
                        regoperand2<={reg_A_bits1[5], C6[0]}; end          
                    default: begin //save next operands_sel
                        regoperand1<={reg_A_bits1[6], C7[0]};
                        regoperand2<={reg_A_bits1[7], C8}; end
                 endcase end
    end
    
    assign operand1_sel = regoperand1;
    assign operand2_sel = regoperand2;

    assign result = regC_out; //if bit 1028 is 0 then C-M>0 so C=C-M
    
    reg [8:0] count;
    reg count_en; 
    reg reset;
    always @(posedge clk) begin
      if (reset) count <= 9'b0;
      else if (count_en)  count <= count +1;
    end
    
  // Task 11
    // Describe state machine registers
    reg [3:0] state, nextstate;

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
                reset_adder2 <= 1'b1;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_sumint <= 1'b1;
            end
            
            3'd1: begin //Do B+M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b1;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_sumint <= 1'b1;
            end
            
            3'd2: begin //Save B+M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b1;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_sumint <= 1'b1;
            end
            
            3'd3: begin // ADD first and second iteration
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_sumint <= 1'b1;

            end        
            
            3'd4: begin // ADD third and fourth iteration
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_sumint <= 1'b0;
            end
            
            3'd5: begin // ADD fifth and sixth iteration
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_sumint <= 1'b0;
            end     
            
            4'd6: begin //Loop
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_sumint <= 1'b0;
            end
            
            4'd7: begin //C-M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1; //Save final value of C before subtraction
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_sumint <= 1'b0;
            end
            
            4'd8: begin //Write C-M if ~Sum2[1027]
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= ~Sum2[1027];
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b1;      //Save Sum2 instead of Res1=Sum2>>2
                reset_sumint <= 1'b0;
            end
            

            default: begin
                regA_en <= 1'b1;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_sumint <= 1'b0;
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
            3'd5: nextstate <= 3'd6;
            4'd6:begin
                if (count == 10'd510) nextstate <= 4'd7;
                else nextstate <= 4'd6; end
            4'd7: nextstate <= 4'd8;    
            4'd8: nextstate <= 3'd0;

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
                    else        regDone <= (state==4'd8) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
    
    
  

endmodule
