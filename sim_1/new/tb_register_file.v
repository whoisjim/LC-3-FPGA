`timescale 1ns / 1ps

module tb_register_file();
    localparam period = 1;
    reg [18:0] i;
    reg clock, load, reset;
    reg [15:0] in_data;
    reg [3:0] in_address, out_address_a, out_address_b;
    wire [15:0] out_data_a, out_data_b;
    
    register_file dut (.clock(clock),
                       .load(load),
                       .reset(reset),
                       .in_address(in_address),
                       .out_address_a(out_address_a),
                       .out_address_b(out_address_b),
                       .in_data(in_data),
                       .out_data_a(out_data_a),
                       .out_data_b(out_data_b));

    initial begin
        in_data = 0;
        in_address = 0;
        out_address_a = 0;
        out_address_b = 0;
        reset = 1'b1;
        load = 1'b0;
        clock = 1'b0;
        #period; // wait for period 
        clock = 1'b1;
        #period; // wait for period
        reset = 1'b0;
        clock = 1'b0;
        load = 1'b1;
        #period; // wait for period  
        clock = 1'b1;
        #period; // wait for period 
        
        // load data
        for (i = 0; i < 16; i = i + 1) begin
            clock = i[0];
            in_data = i[16:1];
            in_address = i[8:1];
            #period; // wait for period 
        end
        
        load = 1'b0;
        #period; // wait for period 
        
        // read data
        for (i = 0; i < 8; i = i + 1) begin
            out_address_a = i;
            out_address_b = 7 - i;
            #period; // wait for period
            #period; // wait for period 
        end
    end
endmodule
