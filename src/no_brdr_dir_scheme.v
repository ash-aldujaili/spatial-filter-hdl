`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:57:16 03/04/2013 
// Design Name: 
// Module Name:    no_brdr_dir_scheme 
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
module no_brdr_dir_scheme


	(
	
		input wire clk, reset,
		input wire en_funct,
		input wire [DATA_BIT-1:0]   data_cu2bufcf,// data routed from control unit to 
		output wire pix_valid_next,
		output wire [PIX_BIT:0] pix_out_next//
    );


	// Signals:
	//------------------------------
	
	// not yet finished
	
  // signal over buffer and mask
  wire [PIX_BIT*MASK_WIDTH-1:0] sngl_col_masked_pixs_buf2msk;    //masked pixels out of the row buffers (one from each row)/ one column of the mask 
  // Filter mask signals:
  wire [1:0] sel_right_col;// selector signal to deal with pixels along the most right column through mirror without duplicate scheme
  wire sel_left_col;        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
  // Filter Function & Output related Signals:
  wire en_funct; // to declare the incoming data into the filter function is valid
  wire [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c_fi2f; // cofficients of filter ( coefficient file & function)
  wire [PIX_BIT   *(MASK_WIDTH**2)-1:0] p_m2f; // current pixels under mask(Mask & fucntion)
  
	
	
	//1. Filter Function
  filter_function_6_adder  #(.PIX_BIT(PIX_BIT),.MASK_WIDTH(MASK_WIDTH),.COFCNT_BIT(COFCNT_BIT))
  funct_u
    (
      .clk(clk),.reset_in(reset),.enable(en_funct), // clk and control signals for pipelining
      .c(c_fi2f), // coefficients
      .p(p_m2f), // input pixels
      .q(pix_out_next), // filter output
      .ready(pix_valid_next)
      );
		
  
  //--------------------------------------------------------------------
  //2. Row buffers (to store incoming pixels to do the necessary convolution)
  //2. This module combine both row buffer and window mask so that it is easily to compare versus other 
  // border scheme:
  no_border_scheme_mask
	 #( .ROW_WIDTH(ROW_WIDTH),     // # pixel per row
       .PIX_BIT(PIX_BIT),       // # pixel bits
       .MASK_WIDTH(MASK_WIDTH)        // # mask Width
    ) no_brdr_msk_buf_u
    (
      .clk(clk),.reset(reset),                                    // clk and reset
      .ctrl2buf_valid(ctrl2buf_valid),                                 // indicates if the incoming pixel is valid
      //.sel_top_row(sel_top_row),                                  // selector signal for mux that deals with top pixel cases
      //.sel_btm_row(sel_btm_row),                            // selector signal for mux that deals with btm pixel cases
      .data_cu2bufcf(data_cu2bufcf[PIX_BIT-1:0]),                         // incoming pixel
		//.sel_right_col(sel_right_col), // selector signal to deal with pixels along the most right column through mirror without duplicate scheme
		//.sel_left_col(sel_left_col),        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
		.p_m2f(p_m2f) // actual/mirrored pixels to be routed to the filter function
   );

endmodule
