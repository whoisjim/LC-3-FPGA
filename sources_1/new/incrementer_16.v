`timescale 1ns / 1ps

module incrementer_16(input [15:0] in, output [15:0] out);
    assign out = in + 1;
endmodule
