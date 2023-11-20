`timescale 1ns / 1ps

`define HUGE_WAIT   300
`define LONG_WAIT   100
`define RESET_TIME   25
`define CLK_PERIOD   10
`define CLK_HALF      5

module tb_rsa_wrapper();
    
  reg           clk         ;
  reg           resetn      ;
  wire          leds        ;

  reg  [16:0]   mem_addr    = 'b0 ;
  reg  [1023:0] mem_din     = 'b0 ;
  wire [1023:0] mem_dout    ;
  reg  [127:0]  mem_we      = 'b0 ;

  reg  [ 11:0] axil_araddr  ;
  wire         axil_arready ;
  reg          axil_arvalid ;
  reg  [ 11:0] axil_awaddr  ;
  wire         axil_awready ;
  reg          axil_awvalid ;
  reg          axil_bready  ;
  wire [  1:0] axil_bresp   ;
  wire         axil_bvalid  ;
  wire [ 31:0] axil_rdata   ;
  reg          axil_rready  ;
  wire [  1:0] axil_rresp   ;
  wire         axil_rvalid  ;
  reg  [ 31:0] axil_wdata   ;
  wire         axil_wready  ;
  reg  [  3:0] axil_wstrb   ;
  reg          axil_wvalid  ;
      
  tb_rsa_project_wrapper dut (
    .clk                 ( clk           ),
    .leds                ( leds          ),
    .resetn              ( resetn        ),
    .s_axi_csrs_araddr   ( axil_araddr   ),
    .s_axi_csrs_arready  ( axil_arready  ),
    .s_axi_csrs_arvalid  ( axil_arvalid  ),
    .s_axi_csrs_awaddr   ( axil_awaddr   ),
    .s_axi_csrs_awready  ( axil_awready  ),
    .s_axi_csrs_awvalid  ( axil_awvalid  ),
    .s_axi_csrs_bready   ( axil_bready   ),
    .s_axi_csrs_bresp    ( axil_bresp    ),
    .s_axi_csrs_bvalid   ( axil_bvalid   ),
    .s_axi_csrs_rdata    ( axil_rdata    ),
    .s_axi_csrs_rready   ( axil_rready   ),
    .s_axi_csrs_rresp    ( axil_rresp    ),
    .s_axi_csrs_rvalid   ( axil_rvalid   ),
    .s_axi_csrs_wdata    ( axil_wdata    ),
    .s_axi_csrs_wready   ( axil_wready   ),
    .s_axi_csrs_wstrb    ( axil_wstrb    ),
    .s_axi_csrs_wvalid   ( axil_wvalid   ),
    .mem_clk             ( clk           ), 
    .mem_addr            ( mem_addr      ),     
    .mem_din             ( mem_din       ), 
    .mem_dout            ( mem_dout      ), 
    .mem_en              ( 1'b1          ), 
    .mem_rst             (~resetn        ), 
    .mem_we              ( mem_we        ));
      
  // Generate Clock
  initial begin
      clk = 0;
      forever #`CLK_HALF clk = ~clk;
  end

  // Initialize signals to zero
  initial begin
    axil_araddr  <= 'b0;
    axil_arvalid <= 'b0;
    axil_awaddr  <= 'b0;
    axil_awvalid <= 'b0;
    axil_bready  <= 'b0;
    axil_rready  <= 'b0;
    axil_wdata   <= 'b0;
    axil_wstrb   <= 'b0;
    axil_wvalid  <= 'b0;
  end

  // Reset the circuit
  initial begin
      resetn = 0;
      #`RESET_TIME
      resetn = 1;
  end

  // Read from specified register
  task reg_read;
    input [11:0] reg_address;
    output [31:0] reg_data;
    begin
      // Channel AR
      axil_araddr  <= reg_address;
      axil_arvalid <= 1'b1;
      wait (axil_arready);
      #`CLK_PERIOD;
      axil_arvalid <= 1'b0;
      // Channel R
      axil_rready  <= 1'b1;
      wait (axil_rvalid);
      reg_data <= axil_rdata;
      #`CLK_PERIOD;
      axil_rready  <= 1'b0;
      $display("reg[%x] <= %x", reg_address, reg_data);
      #`CLK_PERIOD;
      #`RESET_TIME;
    end
  endtask

  // Write to specified register
  task reg_write;
    input [11:0] reg_address;
    input [31:0] reg_data;
    begin
      // Channel AW
      axil_awaddr <= reg_address;
      axil_awvalid <= 1'b1;
      // Channel W
      axil_wdata  <= reg_data;
      axil_wstrb  <= 4'b1111;
      axil_wvalid <= 1'b1;
      // Channel AW
      wait (axil_awready);
      #`CLK_PERIOD;
      axil_awvalid <= 1'b0;
      // Channel W
      wait (axil_wready);
      #`CLK_PERIOD;
      axil_wvalid <= 1'b0;
      // Channel B
      axil_bready <= 1'b1;
      wait (axil_bvalid);
      #`CLK_PERIOD;
      axil_bready <= 1'b0;
      $display("reg[%x] <= %x", reg_address, reg_data);
      #`CLK_PERIOD;
      #`RESET_TIME;
    end
  endtask

  // Read at given address in memory
  task mem_write;
    input [  16:0] address;
    input [1024:0] data;
    begin
      mem_addr <= address;
      mem_din  <= data;
      mem_we   <= {128{1'b1}};
      #`CLK_PERIOD;
      mem_we   <= {128{1'b0}};
      $display("mem[%x] <= %x", address, data);
      #`CLK_PERIOD;
    end
  endtask

  // Write to given address in memory
  task mem_read;
    input [  16:0] address;
    begin
      mem_addr <= address;
      #`CLK_PERIOD;
      $display("mem[%x] => %x", address, mem_dout);
    end
  endtask

  // Byte Addresses of 32-bit registers
  localparam  COMMAND = 0, // r0
              R1  = 4, // r1
              R2  = 8, // r2
              R3 = 12,
              R4 = 16,
              R5 = 20,
              R6 = 24,
              R7 = 28,
              STATUS  = 0;

  // Byte Addresses of 1024-bit distant memory locations
  localparam  MEM1_ADDR  = 16'd00,
              MEM2_ADDR  = 16'd128,
              MEM3_ADDR  = 16'd256,
              MEM4_ADDR  = 16'd384,
              MEM5_ADDR  = 16'd512,
              MEM6_ADDR  = 16'd640;

  reg [31:0] reg_status;

  initial begin

    #`LONG_WAIT
    
    // WRITE TESTVECTORS TO MEMORY
    // write modulus M
    mem_write(MEM1_ADDR, 1024'ha4e2010b06082b0ebec377a8955c0aecddc25e1ec59cd6df72b890a32442b812154bdc9edb482e160fb28dbf1530eb09b943a41b2419e74f6a2fd6e7d7bb9c7595b65c8ad9917d50c0cbee16dc4df7c0d74c5d5dd908ad146d138a626443890a7eabd01aab72ad5774e5dab41d1b5b57ae99b304d96e1505c771a7c2c677823d);
    // write exponent E
    mem_write(MEM2_ADDR, 1024'heb);
    // write message X
    mem_write(MEM3_ADDR, 1024'hea132c164b791291d956c29d7d55c70b2f6d9bb2938b5cba145e268c162be86a24884a4eb2b32f5080a47c1aaec4e4793ad045598404ee9d81ac18e0fc8ae892ce30bc0738bfb937846b50470057075f08fdf52501b93e63e66c6e844aed030c61606436db4ffcbb6eec116e1df61006ae2ab0260b537e7c7a65f0407a6e75f5);
    // write A
    mem_write(MEM4_ADDR, 1024'h5b1dfef4f9f7d4f1413c88576aa3f513223da1e13a6329208d476f5cdbbd47edeab4236124b7d1e9f04d7240eacf14f646bc5be4dbe618b095d029182844638a6a49a375266e82af3f3411e923b2083f28b3a2a226f752eb92ec759d9bbc76f581542fe5548d52a88b1a254be2e4a4a851664cfb2691eafa388e583d39887dc3);
    // write R2
    mem_write(MEM5_ADDR, 1024'h85f3b8aa14a91171c7439f689098098dadce671bd56d521b457dae49155cf364b81959638f836b864759ede397a4f6fa7d3e6998aa586a4701dd79a730892e2ca1cec8729e2c64eb03ea521541fc93ca7677f29ae3c51e51258af5fdd88357643130eb6fda24d36d3998604427255f759ac36b2f6cb37e97985bce027856d908);

    // WRITE VALUES TO REGISTERS
    reg_write(R1, MEM1_ADDR);
    reg_write(R2, MEM2_ADDR);
    reg_write(R3, MEM3_ADDR);
    reg_write(R4, MEM4_ADDR);
    reg_write(R5, MEM5_ADDR);
    reg_write(R6, 16'd8); // length of exponent
    reg_write(R7, MEM6_ADDR);

    reg_write(COMMAND, 32'h00000001);
    
    // Poll Done Signal
    reg_read(COMMAND, reg_status);
    while (reg_status[0]==1'b0)
    begin
      #`LONG_WAIT;
      reg_read(COMMAND, reg_status);
    end
    
    reg_write(COMMAND, 32'h00000000);

    mem_read(MEM6_ADDR);

    $finish;

  end
endmodule