// lab6 part1
// E17358
// E17256*****/

module inscache( clock,reset,pc,read,address, readinst,mem_busywait,busywait,instruction );
// input signels
input clock,mem_busywait,reset;
input [31:0] pc;
input [127:0]readinst;


reg [131:0]cache_mem[7:0];    // cache memory
reg hit,valid;
reg [2:0]index,tag,ctag;
reg [1:0] offset;

// output  signels
output reg busywait,read;
output reg [31:0]instruction;         // instruction form cache memory
output reg [5:0]address;              // address for instruction memory


// take tag,index, offset form pc
always @ ( * ) begin
 #1 tag<=pc[9:7];
  index<=pc[6:4];
  offset<=pc[3:2];
  ctag=cache_mem[index][130:128];
  valid=cache_mem[index][131];
end

// check if the tag is in cache memory
always @(*) begin
#0.9
      if (ctag[0] == tag[0] && ctag[1]==tag[1] && ctag[2]==tag[2] && valid) begin
          hit= 1'b1;
      end
      else begin
          hit= 1'b0;
      end
  end

// when instruction not found controller for instruction memory
reg write;
always @ ( posedge clock ) begin
  if (!hit) begin
   	busywait=1;
      read=1;
      write=1;
   	address = { tag, index};
   end
end

// read instruction from cache memory
always @ ( * ) begin
    if(hit) begin
    #1
    case (offset)
      2'b00: instruction=cache_mem[index][31:0];
      2'b01: instruction=cache_mem[index][63:32];
      2'b10: instruction=cache_mem[index][95:64];
      2'b11: instruction=cache_mem[index][127:96];
    endcase
    end
end

// wirte a instruction to cache memory
always @ ( * ) begin
   if (!hit & write & !mem_busywait) begin
      #1
      cache_mem[index]={1'b1,tag,readinst};
      write=0;
   end
end

// reset the cache memory
integer i;
always @ ( posedge clock ) begin
	if (reset) begin
		#1
		for(i=0;i<8;i++) begin
			cache_mem[i]=132'd0;
		end
		busywait=0;
	end
end

// change the read control when hit is 1
always @ ( posedge clock ) begin
   if (hit & !reset) begin
      busywait=0;
      read=0;
   end
end
endmodule
