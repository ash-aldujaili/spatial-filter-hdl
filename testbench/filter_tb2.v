`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:53:57 09/28/2012 
// Design Name: 
// Module Name:    filter_tb2 
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
module filter_tb2;

///////////////////////////
// Simulation Paramters
//////////////////////////
parameter CLK_PERIOD=2,
			 COFCNT_BIT=15,
			 DATA_BIT=15,
			 PIX_BIT=8,
			 MASK_WIDTH=7,
			 CNT_BIT=7,
			 ROW_WIDTH=100,
			 COL_WIDTH=100,
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
wire signed [PIX_BIT:0] pix_out; // s+m
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


/////////////////////////////////////
// Files in and out:
/////////////////////////////////////
integer fdin,fdout,fdin1;
integer nend_file;
integer txt_in,txt_out;
integer unused,r;
reg [100:1] string;


/////////////////////////////
// Unit Under Test
/////////////////////////////
/*
// transposed
im_filter
  #(
    .DATA_BIT(DATA_BIT),           // # pixel,mask,mask size bits
    .DATA_IDBIT(DATA_IDBIT),         //  # data ID bits
    .ROW_WIDTH(ROW_WIDTH),        // row width of the image
    .COL_WIDTH(COL_WIDTH),        // col width of the image
    .MASK_WIDTH(MASK_WIDTH),         // mask size
    .CNT_BIT(CNT_BIT),            //# counter bits
	 .COFCNT_BIT(COFCNT_BIT), 		// # coficient bits
	 .PIX_BIT(PIX_BIT)  		// # pixel bits
   ) uut
  (
    .clk(clk),.reset_in(reset),
    .data_in_valid(data_in_valid),             // incoming data is valid
    .data_in(data_in),    // incoming data value
    .data_id(data_id),  // determines incoming data type
    .pix_out_valid(pix_out_valid),            // outcoming pixel is valid
    .pix_out(pix_out)    // outcoming pixel value
  );
  
  */
  // no border filter + direct form
 /* 
  im_filter_no_border
  #(
    .DATA_BIT(DATA_BIT),           // # pixel,mask,mask size bits
    .DATA_IDBIT(DATA_IDBIT),         //  # data ID bits
    .ROW_WIDTH(ROW_WIDTH),        // row width of the image
    .COL_WIDTH(COL_WIDTH),        // col width of the image
    .MASK_WIDTH(MASK_WIDTH),         // mask size
    .CNT_BIT(CNT_BIT),            //# counter bits
	 .COFCNT_BIT(COFCNT_BIT), 		// # coficient bits
	 .PIX_BIT(PIX_BIT)  		// # pixel bits
   ) uut
  (
    .clk(clk),.reset_in(reset),
    .data_in_valid(data_in_valid),             // incoming data is valid
    .data_in(data_in),    // incoming data value
    .data_id(data_id),  // determines incoming data type
    .pix_out_valid(pix_out_valid),            // outcoming pixel is valid
    .pix_out(pix_out)    // outcoming pixel value
  );
  */
// /*
  // best implemented design usign compression circuit
  im_filter_no_temp
  #(
    .DATA_BIT(DATA_BIT),           // # pixel,mask,mask size bits
    .DATA_IDBIT(DATA_IDBIT),         //  # data ID bits
    .ROW_WIDTH(ROW_WIDTH),        // row width of the image
    .COL_WIDTH(COL_WIDTH),        // col width of the image
    .MASK_WIDTH(MASK_WIDTH),         // mask size
    .CNT_BIT(CNT_BIT),            //# counter bits
	 .COFCNT_BIT(COFCNT_BIT), 		// # coficient bits
	 .PIX_BIT(PIX_BIT)  		// # pixel bits
   ) uut1
  (
    .clk(clk),.reset_in(reset),
    .data_in_valid(data_in_valid),             // incoming data is valid
    .data_in(data_in),    // incoming data value
    .data_id(data_id),  // determines incoming data type
   .pix_out_valid(pix_out_valid),            // outcoming pixel is valid
    .pix_out(pix_out)    // outcoming pixel value
  );
//*/
//////////////////////////////////


//////////////////////////////////
// Test Vectors
//////////////////////////////////
initial 
	begin

	data_in_valid=0;
		data_id=0;
		#200;
		
 // Smoothing		
		for (i=1;i<=50;i=i+1)
			@(posedge clk)
				begin 
				  data_in_valid=1; //
					data_id=1; // data id ==>cf
					data_in=334;
				end
		#10;
		data_in_valid=0; //
		data_id=0;
		#200;
	/////////////

/*// edge	
		/// read filter coefficients from input file
		fdin1 = $fopen ("FilCof.txt","r");
		nend_file=1;
		
		while(nend_file)
		begin		
			nend_file = $fgets(string,fdin1);
			unused=$sscanf(string,"%d",txt_in);
			begin 
					
					data_in_valid=1; //
					data_id=1; // data id ==>pix
					data_in=txt_in*57; // *2^14/299
					
					@(posedge clk);
			end
		end
		// data halt
		$fclose(fdin1);
		data_in_valid=0; //
		data_id=0; // data id ==>pix
		#200;
	//////////////////

*/	
		/// read image pixels from input file
		fdin = $fopen ("ImageText.txt","r");
		nend_file=1;
		
		while(nend_file)
		begin		
			nend_file = $fgets(string,fdin);
			unused=$sscanf(string,"%d",txt_in);
			begin 
					
					data_in_valid=1; //
					data_id=0; // data id ==>pix
					data_in=txt_in;
					
					@(posedge clk);
			end
		end
		// data halt
		$fclose(fdin);
		data_in_valid=0; //
		data_id=0; // data id ==>pix
end

initial 

begin		
		
		
		
		fdout= $fopen ("TextImage.txt","w");
		// waiting for output to be ready
		wait(pix_out_valid);
		i=0;
		while(i<7) 
			begin
			
				
				@(posedge clk )
				   if (pix_out_valid)
						begin
						$fdisplay(fdout,"%d",pix_out);
						i=0;
						end
					else
						i=i+1;
						
		    
			end
			
		
		// Close the files:
		
		$fclose(fdout);
		$finish;
	
			
			
end
///////////////////////////////////




///////////////////////////////////
//////////////////////////////////

endmodule
