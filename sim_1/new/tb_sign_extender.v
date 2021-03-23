`timescale 1ns / 1ps

module tb_sign_extender();
    reg [3:0] in_4 = 4'b1010;
    wire [15:0] out_4;
    reg [4:0] in_5 = 5'b01010;
    wire [15:0] out_5;
    reg [5:0] in_6 = 6'b111010;
    wire [15:0] out_6;
    reg [14:0] in_15 = 15'b011111010101010;
    wire [15:0] out_15;
    sign_extender #(4) dut4 (.in(in_4), .out(out_4));
    sign_extender #(5) dut5 (.in(in_5), .out(out_5));
    sign_extender #(6) dut6 (.in(in_6), .out(out_6));
    sign_extender #(15) dut15 (.in(in_15), .out(out_15));
    initial begin
        #1; // wait for period 
    end
endmodule
