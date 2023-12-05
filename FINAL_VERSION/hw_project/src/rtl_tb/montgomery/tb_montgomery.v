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
        in_a    <= 1024'h 9d67580c21d551af7fef5a8fad0b8701624c898eb54fb4cb3ddcde1e29af70d23932e53e8c74e9416de799bdd9b6bf3cecce2e6ab2d805a6f98580ae03eaf5e1c2e99d81c5564113c391a5ac284d637e442ea01f2ef00ca547bb3b9aed28635a278995fb4fe0c5d8343fc042ff22e50171cd03911bc9f4b96c167b15f4ff1841 ;
        in_b    <= 1024'h bd45b6910b6d66c74af4ce5145479013a3aa7cca299177242e88ea8f535ee153eeaa2273d1d24face050f3b3a61764251677165a306db18b221a93bfe4ef3f95f9ce726b18514f285d79500818321b4d9fd85f69abcae81e3b6577669961801ec4c40be5d79269be104ba47d0d5c499d59e5b21426da7160c6b8665e96ab0079 ;
        in_m    <= 1024'h f8036f33fab4c0ca3aec5f05425a86115410c6023ccb495e40f9636b6cc2605d3176e4013400b26a71a37166073b74b6b34988c5cd30e354891398b5eed783eccff409df5aae60a51f49238c9fe5c4924fbf46aefdc0f53df1e5608ff9950c86e94361f920af2ed350af598f087685ad416a883fe0489887dcdabb240aac6267 ;
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
