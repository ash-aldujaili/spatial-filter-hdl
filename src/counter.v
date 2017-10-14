/*
This is a modulo-counter circuit
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
This counter can be used to track down the pixel coordinates
*/

module counter
  #
  (
   parameter CNT_BIT=8,
             CNT_MOD=256
  )
  (
    input  wire clk,reset, enable,// reset circuitry,
    output wire max_tick,
    output wire [CNT_BIT-1:0] count
  );
  
  
  //Signal Declarartion
  reg [CNT_BIT-1:0] cnt_reg,cnt_next;
  wire max_tick_sig = (cnt_reg==CNT_MOD-1); // due to delayed enable control signal
  
  
  // Sequential Logic
  always@(posedge clk)
    if(reset)
      cnt_reg <= 0;
    else
      cnt_reg <= cnt_next;

  //Next state logic
  always@*
  begin
    //default settings
    cnt_next=cnt_reg;
    if (enable)
      cnt_next=(max_tick_sig)?0:cnt_reg+1;
  end
  
  // Output logic
  assign count=cnt_reg;
  assign max_tick= max_tick_sig;
  
endmodule

  