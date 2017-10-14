`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:05:35 01/08/2013 
// Design Name: 
// Module Name:    filter_function_fabric 
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
/*
This module implements a 7*7 filter function, it's
implemented explicitly for a 7*7 usign an adder tree
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
*/

module filter_function_fabric
  
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
	  wire signed [PIX_BIT+COFCNT_BIT:0]   term 			[0:TERM_SIZE-1]; // products of p*c
	 
	  //============================================================
	  wire [42:0]						  term_temp 	[0:TERM_SIZE-1]; // actual prodcut from DSP Block
	  // addition-related signals:
	  wire signed [PIX_BIT+COFCNT_BIT+1  :0] reduced_term [0:RED_TRM_SZ-1];// reduced products into two (summing pairs of the product)
	  reg  signed [PIX_BIT+COFCNT_BIT+1  :0] reduced_term_reg [0:RED_TRM_SZ-1];
	  wire signed [47:0]                     addened [0:RED_TRM_SZ-1][5:0]; // adder tree signal till //5 =LOG2(RED_TRM_SZ)
	  reg  signed [47:0]                     addened_reg [0:RED_TRM_SZ-1][5:0];
	  // Leftover term pipeline
	  reg  [(PIX_BIT+COFCNT_BIT+1)*4-1:0]		lftovr_pipe_reg ;//0:15
	  reg	 [(PIX_BIT+COFCNT_BIT+1)*4-1:0]		lftovr_pipe_next;//0:15
	  reg  [11:0]  ready_reg,ready_next; // 2 additional stages for the pipe
	  //  circuit
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
	  //Addition tree: this was implemented for 49-tap specfically:
	  //==========================================================
	 
	 
		// renaming signal (packing term signal):
		//-----------------
		localparam PK_LEN= TERM_SIZE,
					  PK_WIDTH= PIX_BIT+COFCNT_BIT+1;
		genvar pk_idx;
		 wire signed [(PIX_BIT+COFCNT_BIT+1)*TERM_SIZE-1:0]   term_in;
			generate 
				for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) 
				begin:PACKING
					assign term_in[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = term[pk_idx][((PK_WIDTH)-1):0];
				end
		endgenerate
		//----------
		// pipe registers :
		 // Set of registers to separate multipliers and adders:
	  reg  signed [(PIX_BIT+COFCNT_BIT+1)*TERM_SIZE-1:0]   term_in_pipe1 ;
	  reg  signed[(PIX_BIT+COFCNT_BIT+1)*TERM_SIZE-1:0]    term_in_pipe2	;
		
		always@(posedge clk)
			begin
				term_in_pipe1 <= term_in;
				term_in_pipe2 <= term_in_pipe1;	
			end
		//////////////////////////
		
		adder_tree_LOG
		#(.PIX_BIT(PIX_BIT),
        .MASK_WIDTH(MASK_WIDTH),
        .COFCNT_BIT(COFCNT_BIT)
		)
			adder_tree_LOG_u
		(
		.clk(clk),.reset(),
		.term_in(term_in_pipe2), // products of p*c
	  
		.q(q) // signed filter output sign+ 8 bit
		
		);


	 //==========================================================
	 /* 
	  // reduced products using single dsp block for two additions
	  //==========================================================
	  genvar j;
	  generate 
			for(j=0;j<RED_TRM_SZ;j=j+2)
			//begin: REDUCED_TERMS
			//	dsp_adder24 add_two(.AIN1(term[2*j]), .AIN2(term[2*(j+1)]), .BIN1(term[2*j+1]), .BIN2(term[2*(j+1)+1]), .CLK(clk), //.RST(reset), 
			//		.OUT1(reduced_term[j]), .OUT2(reduced_term[j+1]));
			//end
			begin: REDUCED_TERMS
				always@(posedge clk)
					begin
						reduced_term_reg[j]	= reduced_term[j];
						reduced_term_reg[j+1]= reduced_term[j+1];
					end
				assign reduced_term[j]	 = term[2*j]		+ term[2*j+1];
				assign reduced_term[j+1] = term[2*(j+1)]	+ term[2*(j+1)+1];
			end
	  endgenerate
	  //==========================================================
	  
	  */
	  // If odd number of TERM_SIE, the left term should be piplined all the way along with the signals
	  //==========================================================
	  //  seqeuntial circuit for pipe line along with the ready signal
	  always@(posedge clk)
			if(reset)
					begin
					// odd element left over from the adder tree
					//lftovr_pipe_reg<=0;
					ready_reg      <=0;
					end
			else
					begin
					// odd element left over from the adder tree
					//lftovr_pipe_reg<=lftovr_pipe_next;
					ready_reg      <=ready_next;
					end
		
	  //next_stage logic for pipe line
	 // always@(term[TERM_SIZE-1],enable,ready_reg,lftovr_pipe_reg)
	  always@(enable,ready_reg)
	  begin
		//			lftovr_pipe_next[0]=term[TERM_SIZE-1];
		//			for(pipe_stage=1;pipe_stage<16;pipe_stage=pipe_stage+1)
		//			lftovr_pipe_next[pipe_stage]=lftovr_pipe_reg[pipe_stage-1];
	//		lftovr_pipe_next={lftovr_pipe_reg[(PIX_BIT+COFCNT_BIT+1)*3-1:0],term[TERM_SIZE-1]};
			ready_next		 ={ready_reg[10:0],enable};
	  end
	 /*
	 // 2nd stage of adder tree signals renaming (5 in array index-descending)
	  //==========================================================
	  generate
			for(i=0;i<RED_TRM_SZ;i=i+1)
				begin: SIG_RENAME
				assign addened[i][5]=$signed({{(46-PIX_BIT-COFCNT_BIT){reduced_term_reg[i][PIX_BIT+COFCNT_BIT+1]}},reduced_term_reg[i]}); //5=LOG2(RED_TRM_SZ)
				end
	  endgenerate
	  //==========================================================
	  
	  //Other stages of the adder down to 2 as the array elements are not a power of two
	  //========================================================== 
	  generate
			for(j=5-1;j>=2;j=j-1) //j=LOG2(RED_TRM_SZ)
			begin: ADDER_STAGE_OUTER
				for(i=0;i<(RED_TRM_SZ/(2**(5-j)));i=i+1) //**(LOG2(RED_TRM_SZ)-j
				begin: ADDER_STAGE_INNER
					always@(posedge clk)
						begin
							addened_reg[i][j]	<= addened [i][j];
						end
					if (j==4)
						begin
							//dsp_adder48 adder_tree(.AIN1(addened[2*i][j+1]), .BIN1(addened[2*i+1][j+1]), .CLK(clk),  .OUT1(addened[i][j]));//.RST(reset),
							assign addened[i][j] =	addened[2*i][j+1] + addened[2*i+1][j+1];
						end
					else
						begin
							assign addened[i][j] =	addened_reg[2*i][j+1] + addened_reg[2*i+1][j+1];
						end
				end// adder stage inner
			
			end // adder stage outer
	  endgenerate
	  
	  assign addened[3][2]=$signed({{(47-PIX_BIT-COFCNT_BIT){lftovr_pipe_reg[4*(PIX_BIT+COFCNT_BIT+1)-1]}},lftovr_pipe_reg[4*(PIX_BIT+COFCNT_BIT+1)-1:3*(PIX_BIT+COFCNT_BIT+1)]});
	  
	  //Left over of the adder tree stage 1 to 0 ( the odd leftover from term to be included)
	  generate
			for(j=1;j>=0;j=j-1)
			begin: LEFT_OVER_OUTER
				for(i=0;i<2**j;i=i+1)
				begin: LEFT_OVER_INNER
					//dsp_adder48 adder_tree_(.AIN1(addened[2*i][j+1]), .BIN1(addened[2*i+1][j+1]), .CLK(clk),  .OUT1(addened[i][j]));//.RST(reset),
					always@(posedge clk)
						begin
							addened_reg [i][j] <= addened [i][j];
						end
					if (j==1 && i==1)
						begin
							assign addened[i][j] = addened_reg[2*i][j+1] + addened[2*i+1][j+1];
						end
					else
						begin
							assign addened[i][j] = addened_reg[2*i][j+1] + addened_reg[2*i+1][j+1];
						end
				end // left over inner
			end// left over outer
	  endgenerate
	 */ 
	  // output logic
	  //assign q		= {addened_reg[0][0][PIX_BIT+15:15]}; //14 in case of averaging .. 15 in case of edge .. 14 is the 1st decimal bit. {addened[0][0][47],addened[0][0][PIX_BIT+13:14]}; 
	  assign ready	= ready_reg[11];
	  
	  
	  
   endmodule
   
