`timescale 1ns / 1ps

module tb_decoder_3_to_8();
    
    localparam period = 1;
    reg [2:0] i = 0;
    reg [2:0] in;
    wire [7:0] out;
    decoder_3_to_8 dut (.in(in),
                        .out(out));
    // loop through all inputs
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            in = i;
            #period; // wait for period 
        end
    end
endmodule
