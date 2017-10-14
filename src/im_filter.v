/*
This is the top level of the image processing system
based on filter incoming images
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
This system acquire pixels with their status and filters them
according to the operator needed
*/


module im_filter
  #(
    parameter DATA_BIT=15,           // # pixel,mask,mask size bits
              DATA_IDBIT=1,         //  # data ID bits
              ROW_WIDTH=640,        // row width of the image
              COL_WIDTH=480,        // col width of the image
              MASK_WIDTH=7,         // mask size
              CNT_BIT=10,            //# counter bits
				  COFCNT_BIT = 15, 		// # coficient bits
				  PIX_BIT    =  8  		// # pixel bits
   )
  (
    input wire clk,reset_in,
    input wire data_in_valid,             // incoming data is valid
    input wire [DATA_BIT-1:0] data_in,    // incoming data value
    input wire [DATA_IDBIT-1:0] data_id,  // determines incoming data type
    output wire pix_out_valid,            // outcoming pixel is valid
    output wire [PIX_BIT:0] pix_out    // outcoming pixel value  s+m
  );
  
  
  // Signal Declaration
  //=================================================================================
  // input logic signals
  reg data_valid_reg,data_valid_next;                // incoming data is valid
  reg [DATA_BIT-1:0]   data_in_reg, data_in_next;    // incoming data value
  reg [DATA_IDBIT-1:0] data_id_reg,data_id_next;     // determines incoming data type
  reg reset_reg, reset_next;
  wire reset = reset_reg;
  // Row Buffers Signal Declarations:
  wire sel_top_row;	  // selector signal for mux that deals with top pixel cases
  wire  [1:0] sel_btm_row;    // selector signal for mux that deals with btm pixel cases
  // signal over buffer and mask
  wire [PIX_BIT*MASK_WIDTH-1:0] sngl_col_masked_pixs_buf2msk;    //masked pixels out of the row buffers (one from each row)/ one column of the mask 
  // Filter mask signals:
  wire [1:0] sel_right_col;// selector signal to deal with pixels along the most right column through mirror without duplicate scheme
  wire sel_left_col;        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
  // Filter Function & Output related Signals:
  wire en_funct; // to declare the incoming data into the filter function is valid
  wire [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c_fi2f; // cofficients of filter ( coefficient file & function)
  wire [PIX_BIT   *(MASK_WIDTH**2)-1:0] p_m2f; // current pixels under mask(Mask & fucntion)
  reg  [PIX_BIT:0] pix_out_reg ; // output pixel s+m
  wire [PIX_BIT:0] pix_out_next;// 
  reg   pix_valid_reg; // output pixel is valid
  wire  pix_valid_next; 
  // cofficient file:
  wire update_cf;                    // write enable
  // control unit:
  wire [DATA_BIT-1:0]   data_cu2bufcf;// data routed from control unit to 
  //====================================================================================
  
  
  
  
  //===============================================================================
  //Input Logic
  //===============================================================================
  //Sequential Circuit:
  always@(posedge clk)
	begin
		data_valid_reg <= data_valid_next;
		data_in_reg		<= data_in_next;
		data_id_reg    <= data_id_next;
		reset_reg		<= reset_next;
	end
  // next-state logic
  always@*
	begin
		data_valid_next = data_in_valid;
		data_in_next	 = data_in;
		data_id_next	 = data_id;
		reset_next		 = reset_in;
   end
  //===============================================================================
  // Transpose Implementation !
  
  
  // Body:
  //================
  // instantiations
  //===============
  //1. Filter Function
  /*
  filter_function  #(.PIX_BIT(PIX_BIT),.MASK_WIDTH(MASK_WIDTH),.COFCNT_BIT(COFCNT_BIT))
  funct_u
    (
      .clk(clk),.reset_in(reset),.enable(en_funct), // clk and control signals for pipelining
      .c(c_fi2f), // coefficients
      .p(p_m2f), // input pixels
      .q(pix_out_next), // filter output
      .ready(pix_valid_next)
      );
	*/	
  
  //--------------------------------------------------------------------
  //2. Row buffers (to store incoming pixels to do the necessary convolution)
  // This unit combines both the row buffers and mask for bailey scheme
  // Enable one of the schemes along with the filter function and the control unit no_temp
  /*
  open_border_scheme_mask
	 #( .ROW_WIDTH(ROW_WIDTH),     // # pixel per row
       .PIX_BIT(PIX_BIT),       // # pixel bits
       .MASK_WIDTH(MASK_WIDTH)        // # mask Width
    ) open_msk_buf_u
    (
      .clk(clk),.reset(reset),                                    // clk and reset
      .ctrl2buf_valid(ctrl2buf_valid),                                 // indicates if the incoming pixel is valid
      .sel_top_row(sel_top_row),                                  // selector signal for mux that deals with top pixel cases
      .sel_btm_row(sel_btm_row),                            // selector signal for mux that deals with btm pixel cases
      .data_cu2bufcf(data_cu2bufcf[PIX_BIT-1:0]),                         // incoming pixel
		.sel_right_col(sel_right_col), // selector signal to deal with pixels along the most right column through mirror without duplicate scheme
		.sel_left_col(sel_left_col),        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
		.p_m2f(p_m2f) // actual/mirrored pixels to be routed to the filter function
   );
	*/
	
/*
  bailey_scheme_mask
	 #( .ROW_WIDTH(ROW_WIDTH),     // # pixel per row
       .PIX_BIT(PIX_BIT),       // # pixel bits
       .MASK_WIDTH(MASK_WIDTH)        // # mask Width
    ) bailey_msk_buf_u
    (
      .clk(clk),.reset(reset),                                    // clk and reset
      .ctrl2buf_valid(ctrl2buf_valid),                                 // indicates if the incoming pixel is valid
      .sel_top_row(sel_top_row),                                  // selector signal for mux that deals with top pixel cases
      .sel_btm_row(sel_btm_row),                            // selector signal for mux that deals with btm pixel cases
      .data_cu2bufcf(data_cu2bufcf[PIX_BIT-1:0]),                         // incoming pixel
		.sel_right_col(sel_right_col), // selector signal to deal with pixels along the most right column through mirror without duplicate scheme
		.sel_left_col(sel_left_col),        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
		.p_m2f(p_m2f) // actual/mirrored pixels to be routed to the filter function
   );
	
  */
  //=========================================================
  ///*
  // Implementation using 2d transposed filter: disable the other schemes and the control unit no_temp
  // and enable control unit trnsps
  no_brdr_trnsps_scheme
	  #(.ROW_WIDTH(ROW_WIDTH-7), 
		 .PIX_BIT(PIX_BIT),
       .MASK_WIDTH(MASK_WIDTH),
       .COFCNT_BIT(COFCNT_BIT))
		no_brdr_trnsps_scheme_u 
    (
      .clk(clk),.reset_in(reset_in),.enable(en_funct),.data_valid(ctrl2buf_valid),// clk and control signals for pipelining
      .c(c_fi2f), // coefficients
      .pix_ine(data_cu2bufcf[PIX_BIT-1:0]), // input pixels
      .q(pix_out_next), // signed filter output sign+ 8 bit
      .ready(pix_valid_next)
      );
  control_unit_trnsps_scheme
		#(
			.DATA_BIT(DATA_BIT),					//  # data bits
			.DATA_IDBIT(DATA_IDBIT),      	//  # data ID bits
			.ROW_WIDTH(ROW_WIDTH),       		// row width of the image
			.COL_WIDTH(COL_WIDTH),       		// col width of the image
			.MASK_WIDTH(MASK_WIDTH),     		// mask size
			.CNT_BIT(CNT_BIT)            		//# counter bits
		 ) control_trnsps_u
	( .clk(clk),.reset(reset),             // clk and reset signals
	  .data_id(data_id_reg),   				// Determines incoming data type
	  .data_in_valid(data_valid_reg),		// Incoming data is valid
	  .data_in(data_in_reg),
	  .ctrl2buf_valid(ctrl2buf_valid),	   // To indicate that data fed to the row buffers is a valid pixel value
	  //.sel_top_row(sel_top_row),	         // selector signal for mux that deals with top pixel cases
    // .sel_btm_row(sel_btm_row),           // selector signal for mux that deals with btm pixel cases
	 // .sel_right_col(sel_right_col),			// selector signal to deal with pixels along the most right column through mirror without duplicate scheme
    // .sel_left_col(sel_left_col),         // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
	  .update_cf(update_cf),           		// write enable for the coefficient file
	  .en_funct(en_funct),
	  .data_out(data_cu2bufcf)         		// data_cu2bufcf
	); 
 //*/
  //==============================================
  //----------------------------------------------------------------------
  //4. Coefficient File:
  coefficient_file
  #(.COFCNT_BIT(COFCNT_BIT), // # coefficient bit
    .MASK_WIDTH(MASK_WIDTH)  // mask width
    ) cfcnt_file_u
    (
      .clk(clk),.reset(reset),                // clk and reset signals
      .wr_en(update_cf),                    // write enable
      .wr_data(data_cu2bufcf[COFCNT_BIT-1:0]), // data to be written
      .out_data(c_fi2f) // coefficient
    );
    
  // on whether the pixel is an image border or not
  //----------------------------------------------------------------------
  //5. Control Unit: use this for the directed form with borders
  /*
  control_unit_no_temp
		#(
			.DATA_BIT(DATA_BIT),					//  # data bits
			.DATA_IDBIT(DATA_IDBIT),      	//  # data ID bits
			.ROW_WIDTH(ROW_WIDTH),       		// row width of the image
			.COL_WIDTH(COL_WIDTH),       		// col width of the image
			.MASK_WIDTH(MASK_WIDTH),     		// mask size
			.CNT_BIT(CNT_BIT)            		//# counter bits
		 ) control_u
	( .clk(clk),.reset(reset),             // clk and reset signals
	  .data_id(data_id_reg),   				// Determines incoming data type
	  .data_in_valid(data_valid_reg),		// Incoming data is valid
	  .data_in(data_in_reg),
	  .ctrl2buf_valid(ctrl2buf_valid),	   // To indicate that data fed to the row buffers is a valid pixel value
	  .sel_top_row(sel_top_row),	         // selector signal for mux that deals with top pixel cases
     .sel_btm_row(sel_btm_row),           // selector signal for mux that deals with btm pixel cases
	  .sel_right_col(sel_right_col),			// selector signal to deal with pixels along the most right column through mirror without duplicate scheme
     .sel_left_col(sel_left_col),         // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
	  .update_cf(update_cf),           		// write enable for the coefficient file
	  .en_funct(en_funct),
	  .data_out(data_cu2bufcf)         		// data_cu2bufcf
	); 
  */
  
  //===============================================================================
  
  
   //
  
  
   //===============================================================================
	//Output Logic
	//===============================================================================
	// Registering output signals
	// Sequential Circuit
	always@(posedge clk)
		begin
			pix_out_reg   <= pix_out_next;
			pix_valid_reg <= pix_valid_next;
		end
		
	 // comb logic:
	 assign pix_out 		 = pix_out_reg;
	 assign pix_out_valid = pix_valid_reg;
   //===============================================================================
  
  
  
            
endmodule
