//register file
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET);
   input [7:0] IN;             // 8 bit input to register
   output [7:0] OUT1,OUT2;     // 8 bit output from register
   input [2:0] INADDRESS,OUT1ADDRESS,OUT2ADDRESS;  // 3 bit in and out INADDRESS
   input WRITE,CLK,RESET;      // 1 bit for clk,write and reset
   reg [7:0]regfile[7:0];      // 8 vector of 8 bit register
   integer i;                  // for loop

   always @ (posedge CLK) begin       // change when the clk is positive
      if (RESET)                      // check if rest is 1
         begin
            #1 for(i=0;i<8;i=i+1) begin  //loop  for change the register values as 0
               regfile[i]=0;             // change register values
            end
         end
      end

   always @ (posedge CLK) begin          // write to register syncrnously
         if (WRITE & ~RESET) begin                // when write is enable
            #1 regfile[INADDRESS]= IN;    // chance the ceratin value of the register
         end
      end


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

   assign #2 OUT1=regfile[OUT1ADDRESS];			//asyncrnously reading from output1
	assign #2 OUT2= regfile[OUT2ADDRESS];        //asyncrnously reading from output2
endmodule
