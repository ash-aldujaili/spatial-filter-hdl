/*
This module implements a 7*7 filter function, it's
implemented explicitly for a 7*7 usign a cascaded tree
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
*/
`include "array_pack_unpack.v"

module filter_function_cas
  
  #(parameter PIX_BIT=8,
              MASK_WIDTH=7,
              COFCNT_BIT=15
    )
    (
      input  wire clk,reset_in,enable, // clk and control signals for pipelining
      input  wire [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c, // coefficients
      input  wire [PIX_BIT   *(MASK_WIDTH**2)-1:0] p, // input pixels
      output wire [PIX_BIT:0] q, // signed filter output sign+ 8 bit
      output wire ready
      );
      
		
	  ////////////////////////////////////////////////////////////////////
	  //function that evaluates log2
	 /* function integer LOG2 (input integer n);
				integer i;
	  begin
			LOG2=1;
			for (i=0; 2**i<n;i=i+1)
				LOG2=i+1;
		end
		endfunction*/
	  ////////////////////////////////////////////////////////////////////
	  // local parameters to establish signals width
	  localparam TERM_SIZE =(MASK_WIDTH**2), // Number of terms (p*c)
					 RED_TRM_SZ= TERM_SIZE/2;	  // Number of reduced terms
     // Signal Declarations
	  // mutliplier-related signals:
	  wire [PIX_BIT+COFCNT_BIT:0]   term 			[0:TERM_SIZE-1]; // products of p*c
	  wire [42:0]						  term_temp 	[0:TERM_SIZE-1]; // actual prodcut from DSP Block
	  // addition-related signals:
	  wire [47:0] add_a [0:47];
	  wire [47:0] add_b [0:47];
	  wire [47:0] a_p_b [0:47];
	  wire [(4*(PIX_BIT+COFCNT_BIT+1)*(TERM_SIZE-2))-1:0]   buff_term    		[0:TERM_SIZE-3]; // 4 for the buffering delay
	  reg  [(4*(PIX_BIT+COFCNT_BIT+1)*(TERM_SIZE-2))-1:0]   buff_term_reg    	[0:TERM_SIZE-3]; 
	  reg  [(4*(PIX_BIT+COFCNT_BIT+1)*(TERM_SIZE-2))-1:0]   buff_term_next     [0:TERM_SIZE-3]; 
	  reg  [194:0]  ready_reg,ready_next; // ready flag 
	  //  reset circuit
	  reg reset_reg,reset_next;
	  wire reset= reset_reg;
	  //==========================================================
	  
	  //===========
	  // Registering Cofficients:
	  //============
	  reg [COFCNT_BIT*(MASK_WIDTH**2)-1:0] c_reg,c_next;
	  
	  always@(posedge clk)
			c_reg<=c_next;
	  always@*
			c_next=c;
	  //====================
	  
	  
	  //==========================================================
	  // Multiplier stage:
	  //==========================================================
	  //==========================================================
	  genvar i;
	  generate
		  for (i=0;i<TERM_SIZE;i=i+1)
		   begin: MULT_STAGE
				mult25x18_parallel_pipe mult(.CLK(clk),  .A_IN({1'b0,p[PIX_BIT*(i+1)-1:PIX_BIT*i],{(24-PIX_BIT){1'b0}}}), .B_IN({c_reg[COFCNT_BIT*(i+1)-1:COFCNT_BIT*i],{(18-COFCNT_BIT){1'b0}}}), .PROD_OUT(term_temp[i]));//.RST(reset),
				assign term[i]=term_temp[i][42:19];
			end
	  endgenerate
	  //==========================================================
	  //==========================================================
	  //==========================================================
	  //==========================================================
	  
	  //==========================================================
	  // Reset Circuit
	  //==========================================================
	  always@(posedge clk)
			reset_reg <= reset_next;
		
	  always@*
			reset_next = reset_in;
			
	  
	  //==========================================================
	  //==========================================================
	  //Cascaded Addition: this was implemented for 49-tap specfically:
	  //==========================================================
	  //==========================================================
	  
	  // buffers for the cascaded adders:
	  generate
			for (i=0;i<TERM_SIZE-2;i=i+1)
					begin : cascade_buffering
						always@(posedge clk)
								  buff_term_reg [i][(4*(PIX_BIT+COFCNT_BIT+1)*(i+1))-1:0]<= buff_term_next[i][(4*(PIX_BIT+COFCNT_BIT+1)*(i+1))-1:0];
						always@*
								  buff_term_next[i][(4*(PIX_BIT+COFCNT_BIT+1)*(i+1))-1:0]= {term[i+2],buff_term_reg[i][(4*(PIX_BIT+COFCNT_BIT+1)*(i+1))-1:PIX_BIT+COFCNT_BIT+1]};
						assign  buff_term		 [i][(4*(PIX_BIT+COFCNT_BIT+1)*(i+1))-1:0] = buff_term_reg[i][(4*(PIX_BIT+COFCNT_BIT+1)*(i+1))-1:0]; // here !
					end
		endgenerate
					
						
						
			
	  
	  //single addition/
	  //==========================================================
	  genvar j;
	  generate 
			for(j=0;j<TERM_SIZE-1;j=j+1)
			begin: cascade_addition
				if(j==0)
				  begin
					assign add_a[j]= {{(47-PIX_BIT-COFCNT_BIT){term[j][PIX_BIT+COFCNT_BIT]}},term[j]};
					assign add_b[j]= {{(47-PIX_BIT-COFCNT_BIT){term[j+1][PIX_BIT+COFCNT_BIT]}},term[j+1]};
				  end
				else
				  begin
					assign add_a[j]= a_p_b[j-1];
					assign add_b[j]= {{(47-PIX_BIT-COFCNT_BIT){buff_term[j-1][PIX_BIT+COFCNT_BIT]}},buff_term[j-1][PIX_BIT+COFCNT_BIT:0]};
				  end
				dsp_adder48 add_cascade(.AIN1(add_a[j]), .BIN1(add_b[j]), .CLK(clk),  .OUT1(a_p_b[j]));
			end
	  endgenerate
	  //==========================================================
	  
	  
	  // If odd number of TERM_SIE, the left term should be piplined all the way along with the signals
	  //==========================================================
	  //  seqeuntial circuit for pipe line along with the ready signal
	  always@(posedge clk)
		/*	if(reset)
					begin
					ready_reg      <=0;
					end
			else*/
					begin
					ready_reg      <=ready_next;
					end
		
	  //next_stage logic for pipe line
	  always@(enable,ready_reg,reset)
	  begin
			ready_next		 = (reset)? 195'd0:{ready_reg[193:0],enable};
	  end
	  /////////////////////////////////////////////////////////////////////////////////////////////////////
	  
	  // output logic
	  assign q		= {a_p_b[47][PIX_BIT+15:15]}; // 14 is the 1st dec. 14 in case of averaging .. 15 in case of edge .. 14 is the 1st decimal bit. {a_p_b[47][47],a_p_b[47][PIX_BIT+13:14]};
	  assign ready	= ready_reg[194];
	  
	  
	  
   endmodule
   