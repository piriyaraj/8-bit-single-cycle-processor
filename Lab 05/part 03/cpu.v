
/* ALU Arithmetic and Logic Operations
----------------------------------------------------------------------*/

module alu(DATA1, DATA2, RESULT, SELECT);                    // module assign
input [7:0] DATA1,DATA2;           //ALU 8-bit Inputs
input [2:0] SELECT;                // ALU Selection
output reg [7:0] RESULT;           // ALU 8-bit Output
always @ (DATA1,DATA2,SELECT,RESULT) begin        // if data1,data2,select and result anything change this always block executed once
    case (SELECT)
        3'b000:   //forward
         #1   RESULT=DATA2;
        3'b001: // Addition
          #2  RESULT=DATA1 + DATA2;
        3'b010:  //  Logical and
         #1   RESULT=DATA1 & DATA2;
        3'b011:  //  Logical or
         #1   RESULT= DATA1 | DATA2;

    endcase
end
endmodule


/*                    REG FILE UNIT
/****************************************************************************************************************/
module reg_file (IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
  input CLK;
   input RESET;
   input WRITE;
   input [2:0] INADDRESS;
   input [7:0] IN;
   input [2:0] OUT1ADDRESS;
   output [7:0] OUT1;
   input [2:0] OUT2ADDRESS;
   output [7:0] OUT2;

   reg [7:0] 	 regfile [0:7];               //      defining 8 bit register as 8 element array

   assign #2  OUT1 = regfile[OUT1ADDRESS];          // here regfile always update when posedge clk or reset then
   assign #2  OUT2 = regfile[OUT2ADDRESS];

   always @(posedge CLK or RESET) begin          //  asynchronous reset condition defind here
    if (RESET == 1'b1) begin            // level triggered condition
      #2
	    regfile[0] <= 0;             // reset condition all regester geting zero value
	    regfile[1] <= 0;
	    regfile[2] <= 0;
	    regfile[3] <= 0;
	    regfile[4] <= 0;
	    regfile[5] <= 0;
	    regfile[6] <= 0;
	    regfile[7] <= 0;
      end
   end
   always @(posedge CLK) begin           // writing synchronously for this always block

	 if (WRITE) begin
      #2 regfile[INADDRESS] <= IN;
      end
   end
endmodule


/*          MUX UNIT
/*********************************************************************************************/




module MUX(out,a,b,control);      //two input mux
	input [7:0] a;
	input [7:0] b;
	output [7:0] out;
	input control;
	reg [7:0] out;

	always@(a,b,control)begin       //  if inputs change this block run
		case(control)
			1'b0 : out=a[7:0];
			1'b1 : out=b[7:0];
		endcase
	end

endmodule


/*            2'S COMPLIMENT UNIT
/*********************************************************************************************/

module compliment(out,in);          // 2's compliment converter
output [7:0] out;
input [7:0] in;
reg [7:0] comp=8'b11111111;
assign out=(comp-in)+8'b00000001; // math for converting
endmodule




/*                     PROGRAM COUNTER UNIT
/*********************************************************************************************/
module counter (INSTaddr,clk,reset);          //program counter unit
input clk;
input reset;
output reg [31:0] INSTaddr;
always @(posedge clk or posedge reset) begin           // this working as asynchronously
case(reset)
1: #1 INSTaddr=31'd0;
0: #1  INSTaddr= INSTaddr+31'd4;
endcase
end
endmodule



/*              CPU UNIT
/*********************************************************************************************/


module cpu(PC, INSTRUCTION, CLK, RESET);
output  [31:0]  PC;
input CLK,RESET;
input  [31:0] INSTRUCTION;

wire [2:0] READREG1,READREG2,WRITEREG,OP_CODE;          // instruction decoding data addreses for sub module so those are wires

reg WRITEENABLE,MUX1_SEL,MUX2_SEL;                // reg file write enable signal and two muxes control signals

reg [2:0] ALUOP,OP1,OP2,DESTINATION;         // instruction decoding data addreses for combinational logic  so those are reg

reg [7:0] IM_VAL;

assign  READREG2=INSTRUCTION[2:0];         // assing wire ports to  whenever change regaddres will get updates

assign  READREG1=INSTRUCTION[10:8];



assign  OP_CODE=INSTRUCTION[26:24];
assign WRITEREG=DESTINATION;

 always @(*)
    begin
        if (OP_CODE==4'b0000) begin                              // assing wire ports to  whenever change regaddres will get updates
            DESTINATION=INSTRUCTION[23:16];
        end else begin
            DESTINATION=INSTRUCTION[18:16];
        end
        #1                      // Instruction Decode delay is added here because while decodeing only op_code get updated
        case(OP_CODE)
        4'b0000:   begin    // loadi  function combinational logic
                    WRITEENABLE=1;
                    MUX2_SEL=1'b0;
                    ALUOP= 3'b000;
                    IM_VAL=INSTRUCTION[7:0];
                end
         4'b0001:  begin     // move function combinational logic
                    WRITEENABLE=1;
                    MUX1_SEL=1'b0;
                    MUX2_SEL=1'b1;
                    ALUOP= 3'b000;

                end
        4'b0010:  begin      //add function combinational logic
                    WRITEENABLE=1;
                    MUX1_SEL=1'b0;
                    MUX2_SEL=1'b1;
                    ALUOP= 3'b001;

                end
        4'b0011:   begin     // sub function combinational logic
                    WRITEENABLE=1;
                    MUX1_SEL=1'b1;
                    MUX2_SEL=1'b1;
                    ALUOP= 3'b001;

                end
        4'b0100:  begin       // And function combinational logic
                    WRITEENABLE=1;
                    MUX1_SEL=1'b0;
                    MUX2_SEL=1'b1;
                    ALUOP= 3'b010;

                end
         4'b0101:  begin       //OR function combinational logic
                    WRITEENABLE=1;
                    MUX1_SEL=1'b0;
                    MUX2_SEL=1'b1;
                    ALUOP= 3'b011;

                end
        endcase
    end


     //...........submodule connections  ............///


 //reg_file (IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
  wire [7:0] IN;
  wire [7:0] OUT1;
  wire [7:0] OUT2;
  reg_file cpu_reg_file(IN,OUT1,OUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET);

 //module compliment(out,in);
 wire [7:0] OUT3;
 compliment cpu_compliment(OUT3,OUT2);

 //module MUX(out,a,b,control);
 wire [7:0] OUT4;
 MUX cpu_MUX1(OUT4,OUT2,OUT3,MUX1_SEL);

 //module MUX(out,a,b,control);
 wire [7:0] OUT5;
 MUX cpu_MUX2(OUT5,IM_VAL,OUT4,MUX2_SEL);

 //module alu(DATA1, DATA2, RESULT, SELECT);
 alu cpu_alu(OUT1,OUT5,IN,ALUOP);

 //module counter (INSTaddr,clk,reset);
  counter cpu_counter(PC,CLK,RESET);

endmodule



/*********************************************************************************************/
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;

    /*
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */

    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
      reg [7:0] instr_mem [1023:0];//1024 ,8 bit registers

    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value
    //       (make sure you include the delay for instruction fetching here)
               assign #2 INSTRUCTION={instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1],instr_mem[PC]};

    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
         // loadi 4 0x05
         // loadi 2 0x09
         // add 6 4 2
         // mov 0 6
         // loadi 5 0x01
         // sub 3 2 5

        // METHOD 1: manually loading instructions to instr_mem
        {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00001000000001000000000000000101;//r4=5
        {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00001000000000100000000000001001;//r2=9
        {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000001000001100000010000000010;//r6=r4+r2,r6=14
	     {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} =        32'b00000000000000010000000000000110;//r0=r6
	     {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]} = 32'b00001000000010100000000000000101;//r5=5
	     {instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]} = 32'b00001001000000110000010100000010;//r3=r5-r2,r3=6
        // {instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]} = 32'b00000000000000000000000000000110;//r0=r6
        // {instr_mem[10'd31], instr_mem[10'd30], instr_mem[10'd29], instr_mem[10'd28]} = 32'b00000010000001110000000100000010;//r7=r1 & r2,
        // {instr_mem[10'd35], instr_mem[10'd34], instr_mem[10'd33], instr_mem[10'd32]} = 32'b00000011000001010000010000000110;//r5=r4|r6
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
         RESET=1'b1;
        #5 RESET=1'b0;
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution


        // finish simulation after some time
        #200
        $finish;

    end

    // clock signal generation
    always
        #4 CLK = ~CLK;


endmodule



//  add 4 1 2

// load 1 0x02
// mov 0 1
// loadi 1 0x02
// mov 2 1

// loadi 1 0x03
// mov 3 1
// loadi 1 0x04
// mov 4 1
// loadi 1 0x05
// mov 5 1
// loadi 1 0x06
// mov 6 1
// loadi 1 0x07
// mov 7 1
// loadi 1 0x08

// load 1 0x01
