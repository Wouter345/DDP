`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_ladder();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg           start;
    reg  [1023:0] in_x;
    reg  [1023:0] in_m;
    reg  [1023:0]  in_e;
    reg  [1023:0] in_r;
    reg  [1023:0] in_r2;
    reg  [31:0]   lene;
    wire [1023:0] result;
    wire          done;

    reg  [1023:0] expected;
    reg           result_ok;

    // Instantiating adder
    ladder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .in_x (in_x),
        .in_m     (in_m    ),
        .in_e     (in_e    ),
        .in_r     (in_r    ),
        .in_r2     (in_r2    ),
        .lene     (lene    ),
        .result   (result  ),
        .done     (done    ));

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals         input [1026:0] b;to zero
    initial begin
        in_m     <= 0;
        in_e     <= 0;
        in_x     <= 0;
        in_r     <= 0;
        in_r2    <= 0;
        lene     <= 0;
        start    <= 0;
        resetn   <= 0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    task perform_exp;
        input [1023:0] x;
        input [1023:0] m;
        input [1023:0] e;
        input [1023:0] r;
        input [1023:0] r2;
        input [31:0]   l;
        
        begin
            in_x <= x;
            in_m <= m;
            in_e <= e;
            in_r <= r;
            in_r2 <= r2;
            lene <= l;
            
            start <= 1'd1;
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
     perform_exp(1024'hea132c164b791291d956c29d7d55c70b2f6d9bb2938b5cba145e268c162be86a24884a4eb2b32f5080a47c1aaec4e4793ad045598404ee9d81ac18e0fc8ae892ce30bc0738bfb937846b50470057075f08fdf52501b93e63e66c6e844aed030c61606436db4ffcbb6eec116e1df61006ae2ab0260b537e7c7a65f0407a6e75f5, 
                1024'ha4e2010b06082b0ebec377a8955c0aecddc25e1ec59cd6df72b890a32442b812154bdc9edb482e160fb28dbf1530eb09b943a41b2419e74f6a2fd6e7d7bb9c7595b65c8ad9917d50c0cbee16dc4df7c0d74c5d5dd908ad146d138a626443890a7eabd01aab72ad5774e5dab41d1b5b57ae99b304d96e1505c771a7c2c677823d,
                1024'heb,
                1024'h5b1dfef4f9f7d4f1413c88576aa3f513223da1e13a6329208d476f5cdbbd47edeab4236124b7d1e9f04d7240eacf14f646bc5be4dbe618b095d029182844638a6a49a375266e82af3f3411e923b2083f28b3a2a226f752eb92ec759d9bbc76f581542fe5548d52a88b1a254be2e4a4a851664cfb2691eafa388e583d39887dc3,
                1024'h85f3b8aa14a91171c7439f689098098dadce671bd56d521b457dae49155cf364b81959638f836b864759ede397a4f6fa7d3e6998aa586a4701dd79a730892e2ca1cec8729e2c64eb03ea521541fc93ca7677f29ae3c51e51258af5fdd88357643130eb6fda24d36d3998604427255f759ac36b2f6cb37e97985bce027856d908,
                4'd8
                );
    expected  = 1024'h491240bb421d34c4e2ca3b1e5b6df9589c5c19e240f1dccb0d69f416ab947e93458b716f6edcb26e4d5c57d5eb8babd10e5944cf1bcb1aff3198154d3268f5709201343270b489b712124c869453dccaae46d52aa460671c0ca0e6b03a4d5167f297288f3d5bf5037d031ea45769512161065d128b4fda1ac2aad49214d4f5de;
    
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
