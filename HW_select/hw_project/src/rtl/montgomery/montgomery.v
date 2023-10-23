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

  // Student tasks:
  // 1. Instantiate an Adder
  // 2. Use the Adder to implement the Montgomery multiplier in hardware.
  // 3. Use tb_montgomery.v to simulate your design.
  
  
  // Task 1
    // Describe a 1024-bit register for A
    // It will save the input data when enable signal is high

    reg           regA_en;
    wire [1023:0] regA_in;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 1024'd0;
        else if (regA_en)   regA_out <= regA_in;
    end
    
// Task 2
    // Describe a 1024-bit register for B

    reg           regBM_en;
    wire [1023:0] regB_in;
    reg  [1023:0] regB_out;
    always @(posedge clk)
    begin
        if(~resetn)         regB_out <= 1024'd0;
        else if (regBM_en)   regB_out <= in_b;
    end
  
  // Task 3
    // Describe a 1024-bit register for M

    wire [1023:0] regM_in;
    reg  [1023:0] regM_out;
    always @(posedge clk)
    begin
        if(~resetn)         regM_out <= 1024'd0;
        else if (regBM_en)   regM_out <= in_m;
    end
    
  // Task 4
    // Describe a 1028 bit register for result
    reg           regC_en;
    wire [1027:0] regC_in;
    reg  [1027:0] regC_out;
    always @(posedge clk)
    begin
        if(~resetn)         regC_out <= 1028'd0;
        if (state == 4'd3)  regC_out <= regC_out >> 1;
        //else if (state == 0)regC_out <= 1028'd0;
        else if (regC_en)   regC_out <= regC_in;
    end
    
  // Task 5
    // Describe a 2-input 1024-bit Multiplexer for A
    // It should select either of these two:
    //   - the input A
    //   - the output of regA shifted-right by 1
    // Also connect the output of Mux to regA's input
    
    reg           muxA_sel;
    wire [1023:0] muxA_Out;
    assign muxA_Out = (muxA_sel == 0) ? in_a : {1'b0,regA_out[1023:1]};
    assign regA_in = muxA_Out;
 
    
   // Task 7 
     //If ai = 1 do C+B
    wire          operandA;
    wire [1023:0] operandB;
    wire [1026:0] operandC;
    wire [1023:0] operandM;
    wire [1027:0] Sum;
    wire          done2;

    assign operandA = regA_out;
    assign operandB = regB_out;
    assign operandM = regM_out;
    assign operandC = regC_out;
    
  // Task 8
    // design Multiplexer to choose between adder input B or M;
    reg           muxInput2_sel;
    wire [1023:0] muxInput2_Out;
    assign muxInput2_Out = (muxInput2_sel == 0) ? operandB : operandM;
   
    
    
    reg subtract;
    reg start_signal;
    reg resetn_signal;
    mpadder adder(clk,resetn_signal,start_signal,subtract,operandC,{3'b0,muxInput2_Out},Sum,done2);

  
    
    assign regC_in = (state == 4'd4) ? Sum >> 1: Sum;
    assign result = regC_out;
    
    reg [10:0] count;
    reg count_en;
    reg reset;
    always @(posedge clk) begin
      if (~resetn) count <= 10'b0;
      else if (reset) count <= 10'b0;
      else if (count_en)  count <= count +1;
    end
    
  // Task 11
    // Describe state machine registers
    // Think about how many bits you will need

    reg [3:0] state, nextstate;

    always @(posedge clk)
    begin
        if(~resetn)	state <= 4'd0;
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
            4'd0: begin
                regA_en <= 1'b1;
                regBM_en <= 1'b1;
                regC_en <= 1'b0;
                muxA_sel <= 1'b0;
                muxInput2_sel <= 1'b0;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b1;
                resetn_signal <= 1'b0;
                start_signal <= 1'b0;
            end

            // Enable registers, switch muxsel, no carryin
            // Calculate the first addition
            4'd1: begin
                regA_en <= 1'b1;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b0;
                count_en <= 1'b1;
                subtract <= 1'b0;
                reset <= 1'b0;
                resetn_signal <= 1'b1;
                if (operandA) start_signal <= 1'b1;
                else start_signal <= 1'b0;
            end
            
            4'd2: begin
                regA_en <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b1;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b0;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b0;
                start_signal <= 1'b0;
                resetn_signal <= 1'b1;
            end

            4'd3: begin
                regA_en <= 1'b0;
                regBM_en  <= 1'b0;
                regC_en <= 1'b1;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b0;
                resetn_signal <= 1'b1;
                if (operandC[0]) start_signal <= 1'b1;
                else start_signal <= 1'b0;
            end
            
            4'd4: begin
                regA_en <= 1'b0;
                regBM_en  <= 1'b0;
                regC_en <= 1'b1;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b0;
                resetn_signal <= 1'b1;
                start_signal <= 1'b0;
            end


            4'd5: begin
                regA_en <= 1'b0;
                regBM_en  <= 1'b0;
                regC_en <= 1'b0;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b1;
                reset <= 1'b0;
                resetn_signal <= 1'b1;
                start_signal <= 1'b1;
            end
            
            4'd6: begin
                regA_en <= 1'b0;
                regBM_en  <= 1'b0;
                regC_en <= 1'b0;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b1;
                reset <= 1'b0;
                resetn_signal <= 1'b1;
                start_signal <= 1'b0;
            end
            
            4'd7: begin
                regA_en <= 1'b0;
                regBM_en  <= 1'b0;
                regC_en <= 1'b0;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b1;
                reset <= 1'b0;
                resetn_signal <= 1'b1;
                start_signal <= 1'b0;
            end

            4'd8: begin
                regA_en <= 1'b0;
                regBM_en  <= 1'b0;
                if (Sum[1027]) regC_en <= 1'b0;
                else regC_en <= 1'b1;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b1;
                reset <= 1'b0;
                resetn_signal <= 1'b1;
                start_signal <= 1'b0;
            end
            
            
            default: begin
                regA_en <= 1'b0;
                regBM_en <= 1'b0;
                regC_en <= 1'b0;
                muxA_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b1;
                start_signal <= 1'b0;
                resetn_signal <= 1'b0;

            end

        endcase
    end

// Task 13
    // Describe next_state logic



    always @(*)
    begin
        case(state)
            4'd0: begin
                if(start)
                    nextstate <= 4'd1;
                else
                    nextstate <= 4'd0;
                end
            4'd1 : 
                if(operandA)
                    nextstate <= 4'd2;    
                else
                    nextstate <= 4'd3;
            4'd2 : begin
                if (done2 == 1'b1) 
                    nextstate <= 4'd3;
                else
                    nextstate <= 4'd2;
                end
             4'd3 : begin
                if (operandC[0]) 
                    nextstate <= 4'd4;
                else if (count == 11'd1024) nextstate <= 4'd5;
                else nextstate <= 4'd1;
                end
             4'd4 : begin
                if (done2 == 1'b1)
                  if (count == 11'd1024) nextstate <= 4'd5;
                  else  nextstate <= 4'd1;
                else
                    nextstate <= 4'd4;
                end
             4'd5 : nextstate <= 4'd6;
             4'd6 : nextstate <= 4'd7;
             4'd7 : nextstate <= 4'd8;
             4'd8 : nextstate <= 4'd0;
            
             default: nextstate <= 4'd0;
        endcase
    end

    // Task 14
    // Describe done signal
    // It should be high at the same clock cycle when the output ready

                reg regDone;
                always @(posedge clk)
                begin
                    if(~resetn) regDone <= 1'd0;
                    else        regDone <= (state==4'd8) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
    
    
  

endmodule
