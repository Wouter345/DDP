`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder4();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg  [1026:0] in_a;
    reg  [1026:0] in_b;
    wire [1027:0] result;

    reg  [1027:0] expected;
    reg           result_ok;

    // Instantiating adder
    mpadder4 dut (
        .clk      (clk     ),
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
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    $display("result_ok = %x", result_ok);
    #`CLK_PERIOD;     
    
    
    $finish;

    end

endmodule
