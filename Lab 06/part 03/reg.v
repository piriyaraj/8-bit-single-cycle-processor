//register file
`timescale  1ns/100ps
module reg_file(IN,OUT1ADDRESS,OUT2ADDRESS,INADDRESS,OUT1,OUT2, WRITE, CLK, RESET);
   input [7:0] IN;             // 8 bit input to register
   output [7:0] OUT1,OUT2;     // 8 bit output from register
   input [2:0] INADDRESS,OUT1ADDRESS,OUT2ADDRESS;  // 3 bit in and out INADDRESS
   input WRITE,CLK,RESET;      // 1 bit for clk,write and reset
   reg [7:0]regfile[7:0];      // 8 vector of 8 bit register
   integer i;                  // for loop

   always@ (posedge CLK) begin
	#0.1
		if(RESET) begin

			for(i=0; i<8; i++) begin
				regfile[i]<= #0.9 0;
			end
		end else if(WRITE) begin						//ALLOW TO WRITE INPUTS TO REGISTER
			 regfile[INADDRESS] <= #0.9 IN;
			end
	end
      assign #2 OUT1=regfile[OUT1ADDRESS];			//asyncrnously reading from output1
   	assign #2 OUT2= regfile[OUT2ADDRESS];        //asyncrnously reading from output2

   initial
   begin
      #5;
      $display("\n\t\t\t==================================================");
      $display("\t\t\t Change of Register Content Starting from Time #5");
      $display("\t\t\t==================================================\n");
      $display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
      $display("\t\t---------------------------------------------------------------------");
      $monitor($time,"\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",regfile[0],regfile[1],regfile[2],regfile[3],regfile[4],regfile[5],regfile[6],regfile[7]);
   end


endmodule
