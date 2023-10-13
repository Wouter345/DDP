`timescale 1ns / 1ps

module mpadder(
  input  wire          clk,
  input  wire          resetn,
  input  wire          start,
  input  wire          subtract,
  input  wire [1026:0] in_a,
  input  wire [1026:0] in_b,
  output wire [1027:0] result,
  output wire          done   
  );

    
// Task 1
    // Describe a 514-bit register for A
    // It will save the input data when enable signal is high

    reg          regA_en;
    reg  [513:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 514'd0;
        else if (regA_en)   regA_out <= in_a[1026:514];
    end
    
   
// Task 2   
    // Describe a 2 input mux choosing B or ~B+1
    wire [1026:0] MuxBin_Out;
    assign MuxBin_Out = (subtract == 0)? in_b : ~in_b;
    
    
// Task 3
    // Describe a 514-bit register for B

    reg           regB_en;
    reg  [513:0] regB_out;
    always @(posedge clk)
    begin
        if(~resetn)         regB_out <= 514'd0;
        else if (regB_en)   regB_out <= MuxBin_Out[1026:514];
    end
    
    
// Task 4
    // Define 2 multixplexers that give either the input value or register value to operandA and operandB
    wire [513:0] operandA;
    wire [513:0] operandB;
    
    reg muxOperandA_sel;
    reg muxOperandB_sel;
    
    assign operandA = (muxOperandA_sel == 0) ? in_a: regA_out;
    assign operandB = (muxOperandB_sel == 0) ? MuxBin_Out: regB_out;
    
    
// Task 5
    // Describe 2 1-bit multiplexers for selecting carry-in depending on subtraction 
    
    wire      carry_in;
    reg       muxsub_sel;
    wire      muxsub_in;
    assign muxsub_in = (muxsub_sel == 0) ? regCout : subtract;
    
    assign carry_in = muxsub_in;
    
    
// Task 6
    // Describe an adder   

    wire [513:0] Sum;
    wire         carry_out;

    assign {carry_out,Sum} = operandA + operandB + carry_in;

// Task 7
    // Describe a 1028-bit register for storing the sum

    reg           regSum_en;
    reg  [1027:0] regSum;
    always @(posedge clk)
    begin
        if(~resetn)          regSum <= 1028'b0;
        else if (regSum_en)  regSum <= {Sum, regSum[1027:514]};
    end

// Task 8
    // Describe a 1-bit register for storing the carry-out

    reg  regCout_en;
    reg  regCout;
    always @(posedge clk)
    begin
        if(~resetn)          regCout <= 1'b0;
        else if (regCout_en) regCout <= carry_out;
    end
    

// Task 9
    // Describe output
    wire      carry;
    
    assign carry = subtract ^ regSum[1027];
    assign result = {carry,regSum[1026:0]};

// Task 11
    // Describe state machine registers
    // Think about how many bits you will need

    reg [0:0] state, nextstate;

    always @(posedge clk)
    begin
        if(~resetn)	state <= 1'd0;
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
                regA_en        <= 1'b1;
                regB_en        <= 1'b1;
                regSum_en      <= 1'b1;
                regCout_en     <= 1'b1;
                muxsub_sel     <= 1'b1;
                muxOperandA_sel <= 1'b0;
                muxOperandB_sel <= 1'b0;
            end

            // Enable registers, switch muxsel, no carryin
            // Calculate the first addition
            2'd1: begin
                                regA_en        <= 1'b0;
                                regB_en        <= 1'b0;
                                regSum_en      <= 1'b1;
                                regCout_en     <= 1'b1;
                                muxsub_sel     <= 1'b0;
                                muxOperandA_sel <= 1'b1;
                                muxOperandB_sel <= 1'b1;
            end


            default: begin
                                regA_en        <= 1'b0;
                                regB_en        <= 1'b0;
                                regSum_en      <= 1'b1;
                                regCout_en     <= 1'b0;
                                muxsub_sel     <= 1'b0;
                                muxOperandA_sel <= 1'b0;
                                muxOperandB_sel <= 1'b0;
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
            2'd1 : nextstate <= 2'd0;    
            
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
                    else        regDone <= (state==2'd1) ? 1'b1 : 1'b0;;
                end

                assign done = regDone;
                
                

endmodule