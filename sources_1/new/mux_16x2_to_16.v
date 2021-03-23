`timescale 1ns / 1ps

module mux_16x2_to_16(
    input select,
    input [15:0] in_0, in_1,
    output [15:0] out
    );
    assign out = select ? in_1 : in_0;
endmodule
