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
    // Describe a 1027-bit register for A
    // It will save the input data when enable signal is high

    reg           regA_en;
    wire [1026:0] regA_in;
    reg  [1026:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 1027'd0;
        else if (regA_en)   regA_out <= regA_in;
    end
    
// Task 2
    // Describe a 1027-bit register for B

    reg           regB_en;
    wire [1026:0] regB_in;
    reg  [1026:0] regB_out;
    always @(posedge clk)
    begin
        if(~resetn)         regB_out <= 1027'd0;
        else if (regB_en)   regB_out <= regB_in;
    end
    
// Task 3
    // Describe a 2-input 1027-bit Multiplexer for A
    // It should select either of these two:
    //   - the input A
    //   - the output of regA shifted-right by 200
    // Also connect the output of Mux to regA's input
    
    reg           muxA_sel;
    wire [1026:0] muxA_Out;
    assign muxA_Out = (muxA_sel == 0) ? in_a : {514'b0,regA_out[1026:514]};

    assign regA_in = muxA_Out;
   
   
// Task 4   
    // Describe a 2 input mux choosing B or ~B+1
    wire [1026:0] MuxBin_Out;
    assign MuxBin_Out = (subtract == 0)? in_b : ~in_b;
    
    // Describe a 2-input 1027-bit Multiplexer for B
    reg           muxB_sel;
    wire [1026:0] muxB_Out;
    assign muxB_Out = (muxB_sel == 0) ? MuxBin_Out : {514'b0,regB_out[1026:514]};
    
    assign regB_in = muxB_Out;
    
// Task 5
    // Describe an adder
    // It should be a combinatorial logic:
    // Its inputs are two 200-bit operands and 1-bit carry-in
    // Its outputs are one 200-bit sum  and 1-bit carry-out

    wire [513:0] operandA;
    wire [513:0] operandB;
    wire         carry_in;
    wire [513:0] Sum;
    wire         carry_out;

    assign {carry_out,Sum} = operandA + operandB + carry_in;

// Task 6
    // Describe a 1028-bit register for storing the sum

    reg           regSum_en;
    reg  [1027:0] regSum;
    always @(posedge clk)
    begin
        if(~resetn)          regSum <= 1028'b0;
        else if (regSum_en)  regSum <= {Sum, regSum[1027:514]};
    end

// Task 7
    // Describe a 1-bit register for storing the carry-out

    reg  regCout_en;
    reg  regCout;
    always @(posedge clk)
    begin
        if(~resetn)          regCout <= 1'b0;
        else if (regCout_en) regCout <= carry_out;
    end
    
// Task 8
    // Describe a 1-bit multiplexer for selecting carry-in
    // It should select either of these two:
    //   - 0
    //   - carry-out
    
    reg muxsub_sel;
    wire muxsub_in;
    assign muxsub_in = (muxsub_sel == 0) ? regCout : subtract;
    
    
    
// Task 9
    // Connect the inputs of adder to the outputs of A and B registers
    // and to the carry mux

    assign operandA = regA_out;
    assign operandB = regB_out;
    assign carry_in = muxsub_in;
    
// Task 10
    // Describe output, previous 5 calculations from regSum and last calculation
    wire      carry;
    
    assign carry = subtract ^ regSum[1027];
    assign result = {carry,regSum[1026:0]};

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
                regA_en        <= 1'b1;
                regB_en        <= 1'b1;
                regSum_en      <= 1'b0;
                regCout_en     <= 1'b0;
                muxA_sel       <= 1'b0;
                muxB_sel       <= 1'b0;
                muxsub_sel     <= 1'b0;
            end

            // Enable registers, switch muxsel, no carryin
            // Calculate the first addition
            2'd1: begin
                                regA_en        <= 1'b1;
                                regB_en        <= 1'b1;
                                regSum_en      <= 1'b1;
                                regCout_en     <= 1'b1;
                                muxA_sel       <= 1'b1;
                                muxB_sel       <= 1'b1;  
                                muxsub_sel     <= 1'b1;
            end

            // Calculate the second addition
            2'd2: begin
                                regA_en        <= 1'b1;
                                regB_en        <= 1'b1;
                                regSum_en      <= 1'b1;
                                regCout_en     <= 1'b1;
                                muxA_sel       <= 1'b1;
                                muxB_sel       <= 1'b1;
                                muxsub_sel     <= 1'b0;
            end

            default: begin
                                regA_en        <= 1'b0;
                                regB_en        <= 1'b0;
                                regSum_en      <= 1'b1;
                                regCout_en     <= 1'b0;
                                muxA_sel       <= 1'b0;
                                muxB_sel       <= 1'b0;
                                muxsub_sel     <= 1'b0;
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
            2'd1 : nextstate <= 2'd2;    
            2'd2 : nextstate <= 2'd0;
            
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
                    else        regDone <= (state==2'd2) ? 1'b1 : 1'b0;;
                end

                assign done = regDone;
                
                

endmodule