`timescale 1ns / 1ps

module tb_mux_16x8_to_16();
    localparam period = 1;
    reg [2:0] i = 0;
    reg [15:0] in_0 = 15;
    reg [15:0] in_1 = 16;
    reg [15:0] in_2 = 17;
    reg [15:0] in_3 = 18;
    reg [15:0] in_4 = 19;
    reg [15:0] in_5 = 20;
    reg [15:0] in_6 = 21;
    reg [15:0] in_7 = 22;
    reg [2:0] select;
    wire [15:0] out;
    mux_16x8_to_16 dut (.select(select),
                       .in_0(in_0),
                       .in_1(in_1),
                       .in_2(in_2),
                       .in_3(in_3),
                       .in_4(in_4),
                       .in_5(in_5),
                       .in_6(in_6),
                       .in_7(in_7),
                       .out(out));
    // loop through all inputs
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            select = i;
            #period; // wait for period 
        end
    end
endmodule
