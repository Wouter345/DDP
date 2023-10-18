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

    reg           regB_en;
    wire [1023:0] regB_in;
    reg  [1023:0] regB_out;
    always @(posedge clk)
    begin
        if(~resetn)         regB_out <= 1024'd0;
        else if (regB_en)   regB_out <= in_b;
    end
  
  // Task 3
    // Describe a 1024-bit register for M

    reg          regM_en;
    wire [1023:0] regM_in;
    reg  [1023:0] regM_out;
    always @(posedge clk)
    begin
        if(~resetn)         regM_out <= 1024'd0;
        else if (regM_en)   regM_out <= in_m;
    end
    
  // Task 4
    // Describe a 1028 bit register for result
    reg          regC_en;
    wire [1027:0]regC_in;
    reg  [1027:0] regC_out;
    always @(posedge clk)
    begin
        if(~resetn)         regC_out <= 1028'd0;
        else if (state == 0)regC_out <= 1028'd0;
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
    

    reg operation1;
    reg operation2;
    reg start_signal;
    
    always @(posedge clk) begin
      if ( (operation1 && operandA) | (operation2 && regC_out[0]) ) begin
        start_signal <= 1'b1;
      end else begin
        start_signal <= 1'b0;
      end
    end
 
    
    mpadder adder(clk,1'b1,start_signal,1'b0,operandC,{3'b0,muxInput2_Out},Sum,done2);

// Task 9
    // design Multixplexer to choose between C or C>>1  
    reg           muxC_sel;
    wire [1027:0] muxC_Out;
    assign muxC_Out = (muxC_sel == 0) ? Sum : Sum>>1;
    assign regC_in  = muxC_Out;
    
    
    reg [9:0] count;
    reg count_en;
    always @(posedge clk) begin
      if (~resetn) count <= 10'b0;
      else if (count_en)  count <= count +1;
      else count <= count;

    end
    
  // Task 11
    // Describe state machine registers
    // Think about how many bits you will need

    reg [1:0] state, nextstate;

    always @(posedge clk)
    begin
        if(~resetn)	state <= 2'd0;
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
            2'd0: begin
                regA_en <= 1'b1;
                regB_en <= 1'b1;
                regM_en <= 1'b1;
                regC_en <= 1'b0;
                muxA_sel <= 1'b0;
                muxC_sel <= 1'b0;
                muxInput2_sel <= 1'b0;
                operation1 <= 1'b0;
                operation2 <= 1'b0;
                count_en <= 1'b0;
                
            end

            // Enable registers, switch muxsel, no carryin
            // Calculate the first addition
            2'd1: begin
                regA_en <= 1'b1;
                regB_en <= 1'b0;
                regM_en <= 1'b1;
                regC_en <= 1'b1;
                muxA_sel <= 1'b1;
                muxC_sel <= 1'b0;
                muxInput2_sel <= 1'b0;
                operation1 <= 1'b1;
                operation2 <= 1'b0;
                count_en <= 1'b1;
            
            end
            
            2'd2: begin
                regA_en <= 1'b1;
                regB_en <= 1'b0;
                regM_en <= 1'b1;
                regC_en <= 1'b1;
                muxA_sel <= 1'b1;
                muxC_sel <= 1'b1;
                muxInput2_sel <= 1'b1;
                operation1 <= 1'b0;
                operation2 <= 1'b1;
                count_en <= 1'b0;
            
            end


            default: begin
                regA_en <= 1'b0;
                regB_en <= 1'b0;
                regM_en <= 1'b0;
                regC_en <= 1'b0;
                muxA_sel <= 1'b1;
                muxC_sel <= 1'b0;
                muxInput2_sel <= 1'b1;
                operation1 <= 1'b0;
                operation2 <= 1'b0;
                count_en <= 1'b0;

            end

        endcase
    end

// Task 13
    // Describe next_state logic



    always @(*)
    begin
        case(state)
            2'd0: begin
                if(start)
                    nextstate <= 2'd1;
                else
                    nextstate <= 2'd0;
                end
            2'd1 : nextstate <= 2'd1;    
            2'd2 : begin
                if (count == 10'd1023) 
                    nextstate <= 2'd3;
                else
                    nextstate <= 2'd1;
                end
            2'd3 : nextstate <= 2'd0;
            
            default: nextstate <= 2'd0;
        endcase
    end

    // Task 14
    // Describe done signal
    // It should be high at the same clock cycle when the output ready

                reg regDone;
                always @(posedge clk)
                begin
                    if(~resetn) regDone <= 1'd0;
                    else        regDone <= (state==2'd3) ? 1'b1 : 1'b0;;
                end

                assign done = regDone;
    
    
  

endmodule
