// group 16
module reg_file(
    // inputs & outputs
    input [7:0] WRITEDATA,
    output [7:0] REGOUT1, REGOUT2,
    // Address inputs
    input [2:0] WRITEREG,
    input [2:0] READREG1, READREG2,
    // Control signals
    input WRITEENABLE, CLK, RESET );

    // Memory array - 8 registers of 8 bits each
    reg [7:0] memory [7:0];
    
    // Loop variable
    integer index;
    
    // Read operations
    // Output values are updated when read addresses change
    assign #2 REGOUT1 = memory[READREG1];
    assign #2 REGOUT2 = memory[READREG2];
    
    // Write and reset operations
    always @(posedge CLK) begin
        if (RESET) begin
            // Reset all memory locations to zero
            #1;  // Artificial delay for reset
            for (index = 0; index < 8; index = index + 1) begin
                memory[index] <= 8'h00;
            end
        end 
        else if (WRITEENABLE) begin
            // Write data to specified address
            #1;  // Artificial delay for writeenable
            memory[WRITEREG] <= WRITEDATA;
        end
    end

initial begin
        //$dumpfile("cpu_wavedata.vcd");
        //$dumpvars(0,cpu_tb);
        /*$dumpvars(1,cpu_tb.mycpu.my_reg.memory[0]);
        $dumpvars(1,cpu_tb.mycpu.my_reg.memory[1]);
        $dumpvars(1,cpu_tb.mycpu.my_reg.memory[2]);
        $dumpvars(1,cpu_tb.mycpu.my_reg.memory[3]);
        $dumpvars(1,cpu_tb.mycpu.my_reg.memory[4]);
        $dumpvars(1,cpu_tb.mycpu.my_reg.memory[5]);
        $dumpvars(1,cpu_tb.mycpu.my_reg.memory[6]);
        $dumpvars(1,cpu_tb.mycpu.my_reg.memory[7]);*/
    end

endmodule
