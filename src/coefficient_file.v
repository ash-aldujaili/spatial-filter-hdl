/*
This module implements a 7*7 register file that's used
to load up the necessary coefficents for filters.
........................
By: Abdullah Al-Dujaili
    NTU, 2012
........................
*/

module coefficient_file
  #(
    parameter COFCNT_BIT=16, // # coefficient bit
              MASK_WIDTH=7   // mask width
    )
    (
      input  wire clk,reset,                // clk and reset signals
      input  wire wr_en,                    // write enable
      input  wire [COFCNT_BIT-1:0] wr_data, // data to be written
      output wire [COFCNT_BIT*(MASK_WIDTH**2)-1:0]   out_data
    );
    
    // Signal Declarations
    reg [COFCNT_BIT*(MASK_WIDTH**2)-1:0] data_reg,data_next;
 
    
    // Sequetial Circuit
    always@(posedge clk)
     //if (reset)
     //  data_reg <=0;
     // else
        data_reg <= data_next;
    
    // Next-state Logic
    always@*
      begin
        //default setttings
        data_next=data_reg;
        if(wr_en)
          data_next={wr_data,data_reg[COFCNT_BIT*(MASK_WIDTH**2)-1:COFCNT_BIT]};
      end
      
    // Output logic:
    assign out_data=data_reg;
    
endmodule

        