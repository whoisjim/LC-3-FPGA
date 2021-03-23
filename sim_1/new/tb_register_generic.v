`timescale 1ns / 1ps

module tb_register_generic();
    localparam period = 1;
    reg [18:0] i;
    reg clock, load, reset;
    reg [15:0] in_data;
    wire [15:0] out_data;
    
    register_generic #(16) dut (.clock(clock), .load(load), .reset(reset), .in_data(in_data), .out_data(out_data));

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            {in_data, reset, load, clock} = i;
            #period; // wait for period 
        end
    end
endmodule
