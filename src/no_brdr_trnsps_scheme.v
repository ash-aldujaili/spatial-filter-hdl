/*
This module implements the filter window,mask, in addition to the row buffers using no border
policy with a transposed filter form 
........................
By: Abdullah Al-Dujaili
    NTU, 2012
.......................
Importantn note :=============================
This filter mask is designed espeically for 7*7 filter mask
as there are multiplexers that are difficult to make them parameterize for the time being
*/

module no_brdr_trnsps_scheme
	  #(parameter ROW_WIDTH=93, // changed for the image size 
					PIX_BIT=8,
              MASK_WIDTH=7,
              COFCNT_BIT=15,	
				  WIDTH_IN=45,		// for dsp block
				  WIDTH_OUT=48, // for dsp block
				  ROW_LATENCY=3, 		// Each row latency (window)*(dsp latency + other reg)
				  ROW_BUFFER_BIT=30  //row buffer bit width (stores the result of partial DSP ops
    )
    (
      input  wire clk,reset_in,enable,data_valid, // clk and control signals for pipelining
      input  wire [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c, // coefficients
      input  wire [PIX_BIT-1:0] pix_ine, // input pixels
      output wire [PIX_BIT:0] q, // signed filter output sign+ 8 bit
      output wire ready
      );
	 

		// Signals:
		//-----------------------
		// Row buffers:
		reg [ROW_BUFFER_BIT*ROW_WIDTH-1:0] rbuffer0_reg,rbuffer1_reg,rbuffer2_reg,rbuffer3_reg,rbuffer4_reg,rbuffer5_reg;
		reg [ROW_BUFFER_BIT*ROW_WIDTH-1:0] rbuffer0_next,rbuffer1_next,rbuffer2_next,rbuffer3_next,rbuffer4_next,rbuffer5_next;
		wire [ROW_BUFFER_BIT-1:0] rbuffer0_in,rbuffer1_in,rbuffer2_in,rbuffer3_in,rbuffer4_in,rbuffer5_in;
		// Clock divider circuit signals:
		//wire max_tick;
		// metadata variable for generating the computational units
		genvar i;
		// PE
		wire [47:0] result_out [0:MASK_WIDTH**2-1];
		wire [47:0] add_in	  [0:MASK_WIDTH**2-1];
		reg [ROW_LATENCY-1:0] ready_reg,ready_next;
		
		// simulation
		wire [PIX_BIT-1:0] pix_in ;//
		//reg [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c_reg,c_next;
		//----------------------------------------
		
		
		
		//BODY:===
		//===========================================
		
		
		// Clock divider signal for row buffer:
		//counter #(.CNT_BIT(CNT_BIT),.CNT_MOD(ROW_LATENCY))
		//	clk_div(.clk(clk),.reset(reset_in),.enable(enable),.max_tick(max_tick));
		//---------------------------------------------------------------------------	
		
		
		//===========
	  // Registering Cofficients:
	  //============
	  reg [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c_reg,c_next; //reg
	  ///*
	  always@(posedge clk)
			c_reg<=c_next;
	  always@*
			c_next=c;
		//*/	
		// Simulation only
		
		//assign	c_reg={49{15'd2}};
		assign	pix_in=pix_ine;
		/*
		always@*
			case(data_valid)
			1'd0: begin
					//c_reg={49{15'd0}};
					pix_in=8'bzzzzzzzz;
					end
			default: begin
					//c_reg={49{15'd2}};
					pix_in=pix_ine;//8'd2;//pix_ine;
						end
			endcase
		*/
		//	end
	  //====================
		
		//-------------------------------------------------------------------------
		// Sequential Circuit for row buffers
		always@(posedge clk)
			begin
				rbuffer0_reg <= rbuffer0_next;
				rbuffer1_reg <= rbuffer1_next;
				rbuffer2_reg <= rbuffer2_next;
				rbuffer3_reg <= rbuffer3_next;
				rbuffer4_reg <= rbuffer4_next;
				rbuffer5_reg <= rbuffer5_next;
			end
		//----
		// Next-state circuit for row buffer
		always@*
			//begin
			//default
			//rbuffer0_next = rbuffer0_reg;
			//rbuffer1_next = rbuffer1_reg;
			//rbuffer2_next = rbuffer2_reg;
			//rbuffer3_next = rbuffer3_reg;
			//rbuffer4_next = rbuffer4_reg;
			//rbuffer5_next = rbuffer5_reg;
			//if ( max_tick )
				begin
					rbuffer0_next = {rbuffer0_in,rbuffer0_reg[ROW_BUFFER_BIT*ROW_WIDTH-1:ROW_BUFFER_BIT]};
					rbuffer1_next = {rbuffer1_in,rbuffer1_reg[ROW_BUFFER_BIT*ROW_WIDTH-1:ROW_BUFFER_BIT]};
					rbuffer2_next = {rbuffer2_in,rbuffer2_reg[ROW_BUFFER_BIT*ROW_WIDTH-1:ROW_BUFFER_BIT]};
					rbuffer3_next = {rbuffer3_in,rbuffer3_reg[ROW_BUFFER_BIT*ROW_WIDTH-1:ROW_BUFFER_BIT]};
					rbuffer4_next = {rbuffer4_in,rbuffer4_reg[ROW_BUFFER_BIT*ROW_WIDTH-1:ROW_BUFFER_BIT]};
					rbuffer5_next = {rbuffer5_in,rbuffer5_reg[ROW_BUFFER_BIT*ROW_WIDTH-1:ROW_BUFFER_BIT]};
				end
			//end
		// Inputs of the row buffers
		assign rbuffer0_in= result_out[6] [ROW_BUFFER_BIT-1:0];	
		assign rbuffer1_in= result_out[13][ROW_BUFFER_BIT-1:0];	
		assign rbuffer2_in= result_out[20][ROW_BUFFER_BIT-1:0];
		assign rbuffer3_in= result_out[27][ROW_BUFFER_BIT-1:0];
		assign rbuffer4_in= result_out[34][ROW_BUFFER_BIT-1:0];
		assign rbuffer5_in= result_out[41][ROW_BUFFER_BIT-1:0];
		//-------------------------------------------------------------------------
		
		// Computational Unit: (transposed form of 2D filter)
		
		generate 
			for (i=0;i<MASK_WIDTH**2;i=i+1)
			begin : PROCE_ELE
				// Inputs of the PEs
				// buffers interfaced
				if (i==0)
					assign add_in[i]=0;
				else if (i==7)
					assign add_in[i]={{(48-ROW_BUFFER_BIT){rbuffer0_reg[ROW_BUFFER_BIT-1]}},rbuffer0_reg[ROW_BUFFER_BIT-1:0]};
				else if (i==14)
					assign add_in[i]={{(48-ROW_BUFFER_BIT){rbuffer1_reg[ROW_BUFFER_BIT-1]}},rbuffer1_reg[ROW_BUFFER_BIT-1:0]};
				else if (i==21)
					assign add_in[i]={{(48-ROW_BUFFER_BIT){rbuffer2_reg[ROW_BUFFER_BIT-1]}},rbuffer2_reg[ROW_BUFFER_BIT-1:0]};
				else if (i==28)
					assign add_in[i]={{(48-ROW_BUFFER_BIT){rbuffer3_reg[ROW_BUFFER_BIT-1]}},rbuffer3_reg[ROW_BUFFER_BIT-1:0]};
				else if (i==35)
					assign add_in[i]={{(48-ROW_BUFFER_BIT){rbuffer4_reg[ROW_BUFFER_BIT-1]}},rbuffer4_reg[ROW_BUFFER_BIT-1:0]};
				else if (i==42)
					assign add_in[i]={{(48-ROW_BUFFER_BIT){rbuffer5_reg[ROW_BUFFER_BIT-1]}},rbuffer5_reg[ROW_BUFFER_BIT-1:0]};
				// other PE
				else
					assign add_in[i]=result_out[i-1];
				
				if (i%7 == 0 ) // interfaced with the buffers from inputs
					mult_add_cascade #(.CONFIG_DSP(3))mult_add_u (
					.CLK(clk), 
					.RST(reset_in), 
					.A_IN({{(24-PIX_BIT){1'b0}},{1'b0,pix_in}}), 
					.B_IN({{(18-COFCNT_BIT){c_reg[COFCNT_BIT*(i+1)-1]}},c_reg[COFCNT_BIT*(i+1)-1:COFCNT_BIT*i]}), 
					.C_IN(add_in[i]), 
					.RESULT_OUT(result_out[i])
					);
				else if (i%7==6) // interfaced with buffers from outputs
					mult_add_cascade #(.CONFIG_DSP(2))mult_add_u (
					.CLK(clk), 
					.RST(reset_in), 
					.A_IN({{(24-PIX_BIT){1'b0}},{1'b0,pix_in}}), 
					.B_IN({{(18-COFCNT_BIT){c_reg[COFCNT_BIT*(i+1)-1]}},c_reg[COFCNT_BIT*(i+1)-1:COFCNT_BIT*i]}), 
					.C_IN(add_in[i]), 
					.RESULT_OUT(result_out[i])
					);
				else
					mult_add_cascade #(.CONFIG_DSP(1))mult_add_u (
					.CLK(clk), 
					.RST(reset_in), 
					.A_IN({{(24-PIX_BIT){1'b0}},{1'b0,pix_in}}), 
					.B_IN({{(18-COFCNT_BIT){c_reg[COFCNT_BIT*(i+1)-1]}},c_reg[COFCNT_BIT*(i+1)-1:COFCNT_BIT*i]}), 
					.C_IN(add_in[i]), 
					.RESULT_OUT(result_out[i])
					);
				
			end
		endgenerate
		
		//===============================================================
		// Ready Circuit
		// Sequential Circuit:
		always@(posedge clk)
			if (reset_in)
				ready_reg <= 0;
			else
				ready_reg <= ready_next;
		
		always@*
			ready_next= {ready_reg[ROW_LATENCY-2:0],enable};
		//===============================================================
		

		// output logic
	  assign q		= {result_out[48][PIX_BIT+15:15]}; //14 in case of averaging .. 15 in case of edge .. 14 is the 1st decimal bit. {addened[0][0][47],addened[0][0][PIX_BIT+13:14]}; 
	  assign ready	= ready_reg[ROW_LATENCY-1];
	
endmodule 