`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg  [1026:0] in_a;
    reg  [1026:0] in_b;
    reg           start;
    reg           subtract;
    wire [1027:0] result;
    wire          done;

    reg  [1027:0] expected;
    reg           result_ok;

    // Instantiating adder
    mpadder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
        .result   (result  ),
        .done     (done    ));

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals to zero
    initial begin
        in_a     <= 0;
        in_b     <= 0;
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
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd0;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    task perform_sub;
        input [1026:0] a;
        input [1026:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd1;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    initial begin

    #`RESET_TIME

    /*************TEST ADDITION*************/
    
    $display("\nAddition with testvector 1");
    
    // Check if 1+1=2
    #`CLK_PERIOD;
     perform_add(1027'h443c9713694a86d1a7469342f8798d18cba2c46faed845b0ba460cd742a58b5178555c7579827dfefc3753d3af0d86918e2ccd7353aa6293cb673c197502eb1fadbaebf6fafd450533874904ae87820e1d9aecc5b0988f91d29dab6145bf7b0ab62bda229d84382e68099fbbe41284be3b43d64568bf47f9b3b35d25d071ce054, 
                1027'h0x5f4ff1841f006de67fab4c0ca3aec5f05425a86115410c6023ccb495e40f9636b6cc2605d3176e4013400b26a71a37166073b74b6b34988c5cd30e354891398b5eed783eccff409df5aae60a51f49238c9fe5c4924fbf46aefdc0f53df1e5608ff9950c86e94361f920af2ed350af598f087685ad416a883fe0489887dcdabb24);
    expected  = 1028'h0xa38c8897884af4b826f1df4f9c2853091fc86cd0c4195210de12c16d26b521882f21827b4c99ec3f0f775efa5627bda7eea084bebedefb20283a4a4ebd9424ab0ca86435c7fc85a329322f0f007c1446e799490ed59483fcc279bab524ddd113b5c52aeb0c186e4dfa1492a9191d7a572bcb3ea03cd5f07db1b7e6ae4e3f79b78;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;   
    
    
    $display("\nAddition with 5testvector 2");

    // Test addition with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
    perform_add(1027'h6, 
                1027'h1);
    expected  = 1028'h7;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;     
    
    /*************TEST SUBTRACTION*************/

    $display("\nSubtraction with testvector 1");
    
    // Check if 1-1=0
    #`CLK_PERIOD;
    perform_sub(1027'h2, 
                1027'h1);
    expected  = 1028'h1;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;    


    $display("\nSubtraction with testvector 2");

    // Test subtraction with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
    perform_sub(1027'h6fb734834375c10c35cd8b58baecd83e32a5249d46f5ff6def02094d2a8733ddd742f92c882b522402700bd74004776e7498e7545abccda330761b80d520326d8762484d6b60908f74f31fd320bb8b6cc5cef91632e1a4bac9b7b946602af8bb662889e6e8ed52c178506c1f3a064581c926c23b8ff85c247827b578aff2ef518,
                1027'h716dd59f485e8c4487b824d5e6500bd021216a91d1d85cb048560a974db668281526d378533bae9acd8c1bf1099f39cfec93111fa7dcf31d2e75410d88769068da07ecdf7bf562167e52817720d03a6d6bbcd76e997dfdb5e95e393446cdfe1601b2a424b06501d121037587cc0895c7bcc96a13e3312785ad637fa6fcb330218);
    expected  = 1028'hfe495ee3fb1734c7ae156682d49ccc6e1183ba0b751da2bda6abfeb5dcd0cbb5c21c25b434efa38934e3efe636653d9e8805d634b2dfda860200da734ca9a204ad5a5b6def6b2e78f6a09e5bffeb50ff5a1221a79963a704e0598012195cfaa56475e5c2388850f0574cf6976dfdafba0c5d5827acc7349ecac435d1b33fbf300;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;    
    
    $finish;

    end

endmodule