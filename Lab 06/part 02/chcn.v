/*
Module  : Data Cache
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale  1ns/100ps


module dcache (CLK,RESET, READ, WRITE,MBUSYWAIT,MREADDATA, ADDRESS , WRITEDATA, MADDRESS,BUSYWAIT , READDATA, MWRITE,MREAD,MWRITEDATA  );

input MBUSYWAIT,CLK,READ,WRITE,RESET;
input [31:0] MREADDATA;
input [7:0] ADDRESS,WRITEDATA;

/****OUTPUTS*****/
output reg MREAD,MWRITE; // memory read and write contorl
output reg BUSYWAIT;     // cpu bc wait
output reg [7:0] READDATA;
output reg [31:0] MWRITEDATA;
output reg [5:0] MADDRESS;

/************other variables*******/
reg hit;
reg [31:0] cache_ram[7:0] ;        // 1 byet size 32 size array
reg valid [7:0];
reg dirty [7:0];
reg [2:0] cacheTAG [7:0];
reg [2:0] tag,Ctag;
reg [2:0] index;
reg [1:0] offset;
reg Cvalid,Cdirty;
reg [7:0] Creaddata;
reg miss_found;
reg readaccess,writeaccess;


//******************check read or write access
always @(READ,WRITE)
begin
  BUSYWAIT    =  (READ || WRITE)? 1 : 0;          //BUSY WAIT =1 WHEN EVER (READ OR WRITE)
  readaccess  =  (READ && !WRITE)? 1 : 0;
  writeaccess =  (!READ && WRITE)? 1 : 0;
end


/*........ parallely extracting data */
always @ ( * ) begin
if(readaccess == 1'b1 || writeaccess == 1'b1)begin
offset = ADDRESS[1:0];
index  = ADDRESS[4:2];
tag    = ADDRESS[7:5];
#1
Ctag    = cacheTAG[index];
Cvalid  = valid[index];
Cdirty  = dirty[index];
end
end


  always @(*) begin //check wheather hit or miss its happend after index value arrived
  #0.9
        if (Ctag[0] == tag[0] && Ctag[1]==tag[1] && Ctag[2]==tag[2] && valid[index]) begin
            hit= 1'b1;
        end
        else begin
            hit= 1'b0;
        end
    end




// READING FROM THE CACHE MEMORY
    always @ ( * ) begin
      if (readaccess && hit) begin
      #1
      case(offset)				//read from cache
      2'b00: READDATA= cache_ram[index][7:0] ;
      2'b01: READDATA= cache_ram[index][15:8] ;
      2'b10: READDATA= cache_ram[index][23:16] ;
      2'b11: READDATA= cache_ram[index][31:24] ;
      endcase
      end

//WRITING THE DATA FROM THE MAIN MEMORY IN CACHE
      else if (!MBUSYWAIT && miss_found) begin
      #1
      cache_ram[index]= MREADDATA;
      cacheTAG[index] = tag;
      valid[index]=1'b1;
      dirty[index]=1'b0;
      miss_found=0;
      end
    end



    always @ ( posedge CLK ) begin
    if(writeaccess  && hit )begin //write hit
    BUSYWAIT=0;
    #1
    case(offset)
      2'b00: cache_ram[index][7:0]   = WRITEDATA;
      2'b01: cache_ram[index][15:8]  = WRITEDATA;
      2'b10: cache_ram[index][23:16] = WRITEDATA;
      2'b11: cache_ram[index][31:24] = WRITEDATA;
    endcase
    valid[index] = 1;		//set dirtybit 1
    dirty[index] = 1;		//set validbit 1
    writeaccess = 1'b0;
    end

    // After read hit
         else if (readaccess && hit) begin
           readaccess=0;
           BUSYWAIT=0;
         end
    end

	parameter IDLE = 3'b000, MEM_READ = 3'b001,MEM_WRITE=3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((READ || WRITE) && !Cdirty && !hit)
                    next_state = MEM_READ;
                else if ((READ || WRITE) && Cdirty && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;



            MEM_READ:
                if (!MBUSYWAIT)
                    next_state = IDLE;
                else
                    next_state = MEM_READ;

            MEM_WRITE:
                if(!MBUSYWAIT)
                    next_state =MEM_READ;
                else
                    next_state= MEM_WRITE;
        endcase
    end

	 // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin

                miss_found=0;
                MREAD = 0;
                MWRITE = 0;
                MADDRESS = 6'dx;
                MWRITEDATA = 32'dx;

            end

            MEM_READ:
            begin

                MREAD = 1;
                MWRITE = 0;
                MADDRESS = {tag, index};
                MWRITEDATA = 32'dx;
                miss_found=1;

            end


            MEM_WRITE:
            begin

                miss_found=0;
                MREAD = 0;
                MWRITE = 1;
                MADDRESS  = {cacheTAG[index],index};
                MWRITEDATA 	=cache_ram[index];

            end
        endcase
    end


	integer i;
    always @(posedge CLK, RESET)
    begin
        if(RESET) begin
            state = IDLE;
            #1
            for(i=0; i<8 ; i=i+1) begin
            valid[i]=0;
            dirty[i]=0;
            cacheTAG[i]=3'b0;
            cache_ram[i]=32'b0;
            end
            BUSYWAIT=0;
        end
        else
            state = next_state;
    end
endmodule
