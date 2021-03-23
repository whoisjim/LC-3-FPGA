`timescale 1ns / 1ps

module mux_16x8_to_16(
    input [2:0] select,
    input [15:0] in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7,
    output [15:0] out
    );
    
    assign out = select[2] ? (select[1] ? (select[0] ? in_7 : in_6) : (select[0] ? in_5 : in_4)) : (select[1] ? (select[0] ? in_3 : in_2) : (select[0] ? in_1 : in_0));
endmodule
