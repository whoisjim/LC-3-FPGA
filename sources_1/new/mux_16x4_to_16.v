`timescale 1ns / 1ps

module mux_16x4_to_16(
    input [1:0] select,
    input [15:0] in_0, in_1, in_2, in_3,
    output [15:0] out
    );
    assign out = select[1] ? (select[0] ? in_3 : in_2) : (select[0] ? in_1 : in_0);
endmodule
