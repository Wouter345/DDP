`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_montgomery();
    
    reg          clk;
    reg          resetn;
    reg          start;
    reg  [1023:0] in_a;
    reg  [1023:0] in_b;
    reg  [1023:0] in_m;
    wire [1023:0] result;
    wire         done;

    reg  [1023:0] expected;
    reg          result_ok;
    
    //Instantiating montgomery module
    montgomery montgomery_instance( .clk    (clk    ),
                                    .resetn (resetn ),
                                    .start  (start  ),
                                    .in_a   (in_a   ),
                                    .in_b   (in_b   ),
                                    .in_m   (in_m   ),
                                    .result (result ),
                                    .done   (done   ));

    //Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end
    
    //Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end
    
    // Test data
    initial begin

        #`RESET_TIME
        
        // You can generate your own with test vector generator python script
    in_a    <= 1024'h 8351d9e0d39641d129b6dc6b47e6f5524235cf20212ca45ecca06624bbf168e86e01547033de622b1213be043b886de4459d6bdda8a8c7cce1d53c40c103dd3597f1770a70732c3e99d28c979eb7eb982b44381b9d057bd6a8fbcbcec5a12758c087419afa0a13f23bfb4a255b891e2a6f93f5c3310bdb081f77f307f07fcbec ;
    in_b    <= 1024'h f04d2376ce58daec7a9cf0ec6b1d2c32b7ce87a196f2bccf906fbdf9a5dccc40685b7a87bb65781215905d6dbfc219c002207d543e44d9b89166d1c2cfb62582ad0ea9be3e886f2791938b82b8406302cdb4737a5f29f5427c2bcc50e66fe81d76f18b5280cafac64075f0263bbde5edfeabb47cf127981c376822e68bb2668 ;
    in_m    <= 1024'h ab3643e8d0ae413d9a4f89f342bc7dc7474183caa52af82922e057fe9e8ecc5371016f690754a23684cf9f85475c498f0467b509a52bfcc637e007e10835e16fcd0f292eb2b18b81a4121c37c367b0dc7324ae760fe8ff8cf53470501164581b7ae6bdfcf114ba41ed0310e1add686ca365224f155de1be75f2633031b71666b ;
    expected <= 1024'h 7deef113111e239e86ebfcdb25593fce197320f2e724b1523a9e23ab3ffb61bfe7ff4ab7e301db2a13f67dcec8fd83e8064dff8b26e997df094a88ad1b135c729f9d3d19587bc635a597bb4e496cb3edef00f1c52e379d9a0d0c55826d5321cbef34678d7ace50b07d0b5f80dcbec1a5a722a71c6ace8241ce23a2ca45624da ;
          
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        
        wait (done==1);
        
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        $display("result_ok =   =%x", result_ok);
        
        #`CLK_PERIOD;   
        
        $finish;
    end
           
endmodule