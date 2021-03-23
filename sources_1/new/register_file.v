`timescale 1ns / 1ps

module register_file(
    input clock, load, reset,
    input [2:0] in_address, out_address_a, out_address_b,
    input [15:0] in_data,
    output [15:0] out_data_a, out_data_b
    );
    
    wire [7:0] load_lines;
    wire [15 : 0] out_register_lines [0 : 7];
    
    decoder_3_to_8 addres_to_load_line (
        .in(in_address),
        .out(load_lines)
    );
    
    mux_16x8_to_16 mux_a (
        .select(out_address_a),
        .in_0(out_register_lines[0]),
        .in_1(out_register_lines[1]),
        .in_2(out_register_lines[2]),
        .in_3(out_register_lines[3]),
        .in_4(out_register_lines[4]),
        .in_5(out_register_lines[5]),
        .in_6(out_register_lines[6]),
        .in_7(out_register_lines[7]),
        .out(out_data_a)
    );
                          
    mux_16x8_to_16 mux_b (
        .select(out_address_b),
        .in_0(out_register_lines[0]),
        .in_1(out_register_lines[1]),
        .in_2(out_register_lines[2]),
        .in_3(out_register_lines[3]),
        .in_4(out_register_lines[4]),
        .in_5(out_register_lines[5]),
        .in_6(out_register_lines[6]),
        .in_7(out_register_lines[7]),
        .out(out_data_b)
    );

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            register_generic #(16) register_16 (
                .clock(clock),
                .load(load_lines[i] & load),
                .reset(reset),
                .in_data(in_data),
                .out_data(out_register_lines[i])
            );
        end
    endgenerate
    
    
endmodule
