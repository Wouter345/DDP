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
    mpadder3 dut (
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
     perform_add(1027'h2,
                 1027'h5);
    expected  = 1028'h7;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD;   
    
    
    $display("\nAddition with 5testvector 2");

    // Test addition with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
    perform_add(1027'h5c5e73dcf394531550048dc95d5d36860fe8d4b76495a357a73f5f8251e3ad3e6f9d8f9becb3ad91fcb139302e752da54bb8176a178ef7854d77a3adb8564122972eb6e5fa57a9efe69b353e92177bbeb73c67385bcaf495813bbdf1b3663500202bd57940cef64c3dcedf6bcacdc0f8dde3229b46f1285388eef248e344ac794, 
                1027'h5464c48c2f6d1723b283f54c2ad25ea58b479a624ef83d64688d397511cb679ceddd184be85f21747bcd2a3d360c2fffcdd70dc1467c3cc0951f6e16a43120f2bcc38a827b25f10bf4778b31b34b04f13a4cd3045c3a22bb291c466eb791c2c12db1c50cb611bafa77627f80eec035ef284fb9458b9cd2a288d87dc9619f6d770);
    expected  = 1028'hb0c3386923016a3902888315882f952b9b306f19b38de0bc0fcc98f763af14db5d7aa7e7d512cf06787e636d64815da5198f252b5e0b3445e29711c45c87621553f24168757d9afbdb12c070456280aff1893a3cb8051750aa5804606af7f7c14ddd9a85f6e0b146b5315eecb98df6e80632dbe0d28dfaf611c7701244e419f04;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD;     
    
    /*************TEST SUBTRACTION*************/

    $display("\nSubtraction with testvector 1");
    
    // Check if 1-1=0
    #`CLK_PERIOD;
    perform_sub(1027'h443c9713694a86d1a7469342f8798d18cba2c46faed845b0ba460cd742a58b5178555c7579827dfefc3753d3af0d86918e2ccd7353aa6293cb673c197502eb1fadbaebf6fafd450533874904ae87820e1d9aecc5b0988f91d29dab6145bf7b0ab62bda229d84382e68099fbbe41284be3b43d64568bf47f9b3b35d25d071ce054, 
                1027'h5f4ff1841f006de67fab4c0ca3aec5f05425a86115410c6023ccb495e40f9636b6cc2605d3176e4013400b26a71a37166073b74b6b34988c5cd30e354891398b5eed783eccff409df5aae60a51f49238c9fe5c4924fbf46aefdc0f53df1e5608ff9950c86e94361f920af2ed350af598f087685ad416a883fe0489887dcdabb24);
    expected  = 1028'he4eca58f4a4a18eb279b473654cac728777d1c0e99973950967958415e95f51ac189366fa66b0fbee8f748ad07f34f7b2db91627e875ca076e942de42c71b1944ecd73b82dfe04673ddc62fa5c92efd5539c907c8b9c9b26e2c19c0d66a12501b692895a2ef0020ed5feacceaf078f254abc6dea94a89f75b5aed39d52a422530;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD;    


    $display("\nSubtraction with testvector 2");

    // Test subtraction with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
    perform_sub(1027'h4,
                1027'h8);
    expected  = 1028'hfe495ee3fb1734c7ae156682d49ccc6e1183ba0b751da2bda6abfeb5dcd0cbb5c21c25b434efa38934e3efe636653d9e8805d634b2dfda860200da734ca9a204ad5a5b6def6b2e78f6a09e5bffeb50ff5a1221a79963a704e0598012195cfaa56475e5c2388850f0574cf6976dfdafba0c5d5827acc7349ecac435d1b33fbf300;
    wait (done==1);
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD;    
    
    $finish;

    end

endmodule