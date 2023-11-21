module rsa (
    input  wire          clk,
    input  wire          resetn,
    output wire   [ 3:0] leds,

    // input registers                     // output registers
    input  wire   [31:0] rin0,             output wire   [31:0] rout0,
    input  wire   [31:0] rin1,             output wire   [31:0] rout1,
    input  wire   [31:0] rin2,             output wire   [31:0] rout2,
    input  wire   [31:0] rin3,             output wire   [31:0] rout3,
    input  wire   [31:0] rin4,             output wire   [31:0] rout4,
    input  wire   [31:0] rin5,             output wire   [31:0] rout5,
    input  wire   [31:0] rin6,             output wire   [31:0] rout6,
    input  wire   [31:0] rin7,             output wire   [31:0] rout7,

    // dma signals
    input  wire [1023:0] dma_rx_data,      output wire [1023:0] dma_tx_data,
    output wire [  31:0] dma_rx_address,   output wire [  31:0] dma_tx_address,
    output reg           dma_rx_start,     output reg           dma_tx_start,
    input  wire          dma_done,
    input  wire          dma_idle,
    input  wire          dma_error
  );

  wire [31:0] command;
  assign command        = rin0; // use rin0 as command
  
  reg [31:0] address;
  assign dma_rx_address = address; // read data from address
  assign dma_tx_address = rin7; // write to address in rin7

  // Only one output register is used. It will the status of FPGA's execution.
  wire [31:0] status;
  wire current_state;
  assign rout0 = status; // use rout0 as status
  assign rout1 = current_state; 
  assign rout2 = 32'b0;  // not used
  assign rout3 = 32'b0;  // not used
  assign rout4 = 32'b0;  // not used
  assign rout5 = 32'b0;  // not used
  assign rout6 = 32'b0;  // not used
  assign rout7 = 32'b0;  // not used


  // we have only one computation command.
  wire isCmdComp = (command == 32'd1);
  wire isCmdIdle = (command == 32'd0);
  
  // Define registers
    reg           regX_en;
    reg  [1023:0] regX_out;
    always @(posedge clk)
    begin
        if(~resetn)         regX_out <= 1024'd0;
        else if (regX_en)   regX_out <= dma_rx_data;
    end
        
    reg           regM_en;
    reg  [1023:0] regM_out;
    always @(posedge clk)
    begin
        if(~resetn)         regM_out <= 1024'd0;
        else if (regM_en)   regM_out <= dma_rx_data;
    end
    
    reg           regE_en;
    reg  [1024:0] regE_out;
    reg shiftE;
    always @(posedge clk)
    begin
        if(~resetn)         regE_out <= 1025'd0;
        else if (regE_en)   regE_out <= dma_rx_data;
    end
    
    reg           regA_en;
    wire [1023:0] regA_in;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 1024'd0;
        else if (regA_en)   regA_out <= dma_rx_data;
    end
    
    reg           regR2_en;
    reg  [1023:0] regR2_out;
    always @(posedge clk)
    begin
        if(~resetn)          regR2_out <= 1024'd0;
        else if (regR2_en)   regR2_out <= dma_rx_data;
    end
    


  // Define state machine's states
  localparam
    STATE_IDLE     = 4'd0,
    STATE_RX1       = 4'd1,
    STATE_RX_WAIT1  = 4'd2,
    STATE_RX2       = 4'd3,
    STATE_RX_WAIT2  = 4'd4,
    STATE_RX3       = 4'd5,
    STATE_RX_WAIT3  = 4'd6,
    STATE_RX4       = 4'd7,
    STATE_RX_WAIT4  = 4'd8,
    STATE_RX5       = 4'd9,
    STATE_RX_WAIT5  = 4'd10,
    STATE_COMPUTE  = 4'd11,
    STATE_COMPUTE_WAIT = 4'd12,
    STATE_TX       = 4'd13,
    STATE_TX_WAIT  = 4'd14,
    STATE_DONE     = 4'd15;

  // The state machine
  reg [3:0] state = STATE_IDLE;
  reg [3:0] next_state;
  wire done;
  reg start;
  
  always@(*) begin
    // defaults
    next_state   <= STATE_IDLE;

    // state defined logic
    case (state)
      // Wait in IDLE state till a compute command
      STATE_IDLE: next_state <= (isCmdComp) ? STATE_RX1 : state;
    
      // READ MODULUS M (called N in software)
      STATE_RX1: next_state <= (~dma_idle) ? STATE_RX_WAIT1 : state;
      STATE_RX_WAIT1: next_state <= (dma_done) ? STATE_RX2 : state;
      
      // READ EXPONENT E
      STATE_RX2: next_state <= (~dma_idle) ? STATE_RX_WAIT2 : state;
      STATE_RX_WAIT2: next_state <= (dma_done) ? STATE_RX3 : state;
      
      // READ MESSAGE X (called M in software)
      STATE_RX3: next_state <= (~dma_idle) ? STATE_RX_WAIT3 : state;
      STATE_RX_WAIT3: next_state <= (dma_done) ? STATE_RX4 : state;
      
      // READ R_N
      STATE_RX4: next_state <= (~dma_idle) ? STATE_RX_WAIT4 : state;
      STATE_RX_WAIT4: next_state <= (dma_done) ? STATE_RX5 : state;
      
      // READ R2_N
      STATE_RX5: next_state <= (~dma_idle) ? STATE_RX_WAIT5 : state;
      STATE_RX_WAIT5: next_state <= (dma_done) ? STATE_COMPUTE : state;
      
      // PERFORM EXPONENTIATION
      STATE_COMPUTE: next_state <= STATE_COMPUTE_WAIT;    
      STATE_COMPUTE_WAIT: next_state <= (done)? STATE_TX : state;

      // WRITE RESULT
      STATE_TX: next_state <= (~dma_idle) ? STATE_TX_WAIT : state;
      STATE_TX_WAIT:  next_state <= (dma_done) ? STATE_DONE : state;

      // The command register might still be set to compute state. Hence, if
      // we go back immediately to the IDLE state, another computation will
      // start. We might go into a deadlock. So stay in this state, till CPU
      // sets the command to idle. While FPGA is in this state, it will
      // indicate the state with the status register, so that the CPU will know
      // FPGA is done with computation and waiting for the idle command.
      STATE_DONE : begin
        next_state <= (isCmdIdle) ? STATE_IDLE : state;
      end

    endcase
  end

  always@(posedge clk) begin
    dma_rx_start <= 1'b0;
    dma_tx_start <= 1'b0;
    case (state)
      STATE_RX1: begin
        dma_rx_start <= 1'b1;
        address <= rin1; end
      STATE_RX2: begin
        dma_rx_start <= 1'b1;
        address <= rin2; end
      STATE_RX3: begin
        dma_rx_start <= 1'b1;
        address <= rin3; end
      STATE_RX4: begin
        dma_rx_start <= 1'b1;
        address <= rin4; end
      STATE_RX5: begin
        dma_rx_start <= 1'b1;
        address <= rin5; end
      
      STATE_TX: dma_tx_start <= 1'b1;
    endcase
  end

  // Synchronous state transitions
  always@(posedge clk)
    state <= (~resetn) ? STATE_IDLE : next_state;

  wire [1023:0] result;
  ladder exp(clk, resetn, start, regX_out, regM_out, regE_out, regA_out, regR2_out, rin6, result, done);
  
  reg           regRes_en;
  reg  [1023:0] regRes_out;
  always @(posedge clk)
    begin
      if(~resetn)          regRes_out <= 1024'd0;
      else if (regRes_en)   regRes_out <= result;
  end

  always @(*) begin
    //default
    regM_en <= 1'b0;
    regE_en <= 1'b0;
    regX_en <= 1'b0;
    regA_en <= 1'b0;
    regR2_en <= 1'b0;
    start <= 1'b0;
    regRes_en <= 1'b0;
  
    
    case (state)
        //read inputs
        STATE_RX_WAIT1: regM_en <= 1'b1;
        STATE_RX_WAIT2: regE_en <= 1'b1;
        STATE_RX_WAIT3: regX_en <= 1'b1;
        STATE_RX_WAIT4: regA_en <= 1'b1;
        STATE_RX_WAIT5: regR2_en <= 1'b1;
        
        // compute
        STATE_COMPUTE: start <= 1'b1;
        STATE_COMPUTE_WAIT: regRes_en <= (done)? 1'b1: 1'b0;
   endcase
  end
  
  assign dma_tx_data = regRes_out;

  // Status signals to the CPU
  wire isStateIdle = (state == STATE_IDLE);
  wire isStateDone = (state == STATE_DONE);
  assign status = {29'b0, dma_error, isStateIdle, isStateDone};
  assign current_state = {28'b0, state};

endmodule


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
    reg           regX_en;
    reg  [1023:0] regX_out;
    always @(posedge clk)
    begin
        if(~resetn)         regX_out <= 1024'd0;
        else if (regX_en)   regX_out <= in_x;
    end
    
    reg           regXX_en;
    wire [1023:0] regXX_in;
    reg  [1023:0] regXX_out;
    always @(posedge clk)
    begin
        if(~resetn)          regXX_out <= 1024'd0;
        else if (regXX_en)   regXX_out <= regXX_in;
    end
    
    reg           regM_en;
    reg  [1023:0] regM_out;
    always @(posedge clk)
    begin
        if(~resetn)         regM_out <= 1024'd0;
        else if (regM_en)   regM_out <= in_m;
    end
    
    reg          regE_en;
    reg  [1024:0] regE_out;
    reg shiftE;
    always @(posedge clk)
    begin
        if(~resetn)         regE_out <= 1025'd0;
        else if (shiftE)    regE_out <= regE_out << 1;
        else if (regE_en)   regE_out <= in_e;
    end
    
    reg          reglene_en;
    reg  [31:0] reglene_out;
    always @(posedge clk)
    begin
        if(~resetn)         reglene_out <= 128'd0;
        else if (reglene_en)   reglene_out <= lene;
    end
    
    wire          Ei;
    assign Ei = regE_out[1024];
    
    
    reg           regA_en;
    wire [1023:0] regA_in;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 1024'd0;
        else if (regA_en)   regA_out <= regA_in;
    end
    
    reg           regR2_en;
    reg  [1023:0] regR2_out;
    always @(posedge clk)
    begin
        if(~resetn)          regR2_out <= 1024'd0;
        else if (regR2_en)   regR2_out <= in_r2;
    end
    
    // initiate montgomery multiplier
    wire [1023:0] operandA;
    wire [1023:0] operandB;
    wire [1023:0] operandM;
    
    reg [1:0] select1;
    reg [1:0] select2;
    assign operandA = select1[1]? (select1[0]? regX_out: regXX_out) : (select1[0]? regA_out: regR2_out);
    assign operandB = select2[1]? (select2[0]? 1023'd1: regXX_out) : (select2[0]? regA_out: regR2_out);
    assign operandM = regM_out;
      
    
    wire [1023:0] Res;
    wire Done2;
    reg reset2;
    reg start2;
    
    
    
    
    montgomery mult(clk, reset2, start2, operandA, operandB, operandM, Res, Done2);
    
    assign regXX_in = Res;
    assign regA_in = (state == 4'd0)? in_r: Res;
    


    assign result = regA_out;
    
    
    reg [10:0] count;
    reg reset_count;
    reg count_en;
    always @(posedge clk) begin
      if (~resetn) count <= 10'b0;
      if (reset_count) count <= 10'b0;
      else if (count_en)  count <= count +1;
    end

    // Describe state machine registers

    reg [3:0] state, nextstate;

    always @(posedge clk)
    begin
        if(~resetn)	state <= 4'd0;
        else        state <= nextstate;
    end

    // Define your states
    // Describe your signals at each state
    always @(*)
    begin
        case(state)
            
            // Idle state; Here the FSM waits for the start signal
            // Enable input registers 
            4'd0: begin
                regX_en <= 1'b1;
                regXX_en <= 1'b0;
                regE_en <= 1'b1;
                regM_en <= 1'b1;
                regA_en <= 1'b1;
                regR2_en <= 1'b1;
                reglene_en <= 1'b1;
                select1 <= 2'b00;
                select2 <= 2'b00;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b0;
                reset_count <= 1'b1;
            end

            4'd1: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b11;
                select2 <= 2'b00;
                count_en <= 1'b0;
                start2 <= 1'b1;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            4'd2: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b1;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b11;
                select2 <= 2'b00;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            4'd10: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b11;
                select2 <= 2'b00;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b0;
                reset_count <= 1'b0;
            end
            
            
            
            4'd3: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b01;
                select2 <= 2'b10;
                count_en <= 1'b1;
                start2 <= 1'b1;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            4'd4: begin
                regX_en <= 1'b0;
                regXX_en <= ~Ei;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= Ei;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b01;
                select2 <= 2'b10;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            4'd11: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b11;
                select2 <= 2'b00;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b0;
                reset_count <= 1'b0;
            end
            
            4'd5: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= {Ei,~Ei};
                select2 <= {Ei,~Ei};
                count_en <= 1'b0;
                start2 <= 1'b1;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            4'd6: begin
                regX_en <= 1'b0;
                regXX_en <= Ei;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= ~Ei;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= {Ei,~Ei};
                select2 <= {Ei,~Ei};
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            4'd12: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b11;
                select2 <= 2'b00;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b0;
                reset_count <= 1'b0;
            end
            
            4'd7: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b1;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b01;
                select2 <= 2'b11;
                count_en <= 1'b0;
                start2 <= 1'b1;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            4'd8: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b1;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <=  2'b00;
                select2 <= 2'b00;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end
            
            4'd9: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <=  2'b00;
                select2 <= 2'b00;      
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b0;
                reset_count <= 1'b0;
            end
       
            default: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                reglene_en <= 1'b0;
                select1 <= 2'b0;
                select2 <= 2'b0;
                count_en <= 1'b0;
                start2 <= 1'b0;
                reset2 <= 1'b1;
                reset_count <= 1'b0;
            end

        endcase
    end
    
    wire Es;
    assign Es = regE_out[1023];
    reg s;   
    always @(posedge clk)
    begin
        if (state == 4'd2) s <= 1'b0;
        if (state == 4'd10) begin
            if (~s) s<= Es;
        end
    end

// Task 13
    // Describe next_state logic

    always @(*)
    begin
        shiftE <= 1'b0;
        case(state)
            4'd0: begin
                if(start) 
                    nextstate <= 4'd1;
                else 
                    nextstate <= 4'd0;
                end
            4'd1 : nextstate <= 4'd2;
 
            4'd2 : begin
                if(Done2) nextstate <= 4'd10;
                else      nextstate <= 4'd2;
                end
            4'd10 : begin
                if (s) begin
                    nextstate <= 4'd3;
                    shiftE <= 1'b0; end
                else begin
                    nextstate <= 4'd10;
                    shiftE <= 1'b1; end
                end
            4'd3 : nextstate <= 4'd4;
            
            4'd4 : begin
                if(Done2) nextstate <= 4'd11;
                else      nextstate <= 4'd4;
                end
            4'd11 : nextstate <= 4'd5;
            4'd5 : nextstate <= 4'd6;
            
            4'd6 : begin 
                if(Done2) begin
                  if (count==reglene_out) begin
                    nextstate <= 4'd12;
                  end else begin
                    nextstate <= 4'd10;
                    shiftE <= 1'b1; end
                end else begin
                    nextstate <= 4'd6; end
                end
            4'd12 : nextstate <= 4'd7;
            4'd7 : nextstate <= 4'd8;
            
            4'd8 : if(Done2)  nextstate <= 4'd9;
                   else       nextstate <= 4'd8;
            
            4'd9 : nextstate <= 4'd0;
                   
           
            default: nextstate <= 4'd0;
        endcase
    end

    // Task 14
    // Describe done signal
    // It should be high at the same clock cycle when the output ready

                reg regDone;
                always @(posedge clk)
                begin
                    if(~resetn) regDone <= 1'b0;
                    else        regDone <= (state==4'd9) ? 1'b1 : 1'b0;;
                end

                assign done = regDone;
                


endmodule