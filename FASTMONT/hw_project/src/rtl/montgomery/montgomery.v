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
  
  // Task 1
    // Describe a 1024-bit register for A
    // It will save the input data when enable signal is high

    reg           regA_en;
    reg           shiftA;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if (regA_en)   regA_out <= in_a;
        else if (shiftA) regA_out <= regA_out >> 1;
    end
    

// Task 2
    // Describe a 1024-bit register for B

    reg           regB_en;
    reg  [1023:0] regB_out;
    always @(posedge clk)
    begin
        if (regB_en)   regB_out <= in_b;
    end

  // Task 4
    // Describe a 1028 bit register for result
    reg           regC_en;
    reg  [1027:0] regC_out;
    reg reset;
    always @(posedge clk)
    begin
        if(reset)     regC_out <= 1028'd0;
        else if (regC_en)   regC_out <= Res;
    end
    
    
    
   // Task 7 
     //If ai = 1 do C+B
    wire [1023:0] operandB;
    wire [1023:0] operandM;
    wire [1027:0] Sum;
    wire [1027:0] Res;

    assign operandB = regB_out;
    assign operandM = in_m;
    
    reg shiftC;
    reg zero;
    assign Res = ~zero? (shiftC? Sum>>1: Sum): (shiftC? regC_out >> 1: 1028'b0);
    
  // Task 8
    // design Multiplexer to choose between adder input B or M;
    reg           muxInput2_sel;
    wire [1023:0] muxInput2_Out;
    assign muxInput2_Out = muxInput2_sel? operandM : operandB;
   
    
    
    reg subtract;
    mpadder adder(clk,subtract,Res,{3'b0,muxInput2_Out},Sum);


    assign result = regC_out;
    
    reg [9:0] count;
    reg count_en; 
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
    
    reg camefrom4;
    reg camefrom3;
    
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
                shiftA  <= 1'b0;
                regB_en <= 1'b1;
                regC_en <= 1'b0;
                muxInput2_sel <= 1'b0;
                shiftC <= 1'b0;
                zero <= 1'b1;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b1;
            end

            3'd1: begin
                regA_en <= 1'b0;
                shiftA  <= 1'b0;
                regB_en <= 1'b0;
                regC_en <= 1'b0;
                muxInput2_sel <= 1'b0;
                shiftC <= 1'b0;
                zero <= 1'b1;
                count_en <= 1'b1;
                subtract <= 1'b0;
                reset <= 1'b0;
            end
            
            3'd2: begin
                regA_en <= 1'b0;
                shiftA  <= 1'b1;
                regB_en <= 1'b0;
                regC_en <= 1'b1;
                muxInput2_sel <= 1'b1;
                shiftC <= 1'b0;
                zero <= ~regA_out;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b0;
            end

            3'd3: begin
                regA_en <= 1'b0;
                shiftA  <= 1'b0;
                regB_en <= 1'b0;
                regC_en <= 1'b0;
                muxInput2_sel <= 1'b0;
                shiftC <= 1'b1;
                zero <= ~regC_out[0];
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b0;
            end
            
            3'd4: begin
                regA_en <= 1'b0;
                shiftA  <= 1'b1;
                regB_en <= 1'b0;
                regC_en <= 1'b1;
                muxInput2_sel <= 1'b1;
                shiftC <= camefrom4;
                zero <= ~(camefrom3 || regC_out[0]);
                count_en <= 1'b1;
                subtract <= 1'b0;
                reset <= 1'b0;
            end
            
            3'd5: begin
                regA_en <= 1'b0;
                shiftA  <= 1'b0;
                regB_en <= 1'b0;
                regC_en <= 1'b1;
                muxInput2_sel <= 1'b1;
                shiftC <= 1'b1;
                zero <= ~regC_out[0];
                count_en <= 1'b0;
                subtract <= 1'b1;
                reset <= 1'b0;
            end
            
            3'd6: begin
                regA_en <= 1'b0;
                shiftA  <= 1'b0;
                regB_en <= 1'b0;
                regC_en <= ~Res[1027];
                muxInput2_sel <= 1'b1;
                shiftC <= 1'b0;
                zero <= 1'b0;
                count_en <= 1'b0;
                subtract <= 1'b1;
                reset <= 1'b0;
            end
                        
            
            default: begin
                regA_en <= 1'b0;
                shiftA  <= 1'b0;
                regB_en <= 1'b0;
                regC_en <= 1'b0;
                muxInput2_sel <= 1'b1;
                shiftC <= 1'b0;
                zero <= 1'b0;
                count_en <= 1'b0;
                subtract <= 1'b0;
                reset <= 1'b1;
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
            3'd1 : nextstate <= 3'd2;
            3'd2 : begin
                if (regA_out[1]) nextstate <= 3'd3; 
                else nextstate <= 3'd4; end
            3'd3 : nextstate <= 3'd4;
            3'd4 : begin
                if (count == 10'd1023)  nextstate <= 3'd5;
                else if (regA_out[1])   nextstate <= 3'd3; 
                else                    nextstate <= 3'd4; end
             3'd5 : nextstate <= 3'd6;
             3'd6 : nextstate <= 3'd0;
            
             default: nextstate <= 3'd0;
        endcase
    end
    
    always @(posedge clk)
    begin
        camefrom4 <= 1'b0;
        camefrom3 <= 1'b0;
        case(state)
            3'd2: camefrom4 <= 1'b1;
            3'd3: camefrom3 <= 1'b1;
            3'd4: camefrom4 <= 1'b1;
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