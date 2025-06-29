`include "alu.v"
`include "reg_file.v"

module ProgramCounter(CLK, RESET, PC, IMMEDIATE_OFFSET, jump, branch, ZERO,STALL);
    input CLK, RESET;
    output reg [31:0] PC;
    wire [31:0] pcNext, pcPlus4, pcTarget;

    input signed [7:0] IMMEDIATE_OFFSET;
    input jump, branch, ZERO, STALL;

    wire isBranching, pcMuxSelector;

    and(isBranching, branch, ZERO);
    or(pcMuxSelector, isBranching, jump);

    Mux_2x1_new pcMux (pcPlus4, pcTarget, pcMuxSelector, pcNext);
    
    always @(posedge CLK) begin
        if (RESET == 1'b1) begin
            #1 PC <= 0;
        end
        else begin
            if (STALL == 1'b0) begin        // Only update PC if not stalled
                #1 PC = pcNext;
            end
        end
    end

    assign #1 pcPlus4 = PC + 4;
    assign #2 pcTarget = (PC +4) + IMMEDIATE_OFFSET * 4;
endmodule

module Mux_2x1_new(IN1, IN2, SELECT, OUT);
    input [31:0] IN1, IN2;
    input SELECT;
    output reg [31:0] OUT;

    // MUX should update output value upon change of any of the inputs
    always @(IN1, IN2, SELECT) begin
        case(SELECT)
        1'b0: OUT = IN1;
        1'b1: OUT = IN2;
        endcase
    end
endmodule

module InstructionDecoder (INSTRUCTION, OPCODE, IMMEDIATE, READREG2, READREG1, WRITEREG, IMMEDIATE_OFFSET);
    input [31:0] INSTRUCTION;
    output [7:0] OPCODE, IMMEDIATE;
    output signed [7:0] IMMEDIATE_OFFSET;  // Signed for branch offset
    output [2:0] READREG2, READREG1, WRITEREG;

    assign OPCODE = INSTRUCTION[31:24];
    assign READREG1 = INSTRUCTION[15:8];
    assign IMMEDIATE = INSTRUCTION[7:0];
    assign READREG2 = INSTRUCTION[7:0];
    assign WRITEREG = INSTRUCTION[23:16];
    assign IMMEDIATE_OFFSET = INSTRUCTION[23:16];
endmodule


module ControlUnit (OPCODE, ALUOP, immSelect, signSelect, WRITEENABLE, movSelect, branch, jump, BUSYWAIT, READ, WRITE, WRITESRC, STALL);

    input [7:0] OPCODE;
    output reg [2:0] ALUOP;
    output reg immSelect, signSelect, WRITEENABLE;
    output reg movSelect, branch, jump;

    input BUSYWAIT;
    output reg READ, WRITE, WRITESRC, STALL;

    always @(BUSYWAIT) begin
        STALL = BUSYWAIT;       // If BUSYWAIT is high, set STALL to high to prevent further operations

        if(BUSYWAIT == 0)       // If BUSYWAIT is low, reset READ & WRITE control signals to prevent any memory access
        begin
            READ = 0;
            WRITE = 0;
        end
    end


    always @(OPCODE) begin
        #1
        movSelect = (OPCODE == 8'b00000001) ? 1'b1 : 1'b0;

        case (OPCODE)
            8'b00000000: begin // loadi
                ALUOP = 3'b000;
                immSelect = 1'b1;
                signSelect = 1'b0;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00000001: begin // mov
                ALUOP = 3'b000;
                immSelect = 1'b0;
                signSelect = 1'b0;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00000010: begin // add
                ALUOP = 3'b001;
                immSelect = 1'b0;
                signSelect = 1'b0;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00000011: begin // sub
                ALUOP = 3'b001;
                immSelect = 1'b0;
                signSelect = 1'b1;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00000100: begin // and
                ALUOP = 3'b010;
                immSelect = 1'b0;
                signSelect = 1'b0;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00000101: begin // or
                ALUOP = 3'b011;
                immSelect = 1'b0;
                signSelect = 1'b0;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00000110: begin // jump
                ALUOP = 3'b000;
                immSelect = 1'b1;
                signSelect = 1'b0;
                WRITEENABLE = 1'b0;
                branch = 1'b0;
                jump = 1'b1;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00000111: begin // beq
                ALUOP = 3'b001;    // ADD for subtraction
                immSelect = 1'b0;
                signSelect = 1'b1;
                WRITEENABLE = 1'b0;
                branch = 1'b1;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b0;
                WRITESRC = 1'b1;
            end

            8'b00001000: begin // lwd
                ALUOP = 3'b000;
                immSelect = 1'b0;
                signSelect = 1'b0;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b1;        // Read value from memory
                WRITE = 1'b0;
                WRITESRC = 1'b0;   // select READDATA (When Input 0) as write-back to register source
            end

            8'b00001001: begin // lwi
                ALUOP = 3'b000;
                immSelect = 1'b1;   // Use immediate value as address offset
                signSelect = 1'b0;
                WRITEENABLE = 1'b1;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b1;        // Read value from memory
                WRITE = 1'b0;       
                WRITESRC = 1'b0;   // select READDATA (When Input 0) as write-back to register source
            end

            8'b00001010: begin // swd
                ALUOP = 3'b000;
                immSelect = 1'b0;
                signSelect = 1'b0;
                WRITEENABLE = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b1;       // Write value to memory
                WRITESRC = 1'b0;
            end

            8'b00001011: begin // swi
                ALUOP = 3'b000;
                immSelect = 1'b1;   // Use immediate value as address offset
                signSelect = 1'b0;
                WRITEENABLE = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
                READ = 1'b0;
                WRITE = 1'b1;       // Write value to memory
                WRITESRC = 1'b0;
            end

            default: begin
                ALUOP = 3'b000;
                immSelect = 1'b0;
                signSelect = 1'b0;
                WRITEENABLE = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
            end
        endcase
    end
endmodule

module TwosCompliment(IN, OUT);
    input [7:0] IN;
    output reg signed [7:0] OUT;

    // Combinational logic to assign two's complement value of input to output
    always @(IN) begin 
        #1 OUT = ~IN + 1;
    end
endmodule

module Mux_2x1(IN1, IN2, SELECT, OUT);
    input [7:0] IN1, IN2;
    input SELECT;
    output reg [7:0] OUT;

    // MUX should update output value upon change of any of the inputs
    always @(IN1, IN2, SELECT) begin
        if (SELECT == 1'b1) begin  // If SELECT is HIGH, switch to 2nd input
            OUT = IN2;
        end else begin              // If SELECT is LOW, switch to 1st input
            OUT = IN1;
        end
    end
endmodule

module main_cpu(PC, INSTRUCTION, CLK, RESET, ADDRESS, WRITE, READ, BUSYWAIT,WRITEDATA, READDATA);
    output [31:0] PC;
    input [31:0] INSTRUCTION;
    input CLK;
    input RESET;

    input BUSYWAIT;     // Control signal indicating if the data memory is busy (e.g., waiting for memory access)
    input [7:0] READDATA;
    output READ,WRITE;      // Control signals for data memory (READ for load, WRITE for store)
    output [7:0] ADDRESS, WRITEDATA;

    wire [7:0] OPCODE;
    wire [2:0] READREG1, READREG2, WRITEREG;
    wire [7:0] IMMEDIATE;
    wire signed [7:0] IMMEDIATE_OFFSET;

    wire immSelect;
    wire [7:0] REGOUT1, REGOUT2;
    wire WRITEENABLE;
    wire movSelect;
    wire branch, jump;

    wire [7:0] OPERAND1, OPERAND2, ALURESULT;
    wire [2:0] ALUOP;
    wire ZERO;

    wire [7:0] negatedOp;
    wire [7:0] signedREGOUT2;
    wire signSelect;

    // Remove redundant wire and output declarations for BUSYWAIT, READ, WRITE, WRITESRC, STALL
    // Only READ and WRITE are module outputs (already declared above)
    wire WRITESRC, STALL;       // Control signals for data memory (WRITESRC is used to select the source for write-back to register file & STALL is used to control the program counter)
    wire [7:0] regwrite;        

    Mux_2x1 movMux(READDATA, ALURESULT, WRITESRC, regwrite);
    ProgramCounter pc(CLK, RESET, PC, IMMEDIATE_OFFSET, jump, branch, ZERO,STALL);
    InstructionDecoder decoder(INSTRUCTION, OPCODE, IMMEDIATE, READREG2, READREG1, WRITEREG, IMMEDIATE_OFFSET);
    ControlUnit controlUnit(OPCODE, ALUOP, immSelect, signSelect, WRITEENABLE, movSelect, branch, jump, BUSYWAIT, READ, WRITE, WRITESRC, STALL);
    reg_file my_reg(regwrite, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    TwosCompliment my_twosComp(REGOUT2, negatedOp);
    Mux_2x1 signSwitcher(REGOUT2, negatedOp, signSelect, signedREGOUT2);
    Mux_2x1 ALUOperand2Selector(signedREGOUT2, IMMEDIATE, immSelect, OPERAND2);
    assign OPERAND1 = REGOUT1;
    alu my_alu(OPERAND1, OPERAND2, ALURESULT, ALUOP, ZERO);

    assign ADDRESS = ALURESULT;
    // For store instructions (swd/swi) the data to write is in RT (REGOUT1)
    assign WRITEDATA = REGOUT1;

    initial begin
        $monitor("Time %0t | PC=%d | INSTR=%b | MEM_WR=%b | MEM_RD=%b | MEM_ADDR=%d | MEM_WDATA=%d | MEM_RDATA=%d | BUSYWAIT=%b | R2=%d | R3=%d | R4=%d | R5=%d | R6=%d",
                 $time, PC, INSTRUCTION,
                 WRITE, READ, ADDRESS, WRITEDATA, READDATA, BUSYWAIT, my_reg.memory[2], my_reg.memory[3], my_reg.memory[4], my_reg.memory[5], my_reg.memory[6]);
    end
endmodule