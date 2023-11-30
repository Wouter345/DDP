`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder2();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg  [1026:0] in_a;
    reg  [1026:0] in_b;
    reg  [1026:0] in_c;
    reg           start;
    reg           subtract;
    wire [1027:0] result;
    wire          done;

    reg  [1027:0] expected;
    reg           result_ok;

    // Instantiating adder
    mpadder4 dut (
        .clk      (clk     ),
        .subtract (subtract),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
//        .in_c     (in_c    ),
        .result   (result  ));

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals to zero
    initial begin
        in_a     <= 0;
        in_b     <= 0;
        in_c     <= 0;
        subtract <= 0;
        start    <= 0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    task perform_add;
        input [1026:0] a;
        input [1026:0] b;
        input [1026:0] c;
        begin
            in_a <= a;
            in_b <= b;
            in_c <= c;
            start <= 1'd1;
            subtract <= 1'd0;
            #`CLK_PERIOD;
            start <= 1'd0;
        end
    endtask

    task perform_sub;
        input [1026:0] a;
        input [1026:0] b;
        input [1026:0] c;
        begin
            in_a <= a;
            in_b <= b;
            in_c <= c;
            start <= 1'd1;
            subtract <= 1'd1;
            #`CLK_PERIOD;
            start <= 1'd0;
        end
    endtask

    initial begin

    #`RESET_TIME

    /*************TEST ADDITION*************/
    
    $display("\nAddition with testvector 1");
    
    
    #`CLK_PERIOD;
     perform_add(1027'h 1cd447e35b8b6d8fe442e3d437204e52db2221a58008a05a6c4647159c324c9859b810e766ec9d28663ca828dd5f4b3b2e4b06ce60741c7a87ce42c8218072e8c35bf992dc9e9c616612e7696a6cecc1b78e510617311d8a3c2ce6f447ed4d57b1e2feb89414c343c1027c4d1c386bbc4cd613e30d8f16adf91b7584a2265b1f5,
                 1027'h 1380208a9ad45f23d3b1a11df587fd2803bab6c398d88348a7eed8d14f06d3fef701966a0c381e88f38c0c8fd8712b8bc076f3787b9d179e06c0fd4f5f8130c4237730edfafbd67f9619699cfe1988ad9f06c144a025b413f8a9a021ea648a7dd06839eb905b6e6e307d4bedc51431193e6c3f3391a2b8f1ff1fd42a29755d4c1,
                 1027'h 2e901e35cd47d380d81f9c1f66c0f3459f79b17aeefba91fc803468b6b610a9f7f9270f4eb8b333a8e5446dd4552b82f6be3edc0a1ef2a4f04be03db0dc2574bdb94067edfe175330a11d459a2f978d8719999e3fa46d6753ec148cb48e73ca47ea90a8f0d66b829e6a8ac4ba05805975ed2f89d94a2f20aaf3c64af775a89294
                 );
    expected  = 1028'h 3054686df65fccb3b7f484f22ca84b7adedcd86918e123a314351fe6eb39209750b9a7517324bbb159c8b4b8b5d076c6eec1fa46dc1134188e8f40178101a3ace6d32a80d79a72e0fc2c51066886756f5695124ab756d19e34d687163251d7d5824b38a4247031b1f17fc83ae14c9cd58b4253169f31cf9ff83b49aecb9bb86b6;
    #`CLK_PERIOD;
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD;   
    
    #`CLK_PERIOD;
     perform_sub(1027'h 1cd447e35b8b6d8fe442e3d437204e52db2221a58008a05a6c4647159c324c9859b810e766ec9d28663ca828dd5f4b3b2e4b06ce60741c7a87ce42c8218072e8c35bf992dc9e9c616612e7696a6cecc1b78e510617311d8a3c2ce6f447ed4d57b1e2feb89414c343c1027c4d1c386bbc4cd613e30d8f16adf91b7584a2265b1f5,
                 1027'h 1380208a9ad45f23d3b1a11df587fd2803bab6c398d88348a7eed8d14f06d3fef701966a0c381e88f38c0c8fd8712b8bc076f3787b9d179e06c0fd4f5f8130c4237730edfafbd67f9619699cfe1988ad9f06c144a025b413f8a9a021ea648a7dd06839eb905b6e6e307d4bedc51431193e6c3f3391a2b8f1ff1fd42a29755d4c1,
                 1027'h 0
                 );
    expected  = 1028'h 9542758c0b70e6c109142b64198512ad7676ae1e7301d11c4576e444d2b789962b67a7d5ab47e9f72b09b9904ee1faf6dd41355e4d704dc810d4578c1ff42249fe4c8a4e1a2c5e1cff97dcc6c53641418878fc1770b6976438346d25d88c2d9e17ac4cd03b954d59085305f57243aa30e69d4af7bec5dbbf9fba15a78b0fdd34;
    #`CLK_PERIOD;
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD; 
    
    

    $finish;

    end

endmodule
