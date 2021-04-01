`timescale 1ns / 1ps

module tb_lc_3();

    localparam period = 1;
    reg [16:0] i;
    reg clock, reset;
    wire [15:0] data_bus;
    
    lc_3 #(16, 16) dut (
        .clock(clock),
        .reset(reset)
    );

    initial begin
        clock = 1'b0;
        reset = 1'b1;
        #period; // wait for period 
        clock = 1'b1;
        #period; // wait for period
        clock = 1'b0;
        #period; // wait for period
        clock = 1'b1;
        #period; // wait for period
        reset = 1'b0;
        for (i = 0; i < 1024; i = i + 1) begin
            clock = i[0];
            #period; // wait for period 
        end
    end

endmodule
