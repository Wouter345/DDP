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
        in_a    <= 1024'h 95cdf03a5dc82ffaea28284bf45f027c53737cf1910c1362ca1fdb97a81775143b6dcdff34bc147fb86c6955a1f88682073f84cec4f80e316fbb7bc6aefa093b84ce2fa98ee201bee8ef580c7117a0c327f6d35c610b1dff76e4e11d4f0e3f81e40f339a62518eb77e0e732ebc3e32d4d12cbbf94df4262e9288b3ca39e21ec9 ;
        in_b    <= 1024'h 1bffdbccfd28a4dba0c2c093c7d68ff5dca8089f9e1d9ac1eef7cc2816e14761b3dd25b689d467d1e13875ca6c9b180462d0c2c0bc8ccbd8fc7a6157a09efee862f59bfc60e2aca8224c0aaa1b01d2422e7764a0f0d4878192d5ddaaf9817c1bea3f67a0d5a064e503c16a8304e589deaf93f7848eadbd7472b53b31162b307 ;
        in_m    <= 1024'h bdb86dd95c0a033603d2df01e2d651ef7b8f8c831c793440bb3a2f5a008d40894786455714b73900d49ea9337cc074fcfe774c33034f9e67c2927ae3645ea035f01c4219c3d11032a34ae494dcbe11c7f3895f32c68a09ae203d608b138b049eed851056fdf1a2d5097d94aa639186c47858122b0266fba704914d49453e778f ;
        expected <= 1024'h 5869a65106f034ccaea74f3361cc20fdcbb998732926e854c47364b9cf26fa2260ca127606012e7b1daf33b6ac46e3984f762987c13df039432c444118ad0001cc266210da9fb5a437f21c7483a8642dbaf9edcdab3e3cabdf2980fad2aac571bb1413b83b8ed9147975ad0f5ecbd555e581216dbf5eace92b67c2c61538607b ;

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