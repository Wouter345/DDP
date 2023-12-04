`timescale 1ns / 1ps

module montgomeryA(
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
    
    // This reg will save The value B+M 
    reg           regBM_en;
    reg  [1024:0] regBM_out;//1025bits
    always @(posedge clk)
    begin
        if (regBM_en)   regBM_out <= Sum1;
    end
    
    reg           regC_en;
    wire [1023:0] regC_in;
    reg  [1023:0] regC_out;//Final value is 1024bits
    always @(posedge clk)
    begin
        if (reset)     regC_out <= 1024'd0;
        else if (regC_en)   regC_out <= regC_in; 
    end
    
    // select operand1/2/3/4
    wire [1025:0] operand1;//1026 bits
    reg [1:0] operand1_sel;
    assign operand1 = operand1_sel[1]? (operand1_sel[0]? regBM_out : {2'b0,in_b}) : (operand1_sel[0]? {2'b0,in_m} : 1026'b0); //Adder selection for first iteration
    
    wire [1025:0] operand2;//1026 bits
    reg [1:0] operand2_sel;
    reg leftshift;
    assign operand2 = leftshift? (operand2_sel[1]? (operand2_sel[0]? {regBM_out,1'b0} : {1'b0,in_b,1'b0}) : (operand2_sel[0]? {1'b0,in_m,1'b0} : 1026'b0)): {2'b0,in_m}; //Adder selection for second iteration 
    
    wire [1027:0] operand3;//1028bits
    reg [1:0] operand3_sel;
    assign operand3 = operand3_sel[1]? (operand3_sel[0]? {1'b0,regBM_out,2'b0} : {2'b0,in_b,2'b0}) : (operand3_sel[0]? {2'b0,in_m,2'b0} : 1028'b0); //Adder selection for first iteration

    wire [1027:0] operand4;//1028bits
    reg [1:0] operand4_sel;
    assign operand4 = operand4_sel[1]? (operand4_sel[0]? {regBM_out,3'b0} : {1'b0,in_b,3'b0}) : (operand4_sel[0]? {1'b0,in_m,3'b0} : 1028'b0); //Adder selection for first iteration


    reg [1025:0] reg_operand1;
    reg [1025:0] reg_operand2;
    reg [1027:0] reg_operand3;
    reg [1027:0] reg_operand4;
    always @(posedge clk)
    begin
        reg_operand1 <= operand1;
        reg_operand2 <= operand2;
        reg_operand3 <= operand3;
        reg_operand4 <= operand4;
    end


    wire [1026:0] Sum1;//1027bits
    wire [1028:0] Sum2;//1029bits
    wire [15:0] prediction1;
    wire [15:0] prediction2;
    mpadderA adder1(clk, reg_operand1, reg_operand2, Sum1, prediction1); 
    mpadderB adder2(clk, reg_operand3, reg_operand4, Sum2, prediction2);
    
    wire [1029:0] Sum3;//1030bits
    reg reset_adder3;
    wire [19:0] prediction3;
    mpadderC adder3(clk, reset_adder3, {2'b0,Sum1}, Sum2, Sum3, prediction3);
    
    wire [1030:0] Sum4;//1030bits
    wire [1026:0] Res4;//shifted by 4 --> 1027bits
    wire [23:0] prediction4;
    reg subtract;
    reg reset_adder4;
    mpadderD adder4(clk, reset_adder4, subtract, {3'b0,Res4}, Sum3, Sum4, prediction4); //feed the output shifted 4 times directly back, use reset_adder4 to make output 0
    
    assign Res4 = Sum4 >> 4;
    
    reg p;
    assign regC_in = p? Sum4 : Res4; //to choose between shifting and not shifting Sum4 (for C-M)
     
    ////////Logic to figure out the next four iterations 
    wire [11:0] prediction_sum;
    assign prediction_sum = ((((prediction4>>4)+prediction3)>>4)+prediction1 + prediction2)>>4;
    wire [11:0] operandsum;
    assign operandsum = operand1[11:0] + operand2[11:0] + operand3[11:0] + operand4[11:0];
    
    reg [11:0] predict;
    reg [11:0] reg_operandsum;
    always @(posedge clk)
    begin
        predict <= prediction_sum;
        reg_operandsum <= operandsum;
    end
    
    wire [7:0] C_new; 
    //assign C_new = (((((Res4[19:0]+Sum3[19:0])>>4) + Sum1[15:0] + Sum2[15:0])>>4) + reg_operand1[11:0] + reg_operand2[11:0] + reg_operand3[11:0] + reg_operand4[11:0])>>4;
    assign C_new = (predict + reg_operandsum)>>4;

    
    wire [7:0] C1; //8 bits after +b first iteration
    assign C1 = C_new[7:0]+ (in_b[7:0] & {regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0], regA_out[0]});
    
    wire[6:0] C2; //7 bits after +b 2th iteration
    assign C2 = ((C1 + (in_m[7:0] & {C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0], C1[0]})) >> 1) + (in_b[6:0] & {regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1], regA_out[1]});
    
    wire[5:0] C3; //6 bits after +b 3th iteration
    assign C3 = ((C2 + (in_m[6:0] & {C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0], C2[0]})) >> 1) + (in_b[5:0] & {regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2], regA_out[2]});

    
    reg [5:0] reg_C3;
    reg [2:0] select_bits;
    reg [7:0] Abits;
    always @(posedge clk)
    begin
        reg_C3 <= C3;
        select_bits <= {C3[0], C2[0], C1[0]};
        Abits <= regA_out[7:0];
    end
          
    wire[4:0] C4; //5 bits after +b 4th iteration
    assign C4 = ((reg_C3 + (in_m[5:0] & {reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0], reg_C3[0]})) >> 1) + (in_b[4:0] & {Abits[3], Abits[3], Abits[3], Abits[3], Abits[3], Abits[3], Abits[3], Abits[3], Abits[3], Abits[3], Abits[3], Abits[3]});
    
    wire[3:0] C5; //4 bits after +b 5th iteration
    assign C5 = ((C4 + (in_m[4:0] & {C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0], C4[0]})) >> 1) + (in_b[3:0] & {Abits[4], Abits[4], Abits[4], Abits[4], Abits[4], Abits[4], Abits[4], Abits[4], Abits[4], Abits[4], Abits[4], Abits[4]});
    
    wire[2:0] C6; //3 bits after +b 6th iteration
    assign C6 = ((C5 + (in_m[3:0] & {C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0], C5[0]})) >> 1) + (in_b[2:0] & {Abits[5], Abits[5], Abits[5], Abits[5], Abits[5], Abits[5], Abits[5], Abits[5], Abits[5], Abits[5], Abits[5], Abits[5]});
    
    wire[1:0] C7; //2 bits after +b 7th iteration
    assign C7 = ((C6 + (in_m[2:0] & {C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0], C6[0]})) >> 1) + (in_b[1:0] & {Abits[6], Abits[6], Abits[6], Abits[6], Abits[6], Abits[6], Abits[6], Abits[6], Abits[6], Abits[6], Abits[6], Abits[6]});
    
    wire C8; //1 bits after +b 8th iteration
    assign C8 = ((C7 + (in_m[1:0] & {C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0], C7[0]})) >> 1) + (in_b[0] & {Abits[7], Abits[7], Abits[7], Abits[7], Abits[7], Abits[7], Abits[7], Abits[7], Abits[7], Abits[7], Abits[7], Abits[7]});
    

    always @(*)
    begin
        case(state)
            3'd0: begin //B+M
                operand1_sel <= 2'b10;
                operand2_sel <= 2'b01; 
                operand3_sel <= 2'b00;
                operand4_sel <= 2'b00; end
            3'd1: begin //all zeros
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00; 
                operand3_sel <= 2'b00;
                operand4_sel <= 2'b00; end
            3'd2: begin//all zeros
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00; 
                operand3_sel <= 2'b00;
                operand4_sel <= 2'b00; end
            4'd14: begin//all zeros
                operand1_sel <= 2'b00;
                operand2_sel <= 2'b00; 
                operand3_sel <= 2'b00;
                operand4_sel <= 2'b00; end
            4'd15: begin
                operand1_sel <= {Abits[0], select_bits[0]};
                operand2_sel <= {Abits[1], select_bits[1]};
                operand3_sel <= {Abits[2], select_bits[2]};
                operand4_sel <= {Abits[3], C4[0]}; end  
            3'd4: begin//M and zeros
                operand1_sel <= 2'b01;
                operand2_sel <= 2'b00; 
                operand3_sel <= 2'b00;
                operand4_sel <= 2'b00; end
            default: begin
                operand1_sel <= {Abits[4], C5[0]};
                operand2_sel <= {Abits[5], C6[0]};
                operand3_sel <= {Abits[6], C7[0]};
                operand4_sel <= {Abits[7], C8}; end          
        endcase
    end

    assign result = regC_out; //if bit 1028 is 0 then C-M>0 so C=C-M
    
    reg [7:0] count;
    reg count_en; 
    reg reset;
    always @(posedge clk) begin
      if (reset) count <= 8'b0;
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
                leftshift <= 1'b0;
                p <= 1'b0;
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
                leftshift <= 1'b1;
                p <= 1'b0;
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
                reset_adder3<=1'b1;
                reset_adder4<=1'b1;
            end
            
            4'd14: begin  //buffer state to give logic time to calculate
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder3<=1'b1;
                reset_adder4<=1'b1;
            end 
            
            4'd15: begin  // iteration 1/2/3/4
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end 
            
            3'd3: begin  //LOOP
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end    

            
            4'd4: begin //LOAD M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1; 
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                leftshift <= 1'b1;
                p <= 1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end
            
            4'd5: begin //ADD M+0
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1; 
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end
            
            4'd6: begin //wait for M to reach adder 4
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1; 
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end
            
            4'd7: begin //DO C-M
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1; 
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b0;
                reset_adder3<=1'b0;
                reset_adder4<=1'b0;
            end
            
            4'd8: begin //Write C-M if ~Sum2[1027]
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= ~Sum4[1030];
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
                leftshift <= 1'b0;
                p <= 1'b1;      //Save Sum2 instead of Res1=Sum2>>2
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
            4'd2: nextstate <= 4'd14;
            4'd14: nextstate <= 4'd15;
            4'd15: nextstate <= 4'd3;
            4'd3:begin
                if (count == 10'd255) nextstate <= 4'd4;
                else nextstate <= 4'd3; end
            4'd4: nextstate <= 4'd5;   
            4'd5: nextstate <= 4'd6;  
            4'd6: nextstate <= 3'd7;
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
