//------------------------------------------------------------------------------ 
// Copyright (c) 2004 Xilinx, Inc. 
// All Rights Reserved 
//------------------------------------------------------------------------------ 
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Author: Latha Pillai, Advanced Product Group, Xilinx, Inc.
//  \   \        Filename: MULT25X18_PARALLEL_PIPE 
//  /   /        Date Last Modified:  OCTOBER 05, 2004 
// /___/   /\    Date Created: OCTOBER 05, 2004 
// \   \  /  \ 
//  \___\/\___\ 
// 
//
// Revision History: 
// $Log: $
//------------------------------------------------------------------------------ 
//
//     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
//     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR
//     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION
//     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION
//     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS
//     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
//     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
//     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
//     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
//     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
//     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//     FOR A PARTICULAR PURPOSE.
//
//------------------------------------------------------------------------------ 
//
// Module: mult 18x25 and a cascaded adder
//
// Description: Verilog instantiation template for 
// DSP48 embedded MAC blocks arranged as a pipelined
// 18 x 18 parallel multiplier. The macro uses 1 DSP
// slice. This is the biggest multiplier that can be 
// made using 1 slice.
//
// Device: Whitney Family
//
// Copyright (c) 2000 Xilinx, Inc.  All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////////
//


module mult_add_cascade #(parameter CONFIG_DSP =1)(CLK, RST, A_IN, B_IN, C_IN,RESULT_OUT);
// the parameter CONFIG_DSP configures the dsp block to route the signals according to the mode of operation
// whether its' a cascaded addition mode or connected to non-dsp blocks	
input           CLK, RST;
input   [24:0]  A_IN;
input   [17:0]  B_IN;
input   [47:0]  C_IN;
output  [47:0]  RESULT_OUT;

// output signals
wire[47:0] P1_OUT_CAS; // pcout
wire[47:0] P1_OUT;	  // p
// op mode	
wire[6:0]  OP_MODE;
// input signals for c and pcin
wire [47:0]  C;
wire [47:0]  PCIN;
//
////////////////////////////////////////////////////////////////////////////////////

generate
	if (CONFIG_DSP==1) // connected to dsp blocks both sides ( OTHER DSPS -- DSP -- OTHER DSPS)
		begin
			//output
			assign RESULT_OUT = P1_OUT_CAS;
			//input
			assign C= 48'b0;
			assign PCIN= C_IN;
			//opmode
			assign OP_MODE =7'b0010101;
		end
	else if (CONFIG_DSP==2) // connected to dsp block from input ( OTHER DSPS -- DSP -- ROW_BUFFER)
		begin
			//output
			assign RESULT_OUT = P1_OUT;
			//input
			assign C= 48'b0;
			assign PCIN= C_IN;
			//opmode
			assign OP_MODE =7'b0010101;
		end
	else	// connected from output ( ROW BUFFER -- DSP -- OTHER DSPS)
		begin
			//output
			assign RESULT_OUT = P1_OUT_CAS;
			//input
			assign C= C_IN;
			assign PCIN= 48'b0;
			//opmode
			assign OP_MODE =7'b0110101;
		end
endgenerate

//
// Instantiation block 1
//

DSP48E #(
   .ACASCREG(1),       
   .ALUMODEREG(1),     
   .AREG(1),           
   .AUTORESET_PATTERN_DETECT("FALSE"), 
   .AUTORESET_PATTERN_DETECT_OPTINV("MATCH"), 
   .A_INPUT("DIRECT"), 
   .BCASCREG(1),       
   .BREG(1),           
   .B_INPUT("DIRECT"), 
   .CARRYINREG(0),     
   .CARRYINSELREG(1),  
   .CREG(0),           
   .MASK(48'h3FFFFFFFFFFF), 
   .MREG(1),           
   .MULTCARRYINREG(0), 
   .OPMODEREG(0),      
   .PATTERN(48'h000000000000), 
   .PREG(1),           
   .SEL_MASK("MASK"),  
   .SEL_PATTERN("PATTERN"), 
   .SEL_ROUNDING_MASK("SEL_MASK"), 
   .USE_MULT("MULT_S"), 
   .USE_PATTERN_DETECT("NO_PATDET"), 
   .USE_SIMD("ONE48") 
) 
DSP48E_1 (
   .ACOUT(),   
   .BCOUT(),  
   .CARRYCASCOUT(), 
   .CARRYOUT(), 
   .MULTSIGNOUT(), 
   .OVERFLOW(), 
   .P(P1_OUT),          
   .PATTERNBDETECT(), 
   .PATTERNDETECT(), 
   .PCOUT(P1_OUT_CAS), 
   .UNDERFLOW(), 
   .A({5'b0,A_IN}),          
   .ACIN(30'b0),    
   .ALUMODE(4'b0000), 
   .B(B_IN),          
   .BCIN(18'b0),    
   .C(C),          
   .CARRYCASCIN(1'b0), 
   .CARRYIN(1'b0), 
   .CARRYINSEL(3'b0), 
   .CEA1(1'b0),      
   .CEA2(1'b1),      
   .CEALUMODE(1'b1), 
   .CEB1(1'b0),      
   .CEB2(1'b1),      
   .CEC(1'b1),      
   .CECARRYIN(1'b0), 
   .CECTRL(1'b1), 
   .CEM(1'b1),       
   .CEMULTCARRYIN(1'b0),
   .CEP(1'b1),       
   .CLK(CLK),       
   .MULTSIGNIN(1'b0), 
   .OPMODE(OP_MODE), 
   .PCIN(PCIN),      
   .RSTA(RST),     
   .RSTALLCARRYIN(RST), 
   .RSTALUMODE(RST), 
   .RSTB(RST),     
   .RSTC(RST),     
   .RSTCTRL(RST), 
   .RSTM(RST), 
   .RSTP(RST) 
);

// End of DSP48_1 instantiation 




endmodule






