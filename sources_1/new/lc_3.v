`timescale 1ns / 1ps

module lc_3(
    input clock, reset, accept,
    input [15:0] switch,
    output segment_ca, segment_cb, segment_cc, segment_cd, segment_ce, segment_cf, segment_cg, 
    output [7:0] segment_an
    );
    
    wire [15 : 0] data_bus;

    wire [15 : 0] arithmetic_logic_mux_data;
    wire [15 : 0] arithmetic_logic_unit_data_out;
    wire [15 : 0] register_file_data_a;
    wire [15 : 0] register_file_data_b;
    wire [15 : 0] immediate_value_5;
    wire [15 : 0] immediate_value_6;
    wire [15 : 0] immediate_value_8;
    wire [15 : 0] immediate_value_9;
    wire [15 : 0] immediate_value_11;
    wire [15 : 0] instruction_register_data_out;
    wire [15 : 0] seven_segment_display_register_data_out;

    wire flag_negative_register_in;
    wire flag_negative_register_out;
    wire flag_zero_register_in;
    wire flag_zero_register_out;
    wire flag_positive_register_in;
    wire flag_positive_register_out;

    wire [15 : 0] program_counter_register_out;
    wire [15 : 0] program_counter_incrementer_out;
    wire [15 : 0] program_counter_mux_out;

    wire [15 : 0] address_adder_mux_a_out;
    wire [15 : 0] address_adder_mux_b_out;
    wire [15 : 0] address_adder_out;
    
    wire [15 : 0] memory_data_register_out;
    wire [15 : 0] memory_out;
    wire [15 : 0] memory_address_register_mux_out;

    wire load_seven_segment_display_register, load_instruction_register, load_program_counter, load_register_file, load_memory_data_register, load_flag_register;
    wire [2:0] register_file_in_address;
    wire [2:0] register_file_out_a_address;
    wire [2:0] register_file_out_b_address;
    wire memory_address_register_mux_select;
    wire [1:0] program_counter_mux_select;
    wire address_adder_mux_a_select;
    wire [1:0] address_adder_mux_b_select;
    wire arithmetic_logic_mux_select;
    wire [1:0] arithmetic_logic_unit_select;
    wire memory_data_buffer_enable, memory_address_buffer_enable, arithmetic_logic_unit_buffer_enable, program_counter_buffer_enable, register_file_out_a_buffer_enable;
    wire memory_read_enable, memory_write_enable;
    
    finite_state_machine_controller finite_state_machine_controller (
        .clock(clock),
        .reset(~reset),
        .flag_negative(flag_negative_register_out),
        .flag_zero(flag_zero_register_out),
        .flag_positive(flag_positive_register_out),
        .instruction_register(instruction_register_data_out),
        .accept(accept),
        .load_instruction_register(load_instruction_register),
        .load_program_counter(load_program_counter),
        .load_register_file(load_register_file),
        .load_memory_data_register(load_memory_data_register),
        .load_flag_register(load_flag_register),
        .load_seven_segment_display_register(load_seven_segment_display_register),
        .register_file_in_address(register_file_in_address),
        .register_file_out_a_address(register_file_out_a_address),
        .register_file_out_b_address(register_file_out_b_address),
        .memory_address_register_mux_select(memory_address_register_mux_select),
        .program_counter_mux_select(program_counter_mux_select),
        .address_adder_mux_a_select(address_adder_mux_a_select),
        .address_adder_mux_b_select(address_adder_mux_b_select),
        .arithmetic_logic_mux_select(arithmetic_logic_mux_select),
        .arithmetic_logic_unit_select(arithmetic_logic_unit_select),
        .memory_data_buffer_enable(memory_data_buffer_enable),
        .memory_address_buffer_enable(memory_address_buffer_enable),
        .arithmetic_logic_unit_buffer_enable(arithmetic_logic_unit_buffer_enable),
        .program_counter_buffer_enable(program_counter_buffer_enable),
        .register_file_out_a_buffer_enable(register_file_out_a_buffer_enable),
        .switch_input_buffer_enable(switch_input_buffer_enable),
        .memory_read_enable(memory_read_enable),
        .memory_write_enable(memory_write_enable)
    );

    register_file register_file (
        .clock(clock),
        .load(load_register_file),
        .reset(~reset),
        .in_address(register_file_in_address),
        .out_address_a(register_file_out_a_address),
        .out_address_b(register_file_out_b_address),
        .in_data(data_bus),
        .out_data_a(register_file_data_a),
        .out_data_b(register_file_data_b)
    );
    
    tristate_buffer_16 register_file_out_a_buffer (
        .enable(register_file_out_a_buffer_enable),
        .in(register_file_data_a),
        .out(data_bus)
    );

    arithmetic_logic_unit arithmetic_logic_unit (
        .select(arithmetic_logic_unit_select),
        .in_a(register_file_data_a),
        .in_b(arithmetic_logic_mux_data),
        .out(arithmetic_logic_unit_data_out)
    );

    mux_16x2_to_16 arithmetic_logic_mux (
        .select(arithmetic_logic_mux_select),
        .in_0(immediate_value_5),
        .in_1(register_file_data_b),
        .out(arithmetic_logic_mux_data)
    );

    tristate_buffer_16 arithmetic_logic_out_buffer (
        .enable(arithmetic_logic_unit_buffer_enable),
        .in(arithmetic_logic_unit_data_out),
        .out(data_bus)
    );

    sign_extender #(5) sign_extender_immediate_value_5 (
        .in(instruction_register_data_out[4:0]),
        .out(immediate_value_5)
    );
    
    sign_extender #(6) sign_extender_immediate_value_6 (
        .in(instruction_register_data_out[5:0]),
        .out(immediate_value_6)
    );
    
    sign_extender #(9) sign_extender_immediate_value_9 (
        .in(instruction_register_data_out[8:0]),
        .out(immediate_value_9)
    );
    
    sign_extender #(11) sign_extender_immediate_value_11 (
        .in(instruction_register_data_out[10:0]),
        .out(immediate_value_11)
    );
    
    zero_extender #(8) zero_extender_immediate_value_8 (
        .in(instruction_register_data_out[7:0]),
        .out(immediate_value_8)
    );
    
    mux_16x2_to_16 address_adder_mux_a (
        .select(address_adder_mux_a_select),
        .in_0(register_file_data_a), 
        .in_1(program_counter_register_out),
        .out(address_adder_mux_a_out)
    );
    
    mux_16x4_to_16 address_adder_mux_b (
        .select(address_adder_mux_b_select),
        .in_0(immediate_value_6), 
        .in_1(immediate_value_9),
        .in_2(immediate_value_11),
        .in_3({16{1'b0}}),
        .out(address_adder_mux_b_out)
    );
    
    adder_16 address_adder (
        .in_a(address_adder_mux_a_out),
        .in_b(address_adder_mux_b_out),
        .out(address_adder_out)
    );
    
    mux_16x4_to_16 program_counter_mux (
        .select(program_counter_mux_select),
        .in_0(data_bus), 
        .in_1(address_adder_out),
        .in_2(program_counter_incrementer_out),
        .in_3({16{1'b0}}),
        .out(program_counter_mux_out)
    );
    
    register_generic #(16) program_counter_register (
        .clock(clock),
        .load(load_program_counter), 
        .reset(~reset),
        .in_data(program_counter_mux_out),
        .out_data(program_counter_register_out)
    );
    
    incrementer_16 program_counter_incrementer (
        .in(program_counter_register_out),
        .out(program_counter_incrementer_out)
    );
    
    tristate_buffer_16 program_counter_out_buffer (
        .enable(program_counter_buffer_enable),
        .in(program_counter_register_out),
        .out(data_bus)
    );
    
    flag_logic flag_logic (.in(data_bus),
        .flag_negative(flag_negative_register_in),
        .flag_zero(flag_zero_register_in),
        .flag_positive(flag_positive_register_in)
    );
    
    register_generic #(1) flag_negative_register (
        .clock(clock),
        .load(load_flag_register), 
        .reset(~reset),
        .in_data(flag_negative_register_in),
        .out_data(flag_negative_register_out)
    );
    
    register_generic #(1) flag_zero_register (
        .clock(clock),
        .load(load_flag_register), 
        .reset(~reset),
        .in_data(flag_zero_register_in),
        .out_data(flag_zero_register_out)
    );
    
    register_generic #(1) flag_positive_register (
        .clock(clock),
        .load(load_flag_register), 
        .reset(~reset),
        .in_data(flag_positive_register_in),
        .out_data(flag_positive_register_out)
    );
    
    register_generic #(16) instruction_register (
        .clock(clock),
        .load(load_instruction_register), 
        .reset(~reset),
        .in_data(data_bus),
        .out_data(instruction_register_data_out)
    );
    
    ram_generic #(16, 16) memory_16_16 (
        .clock(clock),
        .read(memory_read_enable), 
        .write(memory_write_enable),
        .address(data_bus),
        .in_data(memory_data_register_out),
        .out_data(memory_out)
    );
    
    register_generic #(16) memory_data_register (
        .clock(clock),
        .load(load_memory_data_register), 
        .reset(~reset),
        .in_data(data_bus),
        .out_data(memory_data_register_out)
    );
    
    mux_16x2_to_16 memory_address_register_mux (
        .select(memory_address_register_mux_select),
        .in_0(immediate_value_8),
        .in_1(address_adder_out),
        .out(memory_address_register_mux_out)
    );
    
    tristate_buffer_16 memory_address_buffer (
        .enable(memory_address_buffer_enable),
        .in(memory_address_register_mux_out),
        .out(data_bus)
    );
    
    tristate_buffer_16 memory_data_buffer (
        .enable(memory_data_buffer_enable),
        .in(memory_out),
        .out(data_bus)
    );

    register_generic #(16) seven_segment_display_register (
        .clock(clock),
        .load(load_seven_segment_display_register), 
        .reset(~reset),
        .in_data(data_bus),
        .out_data(seven_segment_display_register_data_out)
    );

    seven_segment_decoder_hex_16 seven_segment_decoder (
    .clock(clock),
    .in_data(seven_segment_display_register_data_out),
    .segments({segment_ca, segment_cb, segment_cc, segment_cd, segment_ce, segment_cf, segment_cg}),
    .annodes(segment_an[3:0])
    );

    assign segment_an[7:4] = 4'b1111;

    tristate_buffer_16 switch_input_buffer (
        .enable(switch_input_buffer_enable),
        .in(switch),
        .out(data_bus)
    );
    
endmodule
