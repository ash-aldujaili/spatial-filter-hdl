`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NTU
// Engineer: Abdullah Al-Dujaili
// 
// Create Date:    14:57:27 01/09/2013 
// Design Name: 
// Module Name:    six_2_three_compressor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module creates a 6:3 compressor, it generates 3 signals out of 6 signals
//					 that can be used with 2 dsp blocks to implement a 6-input adder.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module six_2_three_compressor
		#(  
			parameter WIDTH= 45
		 )
		 (	
			// clocking signal:
			input  wire clk,
			// input signals:
			input  wire [WIDTH-1:0] A_in,B_in,C_in,D_in,E_in,F_in,
			// output signals:
			output wire [WIDTH-1:0] X,Y,Z
		 );
		
		// Internal Signals declarations:
		reg [WIDTH-1:0] A,B,C,D,E,F;
		reg [WIDTH-1:0] X_reg,Y_reg,Z_reg,X_reg_o;
		wire [WIDTH-1:0] X_next,Y_next,Z_next;
		// GENERATE variable:
		genvar i;
		
		
		
		// Combinational Signal:
		//-----------------
		generate 
			for (i=0;i<WIDTH;i=i+1)
			begin : LOGIC_BLOCK
				assign X_next[i] = 		A[i] ^ B[i]  ^ C[i]  ^ D[i]  ^ E[i]  ^ F[i];
				assign Y_next[i] = 	  (A[i] & B[i]) ^ (A[i] & C[i]) ^ (A[i] & D[i]) ^ (A[i] & E[i]) ^ (A[i] & F[i]) ^ (B[i] & C[i])
											^ (B[i] & D[i]) ^ (B[i] & E[i]) ^ (B[i] & F[i]) ^ (C[i] & D[i]) ^ (C[i] & E[i]) ^ (C[i] & F[i])
											^ (D[i] & E[i]) ^ (D[i] & F[i]) ^ (E[i] & F[i]);
				assign Z_next[i] = 	  (A[i] & B[i] & C[i] & D[i]) | (A[i] & B[i] & C[i] & E[i]) | (A[i] & B[i] & C[i] & F[i]) | (A[i] & B[i] & D[i] & E[i])
											| (A[i] & B[i] & D[i] & F[i]) | (A[i] & B[i] & E[i] & F[i]) | (A[i] & C[i] & D[i] & E[i]) | (A[i] & C[i] & D[i] & F[i])
											| (A[i] & C[i] & E[i] & F[i]) | (A[i] & D[i] & E[i] & F[i]) | (B[i] & C[i] & D[i] & E[i]) | (B[i] & C[i] & D[i] & F[i])
											| (B[i] & C[i] & E[i] & F[i]) | (B[i] & D[i] & E[i] & F[i]) | (C[i] & D[i] & E[i] & F[i]);
			end
		endgenerate
		// Sequential Logic
		//-----------------
		always@(posedge clk)
			begin
				// registering inputs:
				A <= A_in;
				B <= B_in;
				C <= C_in;
				D <= D_in;
				E <= E_in;
				F <= F_in;
				// registering outputs:
				X_reg_o <= X_reg;
				X_reg <= X_next;
				Y_reg <= Y_next;
				Z_reg <= Z_next;
			end
		
		
		// Output circuit:
		//-----------------
		assign X = X_reg_o;
		assign Y = Y_reg;
		assign Z = Z_reg;

endmodule
