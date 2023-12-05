`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder2();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg  [1030:0] in_a;
    reg  [1030:0] in_b;
    reg           start;
    reg           subtract;
    wire [1030:0] result;
    wire          done;

    reg  [1030:0] expected;
    reg           result_ok;

    // Instantiating adder
    mpadderD dut (
        .clk      (clk     ),
        .reset    (~resetn ),
        .subtract (subtract),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
        .result   (result  ));

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
        input [1030:0] a;
        input [1030:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd0;
            #`CLK_PERIOD;
            start <= 1'd0;
        end
    endtask

    task perform_sub;
        input [1030:0] a;
        input [1030:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd1;
            #`CLK_PERIOD;
            start <= 1'd0;
        end
    endtask

    initial begin

    #`RESET_TIME

    /*************TEST ADDITION*************/
    
    $display("\nAddition with testvector 1");
    
    
    #`CLK_PERIOD;
     perform_add(1030'h ff7d5ec09bc03e20af2529cad670a8382054fa816e7c0c6a07ac5fed4b6ea010bea4256e36c2a4c7d885bbac88043e5f1221b5a22155a41c2ff7c0fcbbe8f88da415c4c839a44721de85eb9025ac45a0aa8b230f3b05e392a6ea1c0d2f8b9e9de3d6e4b9d96e182dcd502d42af1ffe0de8d79f49af6d114c4a6f188a424e617b,
                 1030'h 385d3c6201abb4da1c6df8ccf6fb3e7196906b630c8cb950a5c147eea8e5f31bed7c9df9403be93fb8d9959a625b1196f741b79d35e08409f0cb348bfb23b6bd8ff306dc016fcfd73dbea7f23973790dfbd38cadcd432ff218ce5915e6e36b0753cf4b1858cb4ac8b4df0c841f15bf54df258ececbd59a0625469d3e78fe339eca


                 );
    expected  = 1031'h 395cb9c0c24775183d1d1df6c1d1af19ceb0c05d8dfb355d0fc8f44e963161bbfe3b421eae72abe480b21b560ee315d55653d952d801d9ae0cfb2c4cf7df9fb61d971ca0c9a9741e5f9d2dddc99925539c7e17d0dc7e35d5ab754331f412f6a5f1b321fd12a4b8e0e2ac5cb161c4df52ed0e666e1585071771910c570340820045;
    #`CLK_PERIOD;
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD;   
    
    #`CLK_PERIOD;
     perform_sub(1030'h 10cecf4f4e5ba8078050cef798e6c648e7deeda8b23927f7d64375d0341e4f6f2ae8af30f7c70b53bf64d0b50f658c6762df7142dcaf29e6f877744cca4d909eb2732242fda8902e3212979bfcbbeb508f4a800646417a8105bc3199944567ceb13f372617f0baef3a86f0ce2ea6ec39c1c15521b1b3dca50a9daa37e51b591d75,
                 1030'h 69b872a76e57b37e7704b3d09ef2eab42fd8cfe3395522f9a67574c0261c2df96fa5e2d63daa4ed3c3454fae446287225154d1eb0071d14815649f8e998466a921f7ea79c11e760a5a6d5b30a02b7075d2a3a0c78467c0714a9fbd797aa59c1698d242349293a9acc2652f8ff842a2f9da1b4ba07a1fa7d4acde560db5c54e05b

                 );
    expected  = 1031'h a334824d7762ccf98e083ba8ef7979da4e160aa7ea3d5c83bdc1e8431bc8c8f93ee510393ec666683307bba2b1f63f53dca24242ca80cd277212a53e0b54a342053a39b6196a8cd8c6bc1e8f2b93449322045f9cdfafe79f11235c1fc9b0e0d47b21302cec780546e609dd52f22c20a241fa067aa11e227bfcfc4d709bf043d1a;
    #`CLK_PERIOD;
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD; 
    
    

    $finish;

    end

endmodule
