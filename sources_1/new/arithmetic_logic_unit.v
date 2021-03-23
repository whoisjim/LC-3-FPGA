`timescale 1ns / 1ps

module arithmetic_logic_unit(
    input [1:0] select,
    input [15:0] in_a,
    input [15:0] in_b,
    output [15:0] out
    );
    
    wire [15:0] out_adder;       // when 00
    wire [15:0] out_not;         // when 01
    wire [15:0] out_and;         // when 10
    assign out_not = ~in_a;
    assign out_and = in_a & in_b;
    adder_16 adder (.in_a(in_a), .in_b(in_b), .out(out_adder));
    mux_16x4_to_16 mux (.select(select), .in_0(out_adder), .in_1(out_not), .in_2(out_and), .in_3(16'b0), .out(out));
endmodule
