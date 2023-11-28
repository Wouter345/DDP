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
        in_a    <= 1024'h 3 ;
        in_b    <= 1024'h 5 ;
        in_m    <= 1024'h 8 ;
        expected <= 1024'h 39f8516f4c471e55f629d58110b193db3ddc9c058a47ca3dcbe11d4ca28eef41b6d89e6f471829eb46b6131967ce26b95fa9067606582ede2cca63187f12748ac4388f4cac2942b59c21ed7c6b278c62fda260dceb293f13b3bcf6a2cb6bfb12afba7da33f5ff5f252374dc8e0ff06c404eee8cc6309cd881559d18811ddcad4 ;

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