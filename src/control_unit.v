//////////////////////////////////////////////////////////////////////////////////
// Company:   NTU
// Engineer:  Abdullah Al-Dujaili
// 
// Create Date:    21:36:40 09/25/2012 
// Design Name:    im_filter
// Module Name:    control_unit 
// Project Name:   Filter
// Target Devices: 
// Tool versions: 
// Description: 
//				This module is the control unit for the image filter
//				it takes care of all the control signals that control 
//				different components of the filter
//				The control scheme is based on evaluating the current
//				pixel location.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module control_unit
		#(
			parameter DATA_BIT=15,          // # data bits
						 DATA_IDBIT=2,         //  # data ID bits
						 ROW_WIDTH=512,        // row width of the image
						 COL_WIDTH=512,        // col width of the image
						 MASK_WIDTH=7,         // mask size
						 CNT_BIT=8            //# counter bits
		 )
	( input  wire clk,reset,                  // clk and reset signals
	  input  wire [DATA_IDBIT-1:0] data_id,   // Determines incoming data type
	  input  wire data_in_valid,				   // Incoming data is valid
	  input  wire [DATA_BIT-1:0] data_in,     // incoming data
	  output wire ctrl2buf_valid,				   // To indicate that data fed to the row buffers is a valid pixel value
	  output wire sel_top_row,	               // selector signal for mux that deals with top pixel cases
     output wire [1:0] sel_btm_row,          // selector signal for mux that deals with btm pixel cases
	  output wire [1:0] sel_right_col,// selector signal to deal with pixels along the most right column through mirror without duplicate scheme
     output wire sel_left_col,        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
	  output wire update_cf,           // write enable for the coefficient file
	  output wire en_funct,				  // enable filter function
	  output wire [DATA_BIT-1:0] data_out // data routed from control unit to both buffers and coefficient file
	);

	
	// Symbolic States:
	localparam IDLE    = 3'd0, // system idle
				  UPDT_CF = 3'd1, // update coefficient file
				  PRIMING = 3'd2, // priming the pipeline
				  PROCESS = 3'd3, // processing pixels
				  EMPTY   = 3'd4; // emptying system
				  
	// Signal Declaration:
	reg [2:0] state_reg, state_next;								  // state signals
	reg buf_valid_reg,buf_valid_next; 					  // to indicate incoming pixel is valid for the row buffers
	reg sel_tr_reg, sel_tr_next;		 					  // select top row signal for border policy management
	reg [1:0] sel_br_reg,sel_br_next;					  // selector signal for mux that deals with btm pixel cases
	reg [1:0] sel_rc_reg,sel_rc_next;                 // selector signal to deal with pixels along the most right column through mirror without duplicate scheme
	reg sel_lc_reg,sel_lc_next;						     //  selector signal to deal with pixels along the most left  column through mirror without duplication scheme
	reg u_cf_reg,u_cf_next;    							  // update coefficient file
	reg en_fn_reg,en_fn_next; 							     // enable filter function flag
	reg [3:0] en_fn_sreg,en_fn_snext;					  // enable filter function shit reg
	reg [DATA_BIT-1:0]  data_out_reg;  // incoming & outgoing data
	// Counter X and Y Signal Declarations
   wire x_cnt_en,y_cnt_en;               					// enable signals for both counters
	reg  x_cnt_en_reg,y_cnt_en_reg;               		// enable signals for both counters
	reg  x_cnt_en_next,y_cnt_en_next;               	// enable signals for both counters
   wire max_tick_x,max_tick_y;           					// maximum value indicators
   wire [CNT_BIT-1:0] x_cnt,y_cnt;       					// counter values
	reg  reset_cnt_reg,reset_cnt_next;					// reset signals for counter x
	wire rst_cnt;
	// control conditons:
	wire update_cf_sig = data_in_valid && (data_id==1'b1); // data valid and cf data id
	wire strm_pix_sig  = data_in_valid && (data_id==1'b0); // data valid and pix data id
	
	//===================================
	// Body:
	//===================================
	
	
	// Logic with counters
	//===================================
	//X and Y Counters:==========================================================
   // used as input signals for the state machine (to control its transition) and the 
   // router circuit to help in dealing with image border 
   assign x_cnt_en = x_cnt_en_reg;
	assign y_cnt_en = y_cnt_en_reg;
	assign rst_cnt= reset_cnt_reg    |((state_reg==IDLE)& (strm_pix_sig)) ;
	//--------------------------------------------------------
   counter #(.CNT_BIT(CNT_BIT),.CNT_MOD(ROW_WIDTH))
   x_counter(.clk(clk),.reset(reset|rst_cnt),.enable(x_cnt_en),.count(x_cnt),.max_tick(max_tick_x));
   //--------------------------------------------------------
   counter #(.CNT_BIT(CNT_BIT),.CNT_MOD(COL_WIDTH))
   y_counter(.clk(clk),.reset(reset|rst_cnt),.enable(y_cnt_en),.count(y_cnt),.max_tick(max_tick_y));
   //--------------------------------------------------------
	
	// Sequential Circuit:
	always@(posedge clk)
	if(reset)
	begin
	   // state_register signals
	   state_reg     <= IDLE;
		buf_valid_reg <= 0;
	   sel_tr_reg	  <= 0;
	   sel_br_reg	  <= 0;
	   sel_rc_reg	  <= 0;
	   sel_lc_reg	  <= 0;
	   u_cf_reg		  <= 0;
	   en_fn_reg	  <= 0;
		en_fn_sreg    <= 0;
	   data_out_reg  <= 0;	
		y_cnt_en_reg  <= 0;
		x_cnt_en_reg  <= 0;
		reset_cnt_reg<=0;

	end
	else
	begin
		state_reg	   <= state_next;
		buf_valid_reg  <= buf_valid_next;
	   sel_tr_reg	   <= sel_tr_next;
	   sel_br_reg	   <= sel_br_next;
	   sel_rc_reg	   <= sel_rc_next;
	   sel_lc_reg	   <= sel_lc_next;
	   u_cf_reg		   <= u_cf_next;
	   en_fn_reg	   <= en_fn_next;
		en_fn_sreg		<= en_fn_snext;
	   data_out_reg   <= data_in;
	   y_cnt_en_reg   <= y_cnt_en_next;
		x_cnt_en_reg   <= x_cnt_en_next;
		reset_cnt_reg<= reset_cnt_next;

	end
	
	
	// next state-logic:
	always@*
	begin
	// default settings:
	// state signals
	state_next     = state_reg;
	// row buffer signals
	buf_valid_next =1'b0;
	// coefficient file signals
	u_cf_next		=1'b0;
	// filter function signals
	en_fn_next		= 1'b0;
	en_fn_snext		= {en_fn_sreg[2:0],en_fn_reg};
	// x and y counters
	x_cnt_en_next   =1'b1;//x_cnt_en_next   =1'b0;
	y_cnt_en_next   =1'b0;
	reset_cnt_next=1'b0;
		case(state_reg)
		// IDLE state which go to either updating the coefficient file or the normal operation
		IDLE   : if (update_cf_sig)
						begin
							u_cf_next      = 1'b1;
							state_next     = UPDT_CF;
						end
				   else if (strm_pix_sig)
						begin
							buf_valid_next = 1'b1;
							state_next     = PRIMING;
							//x_cnt_en_next  = 1'b1;
						end
		// Update the coefficient file then go back to IDLE
		UPDT_CF : if (update_cf_sig)
							u_cf_next      = 1'b1;
					 else
							state_next     = IDLE;
		// priming the system (row buffers
		PRIMING  :  
		            begin
								buf_valid_next = 1'b1; // activate row buffer
							//x_cnt_en_next  = 1'b1; // activate row pixel counter
							if(x_cnt==ROW_WIDTH-2)    // next row condition
								 y_cnt_en_next = 1'b1;
							if( (y_cnt==2) && (x_cnt==ROW_WIDTH-2) ) // prime condition is met
							   begin
								  // reset counters to start the normal process and track the pixels
								 reset_cnt_next=1'b1; // w.r.t the pixel located athe end of the 3rd row buffer
								 state_next      =PROCESS;
								 //en_fn_next      =1'b1; // flag to enable the filter function output
								end
						end
		PROCESS	:  begin
								buf_valid_next = 1'b1; // activate row buffer
							//	x_cnt_en_next  = 1'b1; // activate row pix counter
								en_fn_next	= 1'b1; // flag to enable the filter function output
							if(x_cnt==ROW_WIDTH-2)	  // next row condition
								y_cnt_en_next = 1'b1;
							if (~strm_pix_sig)			// go to empty if pixels streaming stopped
								state_next= EMPTY;
						end
		EMPTY		:  begin
								en_fn_next    =1'b1;    // flag to enable filter function
								buf_valid_next=1'b1;    // activate row buffer
							//	x_cnt_en_next =1'b1;		// activate row pix counter
							if(x_cnt==ROW_WIDTH-2)     // next row condition
								y_cnt_en_next =1'b1;
						   if(max_tick_x && max_tick_y) // end of frame
								begin
									state_next= IDLE;
									en_fn_next    =1'b0;
								end
						end

						  
		
		endcase
	end
	
	
	//====================================================================
	// Border Policy control signals
	//====================================================================
	// column-basis
	always@*
	begin
	// default settings
	// border policy signals
	sel_rc_next		=2'b0;
	sel_lc_next		=1'b0;
	case(x_cnt)
		ROW_WIDTH-1 : sel_rc_next		=2'd1;							// -3 col
		0 				: sel_rc_next		=2'd2;							// -2 col
		1 				: sel_rc_next		=2'd3;							// -1 col
		2 				: sel_lc_next		=1'b1;							//  1 col
	endcase
	end
  //   row-basis
   always@*
	begin
	// default settings
	// border policy signals
	sel_br_next    =0;
	//sel_tr_next    =1'b0;
	sel_tr_next    =(max_tick_x && max_tick_y) || (rst_cnt);
	if (max_tick_x)
		case(y_cnt)
		COL_WIDTH-4 : sel_br_next		=2'd1;							// -3 row
		COL_WIDTH-3	: sel_br_next		=2'd2;							// -2 row
		COL_WIDTH-2 : sel_br_next		=2'd3;							// -1 row
	//	COL_WIDTH-1 : if ((state_reg== PROCESS)||(state_reg== EMPTY)) // 1 row during normal process
	//							sel_tr_next    =1'b1;
	//	2				: if ((state_reg== PRIMING)) // 1 row during priming
	//							sel_tr_next    =1'b1;
		endcase	
	else
		case(y_cnt)
		COL_WIDTH-3 : sel_br_next		=2'd1;							// -3 row
		COL_WIDTH-2	: sel_br_next		=2'd2;							// -2 row
		COL_WIDTH-1 : sel_br_next		=2'd3;							// -1 row
		0				: sel_tr_next		=1'b1;
		endcase
	end
	

	//===================================
	
	
	
	
	//===================================
	// Output logic:
	//===================================
	assign ctrl2buf_valid = buf_valid_reg;
	assign sel_top_row	 = sel_tr_reg;
	assign sel_btm_row    = sel_br_reg;
	assign sel_right_col  = sel_rc_reg;
	assign sel_left_col   = sel_lc_reg;
	assign update_cf		 = u_cf_reg;
	assign en_funct		 = en_fn_sreg[3];
	assign data_out       = data_out_reg;
	//===================================


endmodule
