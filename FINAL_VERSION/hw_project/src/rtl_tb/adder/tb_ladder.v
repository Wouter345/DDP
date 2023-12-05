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
     perform_exp(1024'h84d0602019b57d24fcb0c4b988343a8715c118246d7ee8659e39a1d76c842e0377f9507da73a4761db9ca41ede8b214b1f9fb7b3babe8f21517e85ec001c52bca19aa82e659f7cc9356f7ec8fbcb972e5ed8baac1e6e899ac37e8cd5822b05be123e8933c85c1b4ff35ed09335e455cf439c0857820425d183930c415d20342a, 
                1024'h8871ad3ad598e0460d066a2e032249f2ee69fe596fd34a5df46b6ead84e27d53f92e6e1dedc7fddeca94afa0847f327fc0fa706f926449a2e8fd51674efaba62e81f9807795aeae93a66adae3a2db29d007d88b9670db890153ce2ae3a3e80c9403f7482ee441baf0f6012d9ecc4cb364ae9cacf04c12020a3fed5ecbdcaa551,
                1024'ha6c9,
                1024'h778e52c52a671fb9f2f995d1fcddb60d119601a6902cb5a20b9491527b1d82ac06d191e212380221356b505f7b80cd803f058f906d9bb65d1702ae98b105459d17e067f886a51516c5995251c5d24d62ff82774698f2476feac31d51c5c17f36bfc08b7d11bbe450f09fed26133b34c9b5163530fb3edfdf5c012a1342355aaf,
                1024'h6ef7ff6bfd20abc32782986bf306fc38ff57094e701b3d1987fdb29cbb58924c4922c850871e72bedd5397970086ae34016a3c843bad109111a1473f7d0e5aad14e105e00e5d91019ef42707f0a44f796e935bdd430c6d63a446761e03c6597c32a25bb6f3b38f174f415d7ba50787975d144fa72cb8ac75bb1b24ad69c0fd33,
                32'd16
                );
    expected  = 1024'h130d6f824a1d28f774af86d34e849cb8b9f021c89eb219496f13d817b53fa177fc6636e31b6858a6d2537b90f014caffead434036e34a315ff4c1b228ca3b5eeda99650cddcfcf04f62419d9815f4b5f72b4690f8f738d14b19217bd0760cb4e281b39f1ba5dd264efeaf014b4d430b7802dd5b8be880200b7f1f3378a9093b6;
    
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
