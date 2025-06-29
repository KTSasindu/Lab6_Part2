module forward_(DATA1, DATA2, RESULT);     //module for forward function. just passes DATA2 to RESULT
    input [7:0]DATA1, DATA2;               //use 8-bit for input data2
    output reg[7:0]RESULT;          //use 8-bit for output result as register

    always @(DATA1, DATA2)                     //used always to executes whenever any input changes
    begin
        #1 RESULT = DATA2;          // Forwarding operation after waiting 1s 
    end
endmodule


module add_(DATA1, DATA2, RESULT);  //module for add function. just add DATA1 to DATA2 and store value into RESULT
    input [7:0]DATA1, DATA2;        //use 2 8-bits for input data1 and data2
    output reg[7:0]RESULT;

    always @(*)
    begin
        #2 RESULT = DATA1 + DATA2;  // Wait 2 time units, then perform add
    end
endmodule

module and_(DATA1, DATA2, RESULT);  //module for and function. just perform and operation to DATA1, DATA2 and store value into RESULT
    input [7:0]DATA1, DATA2;
    output reg[7:0]RESULT;

    always @ (*)
    begin
        #1 RESULT = DATA1 & DATA2;  //Wait 1 time unit, then perform AND operation
    end
endmodule

module or_(DATA1, DATA2, RESULT);   //module for or function. just perform or operation to DATA1, DATA2 and store value into RESULT
    input [7:0]DATA1, DATA2;
    output reg[7:0]RESULT;

    always@(*)
    begin
        #1 RESULT = DATA1 | DATA2;  //Wait 1 time unit, then perform OR operation
    end
endmodule


module alu(DATA1, DATA2, RESULT, SELECT, ZERO);   //The main ALU module that perform all operation modules according to SELECT 
    input [7:0]DATA1, DATA2;
    output reg [7:0]RESULT;                 //use 8-bit for output result as register
    input [2:0]SELECT;
    output ZERO;                      //use 3-bit for input SELECT

    wire [7:0]forward_output, add_output, and_output, or_output;    //wires to connect the immidiate outputs of each operation module

    forward_ forward_u(DATA1, DATA2, forward_output);      // Instantiate foraward operation module
    add_ add_u(DATA1, DATA2, add_output);           // Instantiate add operation module
    and_ and_u(DATA1, DATA2, and_output);           // Instantiate and operation module
    or_ or_u(DATA1, DATA2, or_output);              // Instantiate or operation module

    always @(*)                                     // logic to select which operation result to output according to the SELECT
    begin
        case (SELECT)
            3'b000: RESULT = forward_output;        //if SELECT = 0 Forward operation
            3'b001: RESULT = add_output;            //if SELECT = 1 add operation
            3'b010: RESULT = and_output;            //if SELECT = 2 and operation
            3'b011: RESULT = or_output;             //if SELECT = 3 or operation
            default: RESULT = 8'bxxxxxxxx;          //if SELECT = 4,5,6,7 null
        endcase
    end

    assign ZERO = (RESULT == 0);
endmodule

/*module test_bench;              // Test Bench Module for testing
    reg [7:0]DATA1, DATA2;      //8 bit registers for inputs
    reg [2:0]SELECT;            //3 bit register for SELECT
    wire [7:0]RESULT;           //8 bit register for result
    wire ZERO;

    alu alu_u(DATA1, DATA2, RESULT, SELECT, ZERO);    //instantiate the ALU

    initial 
    begin

        //to monitoring and to display changes in signals
        $monitor("time = %0d, data1 = %d, data2 = %d, select = %d, result = %d, ZERO = %b",$time, DATA1, DATA2, SELECT, RESULT, ZERO);
        $dumpfile("waveform.vcd");      //for waveform
        $dumpvars(0,test_bench);

        //data1 = 7 and data2 = 2
        DATA1 = 8'b00000111; DATA2 = 8'b00000010; SELECT = 3'b000; #5;  //select is 0, forward, delay 5 time units,Expected result: RESULT = DATA2 = 2
        DATA1 = 8'b00001111; DATA2 = 8'b00001010; SELECT = 3'b001; #5;  //select is 1, add, delay 5 time units,Expected result: RESULT = DATA1 + DATA2 = 9
        DATA1 = 8'b00000111; DATA2 = 8'b00000010; SELECT = 3'b010; #5;  //select is 2, and, delay 5 time units,Expected result: RESULT =DATA1 & DATA2 = 2
        DATA1 = 8'b00001111; DATA2 = 8'b00001010; SELECT = 3'b011; #5;  //select is 3, or, delay 5 time units,Expected result: RESULT = DATA1 | DATA2 = 7
        SELECT = 3'b100; #5;                                            //Test cases 5-8: Invalid SELECT values, DON'T CARE
        SELECT = 3'b101; #5;
        SELECT = 3'b110; #5;
        SELECT = 3'b111; #5;

        $finish;                    //end the simulation
    end
endmodule*/
