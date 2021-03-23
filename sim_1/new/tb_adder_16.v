`timescale 1ns / 1ps

module tb_adder_16();
    localparam period = 1;
    reg [31:0] i = 0;
    reg [15:0] in_a;
    reg [15:0] in_b;
    wire [15:0] out;
    adder_16 dut (.in_a(in_a), .in_b(in_b), .out(out));
    // loop through all inputs
    initial begin
        in_a = 0;
        in_b = -23;
        #period;
        in_a = -1;
        in_b = 2345;
        #period;
        in_a = 1;
        in_b = 2281;
        #period;
        in_a = -42;
        in_b = -456;
        #period;
        in_a = 234;
        in_b = 0;
        #period;
        in_a = 324;
        in_b = -324;
        #period;
    end
endmodule
