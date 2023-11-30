`timescale 1ns / 1ps

module ladder(
    input clk,
    input resetn,
    input start,
    input [1023:0] in_x,
    input [1023:0] in_m,
    input [1023:0] in_e,
    input [1023:0] in_r,
    input [1023:0] in_r2,
    input [31:0]   lene,
    output [1023:0] result,
    output          done
 );


    // Save inputs in registers
    reg           regXX_en;
    wire [1023:0] regXX_in;
    reg  [1023:0] regXX_out;
    always @(posedge clk)
    begin
        if (regXX_en)   regXX_out <= regXX_in;
    end
    
    
    reg          regE_en;
    reg  [1023:0] regE_out;
    reg shiftE;
    always @(posedge clk)
    begin
        if (shiftE)    regE_out <= regE_out << 1;
        else if (regE_en)   regE_out <= in_e;
    end

    wire          Ei;
    assign Ei = regE_out[1023];
    
    
    reg           regA_en;
    wire [1023:0] regA_in;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if (regA_en)   regA_out <= regA_in;
    end
    
    
    // initiate montgomery multiplier///// 2 montgomeries working in parallel
    wire [1023:0] operandA1;
    wire [1023:0] operandB1;
    
    wire [1023:0] operandM;
    
    reg select1;
    reg [1:0] select2;
    assign operandA1 = select1? in_x: regA_out;
    assign operandB1 = select2[1]? (select2[0]? 1023'd1: regXX_out) : (in_r2);
    assign operandM = in_m;
    
    reg select3;
    wire [1023:0] operandA2;
    assign operandA2 = select3? regA_out: regXX_out;
      
    
    wire [1023:0] Res1;
    wire [1023:0] Res2;
    wire Done1;
    wire Done2;
    reg reset2;
    reg start1;
    reg start2;

    montgomery mult1(clk, reset2, start1, operandA1, operandB1, operandM, Res1, Done1);
    montgomery mult2(clk, reset2, start2, operandA2, operandA2, operandM, Res2, Done2);
    
    
    reg select_res;
    assign regXX_in = select_res? Res1: Res2;
    assign regA_in = (state == 3'd0)? (in_r): (select_res? Res2: Res1);
    
    
    
    // Save done values to know when both montgomeries are done
    reg save_done1;
    reg save_done2;
    reg reset3;
    always @(posedge clk) 
    begin
        if (reset3) begin
            save_done1 <= 1'b0;
            save_done2 <= 1'b0; end
        else begin
            if (~save_done1) save_done1 <= Done1; 
            if (~save_done2) save_done2 <= Done2; end
    end
    wire bothdone;
    assign bothdone = save_done1 && save_done2;


    assign result = regA_out;
    
    
    reg [10:0] count;
    reg reset_count;
    reg count_en;
    always @(posedge clk) begin
      if (reset_count) count <= 10'b0;
      else if (count_en)  count <= count +1;
    end

    // Describe state machine registers

    reg [2:0] state, nextstate;

    always @(posedge clk)
    begin
        if(~resetn)	state <= 3'd0;
        else        state <= nextstate;
    end

    // Define your states
    // Describe your signals at each state
    always @(*)
    begin
        case(state)
            
            // Idle state; Here the FSM waits for the start signal
            // Enable input registers 
            3'd0: begin
                regXX_en <= 1'b0;
                regE_en <= 1'b1;
                regA_en <= 1'b1;
                select1 <= 1'b0;
                select2 <= 2'b00;
                select3 <= 1'b0;
                select_res <= 1'b0;
                count_en <= 1'b0;
                start1 <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b0;
                reset3 <= 1'b1;
                reset_count <= 1'b1;
            end

            3'd1: begin
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regA_en <= 1'b0;
                select1 <= 1'b1;
                select2 <= 2'b00;
                select3 <= 1'b0;
                select_res <= 1'b1;
                count_en <= 1'b0;
                start1 <= 1'b1;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset3 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            3'd2: begin
                regXX_en <= 1'b1;
                regE_en <= 1'b0;
                regA_en <= 1'b0;
                select1 <= 1'b1;
                select2 <= 2'b00;
                select3 <= 1'b0;
                select_res <= 1'b1;
                count_en <= 1'b0;
                start1 <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset3 <= 1'b0;
                reset_count <= 1'b0;
            end
            
            3'd3: begin
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regA_en <= 1'b0;
                select1 <= 1'b0;
                select2 <= 2'b10;
                select3 <= ~Ei;
                select_res <= 1'b0;
                count_en <= 1'b1;
                start1 <= 1'b1;
                start2 <= 1'b1;
                reset2 <= 1'b1;
                reset3 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            3'd4: begin
                regXX_en <= bothdone;
                regE_en <= 1'b0;
                regA_en <= bothdone;
                select1 <= 1'b0;
                select2 <= 2'b10;
                select3 <= ~Ei;
                select_res <= ~Ei;
                count_en <= 1'b0;
                start1 <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset3 <= 1'b0;
                reset_count <= 1'b0;
            end
            
            3'd5: begin
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regA_en <= 1'b1;
                select1 <= 1'b0;
                select2 <= 2'b11;
                select3 <= 1'b0;
                select_res <= 1'b0;
                count_en <= 1'b0;
                start1 <= 1'b1;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset3 <= 1'b1;
                reset_count <= 1'b0;
            end
            3'd6: begin
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regA_en <= 1'b1;
                select1 <=  1'b00;
                select2 <= 2'b11;
                select3 <= 1'b0;
                select_res <= 1'b0;
                count_en <= 1'b0;
                start1 <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset3 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            3'd7: begin
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regA_en <= 1'b0;
                select1 <=  1'b0;
                select2 <= 2'b00;
                select3 <= 1'b0;   
                select_res <= 1'b0;   
                count_en <= 1'b0;
                start1 <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b0;
                reset3 <= 1'b1;
                reset_count <= 1'b0;
            end
       
            default: begin
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regA_en <= 1'b0;
                select1 <= 1'b0;
                select2 <= 2'b0;
                select3 <= 1'b0;
                select_res <= 1'b0;
                count_en <= 1'b0;
                start1 <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset3 <= 1'b1;
                reset_count <= 1'b0;
            end

        endcase
    end
    

    // Describe next_state logic

    always @(*)
    begin
        shiftE <= 1'b0;
        case(state)
            3'd0: begin
                if(start) nextstate <= 3'd1;
                else      nextstate <= 3'd0; end
                
            3'd1 : nextstate <= 3'd2;
                
            3'd2 : begin
                if(save_done1&&Ei) nextstate <= 3'd3;
                else      nextstate <= 3'd2; 
                if(Ei)    shiftE <= 1'b0;
                else      shiftE <= 1'b1;
                end
                
            3'd3 : nextstate <= 3'd4;
            
            3'd4 : begin
                if(bothdone) begin
                    if (count==lene) begin
                        nextstate <= 3'd5;
                    end else begin
                        nextstate <= 3'd3;
                        shiftE <= 1'b1; end
                end else nextstate <= 3'd4; 
                end
            3'd5 : nextstate <= 3'd6;
            
            3'd6 : if(Done1)  nextstate <= 3'd7;
                   else       nextstate <= 3'd6;
            
            3'd7 : nextstate <= 3'd0;
                   
           
            default: nextstate <= 3'd0;
        endcase
    end

    // Describe done signal
    // It should be high at the same clock cycle when the output ready

                reg regDone;
                always @(posedge clk)
                begin
                    if(~resetn) regDone <= 1'b0;
                    else        regDone <= (state==3'd7) ? 1'b1 : 1'b0;;
                end

                assign done = regDone;
                


endmodule
