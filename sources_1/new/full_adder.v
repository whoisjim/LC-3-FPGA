`timescale 1ns / 1ps

module full_adder(input a, b, c, output sum, carry);
    wire d;
    assign d = a ^ b;
    assign sum = c ^ d;
    assign carry = a & b | c & d; 
endmodule
