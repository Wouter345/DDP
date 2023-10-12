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
    reg  [1026:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 1027'd0;
        else if (regA_en)   regA_out <= in_a;
    end
    
// Task 2
    // Describe a 1027-bit register for B

    reg           regB_en;
    reg  [1026:0] regB_out;
    always @(posedge clk)
    begin
        if(~resetn)         regB_out <= 1027'd0;
        else if (regB_en)   regB_out <= in_b;
    end
    

    wire [1027:0] carry;
    wire [1027:0] a;
    wire [1027:0] b;
    wire [1027:0] sum;
    
    genvar i;
    generate
        assign carry[0] = 0;
        for (i=0;i<1027;i = i+1) begin : carry_generator
            assign carry[i+1] = a[i] & b[i] | a[i] & carry[i] | b[i] & carry[i];
        end
    endgenerate
    
    genvar j;
    generate
        for (j=0;j<1028;j=j+1) begin : sum_generator
            assign sum[j] = a[j] ^ b[j] ^ carry[j];
        end
    endgenerate
    
        
    
// Task 6
    // Describe a 1028-bit register for storing the sum

    reg          regSum_en;
    reg  [1027:0] regSum;
    always @(posedge clk)
    begin
        if(~resetn)             regSum <= 1027'b0;
        else if (regSum_en)  regSum <= sum;
    end

// Task 9
    // Connect the inputs of adder to the outputs of A and B registers
    // and to the carry mux

    assign a = {1'b0,regA_out};
    assign b = {1'b0,regB_out};


    
// Task 10
    // Describe output, concatenate the registers of carry_out and result
    assign result = regSum[1027:0];

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
            end

            // Enable registers, switch muxsel, no carryin
            // Calculate the first addition
            2'd1: begin
                                regA_en        <= 1'b0;
                                regB_en        <= 1'b0;
                                regSum_en      <= 1'b1;
            end


            default: begin
                regA_en        <= 1'b0;
                regB_en        <= 1'b0;
                regSum_en      <= 1'b1;
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
                    else        regDone <= (state==3'd1) ? 1'b1 : 1'b0;
                end

                assign done = regDone;
                
                

endmodule