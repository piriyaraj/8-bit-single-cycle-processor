module testbench;

    reg [7:0]a,b;  // data1 and data2
    reg [2:0]sel;  // selection
    wire [7:0]out; // output  of the operation

    alu alu1(a,b,out,sel);  // call alu

    initial
    begin
      $monitor($time," a: %b/(%d), b: %b/(%d), sel: %b/(%d), out: %b/(%d)",a,a,b,b,sel,sel,out,out);//moniter output
      $dumpfile("wavedata.vcd"); // create vcd file
      $dumpvars(0,alu1);
    end
    initial begin
      #5       // assingn value for a and b at 5 sec
         a=1;
         b=2;
       #20    //  assingn value for a and b at 25 sec
         a=4;
         b=7;
       #20     // assingn value for a and b at 45 sec
         a=8;
         b=2;
       #20     // assingn value for a and b at 65 sec
         a=20;
         b=15;
    end
    always
    begin                 // change section with 5 sec intervel
      #5 sel = 3'b000;
      #5 sel = 3'b001;
      #5 sel = 3'b010;
      #5 sel = 3'b011;
    end
    initial begin
       #80 $finish;       // finish at 80 sec
    end
endmodule
