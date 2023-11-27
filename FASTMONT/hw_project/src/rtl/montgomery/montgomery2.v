`timescale 1ns / 1ps

module montgomery2(
  input           clk,
  input           resetn,
  input           start,
  input  [1023:0] in_a,
  input  [1023:0] in_b,
  input  [1023:0] in_m,
  output [1023:0] result,
  output          done
    );
    
    // In this implementation we do 2 iterations at a time, taking 2 clock cycles to complete.
    
    reg           regA_en;
    reg           shiftA;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if (regA_en)   regA_out <= in_a;
        else if (shiftA) regA_out <= regA_out >> 2; //shift twice
    end
    
    // This reg will save The value B+M and in state 6 the value C-M
    reg           regBM_en;
    reg  [1027:0] regBM_out;
    always @(posedge clk)
    begin
        if (regBM_en)   regBM_out <= Sum2;
    end
    
    reg           regC_en;
    wire [1027:0] regC_in;
    reg  [1027:0] regC_out;
    always @(posedge clk)
    begin
        if (reset)     regC_out <= 1028'd0;
        else if (regC_en)   regC_out <= regC_in; //shift twice
    end
    
    // select operand1 and operand2 and operand3
    wire [1026:0] operand1;
    reg [1:0] operand1_sel;
    assign operand1 = operand1_sel[1]? (operand1_sel[0]? regBM_out : {3'b0,in_b}) : (operand1_sel[0]? {3'b0,in_m} : 1027'b0); //Adder selection for first iteration
    
    wire [1026:0] operand2;
    reg [1:0] operand2_sel;
    assign operand2 = operand2_sel[1]? (operand2_sel[0]? regBM_out : {3'b0,in_b}) : (operand2_sel[0]? {3'b0,in_m} : 1027'b0); //Adder selection for second iteration 
    
    wire [1027:0] Sum1;
    mpadder4 adder1(clk,operand1,{operand2,1'b0},Sum1); //op2*2 --> after >>2 ---> opt/2
    
    wire [1027:0] Sum2;
    reg subtract;
    mpadder adder2(clk, subtract, regC_out, Sum1, Sum2);
    
    wire [1027:0] Res1 = Sum2 >> 2;
    reg selectC;
    assign regC_in = selectC? Res1: in_m;
    
    reg first;
    wire [3:0] Res2 = first? 2'b00 : Res1[3:0];
    
    reg first_en;
    always @(posedge clk)
    begin
        if (reset) first <= 1'b1;
        if (first_en) first <= 1'b0;
    end
    
//    /// Pre calculation of C0/C1 in different stages so as to choose the adder inputs for the 2 iterations
//    wire C0_new; //C0 after +b 1st iteration
//    assign C0_new = regA_out[0]? (in_b[0]^Res2[0]):Res2[0];
    
//    wire C1_new; //C1 after +b 1st iteration
//    assign C1_new = regA_out[0]? ((in_b[1]^Res2[1])^(in_b[0]&&Res2[0])):Res2[1];
    
//    wire C1p;   //C1 after +m 1st iteration
//    assign C1p = C0_new? ((in_m[1]^C1_new)^(in_m[0]&&C0_new)): C1_new;
    
//    wire C1p_new; //C0 after +b 2nd iteration
//    assign C1p_new = regA_out[1]? (in_b[0]^C1p):C1p;
    
    
    wire [3:0] C_first; //4 bits after +b first iteration
    assign C_first = regA_out[0]? (regC_out[3:0]+in_b[3:0]): regC_out[3:0];
    
    wire [2:0] C_second; //3 bits after first entire iteration
    wire [3:0] f;
    assign f = (C_first+in_m[3:0]);
    assign C_second = C_first[0]? f[3:1] :C_first[3:1];
    
    wire [2:0] C_third; //3bits after +b second iteration
    assign C_third = regA_out[1]? (C_second+in_b[2:0]):C_second;
    
    wire [1:0] C_fourth; //2bits after second entire iteration
    wire [2:0] g;
    assign g = (C_third+in_m[2:0]);
    assign C_fourth = C_third[0]? g[2:1]: C_third[2:1];
    
    wire [1:0] C_fifth;
    assign C_fifth = regA_out[2]? (C_fourth+in_b[1:0]):C_fourth;
    
    wire C_sixth;
    wire [1:0] h;
    assign h = (C_fifth+in_m[1:0]);
    assign C_sixth = C_fifth[0]? h[1]: C_fifth[1];
    
    wire C_seventh;
    assign C_seventh = regA_out[3]? (C_sixth+in_b[0]):C_sixth;
    
    
    reg [1:0] regoperand1;
    reg [1:0] regoperand2;
    reg ops;
    always @(posedge clk)
    begin
        if(ops) begin
            regoperand1<={regA_out[0], C_first[0]};
            regoperand2<={regA_out[1], C_third[0]}; end
        else begin
            regoperand1<={regA_out[2], C_fifth[0]};
            regoperand2<={regA_out[3], C_seventh}; end
    end

    assign result = regBM_out[1027]? regC_out: regBM_out; //if bit 1028 is 0 then C-M>0 so C=C-M
    
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
                selectC <= 1'b0;
                ops <= 1'b1;
                first_en <= 1'b0;
            end
            
            3'd1: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                operand1_sel <= 2'b10; //B
                operand2_sel <= 2'b00; //0
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                selectC <= 1'b0;
                ops <= 1'b1;
                first_en <= 1'b0;
            end
            
            3'd7: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b1;
                selectC <= 1'b1;
                ops <= 1'b1;
                first_en <= 1'b0;
            end
            
            3'd2: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b1;
                regC_en <= 1'b0;
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                selectC <= 1'b1;
                ops <= 1'b1;
                first_en <= 1'b0;
            end        
            
            3'd3: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                operand1_sel <= regoperand1;
                operand2_sel <= regoperand2;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                selectC <= 1'b1;
                ops <= 1'b0;
                first_en <= 1'b0;
            end
            
            3'd4: begin
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 2'b00; 
                operand2_sel <= 2'b00;
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                selectC <= 1'b1;
                ops <= 1'b0;
                first_en <= 1'b1;
            end
            
            4'd8: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                operand1_sel <= 2'b01;
                operand2_sel <= 2'b00;
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                selectC <= 1'b1;
                ops <= 1'b0;
                first_en <= 1'b0;
            end
            
            3'd5: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                selectC <= 1'b1;
                ops <= 1'b0;
                first_en <= 1'b0;
            end
            
            3'd6: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b1;
                regC_en <= 1'b0;
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00;
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                selectC <= 1'b1;
                ops <= 1'b0;
                first_en <= 1'b0;
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
                selectC <= 1'b1;
                ops <= 1'b0;
                first_en <= 1'b0;
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
            3'd1: nextstate <= 3'd7;
            3'd7: nextstate <= 3'd2;
            3'd2: nextstate <= 3'd3;
            3'd3: nextstate <= 3'd4;
            3'd4:begin
                if (count == 10'd511) nextstate <= 4'd8;
                else nextstate <= 3'd3; end
            4'd8: nextstate <= 3'd5;    
            3'd5: nextstate <= 3'd6;
            3'd6: nextstate <= 3'd0;

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
                    else        regDone <= (state==3'd6) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
    
    
  

endmodule
