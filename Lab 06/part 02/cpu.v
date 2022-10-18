
// lab6 part1
// E17358
// E17256

`timescale  1ns/100ps

//=============================COMPLIMENT OF THE INPUT=================================================================//
module compliment(in,out);
	input [7:0] in;
	output reg [7:0] out;

	always@ (in)
		out= #1 (~in +1);

endmodule
//===========================8 BIT MUX SELECT ONE DATA WITHIN 2 DATA===================================================//

module mux8 (DATA1, DATA2 ,SEL, MUX_OUT);

	input [7:0] DATA1,DATA2;
	input SEL;
	output reg  [7:0] MUX_OUT;

	always@ (DATA1,DATA2,SEL)begin
		if(SEL) begin					//if SEL==1, then (OUT=DATA1)
			MUX_OUT=DATA1;
		end else begin							//otherwise
			MUX_OUT=DATA2;						//OUT=DATA2
		end
	end
endmodule

//===============================SINGNEL GENERATER=====================================================================//
module controlunit (CLK,op_data,op_code,SEL1, SEL2, SEL3, SEL4,write_enb, busywait,read,write,sel_r);

	input [31:0] op_data;
	input NXT_PC_ADD_1, busywait,CLK;
	output reg [2:0] op_code;
	output reg SEL1,SEL2,SEL3,SEL4,write_enb,read,write,sel_r;

	always@(posedge CLK)
		if(busywait==0) begin
			read  <= 0;
			write <= 0;
		end


	always@ (op_data) begin
		case(op_data[31:24])
						// SEL1 => MUX1-2S       SEL2 => MUX2-IMMIDIATE
						// SEL3 => J             SEL4 => BEQ
		8'b00000000: begin op_code<= #1 0; SEL1<= #1 0; SEL2 <= #1 1; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//0 - LOADI  SEL2=1 IMMIDIATE
		8'b00000001: begin op_code<= #1 0; SEL1<= #1 0; SEL2 <= #1 0; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//1 - MOV
		8'b00000010: begin op_code<= #1 1; SEL1<= #1 0; SEL2 <= #1 0; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//2 - ADD
		8'b00000011: begin op_code<= #1 1; SEL1<= #1 1; SEL2 <= #1 0; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//3 - SUB	SEL1=1  SUBTRACT 2S
		8'b00000100: begin op_code<= #1 2; SEL1<= #1 0; SEL2 <= #1 0; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//4 - AND
		8'b00000101: begin op_code<= #1 3; SEL1<= #1 0; SEL2 <= #0 0; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//5 - OR
		8'b00000110: begin op_code<= #1 1; SEL1<= #1 0; SEL2 <= #0 0; SEL3 <= #1 1; SEL4 <= #1 0; write_enb <= #1 0; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//6 - J 	SEL3=1  J
		8'b00000111: begin op_code<= #1 1; SEL1<= #1 1; SEL2 <= #0 0; SEL3 <= #1 0; SEL4 <= #1 1; write_enb <= #1 0; read <= #1 0; write<= #1 0; sel_r <= #1 0; end	//7 - BEQ 	SEL1=1  2_S , SEL4=1 BEQ

		8'd8 : begin op_code<= #1 0; SEL1<= #1 0; SEL2 <= #1 0; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1;  read <= #1 1;  write<= #1 0; sel_r <= #1 1; end  //lwd
		8'd9 : begin op_code<= #1 0; SEL1<= #1 0; SEL2 <= #1 1; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 1;  read <= #1 1;  write<= #1 0; sel_r <= #1 1; end  //lwi
		8'd10: begin op_code<= #1 0; SEL1<= #1 0; SEL2 <= #1 0; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 0;  read <= #1 0;  write<= #1 1; sel_r <= #1 1; end  //swd
		8'd11: begin op_code<= #1 0; SEL1<= #1 0; SEL2 <= #1 1; SEL3 <= #1 0; SEL4 <= #1 0; write_enb <= #1 0;  read <= #1 0;  write<= #1 1; sel_r <= #1 1; end  //swi

		endcase
	end
endmodule

////========================PC COUNT INCREASER ==========================================================================//
module counter (PC,PC_NEW,RESET);          //program counter unit
	input [31:0] PC;
	output reg [31:0] PC_NEW;
	input RESET;
	always @ ( RESET ) begin
		if (RESET) begin
			#1 PC_NEW <= 0;
		end
	end
	always@ (PC) begin
		#1 PC_NEW <= (PC+4);
	end
 endmodule

 //==============SELECT NEXT PC VALUE WRT BRANCH EQUAL =================================================================//

 module BEQ_SELECTOR (SEL3,SEL4,ZERO,BEQ_SEL_SIG);		//NEXT PC ADDRESS SELECT FOR J OR (BEQ & ZERO)

 	input ZERO,SEL3,SEL4;
 	output BEQ_SEL_SIG;

 	wire beq_0;

 	assign beq_0 = SEL4 & ZERO;				//BEQ_0=1 IF (ZERO & BEQ_OP)
 	assign BEQ_SEL_SIG = SEL3 | beq_0;			//NXT_SEL=1 IF (BEQ_0 | J)

 endmodule

 //==================== CHANGE 8 BIT INTO 32 BIT SINGNEL================================================================//
 module sing_extend_shift(IN,OUT);
     input [7:0] IN;           // 8 bit immediate value as input
     output  [31:0] OUT;     // 32 bit output value for pc
     reg [31:0] result;
     assign OUT= {{22{IN[7]}},IN,2'b00};
 endmodule

 //================== MODULE FOR PC VALUE INCREASE WITH FORWARD COMMENT=================================================//

 module add_forward (DATA1,DATA2,RESULT);		//A dedicated adder to add the PC

 	input [31:0] DATA1,DATA2;				// Next PC val and output from making_32bit
 	output reg [31:0] RESULT;

 	always@ (DATA1,DATA2)
 		#2 RESULT=DATA1+DATA2;				//adding with 2 unit delay

 endmodule


 //============= CHANGE PC VALUE WRT FORWARD AND BRANCH EQUAL ==========================================================//
 module NXT_PC_ADDRESS (PC_4, FORW_ADD, NXT_Add_SEL, NXT_PC_ADD);

 	input [31:0] PC_4,FORW_ADD;					//pc_4->pc+4 / FORW_ADD->pc+4+immidiate*4
 	input NXT_Add_SEL;							// is a selector -> j|(beq & zero)
 	output reg [31:0] NXT_PC_ADD;				//output depend on the selector

 	always@(PC_4, FORW_ADD, NXT_Add_SEL)
 		begin
 			if (NXT_Add_SEL) begin				// if selectoris 1 then jump
 				assign NXT_PC_ADD = FORW_ADD;
 			end else begin
 				assign NXT_PC_ADD = PC_4;
 			end
 		end

 endmodule


 //================= MUX FOR 32 BIT SINGNEL SELECTOR ===================================================================//
 module mux32 (DATA1, DATA2 ,SEL, MUX_OUT);

 	input [31:0] DATA1,DATA2;
 	input SEL;
 	output reg  [31:0] MUX_OUT;

 	always@ (DATA1,DATA2,SEL)begin
 		if(SEL) begin					//if SEL==1, then (OUT=DATA1)
 			MUX_OUT=DATA1;
 		end else begin							//otherwise
 			MUX_OUT=DATA2;						//OUT=DATA2
 		end
 	end

 endmodule

 //========================CHANGE MEMERY WRITE SINGNEL WRT BUSYWAIT SINGNEL=============================================//
 module busywait_write (WRITE_SIG_IN, busywait, WRITE_SIG_OUT);		//busywait , then write_enable of register, w_enable will go to register in

 	input WRITE_SIG_IN,busywait;
 	output reg WRITE_SIG_OUT;

 	always@ (WRITE_SIG_IN, busywait)begin
 		WRITE_SIG_OUT= WRITE_SIG_IN & ~busywait;
 	end

 endmodule


 //==========================================CPU =====================================================================================//

module cpu (PC, INSTRUCTION, CLK, RESET);		//main module

	input [31:0] INSTRUCTION;
	input CLK,RESET;
	wire [31:0] NXT_PC_ADD, NXT_PC_ADD_1;
	output reg [31:0] PC;

	wire [2:0] op_code;
	wire SEL1,SEL2,SEL3,SEL4,ZERO,NXT_SEL, write_enb,   busywait,read,write,w_enable,sel_r;
	wire [7:0] Complement_2s,out1,out2,mux1_out,mux2_out,Alu_out,  readdata,MUX3_OUT;
	wire [31:0] pc_4,out_32bit,nxt_pc_add, forw_32;

	wire m_busywait, mem_read, mem_write;
	wire [31:0] mem_writedata, mem_readdata;
	wire [5:0] mem_address;

	always@ (posedge CLK) begin
		#1	PC <=  NXT_PC_ADD_1;
	end

//========================================modules from outside files==================================================================//
	dcache cache (CLK,RESET, read, write, m_busywait, mem_readdata, Alu_out, out1, mem_address, busywait, readdata, mem_write, mem_read, mem_writedata);

	reg_file Reg1    (MUX3_OUT, INSTRUCTION[10:8], INSTRUCTION[2:0], INSTRUCTION[18:16], out1, out2, w_enable, CLK, RESET);

	alu ALU1(mux2_out, out1, Alu_out, op_code, ZERO);	//alu unit to do arithmatic operations

	data_memory data_mem(CLK, RESET, mem_read, mem_write, mem_address, mem_writedata, mem_readdata, m_busywait);
//===========================================modules from insdie======================================================================//

	compliment 	compliment1(out2, Complement_2s);// change to 2s complement

	controlunit controlunit1 (CLK,INSTRUCTION[31:0], op_code, SEL1, SEL2,SEL3,SEL4,write_enb, busywait,read,write,sel_r);

	mux8 IMM_0R_2S (Complement_2s, out2, SEL1, mux1_out);  // Mux to select 2s complement or original value

	mux8  IMM_OR_REG (INSTRUCTION[7:0], mux1_out, SEL2, mux2_out);  //Immidiate value or register val

	counter  counter1 (PC, pc_4,RESET);  //PC_counter increment pc by 4

	BEQ_SELECTOR  BEQ_SIGNEL(SEL3,SEL4,ZERO,NXT_SEL); //creating a selecor to select the next_pc

	sing_extend_shift  SIGN_EXT (INSTRUCTION[23:16], out_32bit);//extender 8 to 32 bit

	add_forward  FORW_ADD (out_32bit, pc_4, forw_32);	//adder  to add the pc+4 +immidiate*4

	NXT_PC_ADDRESS  NEXTPC (pc_4, forw_32, NXT_SEL, NXT_PC_ADD); //selecting the next pc usng the selector (NXT_SEL)

	mux32 PC_OR_NEXTPC (PC, NXT_PC_ADD ,busywait, NXT_PC_ADD_1);	//wait and take same pc or next_pc_value

	mux8 MEM_OR_ALU(readdata, Alu_out ,sel_r, MUX3_OUT);	//mux3_out will go to register in

	busywait_write  WRITECONT(write_enb,busywait,w_enable);  // wrrite singnel control

endmodule
