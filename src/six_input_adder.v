`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NTU
// Engineer: Abdullah Al-Dujaili	
// 
// Create Date:    16:22:24 01/09/2013 
// Design Name: 
// Module Name:    six_input_adder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This circuit performs 6-input adder, it makes use of a 6:3 compressor
//              and two serial dsp blocks

//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module six_input_adder
	 #( parameter WIDTH_IN=45, // input bit width
					  WIDTH_OUT=48 // output bit width
	 )
	 (
		input wire clk, reset, // clock and reset siganls
		input wire [WIDTH_IN-1:0] A,B,C,D,E,F,
		output wire [WIDTH_OUT-1:0] SUM
	 );

		// Internal Signals declaration:
		wire [47:0] AIN0,BIN0,AIN1,BIN1;	
		wire [48:0] OUT0,OUT1;
		wire [WIDTH_IN-1:0] X,Y,Z;
		
		//Body (structural model):
		//========================
		
		//1. 6:3 compressor unit:------------------
		six_2_three_compressor
		#(  
		  .WIDTH(WIDTH_IN)
		 ) 
		 six_2_three_com_ut
		 ( 
		   // clocking:
			.clk(clk),
			// input
			.A_in(A),.B_in(B),.C_in(C),.D_in(D),.E_in(E),.F_in(F),
			// output
			.X(X),.Y(Y),.Z(Z)
		 );
		 //-----------------------------------------
		 
		 //2. 2 serial DSP slices------------------------
		 // Signal renaming and shifiting:
		 assign AIN0 = {{(46-WIDTH_IN){Z[WIDTH_IN-1]}},Z,2'd0};
		 assign BIN0 = {{(47-WIDTH_IN){Y[WIDTH_IN-1]}},Y,1'd0};
		 assign BIN1 =  OUT0[47:0];
		 assign AIN1 = {{(48-WIDTH_IN){X[WIDTH_IN-1]}},X};
		 // instantiate adders
		 first_stage_adder frst_stg_adder_ut  (.AIN1(AIN0), .BIN1(BIN0), .CLK(clk), .RST(reset), .OUT1(OUT0));
		 second_stage_adder sec_stg_adder_ut  (.AIN1(AIN1), .BIN1(BIN1), .CLK(clk), .RST(reset), .OUT1(OUT1));
		 //-------------------------------------------------------------------------------------------
		 
		
		
		
		 //Output:
		 assign SUM=OUT1[WIDTH_OUT-1:0];
		
		
		
		
		
endmodule
