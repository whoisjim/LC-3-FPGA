`timescale 1ns / 1ps

module seven_segment_decoder_hex_16(
    input clock,
    input [15:0] in_data,
    output reg [6:0] segments,
    output [3:0] annodes
    );

    parameter delay = 100000;
    reg [31:0] count = 0;
    reg [1:0] digit_select = 0;

    // select digit, activate high
    assign annodes[0] = ~(~digit_select[0] & ~digit_select[1]);
    assign annodes[1] = ~(digit_select[0] & ~digit_select[1]);
    assign annodes[2] = ~(~digit_select[0] & digit_select[1]);
    assign annodes[3] = ~(digit_select[0] & digit_select[1]);
    
    // encode digit, active low
    always @(negedge clock) begin
        count = count + 1;
        if (count == delay) begin
            count = 0;
            digit_select = digit_select + 1;
        end
        case(digit_select[1] ? (digit_select[0] ? in_data[15:12] : in_data[11:8]) : (digit_select[0] ? in_data[7:4] : in_data[3:0]))
            4'b0000: segments = 7'b0000001; // 0
            4'b0001: segments = 7'b1001111; // 1
            4'b0010: segments = 7'b0010010; // 2
            4'b0011: segments = 7'b0000110; // 3
            4'b0100: segments = 7'b1001100; // 4
            4'b0101: segments = 7'b0100100; // 5
            4'b0110: segments = 7'b0100000; // 6
            4'b0111: segments = 7'b0001111; // 7
            4'b1000: segments = 7'b0000000; // 8
            4'b1001: segments = 7'b0000100; // 9
            4'b1010: segments = 7'b0001000; // a
            4'b1011: segments = 7'b1100000; // b
            4'b1100: segments = 7'b0110001; // c
            4'b1101: segments = 7'b1000010; // d
            4'b1110: segments = 7'b0110000; // e
            4'b1111: segments = 7'b0111000; // f
            default: segments = 7'b1111111; // none
        endcase
    end
endmodule

