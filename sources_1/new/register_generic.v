`timescale 1ns / 1ps

module register_generic #(
    parameter SIZE = 1
    ) (
    input clock, load, reset,
    input [SIZE - 1:0] in_data,
    output reg [SIZE - 1:0] out_data
    );
    
    always @(posedge clock) begin
        if (reset == 1'b1) begin
            out_data = 0;
        end
        else if (load == 1'b1) begin
            out_data = in_data;
        end
    end
endmodule
