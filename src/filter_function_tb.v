`timescale 1ns/1ps

module fitler_function_tb;

///////////////////////////
// Simulation Parameters:
///////////////////////////
parameter CLK_PERIOD=10,
			 COFCNT_BIT=15,
			 PIX_BIT=8,
			 MASK_WIDTH=7;
///////////////////////////

/////////////////////////////////////////////////
//test vector signals
/////////////////////////////////////////////////
// sync signals
reg clk, reset;
// control signals
reg enable;
// incoming data
reg [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c; // coefficients
reg [PIX_BIT   *(MASK_WIDTH**2)-1:0] p; // input pixels
// outcoming data
wire [PIX_BIT-1:0] q; // filter output
wire ready;

integer i,j;
//////////////////////////////////////////








/////////////////////////
// Reset Configuration:
/////////////////////////
initial
begin
clk<=1'b0;
reset<=1'b1;
#20 reset<=1'b0;
end
/////////////////////////


/////////////////////////
// Clock Circuit
/////////////////////////
always
#(CLK_PERIOD/2) clk=~ clk;

/////////////////////////
// Unit Under Test
/////////////////////////
filter_function 
  
  #(.PIX_BIT(PIX_BIT),
    .MASK_WIDTH(MASK_WIDTH),
    .COFCNT_BIT(COFCNT_BIT)
    )
	 uut
    (
      .clk(clk),.reset(reset),.enable(enable), // clk and control signals for pipelining
      .c(c), // coefficients
      .p(p), // input pixels
      .q(q), // filter output
      .ready(ready)
      );

/////////////////////////
//Test Vectors:
/////////////////////////


// Cofficients & Pixels
initial 
begin
  #200
	@(posedge clk)
   for(i=(MASK_WIDTH**2)*COFCNT_BIT-1;i>=COFCNT_BIT-1;i=i-COFCNT_BIT)
	 begin
    c[i-:COFCNT_BIT]<=15'd334;
	 end
	@(posedge clk)
   for(i=(MASK_WIDTH**2)*COFCNT_BIT-1;i>=COFCNT_BIT-1;i=i-COFCNT_BIT)
	 begin
    c[i-:COFCNT_BIT]<=15'd0;
	end
end

initial
begin
	enable<=1'b0;
	#200
	@(posedge clk)
	enable<=1'b1;
	@(posedge clk)
	enable<=1'b0;
end

initial 
begin
  #200
  @(posedge clk)
  for(j=(MASK_WIDTH**2)*PIX_BIT-1;j>=PIX_BIT-1;j=j-PIX_BIT)
    begin
	 p[j-:PIX_BIT]<=255;
	 end
  @(posedge clk)
  for(j=(MASK_WIDTH**2)*PIX_BIT-1;j>=PIX_BIT-1;j=j-PIX_BIT)
    begin
	 p[j-:PIX_BIT]<=0;
	 end
end
/*
initial
begin
for (i=0;i<MASK_WIDTH**2;i=i+1)
	c[PIX_BIT*(i+1)-1:PIX_BIT*i]<=0;
end
*/

endmodule