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
        in_a    <= 1024'h d8afaf482a5ef533be55890f115e4a35201ac44baac4a2f3eaf97866ce120ff664301d06351ce58f8107897e40d3161a11d4d2ab681e96c912be9681a9e857fe7d4f3ea76d02dd144b9be33401cf3003f1d6bc65c081b59f2c1604c0fbafcf14760b57e8d0a569c2d5ca3814518f890b9f5e6d9eda63938ec1c4fa6e221b21a ;
        in_b    <= 1024'h 30be51ddaf11815e84b5b4f15547eaf7ab45c05cf6adfbb79ef48a7314984fd854185af505be4f3cf6cea3da0ebfa3238fcd5c49a49c10b75ef8e83a6a4faaddb62aba2867d148c2fccc31120cba7d1c44b6fd65a86583834333f07231f2e041a6d5af45e4ec6e2d7ecaa6df21e222a8adb2a1da0f11e735b7014f8eae5aff05 ;
        in_m    <= 1024'h 9bc74b7b1e220ff48c9d8ec3ef09f4e47aae25366b42a2725a62d6576a3d63d3d68d0a7b65cb92c2dd7642623622bc85134f466198faa5b56526cc3a08dfe47368a14180b7354ed9d67d4d22cdb53c494653512532066d452b31ded1b1c5d1f83b84a05f7405b987168e11e71fabadd9f26b785b17ed85bdd84ab0e0be2a9511 ;
        expected <= 1024'h 6e67c277c67bcd268e543310d54b8f6fe2bc23c070518b6f4d70148c2bca0be0675c050b72c51f3a27fd01aca1aef59a9f9247ae5d7ba6399cb74cce66564c1802d68b4a901626f56975b82b72ad205a22f1810f5d85cf46ff797889577e4d197a0d43567d819ea83f522fd82bfb2444b977ebb222fe50b582ccc63afb54dd8 ;
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