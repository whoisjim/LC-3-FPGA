`timescale 1ns / 1ps

module ram_generic #(
    parameter WORD_SIZE = 16,
    parameter ADDRESS_SIZE = 16
    ) (
    input clock, read, write,
    input [ADDRESS_SIZE - 1:0] address,
    input [WORD_SIZE - 1:0] in_data,
    output reg [WORD_SIZE - 1:0] out_data
    );

    reg [WORD_SIZE - 1 : 0] memory [0 : (1 << ADDRESS_SIZE) - 1];
    
    // registers
    parameter R0 = 3'b000;
    parameter R1 = 3'b001;
    parameter R2 = 3'b010;
    parameter R3 = 3'b011;
    parameter R4 = 3'b100;
    parameter R5 = 3'b101;
    parameter R6 = 3'b110;
    parameter R7 = 3'b111;

    // keywords
    parameter IMM = 1'b1;
    parameter REG = 3'b000;
    parameter NEG = 3'b100;
    parameter ZER = 3'b010;
    parameter POS = 3'b001;

    // instructions
    parameter BR  =  4'b0000;             // 0
    parameter ADD =  4'b0001;             // 1
    parameter LD  =  4'b0010;             // 2
    parameter ST  =  4'b0011;             // 3
    parameter JSR =  4'b0100;             // 4
    parameter AND =  4'b0101;             // 5
    parameter LDR =  4'b0110;             // 6
    parameter STR =  4'b0111;             // 7
    parameter NOT =  4'b1001;             // 9
    parameter LDI =  4'b1010;             // a
    parameter STI =  4'b1011;             // b
    parameter JMP =  4'b1100;             // c
    parameter RET = 12'b1100000111000000; // c
                                          // d
    parameter LEA =  4'b1110;             // e
    parameter HLT = 16'b1111000000000000; // f
    parameter NOP = 16'b0000000000000000; // jump to curent location

    // setup initial memory configuration
    /*
    // test add, and, not
    initial memory[0] = {ADD, R0, R0, IMM, 5'b00101}; // 1 | r0 = r0 + 5 = 5
    initial memory[1] = {ADD, R1, R1, IMM, 5'b01001}; // 1 | r1 = r1 + 9 = 9
    initial memory[2] = {ADD, R2, R1, REG, R0};       // 1 | r2 = r1 + r0 = e
    initial memory[3] = {AND, R3, R2, REG, R1};       // 5 | r3 = r2 & r1 = 8
    initial memory[4] = {NOT, R4, R3, 6'b000000};     // 9 | r4 = ~ r3 = FFF7
    initial memory[5] = {HLT};                        // f | halt
    */

    /*
    // test reading and writing memory pc relative mode
    initial memory[0] = {NOP};                        //   | do nothing
    initial memory[1] = {LD, R0, 9'b111111110};       // 2 | load memory at pc - 2 into R0 // this is address 0
    initial memory[2] = {ST, R0, 9'b000000000};       // 3 | write data in R0 to memory at pc // this is address 3
    initial memory[3] = {HLT};                        // f | halt
    initial memory[4] = {HLT};                        // f | halt
    */

    /*
    // test reading and writing memory register relitive mode
    initial memory[0] = {NOP};                        //   | do nothing
    initial memory[1] = {ADD, R1, R1, IMM, 5'b00001}; // 1 | r1 = r1 + 1 = 1
    initial memory[2] = {LDR, R0, R1, 6'b111111};     // 6 | load memory at R1 + -1 into R0
    initial memory[3] = {STR, R0, R1, 6'b000011};     // 7 | write data in R0 to memory at R1 + 3
    initial memory[4] = {HLT};                        // f | halt
    initial memory[5] = {HLT};                        // f | halt
    */

    /*
    // test reading and writing memory register relitive mode
    initial memory[0] = {NOP};                        //   | do nothing
    initial memory[1] = {LDI, R0, 9'b000000011};      // a | load memory at memory pointed to by pc + 3 into R0 // this is address 5 then 0
    initial memory[2] = {STI, R0, 9'b000000011};      // b | write data in R0 to memory at memory pointed to by pc + 2 // this is address 6 then 3
    initial memory[3] = {HLT};                        // f | halt
    initial memory[4] = {HLT};                        // f | halt
    initial memory[5] = {16'b0};                      //   | zero in memory
    initial memory[6] = {16'b11};                     //   | three in memory
    */

    /*
    // test load effective address
    initial memory[0] = {LEA, R0, 9'b000000000};      // e | R0 = PC = 1
    initial memory[1] = {LEA, R1, 9'b111111111};      // e | R1 = PC - 1 = 1
    initial memory[2] = {LEA, R2, 9'b111111110};      // e | R2 = PC - 2 = 1
    initial memory[3] = {LEA, R3, 9'b111111101};      // e | R3 = PC - 3 = 1
    initial memory[4] = {LEA, R4, 9'b111111100};      // e | R4 = PC - 4 = 1
    initial memory[5] = {LEA, R5, 9'b111111011};      // e | R5 = PC - 5 = 1
    initial memory[6] = {LEA, R6, 9'b111111010};      // e | R6 = PC - 6 = 1
    initial memory[7] = {LEA, R7, 9'b111111001};      // e | R7 = PC - 7 = 1
    initial memory[8] = {HLT};                        // f | halt
    */

    /*
    // test br
    initial memory[0]  = {ADD, R0, R0, IMM, 5'b00001}; // 1 | r0 = r0 + 1 = 1
    initial memory[1]  = {BR, POS, 9'b000000001};      // 0 | jmp to pc + 1 if positive
    initial memory[2]  = {HLT};                        // f | halt
    initial memory[3]  = {NOT, R0, R0, 6'b000000};     // 9 | r0 = ~ r0 = FFFe
    initial memory[4]  = {BR, NEG, 9'b000000001};      // 0 | jmp to pc + 1 if negitive
    initial memory[5]  = {HLT};                        // f | halt
    initial memory[6]  = {ADD, R0, R0, IMM, 5'b00010}; // 1 | r0 = r0 + 2 = 0
    initial memory[7]  = {BR, ZER, 9'b000000001};      // 0 | jmp to pc + 1 if zero
    initial memory[8]  = {HLT};                        // f | halt
    initial memory[9]  = {ADD, R0, R0, IMM, 5'b00010}; // 1 | r0 = r0 + 2 = 0
    initial memory[10] = {BR, ZER, 9'b000000001};      // 0 | jmp to pc + 1 if zero
    initial memory[11] = {HLT};                        // f | halt
    initial memory[12] = {NOP};                        //   | do nothing
    initial memory[13] = {HLT};                        // f | halt
    */

    // fibinachi numbers program
    initial memory[0] = {ADD, R0, R0, IMM, 5'b00001}; // 1 | r0 = r0 + 1 = 1
    initial memory[1] = {ADD, R1, R1, IMM, 5'b00001}; // 1 | r1 = r1 + 1 = 1
    initial memory[2] = {ADD, R2, R2, IMM, 5'b00001}; // 1 | r2 = r2 + 1 = 1
    initial memory[3] = {ADD, R3, R3, IMM, 5'b00100}; // 1 | r3 = r3 + 4 = 4
    initial memory[4] = {ADD, R0, R1, REG, R2};       // 1 | r0 = r1 + R2
    initial memory[5] = {ADD, R1, R1, REG, R2};       // 1 | r1 = r1 + R2
    initial memory[6] = {NOP};                        //   | do nothing
    initial memory[7] = {ADD, R0, R1, REG, R2};       // 1 | r0 = r1 + R2
    initial memory[8] = {ADD, R2, R1, REG, R2};       // 1 | r2 = r1 + R2
    initial memory[9] = {JMP, 3'b000, R3, 6'b000000}; // c | jump to R3

    /*
    // test jmp jsr
    initial memory[0] = {ADD, R0, R0, IMM, 5'b00100}; // 1 | r0 = r0 + 4 = 4
    initial memory[1] = {JSR, REG, R0, 6'b000000};    // 4 | jump to R0 an store returna address in R7
    initial memory[2] = {JSR, IMM, 11'b0000000001};   // 4 | jump to pc + 1 an store return address in R7
    initial memory[3] = {HLT};                        // f | halt
    initial memory[4] = {JMP, 3'b000, R7, 6'b000000}; // c | jmp to R7
    initial memory[5] = {HLT};                        // f | halt
    */

    always @(posedge clock) begin
        if (read == 1'b1) begin 
            out_data = memory[address];
        end
        if (write == 1'b1) begin 
            memory[address] = in_data;
        end
    end
    
endmodule
