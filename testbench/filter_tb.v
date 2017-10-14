`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:53:57 09/28/2012 
// Design Name: 
// Module Name:    filter_tb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module filter_tb;

///////////////////////////
// Simulation Paramters
//////////////////////////
parameter CLK_PERIOD=10,
			 COFCNT_BIT=15,
			 DATA_BIT=15,
			 PIX_BIT=8,
			 MASK_WIDTH=7,
			 CNT_BIT=9,
			 ROW_WIDTH=10,
			 COL_WIDTH=10,
			 DATA_IDBIT=1;
//////////////////////////


/////////////////////////
// Test Vector Signals
//////////////////////////
//Sync signals
reg clk,reset;
//input signals
reg data_in_valid;
reg [DATA_BIT-1:0] data_in;
reg [DATA_IDBIT-1:0] data_id;
//output signals
wire pix_out_valid;
wire [PIX_BIT-1:0] pix_out;

///////////////////////////


// Handy Variables:
integer i,j;

////////////////////////////
//Reset Configuration
///////////////////////////
initial
begin 
clk<=1'b0;
reset<=1'b1;
#20 reset<=1'b0;
end
/////////////////////////////

///////////////////////////
// Clock Circuit
////////////////////////////
always
#(CLK_PERIOD/2) clk=~clk;
////////////////////////////


/////////////////////////////
// Unit Under Test
/////////////////////////////
im_filter
  #(
    .DATA_BIT(DATA_BIT),             // # pixel,mask,mask size bits
    .DATA_IDBIT(DATA_IDBIT),         //  # data ID bits
    .ROW_WIDTH(ROW_WIDTH),           // row width of the image
    .COL_WIDTH(COL_WIDTH),           // col width of the image
    .MASK_WIDTH(MASK_WIDTH),         // mask size
    .CNT_BIT(CNT_BIT),               //# counter bits
	 .COFCNT_BIT(COFCNT_BIT), 		    // # coficient bits
	 .PIX_BIT(PIX_BIT)  		          // # pixel bits
   ) uut
  (
    .clk(clk),.reset(reset),
    .data_in_valid(data_in_valid),             // incoming data is valid
    .data_in(data_in),    // incoming data value
    .data_id(data_id),  // determines incoming data type
    .pix_out_valid(pix_out_valid),            // outcoming pixel is valid
    .pix_out(pix_out)    // outcoming pixel value
  );

//////////////////////////////////


//////////////////////////////////
// Test Vectors
//////////////////////////////////
initial 
begin
data_in_valid=0;
data_id=0;
#200;
for (i=1;i<=50;i=i+1)
@(posedge clk)
begin data_in_valid=1; //
      data_id=1; // data id ==>cf
	   data_in=334;
end
#10;
data_in_valid=0; //
data_id=0;
#200;
for (i=1;i<255;i=i+1)
@(posedge clk)
begin data_in_valid=1; //
      data_id=0; // data id ==>pix
	   data_in=i;
end
end
///////////////////////////////////









endmodule
