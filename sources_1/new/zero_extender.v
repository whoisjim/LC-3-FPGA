`timescale 1ns / 1ps

module zero_extender #(
    parameter SIZE = 15
    ) (
    input [SIZE - 1:0] in,
    output [15:0] out
    );
    
    wire [16 - SIZE:0] zeros = 0;
    assign out = {zeros, in};
endmodule
