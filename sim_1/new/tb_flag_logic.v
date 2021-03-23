`timescale 1ns / 1ps

module tb_flag_logic();

    localparam period = 1;
    reg [15:0] in;
    wire flag_negative, flag_zero, flag_positive;
    flag_logic dut (.in(in), .flag_negative(flag_negative), .flag_zero(flag_zero), .flag_positive(flag_positive));
    // loop through all inputs
    initial begin
        in = 0;
        #period;
        in = -1;
        #period;
        in = 1;
        #period;
        in = -42;
        #period;
        in = 234;
        #period;
        in = 0;
        #period;
    end

endmodule
