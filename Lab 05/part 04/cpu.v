/*          MUX UNIT
/*********************************************************************************************/

module MUX8(out,a,b,control);      //two input mux
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

/*        32 BIT  MUX UNIT  working with timing
/*********************************************************************************************/

module MUX32(out,a,b,control,reset,clk);      //two input mux
	input [31:0] a;
    input reset,clk;
	input [31:0] b;
	output  [31:0] out;
	input control;
	reg [31:0] out;

	always@(a or posedge clk or posedge reset)begin       //  Here if input1 ,fall of clk,rice of reset should be out update

        if(reset==1)begin
            out=32'd0;
        end else if (control==1'b0) begin
            out=a[31:0];
        end else if(control==1'b1) begin
            out=b[31:0];
        end
	end

endmodule

/*         PC and 32 bit  MUX UNIT working with timing
/*********************************************************************************************/

module PC_MUX32(out,input1,input2,control,reset,clk);      //
	input [31:0] input1;
    input reset,clk;
	input [31:0] input2;
	output  [31:0] out;
	input control;
	reg [31:0] out;

	always@(input1  or posedge clk or posedge reset)begin       //  Here if input1 ,fall of clk,rice of reset should be out update

        #1                         // this delay for PC updateing
        if(reset==1)begin        // this start the program or giving the value for pc
            out=32'd0;
        end else if (control==1'b0) begin     // here to end mux function
            out=input1[31:0];
        end else if(control==1'b1) begin
            out=input2[31:0];            // if it is jump
        end
	end

endmodule



/*            2'S COMPLIMENT UNIT
/*********************************************************************************************/

module compliment(out,in);          // 2's compliment converter
    output [7:0] out;
    input [7:0] in;
    reg [7:0] comp=8'b11111111;
    assign #1 out=(comp-in)+8'b00000001; // math for converting
endmodule

// /*                    DEFAULT PROGRAM COUNTER UNIT
// /*********************************************************************************************/
 module counter (in_pc,out_pc,clk,reset);          //program counter unit

    input [31:0] in_pc;
    input clk,reset;
    output reg [31:0] out_pc;
    always @(posedge clk) begin   // this block always adding +4 with current pc value  in fall clk time
           out_pc=in_pc+32'd4;
    end

 endmodule

//                         Sing Extend and Shift unit
/*********************************************************************************************/

module sing_extend_shift(IN,OUT);
    input [7:0] IN;           // 8 bit immediate value as input
    output  [31:0] OUT;     // 32 bit output value for pc
    reg [31:0] result;
    assign OUT=result;
   always @(IN) begin // If IN change this will run
       #2 case(IN[7])   // most signifigent bit of input diside whether is this positive or negative
        1'b1:result<={22'b1111111111111111111111,IN,2'b00};   // if it is a negative value then sing extention
        1'b0:result<={22'b0000000000000000000000,IN,2'b00};    // if it is a positive value then sing extention
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

    reg WRITEENABLE,MUX1_SEL,MUX2_SEL,MUX4_SEL,JUMP,BEQ;                // reg file write enable signal and two muxes control signals

    reg [2:0] ALUOP,OP1,OP2,DESTINATION;         // instruction decoding data addreses for combinational logic  so those are reg

    reg [7:0] IM_VAL;    // this wire for geting immdeate

    wire MUX3_SEL;       // this for beq and defulte pc selection wire
    wire [31:0] Branch;    // this wire holding value of jump or value of beq  for pc updating
    assign Branch=NEXT+SinEx;        // this the adder operation so that for 2 time unit delay
    assign MUX3_SEL=BEQ & zero;          // selecting signal genetion for beq
    assign  PC=J_out;            // here assinnig output of jump mux value as pc

    assign  READREG2=INSTRUCTION[2:0];         // assing wire ports to  whenever change regaddres will get updates

    assign  READREG1=INSTRUCTION[10:8];


    assign  OP_CODE=INSTRUCTION[26:24];
    assign WRITEREG=DESTINATION;

    always @(*)
        begin
            if (OP_CODE==4'b0000) begin                              // assing wire ports to  whenever change regaddres will get updates
                DESTINATION=INSTRUCTION[18:16];
            end else begin
                DESTINATION=INSTRUCTION[18:16];
            end
                                 // Instruction Decode delay is added here because while decodeing only op_code get updated
            case(OP_CODE)
            4'b0000:   begin    // loadi  function combinational logic
                        WRITEENABLE=#1 1;
                        MUX2_SEL=1'b0;
                        ALUOP= 3'b000;
                        IM_VAL=INSTRUCTION[7:0];
                        BEQ=1'd0;
                        JUMP=1'd0;
                    end
            4'b0001:  begin     // move function combinational logic
                        WRITEENABLE=#1 1;
                        MUX1_SEL=1'b0;
                        MUX2_SEL=1'b1;
                        ALUOP= 3'b000;
                        BEQ=1'd0;
                        JUMP=1'd0;
                        IM_VAL=8'd0;

                    end
            4'b0010:  begin      //add function combinational logic
                        WRITEENABLE=#1 1;
                        MUX1_SEL=1'b0;
                        MUX2_SEL=1'b1;
                        ALUOP= 3'b001;
                        IM_VAL=8'd0;
                        BEQ=1'd0;
                        JUMP=1'd0;

                    end
            4'b0011:   begin     // sub function combinational logic
                        WRITEENABLE=#1 1;
                        MUX1_SEL=1'b1;
                        MUX2_SEL=1'b1;
                        ALUOP= 3'b001;
                        BEQ=1'd0;
                        JUMP=1'd0;
                        IM_VAL=8'd0;

                    end
            4'b0100:  begin       // And function combinational logic
                        WRITEENABLE=#1 1;
                        MUX1_SEL=1'b0;
                        MUX2_SEL=1'b1;
                        ALUOP= 3'b010;
                        BEQ=1'd0;
                        JUMP=1'd0;
                        IM_VAL=8'd0;

                    end
            4'b0101:  begin       //OR function combinational logic
                        WRITEENABLE=#1 1;
                        MUX1_SEL=1'b0;
                        MUX2_SEL=1'b1;
                        ALUOP= 3'b011;
                        BEQ=1'd0;
                        JUMP=1'd0;
                        IM_VAL=8'd0;

                    end
            4'b0110:  begin       //J function combinational logic
                        WRITEENABLE=#2 0;
                        BEQ=1'd0;
                        JUMP=1'd1;
                        IM_VAL=INSTRUCTION[23:16];

                    end
            4'b0111:  begin       //beq function combinational logic
                        WRITEENABLE=#2 0;
                        MUX1_SEL=1'b1;
                        MUX2_SEL=1'b1;
                        ALUOP= 3'b001;
                        BEQ=1'd1;
                        JUMP=1'd0;
                        IM_VAL=INSTRUCTION[23:16];

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
    compliment cpu_compliment(OUT3,OUT2);       // get compliment value of out2

    //module MUX8(out,a,b,control);
    wire [7:0] OUT4;
    MUX8 cpu_MUX1(OUT4,OUT2,OUT3,MUX1_SEL);     // select compliment or normal value to out4

    //module MUX8(out,a,b,control);
    wire [7:0] OUT5;
    MUX8 cpu_MUX2(OUT5,IM_VAL,OUT4,MUX2_SEL);   // take immediate or reg value to out5

    //module alu(DATA1, DATA2, RESULT, SELECT);
    wire zero;
    alu cpu_alu(OUT1,OUT5,IN,ALUOP,zero);       // get alu output

    // module counter (in_pc,out_pc,clk,reset);
    wire [31:0]NEXT;
    wire [31:0] J_out;
    counter cpu_counter(J_out,NEXT,CLK,RESET);   // increase pc value

    //module sing_extend_shift(IN,OUT);
    wire [31:0]SinEx;
    sing_extend_shift cpu_sing_extend_shift(IM_VAL,SinEx); // change immdeate value for j and beq fucntion as 32 bit

    //module MUX32(out,a,b,control,reset,clk);
    wire [31:0] B_out;
    MUX32 cpu_MUX32_1(B_out,NEXT,Branch,MUX3_SEL,RESET,CLK);// Branch=NEXT+SinEx; MUX3_SEL=BEQ & ZERO
    // select Branch pc value or next pc value for beq

    //module PC_MUX32(out,a,b,control,reset,clk);

    PC_MUX32  cpu_PC_MUX32 (J_out,B_out,Branch,JUMP,RESET,CLK);// Branch=NEXT+SinEx; MUX3_SEL=BEQ & ZERO
    // select Branch pc value or next pc value for jump
endmodule
