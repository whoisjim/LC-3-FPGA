`timescale 1ns / 1ps

module tb_arithmetic_logic_unit();
    localparam period = 1;
    reg [1:0] i = 0;
    reg [1:0] select;
    reg [15:0] in_a = 16'b00010011010101110;
    reg [15:0] in_b = 16'b01100010100001001;
    wire [15:0] out;
    
    arithmetic_logic_unit dut (.select(select), .in_a(in_a), .in_b(in_b), .out(out));
    
    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            select = i;
            #period; // wait for period 
        end
    end
endmodule
