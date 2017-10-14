/*
This module implements a window operator
to be used in an window-based image filter scheme
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
The window operator simplys acquires N*N pixels out of 
an image and repecitively convolve them with a maks of
a certain feature to obtain a desired results.
The cofficients of the filter determines the operation.
Here I mapped the coefficinets of a certain mask into a mathemitcal 
hardware circuit
*/

module window_operator
  #
  (
    parameter PIX_BIT=8 ,
              MASK_WIDTH=3
  )
  (
    input wire clk,reset, // clk and asynchronous reset
    input wire [PIX_BIT*(MASK_WIDTH**2)-1:0] pixs_in , // pixels encompassed by the mask
    input wire pixs_in_valid,  // indicates input pixels are valid
    output wire [PIX_BIT-1:0] pix_out, // resulting pixel
    output wire pix_out_valid
  );
        
            
  // Signal Declaration
  reg [PIX_BIT-1:0] pix_out_reg,pix_out_next;
  reg pix_out_valid_reg,pix_out_valid_next;
  // Mask-related Signals for 3*3 filter specifically parameterized to be consider later
  wire [PIX_BIT:0] sum00,sum01,sum02,sum03; // First Stage (p0+p1)(p2+p3)(p5+p6)(p7+p8)
  wire [PIX_BIT+1:0] sum10,sum11;           // Second Stage
  wire [PIX_BIT+2:0] sum20,sum21;           // 3rd Stage 
  wire comp_flag; // comparator flag between sum20 and 21
  wire [PIX_BIT+2:0] a,b,c; // parameters of the final equation c= abs(sum surroinding pix- 8*cener pix)
  
  // Body:
  // Sequential Logic:
  always@(posedge clk)
    if (reset)
      begin
        pix_out_reg <= 0;
        pix_out_valid_reg<=0;
      end
    else
      begin
        pix_out_reg<= pix_out_next;
        pix_out_valid_reg <= pix_out_valid_next;
      end
  // Mask-related body
    //1st stage
    assign sum00= pixs_in[PIX_BIT-1:0]+pixs_in[PIX_BIT*2-1:PIX_BIT];
    assign sum01= pixs_in[PIX_BIT*3-1:PIX_BIT*2]+pixs_in[PIX_BIT*4-1:PIX_BIT*3];
    assign sum02= pixs_in[PIX_BIT*5-1:PIX_BIT*4]+pixs_in[PIX_BIT*6-1:PIX_BIT*5];
    assign sum03= pixs_in[PIX_BIT*7-1:PIX_BIT*6]+pixs_in[PIX_BIT*8-1:PIX_BIT*7];
    //2nd stage
    assign sum10= sum00 + sum01;
    assign sum11= sum02 + sum03;
    //3rd stage
    assign sum20= sum10 + sum11;
    assign sum21= {pixs_in[PIX_BIT*9-1:PIX_BIT*8],3'b000};
    //Final stage:
    assign comp_flag = (sum21>sum20); // to check which one is greater
    assign a = comp_flag ? sum21:sum20;
    assign b = comp_flag ? sum20:sum21;
    assign c = a-b;
    
  // Next-state Logic:
  always@*
  begin
    //Default Setting
    pix_out_valid_next= pix_out_valid_reg;
    // This line is window-operation-dependent 
    // It could have a control signal where it determines the kind of operation
    // The following operation performs a laplacian operator (Edge Detection)
    pix_out_next = c[PIX_BIT-1:0];
    // Managing valid output flag
    case(pixs_in_valid)
      1'b1    : pix_out_valid_next=1'b1;
      default : pix_out_valid_next=1'b0;
    endcase
  end
  // Output logic
  assign pix_out      = pix_out_reg;
  assign pix_out_valid= pix_out_valid_reg;
 
 endmodule   