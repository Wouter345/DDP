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

  // In this example three input registers are used.
  // The first one is used for giving a command to FPGA.
  // The others are for setting DMA input and output data addresses.
  wire [31:0] command;
  assign command        = rin0; // use rin0 as command
  assign dma_rx_address = rin1; // use rin1 as input  data address
  assign dma_tx_address = rin2; // use rin2 as output data address

  // Only one output register is used. It will the status of FPGA's execution.
  wire [31:0] status;
  assign rout0 = status; // use rout0 as status
  assign rout1 = 32'b0;  // not used
  assign rout2 = 32'b0;  // not used
  assign rout3 = 32'b0;  // not used
  assign rout4 = 32'b0;  // not used
  assign rout5 = 32'b0;  // not used
  assign rout6 = 32'b0;  // not used
  assign rout7 = 32'b0;  // not used


  // In this example we have only one computation command.
  wire isCmdComp = (command == 32'd1);
  wire isCmdIdle = (command == 32'd0);


  // Define state machine's states
  localparam
    STATE_IDLE     = 3'd0,
    STATE_RX       = 3'd1,
    STATE_RX_WAIT  = 3'd2,
    STATE_COMPUTE  = 3'd3,
    STATE_TX       = 3'd4,
    STATE_TX_WAIT  = 3'd5,
    STATE_DONE     = 3'd6;

  // The state machine
  reg [2:0] state = STATE_IDLE;
  reg [2:0] next_state;
  reg start;
  reg reset2;
  reg done;
  
  
  always@(*) begin
    // defaults
    next_state   <= STATE_IDLE;

    // state defined logic
    case (state)
      // Wait in IDLE state till a compute command
      STATE_IDLE: begin
        next_state <= (isCmdComp) ? STATE_RX : state;
        start <= 1'b0;
        reset2 <=1'b0;
      end

      // Wait, if dma is dma_idlenot idle. Otherwise, start dma operation and go to
      // next state to wait its completion.
      STATE_RX: begin
        next_state <= (~dma_idle) ? STATE_RX_WAIT : state;
      end

      // Wait the completion of dma.
      STATE_RX_WAIT : begin
        next_state <= (dma_done) ? STATE_COMPUTE : state;
        reset2 <= 1'b1;
      end

      // A state for dummy computation for this example. Because this
      // computation takes only single cycle, go to TX state immediately
      STATE_COMPUTE : begin
        next_state <= (done) ? STATE_TX : state;    
        start <= 1'b1;
      end

      // Wait, if dma is not idle. Otherwise, start dma operation and go to
      // next state to wait its completion.
      STATE_TX : begin
        next_state <= (~dma_idle) ? STATE_TX_WAIT : state;
      end

      // Wait the completion of dma.
      STATE_TX_WAIT : begin
        next_state <= (dma_done) ? STATE_DONE : state;
      end

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
      STATE_RX: dma_rx_start <= 1'b1;
      STATE_TX: dma_tx_start <= 1'b1;
    endcase
  end

  // Synchronous state transitions
  always@(posedge clk)
    state <= (~resetn) ? STATE_IDLE : next_state;

  wire [1027:0] Res;
  wire donemult;
  montgomery mult(clk, reset2, start, 1024'h2, 1024'h3, 1024'h8, Res, donemult);
  always @(posedge clk) begin
    case (state)
     STATE_COMPUTE : done <= donemult;
     default : done<= 1'b0;
   endcase
  end

  // Here is a register for the computation. Sample the dma data input in
  // STATE_RX_WAIT. Update the data with a dummy operation in STATE_COMP.
  // In this example, the dummy operation sets most-significant 32-bit to zeros.
  // Use this register also for the data output.
  reg [1023:0] r_data = 1024'h0;
  always@(posedge clk)
    case (state)
      STATE_RX_WAIT : r_data <= (dma_done) ? dma_rx_data : r_data;
//      STATE_COMPUTE : r_data <= {32'hDEADBEEF, r_data[991:0]};
      STATE_COMPUTE : r_data <= Res;
    endcase
  assign dma_tx_data = r_data;


  // Status signals to the CPU
  wire isStateIdle = (state == STATE_IDLE);
  wire isStateDone = (state == STATE_DONE);
  assign status = {29'b0, dma_error, isStateIdle, isStateDone};

endmodule


module ladder(
    input clk,
    input resetn,
    input start,
    input [1023:0] in_x,
    input [1023:0] in_m,
    input [127:0]  in_e,
    input [1023:0] in_r,
    input [1023:0] in_r2,
    input [31:0]   lene,
    output [1023:0] result,
    output          done
 );


    // Save inputs in registers
    
    
    reg           regX_en;
    wire [1023:0] regX_in;
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
    wire [1023:0] regM_in;
    reg  [1023:0] regM_out;
    always @(posedge clk)
    begin
        if(~resetn)         regM_out <= 1024'd0;
        else if (regM_en)   regM_out <= in_m;
    end
    
    reg          regE_en;
    wire [127:0] regE_in;
    reg  [127:0] regE_out;
    reg shiftE;
    always @(posedge clk)
    begin
        if(~resetn)         regE_out <= 128'd0;
        else if (shiftE)    regE_out <= regE_in << 1;
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
    assign Ei = regE_out[127];
    
    
    reg           regA_en;
    wire [1023:0] regA_in;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if(~resetn)         regA_out <= 1024'd0;
        else if (regA_en)   regA_out <= regA_in;
    end
    
    reg           regR2_en;
    wire [1023:0] regR2_in;
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
    reg start2;
    
    
    
    
    montgomery mult(clk, res, start2, operandA, operandB, operandM, Res, Done2);
    
    assign regA_in = Res;
    assign RegXX_in = Res;

    
    
    reg [8:0] count;
    reg count_en;
    always @(posedge clk) begin
      if (~resetn) count <= 8'b0;
      else if (count_en)  count <= count +1;
    end

    // Task 11
    // Describe state machine registers
    // Think about how many bits you will need

    reg [3:0] state, nextstate;

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
                regX_en <= 1'b1;
                regXX_en <= 1'b0;
                regE_en <= 1'b1;
                regM_en <= 1'b1;
                regA_en <= 1'b1;
                regR2_en <= 1'b1;
                select1 <= 2'b00;
                select2 <= 2'b00;
                shiftE <= 1'b0;
                count_en <= 1'b0;
            end

            // Enable registers, switch muxsel, no carryin
            // Calculate the first addition
            2'd1: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b1;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                select1 <= 2'b11;
                select2 <= 2'b00;
                shiftE <= 1'b0;
                count_en <= 1'b0;
            end

            // Calculate the second addition
            2'd2: begin
                regX_en <= 1'b0;
                regXX_en <= ~Ei;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= Ei;
                regR2_en <= 1'b0;
                select1 <= 2'b01;
                select2 <= 2'b10;
                shiftE <= 1'b0;
                count_en <= 1'b0;

            end
            
            2'd3: begin
                regX_en <= 1'b0;
                regXX_en <= Ei;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= ~Ei;
                regR2_en <= 1'b0;
                select1 <= {Ei,~Ei};
                select2 <= {Ei,~Ei};
                shiftE <= 1'b0;
                count_en <= 1'b0;
            end
            
            2'd4: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                select1 <= 2'b00;
                select2 <= 2'b00;
                shiftE <= 1'b1;
                count_en <= 1'b1;
            end
            
            2'd5: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b1;
                regR2_en <= 1'b0;
                select1 <= 2'b01;
                select2 <= 2'b11;
                shiftE <= 1'b0;
                count_en <= 1'b0;
            end
            2'd6: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                select1 <=  2'b00;
                select2 <= 2'b00;
                shiftE <= 1'b0;
                count_en <= 1'b0;
            end
       
            
            
         
            default: begin
                regX_en <= 1'b0;
                regXX_en <= 1'b0;
                regE_en <= 1'b0;
                regM_en <= 1'b0;
                regA_en <= 1'b0;
                regR2_en <= 1'b0;
                select1 <= 2'b0;
                select2 <= 2'b0;
                shiftE <= 1'b0;
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
                if(start) begin
                    nextstate <= 2'd1;
                    start2    <= 3'd1; 
                end else
                    nextstate <= 2'd0;
                end
            2'd1 : if(Done2) nextstate <= 3'd2;
                   else      nextstate <= 3'd1;
            
            2'd2 : if(Done2) nextstate <= 3'd3;
                   else      nextstate <= 3'd2;
            
            3'd3 : if(Done2) nextstate <= 3'd4;
                   else      nextstate <= 3'd3;
            3'd4 : if(count==reglene_out) nextstate <= 3'd5;
                   else              nextstate <= 3'd2;
            
            3'd5 : if(Done2)  nextstate <= 3'd6;
                   else       nextstate <= 3'd5;
            
            3'd6 : nextstate <= 3'd0;
                   
           
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
                    else        regDone <= (state==3'd6) ? 1'b1 : 1'b0;;
                end

                assign done = regDone;
                


endmodule