// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne
`include "cpu.v"
`include "DataMemory.v"

module cpu_tb;

    reg CLK, RESET, RESET_MEMORY;
    wire [31:0] PC;
    reg [31:0] INSTRUCTION;  

    // Initialize instruction memory
    reg [7:0] instr_mem [1023:0];

    // Instruction fetch logic
    always @(PC) 
    begin
        #2 INSTRUCTION = {instr_mem[PC+3], instr_mem[PC+2], instr_mem[PC+1], instr_mem[PC]};
    end

    initial
    begin

    // loadi r4, 0x05
        {instr_mem[3], instr_mem[2], instr_mem[1], instr_mem[0]} = 32'b00000000_00000100_00000000_00000101;
        
        // loadi r2, 0x05
        {instr_mem[7], instr_mem[6], instr_mem[5], instr_mem[4]} = 32'b00000000_00000010_00000000_00000101;
        
        // beq 0x01 r4 r2
        {instr_mem[11], instr_mem[10], instr_mem[9], instr_mem[8]} = 32'b00000111_00000001_00000100_00000010;
        
        // add r6, r4, r2
        {instr_mem[15], instr_mem[14], instr_mem[13], instr_mem[12]} = 32'b00000010_00000110_00000100_00000010;
        
        // loadi r6, 0x03
        {instr_mem[19], instr_mem[18], instr_mem[17], instr_mem[16]} = 32'b00000000_00000110_00000000_00000011;
        
        // mov r0, r6
        {instr_mem[23], instr_mem[22], instr_mem[21], instr_mem[20]} = 32'b00000001_00000000_00000000_00000110;
        
        // jump 0x01 (PC += 4 + 4)
        {instr_mem[27], instr_mem[26], instr_mem[25], instr_mem[24]} = 32'b00000110_00000001_00000000_00000000;
        
        // loadi r1, 0x01 (should be skipped if jump works)
        {instr_mem[31], instr_mem[30], instr_mem[29], instr_mem[28]} = 32'b00000000_00000001_00000000_00000001;
        
        // add r2, r2, r0
        {instr_mem[35], instr_mem[34], instr_mem[33], instr_mem[32]} = 32'b00000010_00000010_00000010_00000000;

        //New comments for memory operations

        // swi r2, 0x10 ; store r2 to memory[0x10] 
        {instr_mem[39], instr_mem[38], instr_mem[37], instr_mem[36]} = 32'b00001011_00000000_00000010_00010000;

        // lwi r5, 0x10 ; load memory[0x10] to r5 
        {instr_mem[43], instr_mem[42], instr_mem[41], instr_mem[40]} = 32'b00001001_00000101_00000000_00010000;

        // loadi r3, 0x0A
        {instr_mem[47], instr_mem[46], instr_mem[45], instr_mem[44]} = 32'b00000000_00000011_00000000_00001010;

        // swd r3, r4 ; store r3 to memory[reg[r4]] 
        {instr_mem[51], instr_mem[50], instr_mem[49], instr_mem[48]} = 32'b00001010_00000000_00000011_00000100;

        // lwd r6, r4 ; load memory[reg[r4]] to r6 
        {instr_mem[55], instr_mem[54], instr_mem[53], instr_mem[52]} = 32'b00001000_00000110_00000000_00000100;
    end
    
    wire [7:0] ADDRESS, WRITEDATA, READDATA;    // Address and data for data memory
    wire WRITE, READ, BUSYWAIT;     // Control signals for data memory

    main_cpu mycpu(PC, INSTRUCTION, CLK, RESET, ADDRESS, WRITE, READ, BUSYWAIT, WRITEDATA, READDATA);   // Main CPU instantiation

    data_memory DataMemory(CLK,RESET_MEMORY,READ,WRITE,ADDRESS,WRITEDATA,READDATA,BUSYWAIT);        // Data memory instantiation

    initial
    begin
        $dumpfile("cpu_wavedata.vcd");
        $dumpvars(0, cpu_tb);


        // add specific registers
        $dumpvars(1, cpu_tb.mycpu.my_reg.memory[2]); // R2
        $dumpvars(1, cpu_tb.mycpu.my_reg.memory[3]); // R3
        $dumpvars(1, cpu_tb.mycpu.my_reg.memory[4]); // R4
        $dumpvars(1, cpu_tb.mycpu.my_reg.memory[5]); // R5
        $dumpvars(1, cpu_tb.mycpu.my_reg.memory[6]); // R6

        
        CLK = 0;
        RESET = 0;
        RESET_MEMORY = 0;

        #2
        RESET = 1;
        RESET_MEMORY = 1;

        #4 
        RESET = 0;
        RESET_MEMORY = 0;
        
        #500 $finish;
    end

    
    always #4 CLK = ~CLK;

endmodule