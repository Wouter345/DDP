`timescale 1ns / 1ps

module montgomery(
  input           clk,
  input           resetn,
  input           start,
  input  [1023:0] in_a,
  input  [1023:0] in_b,
  input  [1023:0] in_m,
  output [1023:0] result,
  output          done
    );

    reg           regA_en;
    reg           shiftA;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if (regA_en)   regA_out <= in_a;
        else if (shiftA) regA_out <= regA_out >> 1;
    end
    
    // This reg will save The value B+M (1024bits+1024bits-->1025bits)
    reg           regBM_en;
    reg  [1027:0] regBM_out;
    always @(posedge clk)
    begin
        if (regBM_en)   regBM_out <= Sum;
    end
    
    reg           regC_en;
    reg  [1027:0] regC_out;
    always @(posedge clk)
    begin
        if (reset)     regC_out <= 1028'd0;
        else if (regC_en)   regC_out <= Sum>>1;
    end
    
    
    
    /// Calculation of C0_new based on A0, B0, C0
    wire C0_new;
    assign C0_new = regA_out[0]? (in_b[0]^regC_out[0]):regC_out[0];
    
    
    // select operand1 and operand2
    reg operand1_sel;
    wire [1026:0] operand1;
    assign operand1 = operand1_sel? regC_out: in_b; 
   
    wire [1026:0] operand2;
    reg [1:0] operand2_sel;
    assign operand2 = operand2_sel[1]? (operand2_sel[0]? regBM_out : {3'b0,in_b}) : (operand2_sel[0]? {3'b0,in_m} : 1027'b0);
    
    
    reg subtract;
    wire [1027:0] Sum;
    wire [1027:0] Res;
    mpadder adder(clk,subtract,operand1,operand2,Sum);
    


    assign result = regBM_out[1027]? regC_out: regBM_out; //At the end C-M will be stored in regBM_out
    
    reg [9:0] count;
    reg count_en; 
    reg reset;
    always @(posedge clk) begin
      if (reset) count <= 10'b0;
      else if (count_en)  count <= count +1;
    end
    
  // Task 11
    // Describe state machine registers
    // Think about how many bits you will need

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
            // Enable input registers to fetch the inputs A and B when start is received
            3'd0: begin
                regA_en <= 1'b1;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 1'b0;
                operand2_sel <= 2'b00;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
            end
            
            3'd1: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 1'b0;
                operand2_sel <= 2'b01;
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b1;
            end
            
            3'd2: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b1;
                regC_en <= 1'b0;
                operand1_sel <= 1'b1;
                operand2_sel <= {regA_out[0], C0_new};
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
            end
            
            3'd3: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 1'b1;
                operand2_sel <= {regA_out[0], C0_new};
                subtract <= 1'b0;
                count_en <= 1'b0;
                reset <= 1'b0;
            end
            
            3'd4: begin
                regA_en <= 1'b0;
                shiftA <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                operand1_sel <= 1'b1;
                operand2_sel <= {regA_out[0], C0_new};
                subtract <= 1'b0;
                count_en <= 1'b1;
                reset <= 1'b0;
            end
            
            3'd5: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                operand1_sel <= 1'b1;
                operand2_sel <= 2'b01;
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
            end
            
            3'd6: begin
                regA_en <= 1'b0;
                shiftA <= 1'b0;
                regBM_en <= 1'b1;
                regC_en <= 1'b0;
                operand1_sel <= 1'b1;
                operand2_sel <= 2'b01;
                subtract <= 1'b1;
                count_en <= 1'b0;
                reset <= 1'b0;
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
            3'd4:begin
                if (count == 10'd1023) nextstate <= 3'd5;
                else nextstate <= 3'd3; end
            3'd5: nextstate <= 3'd6;
            3'd6: nextstate <= 3'd0;

            default: nextstate <= 3'd0;
        endcase
    end
    

    // Task 14
    // Describe done signal
    // It should be high at the same clock cycle when the output ready

                reg regDone;
                always @(posedge clk)
                begin
                    if(~resetn) regDone <= 1'd0;
                    else        regDone <= (state==3'd6) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
    
    
  

endmodule