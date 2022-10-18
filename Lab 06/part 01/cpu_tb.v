// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Kisaru Liyanage

module cpu_tb;

    reg CLK, RESET;
	reg [31:0] NXT_PC_ADD;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
	
    reg [7:0] instr_mem [1023:0];
	
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
	
	assign #2 INSTRUCTION={instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1],instr_mem[PC]};
	
    //       (make sure you include the delay for instruction fetching here)
    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} =     32'b00000000_00000100_00000000_00000101;//r4=5
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} =     32'b00000000_00000101_00000000_00000011;//r5=3
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} =   32'b00001011_00000000_00000100_00000000;//swi 4 0
		{instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} = 32'b00001011_00000000_00000101_00000001;//swi 5 1
	    {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]} = 32'b00000010_00000100_00000100_00000101;//add 4 4 5 r4=8
	    {instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]} = 32'b00000011_00000101_00000100_00000101;//sub 5 4 5 r5=5
        {instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]} = 32'b00001001_00000110_00000000_00000000;//lwi 6 0   r6=5
        {instr_mem[10'd31], instr_mem[10'd30], instr_mem[10'd29], instr_mem[10'd28]} = 32'b00001001_00000111_00000000_00000001;//lwi 7 1   r7=3
				
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("instr_mem.mem", instr_mem);
    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET);

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
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule