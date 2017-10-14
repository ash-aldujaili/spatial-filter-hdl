/*
This module implements the filter window,mask, in addition to the row buffers 
........................
By: Abdullah Al-Dujaili
    NTU, 2012
.......................
Importantn note :=============================
This filter mask is designed espeically for 7*7 filter mask
as there are multiplexers that are difficult to make them parameterize for the time being
*/

module open_border_scheme_mask
	 #( parameter ROW_WIDTH = 100,     // # pixel per row
                 PIX_BIT   = 8,       // # pixel bits
                 MASK_WIDTH= 7        // # mask Width
    )
    (
      input wire  clk,reset,                                    // clk and reset
      input wire  ctrl2buf_valid,                                 // indicates if the incoming pixel is valid
      input wire  sel_top_row,                                  // selector signal for mux that deals with top pixel cases
      input wire  [1:0] sel_btm_row,                            // selector signal for mux that deals with btm pixel cases
      input wire  [PIX_BIT-1:0] data_cu2bufcf,                         // incoming pixel
		input wire  [1:0] sel_right_col, // selector signal to deal with pixels along the most right column through mirror without duplicate scheme
		input wire  sel_left_col,        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
		output wire [PIX_BIT*(MASK_WIDTH**2)-1:0] p_m2f // actual/mirrored pixels to be routed to the filter function
   );
	 

		
		
		
		
		
		
		
		
		// Internal signals between mask and row buffers:
		wire [PIX_BIT*MASK_WIDTH-1:0] sngl_col_masked_pixs_buf2msk;
		
		
		
		
		
		
		
		
		//Unit Instantiations of both row buffers and window mask using open border scheme:
		//----------------------------------------------------------------------------------
		 //1. Row buffers (to store incoming pixels to do the necessary convolution)
		row_buffers_no_temp 
		#(.ROW_WIDTH(ROW_WIDTH),     // # pixel per row
			.PIX_BIT(PIX_BIT),       // # pixel bits
			.MASK_WIDTH(MASK_WIDTH))        // # mask Width
			row_buffers_u
		(
      .clk(clk),.reset(reset),          // clk and reset
      .pix_in_valid(ctrl2buf_valid),      // indicates if the incoming pixel is valid
      .sel_top_row(sel_top_row),        // selector signal for mux that deals with top pixel cases
      .sel_btm_row(sel_btm_row),        // selector signal for mux that deals with btm pixel cases
      .pix_in(data_cu2bufcf),   // incoming pixel
      .sngl_col_masked_pixs_out(sngl_col_masked_pixs_buf2msk)    //masked pixels out of the row buffers (one from each row)/ one column of the mask
		);
     //----------------------------------------------------------------------
		//2. Filter Mask:
		filter_mask_no_temp
		#(.PIX_BIT(PIX_BIT),     //# pixel bits
		.MASK_WIDTH(MASK_WIDTH) // mask width
		) mask_u
		(
		.clk(clk),.reset(reset),     // clk reset signals
		.sngl_col_masked_pixs_in(sngl_col_masked_pixs_buf2msk),  // pixels coming from each row of the buffers & the incoming pixel (one pixel each)
		.sel_right_col(sel_right_col), // selector signal to deal with pixels along the most right column through mirror without duplicate scheme
		.sel_left_col(sel_left_col),        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
		.masked_pixs_out(p_m2f) // actual/mirrored pixels to be routed to the filter function
		);
		//----------------------------------------------------------------------------
		
		
endmodule 