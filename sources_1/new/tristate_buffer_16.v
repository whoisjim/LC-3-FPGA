`timescale 1ns / 1ps
module tristate_buffer_16(input enable, input [15:0] in, output [15:0] out);
    assign out = enable ? in : 16'bzzzzzzzzzzzzzzzz;
endmodule
