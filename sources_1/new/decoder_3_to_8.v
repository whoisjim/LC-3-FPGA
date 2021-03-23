`timescale 1ns / 1ps

module decoder_3_to_8(input [2:0] in, output [7:0] out);
    assign out = in[2] ? (in[1] ? (in[0] ? 8'b10000000 : 8'b01000000) : (in[0] ? 8'b00100000 : 8'b00010000)) : (in[1] ? (in[0] ? 8'b00001000 : 8'b00000100) : (in[0] ? 8'b00000010 : 8'b00000001));
endmodule
