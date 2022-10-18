module test;

   //inputs
    reg clk,reset;
    wire [31:0] inst;
    reg [7:0] memory[1023:0];

    //outputs
    wire [31:0] PC;

  cpu mycpu(PC,inst,clk,reset);
  assign #2 inst={ memory[PC],memory[PC+1],memory[PC+2],memory[PC+3]};   // counter assing




      initial
    begin
//load:000,add:010,sub:011,mov:001,BEQ:111,j:110,  opcode  distina data1   data2
                                                 //11111111222222223333333344444444
{ memory[0],memory[1],memory[2],memory[3]}    =32'b00000000000001000000000000001010;//loadi 4 0x0A
{ memory[4],memory[5],memory[6],memory[7]}    =32'b00000000000001010000000000000001;//loadi 5 0x01
{ memory[8],memory[9],memory[10],memory[11]}  =32'b00000000000001100000000000000001;//loadi 6 0x01
{ memory[12],memory[13],memory[14],memory[15]}=32'b00000000000001110000000000001001;//loadi 7 0x09
{ memory[16],memory[17],memory[18],memory[19]}=32'b00000011000001000000010000000101;//sub 4 4 5
{ memory[20],memory[21],memory[22],memory[23]}=32'b00000111000000010000010000000110;//beq 0x01 4 6
{ memory[24],memory[25],memory[26],memory[27]}=32'b00000110111111010000000000000000;//j 0xFD
{ memory[28],memory[29],memory[30],memory[31]}=32'b00000010000000010000010000000111;//add 1 4 7



        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, test);

        clk  = 1'b0;
        reset = 1'b0;

        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
         #1
         reset=1'b1;
         #5
        reset = 1'b0;
        // finish simulation after some time
        #400
        $finish;

    end

    // clock signal generation
    always
        #4 clk = ~clk;
    endmodule
