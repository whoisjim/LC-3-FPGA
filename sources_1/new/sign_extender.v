`timescale 1ns / 1ps

module sign_extender #(
    parameter SIZE = 15
    ) (
    input [SIZE - 1:0] in,
    output [15:0] out
    );
    
    wire [16 - SIZE:0] ones = {16-SIZE{1'b1}};
    wire [16 - SIZE:0] zeros = 0;
    assign out = in[SIZE - 1] ? {ones, in} : {zeros, in};
endmodule
