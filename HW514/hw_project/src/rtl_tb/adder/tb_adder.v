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
    reg  [127:0]  in_e;
    reg  [1023:0] in_r;
    reg  [1023:0] in_r2;
    reg  [31:0]   lene;
    wire [1027:0] result;
    wire          done;

    reg  [1027:0] expected;
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
        input [127:0]  e;
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
     perform_exp(1023'hd6b57402dc660045a2c7a3b8036d1c7dccaf10a883eec36b63e02342347eb8eac9741ddbde5a33fb1c1cae3f6735dd1e3f9de283d319e8cffc6645776fca5d66f4a4627e04c1a85ce7bab90319ea53f4e9fcb8aa198f3ee76897ceb43469e51380f4ea55b3d77be8998f50134ad9e071512e3519844d8d37565d2102931aa47f, 
                1023'h8677465bb8d2690bb98e537a71796c49a9c5a4dd4cc3f10fc60dac450abb232a4d7c966855d2f8f1fd9a566ee5c1b24c27d283469aa4d128f273c8b1104d73ab874e40890901b4cf4b6b100574a3df9070884b3db5c6b1d78902ffe9fda01d8fdf57f65f205620145290a0a0d4f8cc0d1afa16a1c6c15568e0a658eaa88edc35,
                128'he7,
                1023'h3649af3dbe351cee3574980d4c93678cb5dbafeb1db049f155f77dc7544cb85ab268ea75163a0e41d4c75702de0556476ba3273b5ce461cd1b3d0fa3385e0f02f239c48b8a3365bd846e9606e02540937ed1860f1dcd5208bbddc266eb18aa638d40f2ca9bf40a5ca7d9fde99c584453a08c7d15ef8fc04b0936198e306cb43f,
                1023'h3b84f452517e94b1584f6f435c3f92406d4f5c045a911deebbedbf690437c3c01a22c6502b29756f7f26ed06b9868cb19acae1efbb653689557455c19af4dfa323d6396dad61a2671d138e1729099eb7764c279933295700aa3b5362a3604a7f26a8aa41dca81131684380871a10ae86d12fbe3baf854d4aaa8d33dffd6ad556,
                4'd8
                );
    expected  = 1023'h3016d28e94016aa532c97157c0441976d5f26a1c0596ca0fda0947c2a1cdd2202d9b559139720d9a84d8bdb607d3e4edd29af37b58edfc828f16987eb20a1fbfe64c1c3e64e5ea9d0b9be9ad3ecbeafd2562722ae7f1cfe6a85f9a20a29aef5e83dd48d1a2bd854bea95da64b5fea69d0ead4fa50831f92de06ffd2d0170574;
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