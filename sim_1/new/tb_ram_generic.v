`timescale 1ns / 1ps

module tb_ram_generic();

    localparam period = 1;
    reg [18:0] i;
    reg clock, read, write;
    reg [15:0] in_data;
    reg [16:0] address;
    wire [15:0] out_data;
    
    ram_generic #(16, 16) dut (.clock(clock),
                               .read(read),
                               .write(write),
                               .address(address),
                               .in_data(in_data),
                               .out_data(out_data));

    initial begin
        clock = 1'b0;
        read = 1'b0;
        write = 1'b1;
        // write data
        for (i = 0; i < 16; i = i + 1) begin
            clock = i[0];
            address = i[8:1];
            in_data = i[16:1] * 2 + 100;
            #period; // wait for period 
        end
        read = 1'b1;
        write = 1'b0;
        in_data = 0;
        // read data
        for (i = 0; i < 16; i = i + 1) begin
            clock = i[0];
            address = i[8:1];
            #period; // wait for period
        end
    end

endmodule
