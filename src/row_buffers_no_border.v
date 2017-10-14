/*
This module implements all the row buffers needed
to be used in an window-based image filter scheme
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
The row buffer is simple a 2D shiftregister
which saves in and out the incoming pixels.
The row buffers have to be cascased to ensure
No pixel is poped out without being processed

Importantn note :=============================
This row buffer design has been implemented espeically for 7*7 filter mask
as there are multiplexers that are difficult to make them parameterize for the time being
*/

module row_buffers_no_border
    #( parameter ROW_WIDTH = 340,     // # pixel per row
                 PIX_BIT   = 8,       // # pixel bits
                 MASK_WIDTH= 3        // # mask Width
    )
    (
      input wire  clk,reset,                                    // clk and reset
      input wire  pix_in_valid,                                 // indicates if the incoming pixel is valid
      //input wire  sel_top_row,                                  // selector signal for mux that deals with top pixel cases
      //input wire  [1:0] sel_btm_row,                            // selector signal for mux that deals with btm pixel cases
      input wire  [PIX_BIT-1:0] pix_in,                         // incoming pixel
      output wire [PIX_BIT*MASK_WIDTH-1:0] sngl_col_masked_pixs_out      //masked pixels out of the row buffers (one from each row)/ one column of the mask
    );
    
    //--------------------------------------------------------
    // Signal Declaration
    // Row buffers holding actual pixel values to keep the streaming un-interrupted (explicitly for 7*7 window):
    reg [PIX_BIT*ROW_WIDTH-1:0] row_buffer1_reg ,row_buffer2_reg ,row_buffer3_reg ,row_buffer4_reg ,row_buffer5_reg ,row_buffer6_reg;
    reg [PIX_BIT*ROW_WIDTH-1:0] row_buffer1_next,row_buffer2_next,row_buffer3_next,row_buffer4_next,row_buffer5_next,row_buffer6_next;
    // Temp row buffers holding the expanded image pixels around the borders to overlap priming/emptying
    //reg [PIX_BIT*ROW_WIDTH-1:0] temp_row_buffer1_reg,temp_row_buffer2_reg;
    //reg [PIX_BIT*ROW_WIDTH-1:0] temp_row_buffer1_next,temp_row_buffer2_next;
    // muxes-related signals: (this multiplexing is implemented to deal with image borders usign mirror without duplicate scheme)
    reg  [PIX_BIT-1:0] pix_o_row_3,pix_o_row_4,pix_o_row_5,pix_o_row_6;
    reg  [PIX_BIT-1:0] pix_o_row_0,pix_o_row_1,pix_o_row_2;
    
    
    //---------------------------------------------------------
    // BODY:
    //======================================================================================================
    // Mux circuit ( no border technique)
    always@*
		begin
			pix_o_row_0 = pix_in;
			pix_o_row_1 = row_buffer1_reg[PIX_BIT-1:0];
			pix_o_row_2 = row_buffer2_reg[PIX_BIT-1:0];
			pix_o_row_3 = row_buffer3_reg[PIX_BIT-1:0];
			pix_o_row_4 = row_buffer4_reg[PIX_BIT-1:0];
			pix_o_row_5 = row_buffer5_reg[PIX_BIT-1:0];
			pix_o_row_6 = row_buffer6_reg[PIX_BIT-1:0]; 
		end
		/*
	 //pix_o_row_0:
    always@*
    begin
      case(sel_btm_row)
        2'd0 : pix_o_row_0 = pix_in; // default feature --direct routing
        2'd1 : pix_o_row_0 = row_buffer2_reg[PIX_BIT-1:0];   // for 3rd last row
        2'd2 : pix_o_row_0 = row_buffer4_reg[PIX_BIT-1:0];        // for 2nd last row
        2'd3 : pix_o_row_0 = row_buffer6_reg[PIX_BIT-1:0];        // for last row
      endcase
    end
    // pix_o_row_1
    //assign pix_o_row_1 = (sel_top_row) ? row_buffer1_reg[PIX_BIT-1:0] : temp_row_buffer1_reg[PIX_BIT-1:0]; // 1 load up the actual pixels, 0 route the duplicated borders from the temp buffers
    always@*
    begin
      case(sel_btm_row)
        2'd0 : pix_o_row_1 = row_buffer1_reg[PIX_BIT-1:0]; // default feature --direct routing
        2'd1 : pix_o_row_1 = row_buffer1_reg[PIX_BIT-1:0];   // for 3rd last row
        2'd2 : pix_o_row_1 = row_buffer3_reg[PIX_BIT-1:0];        // for 2nd last row
        2'd3 : pix_o_row_1 = row_buffer5_reg[PIX_BIT-1:0];        // for last row
      endcase
    end
	 // pix_o_row_2
    //assign pix_o_row_2 = (sel_top_row) ? row_buffer2_reg[PIX_BIT-1:0] : temp_row_buffer2_reg[PIX_BIT-1:0]; // 1 load up the actual pixels, 0 route the duplicated borders from the temp buffers
     always@*
    begin
      case(sel_btm_row)
        2'd0 : pix_o_row_2 = row_buffer2_reg[PIX_BIT-1:0]; // default feature --direct routing
        2'd1 : pix_o_row_2 = row_buffer2_reg[PIX_BIT-1:0];   // for 3rd last row
        2'd2 : pix_o_row_2 = row_buffer2_reg[PIX_BIT-1:0];        // for 2nd last row
        2'd3 : pix_o_row_2 = row_buffer4_reg[PIX_BIT-1:0];        // for last row
      endcase
    end
	 // pix_o_row_3
    assign pix_o_row_3 = row_buffer3_reg[PIX_BIT-1:0]; // no need for routing
    // pix o row 4
    assign pix_o_row_4 = (sel_top_row) ? row_buffer2_reg[PIX_BIT-1:0] : row_buffer4_reg[PIX_BIT-1:0];     // 1 : load up mirrored values, 0 load up actual pixels
    // pix 0 row 5
    assign pix_o_row_5 = (sel_top_row) ? row_buffer1_reg[PIX_BIT-1:0] : row_buffer5_reg[PIX_BIT-1:0];     // 1 : load up mirrored values, 0 load up actual pixels
    // pix 0 row 6
    assign pix_o_row_6 = (sel_top_row) ? pix_in                       : row_buffer6_reg[PIX_BIT-1:0];     // 1 : load up mirrored values, 0 load up actual pixels
    //===========================================================================================================
    */
	 // Sequential Circuit
    always@(posedge clk)
    /* if(reset)
       begin
        row_buffer1_reg     <=0;
        row_buffer2_reg     <=0;
        row_buffer3_reg     <=0;
        row_buffer4_reg     <=0;
        row_buffer5_reg     <=0;
        row_buffer6_reg     <=0;
        temp_row_buffer1_reg<=0;
        temp_row_buffer2_reg<=0;
      end
     else*/
       begin
        row_buffer1_reg       <= row_buffer1_next;
        row_buffer2_reg       <= row_buffer2_next;
        row_buffer3_reg       <= row_buffer3_next;
        row_buffer4_reg       <= row_buffer4_next;
        row_buffer5_reg       <= row_buffer5_next;
        row_buffer6_reg       <= row_buffer6_next;
       // temp_row_buffer1_reg  <= temp_row_buffer1_next;
       // temp_row_buffer2_reg  <= temp_row_buffer2_next;
      end
    //---------------------------------------------------------
    // Next-state logic
    always@*
    begin   
     /* //default setting row_buffer_next=row_buffer_reg;
      row_buffer1_next      = row_buffer1_reg;
      row_buffer2_next      = row_buffer2_reg;
      row_buffer3_next      = row_buffer3_reg;
      row_buffer4_next      = row_buffer4_reg;
      row_buffer5_next      = row_buffer5_reg;
      row_buffer6_next      = row_buffer6_reg;
     // temp_row_buffer1_next = temp_row_buffer1_reg;
     // temp_row_buffer2_next = temp_row_buffer2_reg;
      //if the incoming pixel is valid then update the buffer
      if (pix_in_valid)
        begin*/
          // some actual buffers are connected to the upper row buffers and some are connected to the 
          // upper row mux according to the mirror-no duplicate scheme.
          row_buffer1_next = {pix_in,row_buffer1_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
          row_buffer2_next = {row_buffer1_reg[PIX_BIT-1:0],row_buffer2_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
          row_buffer3_next = {row_buffer2_reg[PIX_BIT-1:0],row_buffer3_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
          row_buffer4_next = {row_buffer3_reg[PIX_BIT-1:0],row_buffer4_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
          row_buffer5_next = {row_buffer4_reg[PIX_BIT-1:0],row_buffer5_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
          row_buffer6_next = {row_buffer5_reg[PIX_BIT-1:0],row_buffer6_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
          // temp buffers storing actual/duplicated pixels to overlap priming/emptying
          //temp_row_buffer1_next= {pix_o_row_0,temp_row_buffer1_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
          //temp_row_buffer2_next= {pix_o_row_1,temp_row_buffer2_reg[PIX_BIT*ROW_WIDTH-1:PIX_BIT]};
        end
     // end
     //---------------------------------------------------------
     // Output Logic:
     assign sngl_col_masked_pixs_out={pix_o_row_6,pix_o_row_5,pix_o_row_4,pix_o_row_3,pix_o_row_2,pix_o_row_1,pix_o_row_0};
     
     
  endmodule