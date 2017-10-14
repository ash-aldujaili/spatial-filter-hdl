/*
This module implements a registered signed multiplier
between filter coefficients (h) and windowed pixels (x)
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
*/

module sgnd_mult
    #(
      parameter PIX_BIT=8,
                COFCNT_BIT=16
      )
     (
      input wire clk,reset,                       // clk and reset siganl for pipeling and registering the multiplier
      input wire [PIX_BIT-1:0] x,                 // U(8,0) to be made A(8,0) ,U: unsigned ,A: signed
      input wire signed [COFCNT_BIT-1:0] h,       // A(0,15)   -1<=cof<+1
      output wire signed [COFCNT_BIT+PIX_BIT-1:0] y // A(8,15)
      );
      
      // Signal Declaration
      reg [COFCNT_BIT+PIX_BIT-1:0] y_reg,y_next;
      
      
      //Sequential Circuit
      always@(posedge clk)
        if (reset)
          y_reg<=0;
        else
          y_reg<=y_next;
          
      //Next-state logic
      always@*
      begin
        //default settings
        y_next= $signed({1'b0,x})*h;
      end
      
      //Output logic (registered output)
      assign y=y_reg;
      
      
    endmodule
    
      