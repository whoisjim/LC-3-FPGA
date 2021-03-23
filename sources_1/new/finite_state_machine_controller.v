`timescale 1ns / 1ps

module finite_state_machine_controller(
  input clock, reset, flag_negative, flag_zero, flag_positive,
  input [15:0] instruction_register,
  output reg load_instruction_register, load_program_counter, load_register_file, load_memory_data_register, load_flag_register,
  output reg [2:0] register_file_in_address,
  output reg [2:0] register_file_out_a_address,
  output reg [2:0] register_file_out_b_address,
  output reg memory_address_register_mux_select,
  output reg [1:0] program_counter_mux_select,
  output reg address_adder_mux_a_select,
  output reg [1:0] address_adder_mux_b_select,
  output reg arithmetic_logic_mux_select,
  output reg [1:0] arithmetic_logic_unit_select,
  output reg memory_data_buffer_enable, memory_address_buffer_enable, arithmetic_logic_unit_buffer_enable, program_counter_buffer_enable, register_file_out_a_buffer_enable,
  output reg memory_read_enable, memory_write_enable
  );

  reg [7:0] state = 0;
  reg [1:0] instruction_clock_count = 0; // how many clocks have passed for this instruction

  always @(negedge clock) begin
    if (reset) begin
      state = 0;
    end
    case(state)
      0: begin // reset
        load_instruction_register = 1'b0;
        load_program_counter = 1'b0;
        load_register_file = 1'b0;
        load_memory_data_register = 1'b0;
        load_flag_register = 1'b0;

        memory_data_buffer_enable = 1'b0;
        memory_address_buffer_enable = 1'b0;
        arithmetic_logic_unit_buffer_enable = 1'b0;
        program_counter_buffer_enable = 1'b0;
        register_file_out_a_buffer_enable = 1'b0;

        memory_read_enable = 1'b0;
        memory_write_enable = 1'b0;

        state = 1;
        instruction_clock_count = 0;
      end
      1: begin// set instruction address
        load_instruction_register = 1'b0;
        load_program_counter = 1'b0;
        load_register_file = 1'b0;
        load_memory_data_register = 1'b0;
        load_flag_register = 1'b0;

        memory_data_buffer_enable = 1'b0;
        memory_address_buffer_enable = 1'b0;
        arithmetic_logic_unit_buffer_enable = 1'b0;
        program_counter_buffer_enable = 1'b1;
        register_file_out_a_buffer_enable = 1'b0;

        memory_read_enable = 1'b1;
        memory_write_enable = 1'b0;

        state = 2;
      end
      2: begin // increment program counter, load instruction register
        memory_data_buffer_enable = 1'b1;
        memory_address_buffer_enable = 1'b0;
        arithmetic_logic_unit_buffer_enable = 1'b0;
        program_counter_buffer_enable = 1'b0;
        register_file_out_a_buffer_enable = 1'b0;

        program_counter_mux_select = 2'b10; // increment
        
        load_instruction_register = 1'b1;
        load_program_counter = 1'b1;
        load_register_file = 1'b0;
        load_memory_data_register = 1'b0;
        load_flag_register = 1'b0;

        memory_read_enable = 1'b0;
        memory_write_enable = 1'b0;

        state = 3;
      end
      3: begin // decode opcode
        case(instruction_register[15:12])
          4'b0000: begin // br
            load_instruction_register = 1'b0;
            load_program_counter = 1'b1;
            load_register_file = 1'b0;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b0;

            address_adder_mux_a_select = 1'b1; // use program counter
            address_adder_mux_b_select = 2'b01; // sext9

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b0;
            arithmetic_logic_unit_buffer_enable = 1'b0;
            program_counter_buffer_enable = 1'b1;
            register_file_out_a_buffer_enable = 1'b0;

            if (instruction_register[11:9] == {flag_negative, flag_zero, flag_positive}) begin
              program_counter_mux_select = 2'b01; // jump
            end else begin
              program_counter_mux_select = 2'b00; // do not jump
            end

            state = 1;
            instruction_clock_count = 0;

          end
          4'b0001: begin // add
            load_instruction_register = 1'b0;
            load_program_counter = 1'b0;
            load_register_file = 1'b1;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b1;

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b0;
            arithmetic_logic_unit_buffer_enable = 1'b1;
            program_counter_buffer_enable = 1'b0;
            register_file_out_a_buffer_enable = 1'b0;

            register_file_in_address = instruction_register[11:9];
            register_file_out_a_address = instruction_register[8:6];
            if (instruction_register[5] == 1'b0) begin
              register_file_out_b_address = instruction_register[2:0];
              arithmetic_logic_mux_select = 1;
            end else begin
              arithmetic_logic_mux_select = 0;
            end
            arithmetic_logic_unit_select = 2'b00;

            state = 1;
            instruction_clock_count = 0;
          end
          4'b0010: begin // ld
            case(instruction_clock_count)  
              0: begin // read memory to data_bus
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                address_adder_mux_a_select = 1'b1; // use program counter
                address_adder_mux_b_select = 2'b01; // sext9
                memory_address_register_mux_select = 1'b1;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b1;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b1;
                memory_write_enable = 1'b0;

                instruction_clock_count = 1;
              end
              1: begin // store data_bus in register
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b1;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b1;

                memory_data_buffer_enable = 1'b1;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                register_file_in_address = instruction_register[11:9];

                memory_read_enable = 1'b0;
                memory_write_enable = 1'b0;

                state = 1;
                instruction_clock_count = 0;
              end
            endcase
          end
          4'b0011: begin // st
            case(instruction_clock_count)  
              0: begin // put register on to data_bus
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b1;
                load_flag_register = 1'b0;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b1;

                register_file_out_a_address = instruction_register[11:9];

                instruction_clock_count = 1;
              end
              1: begin // put address on bus and write data to memory
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                address_adder_mux_a_select = 1'b1; // use program counter
                address_adder_mux_b_select = 2'b01; // sext9
                memory_address_register_mux_select = 1'b1;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b1;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b0;
                memory_write_enable = 1'b1;

                state = 1;
                instruction_clock_count = 0;
              end
            endcase
          end
          4'b0100: begin // jsr
            case(instruction_clock_count)  
              0: begin // store return address
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b1;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b1;
                register_file_out_a_buffer_enable = 1'b0;

                register_file_in_address = 3'b111;

                state = 3;
                instruction_clock_count = 1;
              end
              1: begin // set pc
                if (instruction_register[11] == 1'b1) begin // pc ofset mode mode
                  load_instruction_register = 1'b0;
                  load_program_counter = 1'b1;
                  load_register_file = 1'b0;
                  load_memory_data_register = 1'b0;
                  load_flag_register = 1'b0;

                  address_adder_mux_a_select = 1'b1; // use program counter
                  address_adder_mux_b_select = 2'b10; // sext11
                  program_counter_mux_select = 2'b01; // get pc from address adder

                  memory_data_buffer_enable = 1'b0;
                  memory_address_buffer_enable = 1'b0;
                  arithmetic_logic_unit_buffer_enable = 1'b0;
                  program_counter_buffer_enable = 1'b0;
                  register_file_out_a_buffer_enable = 1'b0;

                end else begin // register mode
                  load_instruction_register = 1'b0;
                  load_program_counter = 1'b1;
                  load_register_file = 1'b0;
                  load_memory_data_register = 1'b0;
                  load_flag_register = 1'b0;

                  memory_data_buffer_enable = 1'b0;
                  memory_address_buffer_enable = 1'b0;
                  arithmetic_logic_unit_buffer_enable = 1'b0;
                  program_counter_buffer_enable = 1'b0;
                  register_file_out_a_buffer_enable = 1'b1;

                  program_counter_mux_select = 2'b00; // get pc from data bus
                  
                  register_file_out_a_address = instruction_register[8:6];
                end
                state = 1;
                instruction_clock_count = 0;
              end
            endcase
          end
          4'b0101: begin // and
            load_instruction_register = 1'b0;
            load_program_counter = 1'b0;
            load_register_file = 1'b1;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b1;

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b0;
            arithmetic_logic_unit_buffer_enable = 1'b1;
            program_counter_buffer_enable = 1'b0;
            register_file_out_a_buffer_enable = 1'b0;

            register_file_in_address = instruction_register[11:9];
            register_file_out_a_address = instruction_register[8:6];
            if (instruction_register[5] == 1'b0) begin
              register_file_out_b_address = instruction_register[2:0];
              arithmetic_logic_mux_select = 1;
            end else begin
              arithmetic_logic_mux_select = 0;
            end
            arithmetic_logic_unit_select = 2'b10;

            state = 1;
            instruction_clock_count = 0;
          end
          4'b0110: begin // ldr
            case(instruction_clock_count)  
              0: begin // read memory to data_bus
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                register_file_out_a_address = instruction_register[8:6];
                address_adder_mux_a_select = 1'b0; // use register
                address_adder_mux_b_select = 2'b00; // sext6
                memory_address_register_mux_select = 1'b1;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b1;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b1;
                memory_write_enable = 1'b0;

                instruction_clock_count = 1;
              end
              1: begin // store data_bus in register
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b1;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b1;

                memory_data_buffer_enable = 1'b1;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                register_file_in_address = instruction_register[11:9];

                memory_read_enable = 1'b0;
                memory_write_enable = 1'b0;

                state = 1;
                instruction_clock_count = 0;
              end
            endcase
          end
          4'b0111: begin // str
            case(instruction_clock_count)  
              0: begin // put register on to data_bus
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b1;
                load_flag_register = 1'b0;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b1;

                register_file_out_a_address = instruction_register[11:9];

                instruction_clock_count = 1;
              end
              1: begin // put address on bus and write data to memory
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                register_file_out_a_address = instruction_register[8:6];
                address_adder_mux_a_select = 1'b0; // use register
                address_adder_mux_b_select = 2'b00; // sext6
                memory_address_register_mux_select = 1'b1;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b1;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b0;
                memory_write_enable = 1'b1;

                state = 1;
                instruction_clock_count = 0;
              end
            endcase
          end
          4'b1000: begin // rti
            state = 1;
            instruction_clock_count = 0;
          end
          4'b1001: begin // not
            load_instruction_register = 1'b0;
            load_program_counter = 1'b0;
            load_register_file = 1'b1;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b1;

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b0;
            arithmetic_logic_unit_buffer_enable = 1'b1;
            program_counter_buffer_enable = 1'b0;
            register_file_out_a_buffer_enable = 1'b0;

            register_file_in_address = instruction_register[11:9];
            register_file_out_a_address = instruction_register[8:6];
            arithmetic_logic_unit_select = 2'b01;

            state = 1;
            instruction_clock_count = 0;

          end
          4'b1010: begin // ldi
            case(instruction_clock_count)  
              0: begin // read memory to data_bus
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                address_adder_mux_a_select = 1'b1; // use program counter
                address_adder_mux_b_select = 2'b01; // sext9
                memory_address_register_mux_select = 1'b1;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b1;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b1;
                memory_write_enable = 1'b0;

                instruction_clock_count = 1;
              end
              1: begin // get address at memory address
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                memory_data_buffer_enable = 1'b1;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b1;
                memory_write_enable = 1'b0;

                instruction_clock_count = 2;
              end 
              2: begin // store data_bus in register
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b1;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b1;

                memory_data_buffer_enable = 1'b1;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                register_file_in_address = instruction_register[11:9];

                memory_read_enable = 1'b0;
                memory_write_enable = 1'b0;

                state = 1;
                instruction_clock_count = 0;
              end
            endcase
          end
          4'b1011: begin // sti
            case(instruction_clock_count)  
              0: begin // put register on to data_bus
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b1;
                load_flag_register = 1'b0;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b1;

                register_file_out_a_address = instruction_register[11:9];

                instruction_clock_count = 1;
              end
              1: begin // put address on bus and write data to memory
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                address_adder_mux_a_select = 1'b1; // use program counter
                address_adder_mux_b_select = 2'b01; // sext9
                memory_address_register_mux_select = 1'b1;

                memory_data_buffer_enable = 1'b0;
                memory_address_buffer_enable = 1'b1;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b1;
                memory_write_enable = 1'b0;

                instruction_clock_count = 2;
              end
              2: begin // get address at memory address and write
                load_instruction_register = 1'b0;
                load_program_counter = 1'b0;
                load_register_file = 1'b0;
                load_memory_data_register = 1'b0;
                load_flag_register = 1'b0;

                memory_data_buffer_enable = 1'b1;
                memory_address_buffer_enable = 1'b0;
                arithmetic_logic_unit_buffer_enable = 1'b0;
                program_counter_buffer_enable = 1'b0;
                register_file_out_a_buffer_enable = 1'b0;

                memory_read_enable = 1'b0;
                memory_write_enable = 1'b1;
                
                state = 1;
                instruction_clock_count = 0;
              end
            endcase
          end
          4'b1100: begin // jmp
            load_instruction_register = 1'b0;
            load_program_counter = 1'b1;
            load_register_file = 1'b0;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b0;

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b0;
            arithmetic_logic_unit_buffer_enable = 1'b0;
            program_counter_buffer_enable = 1'b0;
            register_file_out_a_buffer_enable = 1'b1;

            register_file_out_a_address = instruction_register[8:6];
            program_counter_mux_select = 2'b00; // jump

            state = 1;
            instruction_clock_count = 0;
          end
          4'b1101: begin // reserved
            load_instruction_register = 1'b0;
            load_program_counter = 1'b0;
            load_register_file = 1'b0;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b0;

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b0;
            arithmetic_logic_unit_buffer_enable = 1'b0;
            program_counter_buffer_enable = 1'b0;
            register_file_out_a_buffer_enable = 1'b0;

            memory_read_enable = 1'b0;
            memory_write_enable = 1'b0;

            state = 1;
            instruction_clock_count = 0;
          end
          4'b1110: begin // lea
            load_instruction_register = 1'b0;
            load_program_counter = 1'b0;
            load_register_file = 1'b1;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b1;

            address_adder_mux_a_select = 1'b1; // use program counter
            address_adder_mux_b_select = 2'b01; // sext9
            memory_address_register_mux_select = 1'b1;
            register_file_in_address = instruction_register[11:9];

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b1;
            arithmetic_logic_unit_buffer_enable = 1'b0;
            program_counter_buffer_enable = 1'b0;
            register_file_out_a_buffer_enable = 1'b0;

            state = 1;
            instruction_clock_count = 0;
          end
          4'b1111: begin // trap
            load_instruction_register = 1'b0;
            load_program_counter = 1'b0;
            load_register_file = 1'b0;
            load_memory_data_register = 1'b0;
            load_flag_register = 1'b0;

            memory_data_buffer_enable = 1'b0;
            memory_address_buffer_enable = 1'b0;
            arithmetic_logic_unit_buffer_enable = 1'b0;
            program_counter_buffer_enable = 1'b0;
            register_file_out_a_buffer_enable = 1'b0;

            state = 4;
          end
        endcase
      end
      4: begin // halt
        load_instruction_register = 1'b0;
        load_program_counter = 1'b0;
        load_register_file = 1'b0;
        load_memory_data_register = 1'b0;
        load_flag_register = 1'b0;

        memory_data_buffer_enable = 1'b0;
        memory_address_buffer_enable = 1'b0;
        arithmetic_logic_unit_buffer_enable = 1'b0;
        program_counter_buffer_enable = 1'b0;
        register_file_out_a_buffer_enable = 1'b0;

        state = 4;
      end
    endcase
  end
endmodule