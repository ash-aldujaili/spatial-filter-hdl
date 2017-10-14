//------------------------------------------------------------------------------ 
// Copyright (c) 2004 Xilinx, Inc. 
// All Rights Reserved 
//------------------------------------------------------------------------------ 
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /   Vendor: Xilinx 
// \   \   \/    Author: Latha Pillai, Advanced Product Group, Xilinx, Inc.
//  \   \        Filename: abs48
//  /   /        Date Last Modified:  March 30, 2006 
// /___/   /\    Date Created: March 30, 2006
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

/**********************************************************************/


module dsp_adder24(AIN1, AIN2, BIN1, BIN2, CLK, RST, OUT1, OUT2);

input [23:0] AIN1, AIN2;
input [23:0] BIN1, BIN2;
input CLK;
input RST;
output [24:0] OUT1, OUT2;

wire [47:0] POUT_1;
wire [3:0]  CARRYOUT_1;
wire [24:0] OUT1_REG, OUT2_REG;

reg [23:0] AIN1_REG, AIN2_REG;
reg [23:0] BIN1_REG, BIN2_REG;
reg [24:0] OUT1, OUT2;


always @ (posedge CLK or posedge RST)
if (RST) 
begin
  AIN1_REG <= 24'b0; AIN2_REG <= 24'b0;
  BIN1_REG <= 24'b0; BIN2_REG <= 24'b0;

end
else 
begin
  AIN1_REG <= AIN1; AIN2_REG <= AIN2;
  BIN1_REG <= BIN1; BIN2_REG <= BIN2;
end

always @ (posedge CLK or posedge RST)
if (RST) 
begin
  OUT1 <= 25'b0; OUT2 <= 25'b0;
end
else 
begin
  OUT1 <= OUT1_REG; OUT2 <= OUT2_REG;
end

//
// Instantiation block 1
//

/*

.A_INPUT("DIRECT"),               // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
      .B_INPUT("DIRECT"),               // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
      .USE_DPORT("FALSE"),              // Select D port usage (TRUE or FALSE)
      .USE_MULT("MULTIPLY"),            // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
      // Pattern Detector Attributes: Pattern Detection Configuration
      .AUTORESET_PATDET("NO_RESET"),    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
      .MASK(48'h3fffffffffff),          // 48-bit mask value for pattern detect (1=ignore)
      .PATTERN(48'h000000000000),       // 48-bit pattern match for pattern detect
      .SEL_MASK("MASK"),                // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
      .SEL_PATTERN("PATTERN"),          // Select pattern value ("PATTERN" or "C")
      .USE_PATTERN_DETECT("NO_PATDET"), // Enable pattern detect ("PATDET" or "NO_PATDET")
      // Register Control Attributes: Pipeline Register Configuration
      .ACASCREG(1),                     // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
      .ADREG(1),                        // Number of pipeline stages for pre-adder (0 or 1)
      .ALUMODEREG(1),                   // Number of pipeline stages for ALUMODE (0 or 1)
      .AREG(1),                         // Number of pipeline stages for A (0, 1 or 2)
      .BCASCREG(1),                     // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
      .BREG(1),                         // Number of pipeline stages for B (0, 1 or 2)
      .CARRYINREG(1),                   // Number of pipeline stages for CARRYIN (0 or 1)
      .CARRYINSELREG(1),                // Number of pipeline stages for CARRYINSEL (0 or 1)
      .CREG(1),                         // Number of pipeline stages for C (0 or 1)
      .DREG(1),                         // Number of pipeline stages for D (0 or 1)
      .INMODEREG(1),                    // Number of pipeline stages for INMODE (0 or 1)
      .MREG(1),                         // Number of multiplier pipeline stages (0 or 1)
      .OPMODEREG(1),                    // Number of pipeline stages for OPMODE (0 or 1)
      .PREG(1),                         // Number of pipeline stages for P (0 or 1)
      .USE_SIMD("ONE48")                // SIMD selection ("ONE48", "TWO24", "FOUR12")
  */
DSP48E1 #(
   .ACASCREG(1),       
   .ALUMODEREG(1),     
   .AREG(1),           
   //.AUTORESET_PATTERN_DETECT("FALSE"), //DSP CHAGNE 1 AUTORESET_PATTERN_DETECT
   //.AUTORESET_PATTERN_DETECT_OPTINV("MATCH"), 
   .A_INPUT("DIRECT"), 
   .BCASCREG(1),       
   .BREG(1),           
   .B_INPUT("DIRECT"), 
   .CARRYINREG(0),     
   .CARRYINSELREG(0),  
   .CREG(1),           
   .MASK(48'h3FFFFFFFFFFF), 
   .MREG(0),           
   //.MULTCARRYINREG(0), 
   .OPMODEREG(0),      
   .PATTERN(48'h000000000000), 
   .PREG(1),           
   .SEL_MASK("MASK"),  
   .SEL_PATTERN("PATTERN"), 
   //.SEL_ROUNDING_MASK("SEL_MASK"),
   .USE_MULT("NONE"), 
   .USE_PATTERN_DETECT("NO_PATDET"), 
   .USE_SIMD("TWO24") 
) 
DSP48E_1 (
   .ACOUT(),   
   .BCOUT(),  
   .CARRYCASCOUT(), 
   .CARRYOUT(CARRYOUT_1), 
   .MULTSIGNOUT(), 
   .OVERFLOW(), 
   .P(POUT_1),          
   .PATTERNBDETECT(), 
   .PATTERNDETECT(), 
   .PCOUT(),  
   .UNDERFLOW(), 
   .A({AIN2_REG,AIN1_REG[23:18]}),          
   .ACIN(30'b0),    
   .ALUMODE(4'b0000), 
   .B({AIN1_REG[17:0]}),          
   .BCIN(18'b0),    
   .C({BIN2_REG,BIN1_REG}),          
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
   .CEM(1'b0),       
   //DSP1 change.CEMULTCARRYIN(1'b0),
   .CEP(1'b1),       
   .CLK(CLK),       
   .MULTSIGNIN(1'b0), 
   .OPMODE(7'b0110011), 
   .PCIN(48'b0),      
   .RSTA(RST),     
   .RSTALLCARRYIN(RST), 
   .RSTALUMODE(RST), 
   .RSTB(RST),     
   .RSTC(RST),     
   .RSTCTRL(RST), 
   .RSTM(RST), 
   .RSTP(RST) 
);

// End of DSP48E_1 instantiation


assign OUT1_REG = {CARRYOUT_1[1], POUT_1[23:0]};
assign OUT2_REG = {CARRYOUT_1[3], POUT_1[47:24]};


endmodule



