`timescale 1ns / 1ps

module adder_16(
    input [15:0] in_a,
    input [15:0] in_b,
    output [15:0] out
    );

    wire [15:0] carry_line;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            if (i == 0) begin
                full_adder addr (
                    .a(in_a[i]), 
                    .b(in_b[i]), 
                    .c(1'b0), 
                    .sum(out[i]), 
                    .carry(carry_line[i])
                );         
            end
            else begin
                full_adder addr (
                    .a(in_a[i]), 
                    .b(in_b[i]), 
                    .c(carry_line[i-1]), 
                    .sum(out[i]), 
                    .carry(carry_line[i])
                );
            end
        end
    endgenerate
endmodule
