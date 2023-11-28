`timescale 1ns / 1ps

module montgomery5(
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
    reg [1:0] operand1_sel;
    assign operand1 = operand1_sel[1]? (operand1_sel[0]? regBM_out : {3'b0,in_b}) : (operand1_sel[0]? {3'b0,in_m} : 1027'b0); //Adder selection for first iteration
    
    wire [1026:0] operand2;
    reg [1:0] operand2_sel;
    reg leftshift;
    assign operand2 = leftshift? (operand2_sel[1]? (operand2_sel[0]? {regBM_out,1'b0} : {3'b0,in_b,1'b0}) : (operand2_sel[0]? {3'b0,in_m,1'b0} : 1027'b0)): in_m; //Adder selection for second iteration 
    
    wire [1027:0] Sum1;
    
    mpadder9 adder1(clk, operand1,operand2,Sum1); 
    
    reg [1027:0] Sum1int;
    always @(posedge clk)
    begin
        Sum1int <= Sum1;
    end
    
    wire [1027:0] Sum2;
    wire [1027:0] Res1;
    reg subtract;
    reg reset_adder2;
    mpadder6 adder2(clk, reset_adder2, subtract, Res1, Sum1int, Sum2); //feed the output shifted 2 times directly back, use reset_adder to make output 0
    
    assign Res1 = Sum2 >> 2; //Actual new value of C after 2 iterations
    
    reg p;
    assign regC_in = p? Sum2 : Res1; 
     
    ////////Logic to figure out operand1 and operand2;;;; predicting/pre calculating the bits of c for 10 iterations
    wire [9:0] C_first; //10 bits after +b first iteration
    assign C_first = regA_out[0]? (Res1[9:0]+in_b[9:0]): Res1[9:0];
    
    wire [8:0] C_second; //9 bits after first entire iteration
    wire [9:0] f;
    assign f = (C_first+in_m[9:0]);
    assign C_second = C_first[0]? f[9:1] :C_first[9:1];
    
    wire [8:0] C_third; //9bits after +b second iteration
    assign C_third = regA_out[1]? (C_second+in_b[8:0]):C_second;
    
    wire [7:0] C_fourth; //8bits after second entire iteration
    wire [8:0] g;
    assign g = (C_third+in_m[8:0]);
    assign C_fourth = C_third[0]? g[8:1]: C_third[8:1];
    
    wire [7:0] C_fifth; //8 bits after +b third iteration
    assign C_fifth = regA_out[2]? (C_fourth+in_b[7:0]):C_fourth;
    
    reg [7:0] reg_C5;
    reg [2:0] reg_selectbits;
    reg [9:0] reg_A_bits;
    always @(posedge clk)
    begin
        reg_C5 <= C_fifth;
        reg_selectbits <= {C_fifth[0], C_third[0], C_first[0]};
        reg_A_bits <= regA_out[9:0];
    end
    
    wire [6:0] C6; //7 bits after third entire iteration
    wire [7:0] h;
    assign h = (reg_C5+in_m[7:0]);
    assign C6 = reg_C5[0]? h[7:1]: reg_C5[7:1];
    
    
    
    wire [6:0] C7; //7 bits after +b fourth iteration
    assign C7 = reg_A_bits[3]? (C6+in_b[6:0]):C6;
    
    wire [5:0] C8; //6 bits after fourth entire iteration
    wire [6:0] i;
    assign i = (C7+in_m[6:0]);
    assign C8 = C7[0]? i[6:1]: C7[6:1];
    
    
    
    wire [5:0] C9; //6 bits after +b fifth iteration
    assign C9 = reg_A_bits[4]? (C8+in_b[5:0]):C8;
    
    wire [4:0] C10; //5 bits after fifth entire iteration
    wire [5:0] j;
    assign j = (C9+in_m[5:0]);
    assign C10 = C9[0]? j[5:1]: C9[5:1];
    
    wire [4:0] C11; //5 bits after +b sixth iteration
    assign C11 = reg_A_bits[5]? (C10+in_b[4:0]):C10;
    
    wire [3:0] C12; //4 bits after sixth entire iteration
    wire [4:0] k;
    assign k = (C11+in_m[4:0]);
    assign C12 = C11[0]? k[4:1]: C11[4:1];
    
    wire [3:0] C13; //4 bits after +b seventh iteration
    assign C13 = reg_A_bits[6]? (C12+in_b[3:0]):C12;
    
    wire [2:0] C14; //3 bit after entire seventh iteration
    wire [3:0] l;
    assign l = (C13+in_m[3:0]);
    assign C14 = C13[0]? l[3:1]: C13[3:1];
    
    wire [2:0] C15; //3 bit after +b eigth iteration
    assign C15 = reg_A_bits[7]? (C14+in_b[2:0]):C14;
    
    wire [1:0] C16; //2 bits after eigth entire iteration
    wire [2:0] m;
    assign m = (C15+in_m[2:0]);
    assign C16 = C15[0]? m[2:1]: C15[2:1];
    
    wire [1:0] C17; //2 bits after +b ninth iteration
    assign C17 = reg_A_bits[8]? (C16+in_b[1:0]):C16;
    
    wire C18; //1 bit after ninth entire iteration
    wire [1:0] n;
    assign n = (C17+in_m[1:0]);
    assign C18 = C17[0]? n[1]: C17[1];
    
    wire C19; //1 bit after +b tenth iteration
    assign C19 = reg_A_bits[9]? (C18+in_b[0]):C18;
    
    
    reg [1:0] regoperand1;
    reg [1:0] regoperand2;
    always @(posedge clk)
    begin
        if (count == 9'd508) begin //choose M for subtraction
            regoperand1<=2'b01;
            regoperand2<=2'b00; end
            
        else begin case(state) 
                    3'd2: begin //save first and second iteration operands_sel
                        regoperand1<={reg_A_bits[0], reg_selectbits[0]};
                        regoperand2<={reg_A_bits[1], reg_selectbits[1]}; end
                    3'd3: begin //save third and fourth iteration operands_sel
                        regoperand1<={reg_A_bits[2], reg_selectbits[2]};
                        regoperand2<={reg_A_bits[3], C7[0]}; end
                    3'd4: begin //save fifth and sixth iteration operands_sel
                        regoperand1<={reg_A_bits[4], C9[0]};
                        regoperand2<={reg_A_bits[5], C11[0]}; end            
                    3'd5: begin //save seventh and eight iteration operands_sel
                        regoperand1<={reg_A_bits[6], C13[0]};
                        regoperand2<={reg_A_bits[7], C15[0]}; end
                    default: begin //save next operands_sel
                        regoperand1<={reg_A_bits[8], C17[0]};
                        regoperand2<={reg_A_bits[9], C19}; end  
                 endcase end
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
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                reset_adder2 <= 1'b1;
                leftshift <= 1'b0;
                p <= 1'b0;
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
                p <= 1'b0;
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
                p <= 1'b0;
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
                p <= 1'b0;

            end        
            
            3'd4: begin // ADD third and fourth iteration
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
                p <= 1'b0;
            end
            
            3'd5: begin // ADD fifth and sixth iteration
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
                p <= 1'b0;
            end
            
            3'd6: begin // ADD seventh and eigth iteration
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
                p <= 1'b0;
            end
            
            3'd7: begin //Loop
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
                p <= 1'b0;
            end
            
            4'd8: begin
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
                p <= 1'b0;
            end
            
            4'd9: begin
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
                p <= 1'b1;
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
                p <= 1'b0;
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
            3'd6: nextstate <= 3'd7;
            3'd7:begin
                if (count == 10'd510) nextstate <= 4'd8;
                else nextstate <= 3'd7; end
            4'd8: nextstate <= 4'd9;    
            4'd9: nextstate <= 3'd0;

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
                    else        regDone <= (state==4'd9) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
    
    
  

endmodule
