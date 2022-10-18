// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Kisaru Liyanage

`timescale  1ns/100ps

module cpu_tb;

    reg CLK, RESET;
	reg [31:0] NXT_PC_ADD;
    wire [31:0] PC;


    cpu mycpu(PC,CLK, RESET);

    initial
    begin

        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);

        CLK = 1'b0;
        RESET = 1'b1;

        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #5 RESET=1'b0;

        // finish simulation after some time
        #4000
        $finish;

    end

    // clock signal generation
    always
        #4 CLK = ~CLK;

endmodule
