`timescale 1ns / 1ps

module tb_tristate_buffer_16();

    localparam period = 1;
    reg [8:0] i = 0;
    reg enable;
    reg [7:0] in;
    wire [7:0] out;
    tristate_buffer_16 dut (.enable(enable),
                            .in(in),
                            .out(out));
    // loop through all inputs
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            {in, enable} = i;
            #period; // wait for period 
        end
    end
    
endmodule
