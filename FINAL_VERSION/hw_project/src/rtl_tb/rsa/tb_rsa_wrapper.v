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
      //$display("reg[%x] <= %x", reg_address, reg_data);
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
      //$display("reg[%x] <= %x", reg_address, reg_data);
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
      //$display("mem[%x] <= %x", address, data);
      #`CLK_PERIOD;
    end
  endtask

  // Write to given address in memory
  task mem_read;
    input [  16:0] address;
    begin
      mem_addr <= address;
      #`CLK_PERIOD;
      #`CLK_PERIOD;
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
              MEM6_ADDR  = 16'd640,
              MEM7_ADDR  = 16'd768;

  reg [31:0] reg_status;
  reg  [1023:0] expected1;
  reg  [1023:0] expected2;
  reg           result_ok;

  initial begin

    #`LONG_WAIT
    
    // WRITE TESTVECTORS TO MEMORY
    // write modulus M
    mem_write(MEM1_ADDR, 1024'h8871ad3ad598e0460d066a2e032249f2ee69fe596fd34a5df46b6ead84e27d53f92e6e1dedc7fddeca94afa0847f327fc0fa706f926449a2e8fd51674efaba62e81f9807795aeae93a66adae3a2db29d007d88b9670db890153ce2ae3a3e80c9403f7482ee441baf0f6012d9ecc4cb364ae9cacf04c12020a3fed5ecbdcaa551);
    // write exponent E
    mem_write(MEM2_ADDR, 1024'ha6c9);
    // write message X
    mem_write(MEM3_ADDR, 1024'h84d0602019b57d24fcb0c4b988343a8715c118246d7ee8659e39a1d76c842e0377f9507da73a4761db9ca41ede8b214b1f9fb7b3babe8f21517e85ec001c52bca19aa82e659f7cc9356f7ec8fbcb972e5ed8baac1e6e899ac37e8cd5822b05be123e8933c85c1b4ff35ed09335e455cf439c0857820425d183930c415d20342a);
    // write A
    mem_write(MEM4_ADDR, 1024'h778e52c52a671fb9f2f995d1fcddb60d119601a6902cb5a20b9491527b1d82ac06d191e212380221356b505f7b80cd803f058f906d9bb65d1702ae98b105459d17e067f886a51516c5995251c5d24d62ff82774698f2476feac31d51c5c17f36bfc08b7d11bbe450f09fed26133b34c9b5163530fb3edfdf5c012a1342355aaf);
    // write R2
    mem_write(MEM5_ADDR, 1024'h6ef7ff6bfd20abc32782986bf306fc38ff57094e701b3d1987fdb29cbb58924c4922c850871e72bedd5397970086ae34016a3c843bad109111a1473f7d0e5aad14e105e00e5d91019ef42707f0a44f796e935bdd430c6d63a446761e03c6597c32a25bb6f3b38f174f415d7ba50787975d144fa72cb8ac75bb1b24ad69c0fd33);
    expected1 = 1024'h130d6f824a1d28f774af86d34e849cb8b9f021c89eb219496f13d817b53fa177fc6636e31b6858a6d2537b90f014caffead434036e34a315ff4c1b228ca3b5eeda99650cddcfcf04f62419d9815f4b5f72b4690f8f738d14b19217bd0760cb4e281b39f1ba5dd264efeaf014b4d430b7802dd5b8be880200b7f1f3378a9093b6;
    // WRITE VALUES TO REGISTERS
    reg_write(R1, MEM1_ADDR);
    reg_write(R2, MEM2_ADDR);
    reg_write(R3, MEM3_ADDR);
    reg_write(R4, MEM4_ADDR);
    reg_write(R5, MEM5_ADDR);
    reg_write(R6, 16'd16); // length of exponent
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
    
    
    // WRITE TESTVECTORS TO MEMORY
    // write modulus M
    mem_write(MEM1_ADDR, 1024'h8871ad3ad598e0460d066a2e032249f2ee69fe596fd34a5df46b6ead84e27d53f92e6e1dedc7fddeca94afa0847f327fc0fa706f926449a2e8fd51674efaba62e81f9807795aeae93a66adae3a2db29d007d88b9670db890153ce2ae3a3e80c9403f7482ee441baf0f6012d9ecc4cb364ae9cacf04c12020a3fed5ecbdcaa551);
    // write exponent E
    mem_write(MEM2_ADDR, 1024'h4936464328d839be4e03ae8b1f9e48f48b7c6a45277a999518e9022b542cce71caf8f015be302afc62940c55af7c606524541619ded64b1d2701b87d1d68c9e8fb0c951921df37252ba7f728e6913b51a2fba212843ef4077132a84285ab6865fcf4a940975222e991ad0a2ef4eadb23d3893d247703e88572cce918e43d48f9);
    // write message X, this is the encrypted message
    mem_write(MEM3_ADDR, 1024'h130d6f824a1d28f774af86d34e849cb8b9f021c89eb219496f13d817b53fa177fc6636e31b6858a6d2537b90f014caffead434036e34a315ff4c1b228ca3b5eeda99650cddcfcf04f62419d9815f4b5f72b4690f8f738d14b19217bd0760cb4e281b39f1ba5dd264efeaf014b4d430b7802dd5b8be880200b7f1f3378a9093b6);
    // write A
    mem_write(MEM4_ADDR, 1024'h778e52c52a671fb9f2f995d1fcddb60d119601a6902cb5a20b9491527b1d82ac06d191e212380221356b505f7b80cd803f058f906d9bb65d1702ae98b105459d17e067f886a51516c5995251c5d24d62ff82774698f2476feac31d51c5c17f36bfc08b7d11bbe450f09fed26133b34c9b5163530fb3edfdf5c012a1342355aaf);
    // write R2
    mem_write(MEM5_ADDR, 1024'h6ef7ff6bfd20abc32782986bf306fc38ff57094e701b3d1987fdb29cbb58924c4922c850871e72bedd5397970086ae34016a3c843bad109111a1473f7d0e5aad14e105e00e5d91019ef42707f0a44f796e935bdd430c6d63a446761e03c6597c32a25bb6f3b38f174f415d7ba50787975d144fa72cb8ac75bb1b24ad69c0fd33);
    expected2 = 1024'h84d0602019b57d24fcb0c4b988343a8715c118246d7ee8659e39a1d76c842e0377f9507da73a4761db9ca41ede8b214b1f9fb7b3babe8f21517e85ec001c52bca19aa82e659f7cc9356f7ec8fbcb972e5ed8baac1e6e899ac37e8cd5822b05be123e8933c85c1b4ff35ed09335e455cf439c0857820425d183930c415d20342a;
    // WRITE VALUES TO REGISTERS
    reg_write(R1, MEM1_ADDR);
    reg_write(R2, MEM2_ADDR);
    reg_write(R3, MEM3_ADDR);
    reg_write(R4, MEM4_ADDR);
    reg_write(R5, MEM5_ADDR);
    reg_write(R6, 16'd1023); // length of exponent
    reg_write(R7, MEM7_ADDR);

    reg_write(COMMAND, 32'h00000001);
    
    // Poll Done Signal
    reg_read(COMMAND, reg_status);
    while (reg_status[0]==1'b0)
    begin
      #`LONG_WAIT;
      reg_read(COMMAND, reg_status);
    end
    
    reg_write(COMMAND, 32'h00000000);

    reg_write(COMMAND, 32'h00000000);
    
    
    mem_read(MEM6_ADDR);
    #`CLK_PERIOD;
    $display("encryption result expected  =%x", expected1);
    result_ok = (expected1==mem_dout);
    $display("encryption result_ok = %x", result_ok);
    
    mem_read(MEM7_ADDR);
    #`CLK_PERIOD;
    $display("decryption result expected  =%x", expected2);
    result_ok = (expected2==mem_dout);
    $display("decryption result_ok = %x", result_ok);

    $finish;

  end
endmodule
