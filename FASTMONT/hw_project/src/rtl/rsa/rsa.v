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
        if (regX_en)   regX_out <= dma_rx_data;
    end
        
    reg           regM_en;
    reg  [1023:0] regM_out;
    always @(posedge clk)
    begin
        if (regM_en)   regM_out <= dma_rx_data;
    end
    
    reg           regE_en;
    reg  [1023:0] regE_out;
    reg shiftE;
    always @(posedge clk)
    begin
        if (regE_en)   regE_out <= dma_rx_data;
    end
    
    reg           regA_en;
    wire [1023:0] regA_in;
    reg  [1023:0] regA_out;
    always @(posedge clk)
    begin
        if (regA_en)   regA_out <= dma_rx_data;
    end
    
    reg           regR2_en;
    reg  [1023:0] regR2_out;
    always @(posedge clk)
    begin
        if (regR2_en)   regR2_out <= dma_rx_data;
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
  ladder4 exp(clk, resetn, start, regX_out, regM_out, regE_out, regA_out, regR2_out, rin6, result, done);
  
  reg           regRes_en;
  reg  [1023:0] regRes_out;
  always @(posedge clk)
    begin
      if (regRes_en)   regRes_out <= result;
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
