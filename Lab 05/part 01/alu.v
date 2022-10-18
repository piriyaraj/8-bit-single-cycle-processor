// alu operations
module alu(DATA1, DATA2, RESULT, SELECT);    // alu module
   input [7:0] DATA1,DATA2;                  // input datas
   output [7:0] RESULT;                      // output vaule
   input [2:0] SELECT;                       // operation
   wire [7:0]output_add,output_and,output_or,output_forward;  // save values from operations


   addope add1(DATA1,DATA2,output_add);    // call add function
   andope and1(DATA1,DATA2,output_and);    // call and fucntion
   orope or1(DATA1,DATA2,output_or);       // cal  or  fucntion
   forwardope forward1(DATA2,output_forward);  // call forward fucntion
   mux8_1 mux1(output_add,output_and,output_or,output_forward,SELECT,RESULT);  // call  mux functkon

endmodule //alu

//=========================================================mux
module mux8_1 (output_add,output_and,output_or,output_forward,SELECT,RESULT);
   input [7:0]output_add,output_and,output_or,output_forward;  // 4 operation output
   input [2:0]SELECT;                                          // seletion
   output reg [7:0]RESULT;                                     // output
   always @ ( output_add,output_and,output_or,output_forward,SELECT )
   begin
      case (SELECT)                                // assgin value to result wrt the select
         3'b000  : assign RESULT = output_forward; // forward operation
         3'b001  : assign RESULT = output_add;     // add opertion
         3'b010  : assign RESULT = output_and;     // and  operation
         3'b011  : assign RESULT = output_or;      // or  operation
         default : RESULT = 0;
      endcase
   end

endmodule // max8_1
//=========================================================add
module addope(DATA1,DATA2,RESULT);   // modules for add
   input [7:0]DATA1,DATA2;           // data for addition
   output reg [7:0] RESULT;          // result
   always @ ( DATA1,DATA2 )
   begin
      #2 RESULT= DATA1+DATA2;        // add two data and assingn to result
   end


endmodule // addoper
//=========================================================and
module andope(DATA1,DATA2,RESULT);    // modules for and
   input [7:0]DATA1,DATA2;            // data for and operation
   output reg [7:0]RESULT;            // add opertion result
   always @ ( DATA1,DATA2 )
   begin
      #1 RESULT= DATA1 & DATA2;       // and two data and assingn to result
   end

endmodule // andoper
//=========================================================or
module orope (DATA1,DATA2,RESULT);     // module for or operation
   input [7:0]DATA1,DATA2;             // data for or operation
   output reg [7:0]RESULT;             // or opertion result
   always @ ( DATA1,DATA2 )
   begin
      #1 RESULT= DATA1 | DATA2;       // or two data and assingn to result
   end
endmodule // oroper
//=========================================================forward
module forwardope (DATA2,RESULT);     // module for forward opertion
   input [7:0]DATA2;                  // data for forward opertion
   output reg [7:0]RESULT;            // result of forward operation
   always @ ( DATA2 )
   begin
      #1 RESULT= DATA2;               // change data2 to result
   end
endmodule // forwardoper
