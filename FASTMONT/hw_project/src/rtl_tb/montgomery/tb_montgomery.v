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
    montgomeryC montgomery_instance( .clk    (clk    ),
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
        in_a    <= 1024'h 9539e7d2f8516eda36a3b898b5bf20136d1be14a58d58a3fea0c5861a6749adcd3d5f624b356ce290d0db988ee5f23b79062927afc5d73160202009201d8fda1067c6f2d93b7607e496b4d66fa1514c52b502541c78288046df6843a6f76924924d9396100b829bee2ca48b544df839f0ebeb0c8045bbcb102e8d7e608ea858e ;
        in_b    <= 1024'h aba7bd12fff162501486a48894fa712a67a3607923284ed401c6821e57123d6ccae9a3c54b864c707b5ff88ca35416f4c8ab9f230156964fce1eb45842051e6468cd5ebf2db6b15aa67b5cd03c5f3cf2d939d978ba704182f2b7dbf2cef1c2f84fe06709b50389e903a532eb09475bb54b5eb2d039e5497b52cfb2707a735aef ;
        in_m    <= 1024'h d786090feb9f7130ee610fb4b64e9a997f448849d57ec44990ea84a194d42325d8bf55777b5fccb2414b07dc2bcb420f69aa2b700f063b471b665a346759085c8f6ef18fa9e4dd3531fe9e2f5fe8ae6b5033f362757d935fde779dc999e1cc38dae5c21ed3f62093030e7d07ea13903075cfbd4218e0920428e2da6bad656d29 ;
        expected <= 1024'h 7ed703b54530fd9d93b4e9f1fa3e76407118a51cb358b766e62857682f9bf70ccc9b91ca4cc78f0c5da631a4381ecb1b10532ec72c65c8ec18e797ec53d83b029c66137e610c11d48d80b168bb14acffe624b00695a03ff3424dcff199055efc91e06c6905daf9f8d7a019490d4f83d628218c0b6cd0659aae5e0e4dd2f64314 ;

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
