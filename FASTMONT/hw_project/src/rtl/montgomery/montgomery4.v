`timescale 1ns / 1ps

module montgomery4(
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
    
    // select operand1 and operand2 and operand3
    wire [1026:0] operand1;
    reg [1:0] operand1_sel;
    assign operand1 = operand1_sel[1]? (operand1_sel[0]? regBM_out : {3'b0,in_b}) : (operand1_sel[0]? {3'b0,in_m} : 1027'b0); //Adder selection for first iteration
    
    wire [1026:0] operand2;
    reg [1:0] operand2_sel;
    assign operand2 = operand2_sel[1]? (operand2_sel[0]? regBM_out : {3'b0,in_b}) : (operand2_sel[0]? {3'b0,in_m} : 1027'b0); //Adder selection for second iteration 
    
    wire [1027:0] Sum1;
    reg leftshift;
    mpadder7 adder1(clk,leftshift, operand1,operand2,Sum1); //op2*2 --> after >>2 ---> opt/2
    
    wire [1027:0] Sum2;
    wire [1027:0] Res1;
    reg subtract;
    reg reset_adder2;
    mpadder6 adder2(clk, reset_adder2, subtract, Res1, Sum1, Sum2); //feed the output shifted 2 times directly back, use reset_adder to make output 0
    
    assign Res1 = Sum2 >> 2; //Actual new value of C after 2 iterations
    assign regC_in = subtract? Sum2 : Res1; 
     
    ////////Logic to figure out operand1 and operand2;;;; predicting/pre calculating the bits of c
    wire [5:0] C_first; //6 bits after +b first iteration
    assign C_first = regA_out[0]? (Res1[5:0]+in_b[5:0]): Res1[5:0];
    
    wire [4:0] C_second; //5 bits after first entire iteration
    wire [5:0] f;
    assign f = (C_first+in_m[5:0]);
    assign C_second = C_first[0]? f[5:1] :C_first[5:1];
    
    wire [4:0] C_third; //5bits after +b second iteration
    assign C_third = regA_out[1]? (C_second+in_b[4:0]):C_second;
    
    wire [3:0] C_fourth; //4bits after second entire iteration
    wire [4:0] g;
    assign g = (C_third+in_m[4:0]);
    assign C_fourth = C_third[0]? g[4:1]: C_third[4:1];
    
    wire [3:0] C_fifth; //4 bits after +b third iteration
    assign C_fifth = regA_out[2]? (C_fourth+in_b[3:0]):C_fourth;
    
    wire [2:0] C_sixth; //3 bits after third entire iteration
    wire [3:0] h;
    assign h = (C_fifth+in_m[3:0]);
    assign C_sixth = C_fifth[0]? h[3:1]: C_fifth[3:1];
    
    wire [2:0] C_seventh; //3 bits after +b fourth iteration
    assign C_seventh = regA_out[3]? (C_sixth+in_b[2:0]):C_sixth;
    
    wire [1:0] C8; //2 bits after fourth entire iteration
    wire [2:0] i;
    assign i = (C_seventh+in_m[2:0]);
    assign C8 = C_seventh[0]? i[2:1]: C_seventh[2:1];
    
    wire [1:0] C9; //2 bits after +b fifth iteration
    assign C9 = regA_out[4]? (C8+in_b[1:0]):C8;
    
    wire C10; //1 bit after fifth entire iteration
    wire [1:0] j;
    assign j = (C9+in_m[1:0]);
    assign C10 = C9[0]? j[1]: C9[1];
    
    wire C11; //1 bit after +b sixth iteration
    assign C11 = regA_out[5]? (C10+in_b[0]):C10;
    
    reg [1:0] regoperand1;
    reg [1:0] regoperand2;
    always @(posedge clk)
    begin
        if (count == 9'd509) begin //choose M for subtraction
            regoperand1<=2'b01;
            regoperand2<=2'b00; end
        else if(state == 3'd2) begin //save first and second iteration operands_sel
            regoperand1<={regA_out[0], C_first[0]};
            regoperand2<={regA_out[1], C_third[0]}; end
        else if (state == 3'd3) begin //save third and fourth iteration operands_sel
            regoperand1<={regA_out[2], C_fifth[0]};
            regoperand2<={regA_out[3], C_seventh}; end
        else begin //save next operands_sel
            regoperand1<={regA_out[4], C9[0]};
            regoperand2<={regA_out[5], C11}; end
    end

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
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b0;
            end
            
            3'd1: begin //Do B+M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 2'b10; //B
                operand2_sel <= 2'b01; //M
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b1;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b0;
            end
            
            3'd2: begin //Save B+M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b1;
                regC_en <= 1'b0;
                operand1_sel <= 2'b00;//0
                operand2_sel <= 2'b00;//0
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b1;
            end
            
            3'd3: begin // ADD first and second iteration
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= regoperand1;
                operand2_sel <= regoperand2;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b1;

            end        
            
            3'd4: begin
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= regoperand1;
                operand2_sel <= regoperand2;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b1;
            end
            
            3'd5: begin
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                operand1_sel <= regoperand1; 
                operand2_sel <= regoperand2;
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b1;
            end
            
            4'd6: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1; //Save final value of C before subtraction
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b0;
            end
            
            3'd7: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= ~Sum2[1027];
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b0;

            end
            

            default: begin
                regA_en <= 1'b1;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 1'b0;
                operand2_sel <= 2'b00;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b0;
                leftshift <= 1'b0;
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
            3'd5:begin
                if (count == 10'd510) nextstate <= 3'd6;
                else nextstate <= 3'd5; end
            3'd6: nextstate <= 3'd7;    
            3'd7: nextstate <= 3'd0;

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
                    else        regDone <= (state==3'd7) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
    
    
  

endmodule
