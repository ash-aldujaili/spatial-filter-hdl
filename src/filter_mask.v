/*
This module implements the filter window,mask, template
that encapsulate the pixels to be routed to the filter 
function, it takes care of the image borders issue through
the mirror without duplication scheme. This module is tailored to a single 
row of the mask,
........................
By: Abdullah Al-Dujaili
    NTU, 2012
.......................
Importantn note :=============================
This filter mask is designed espeically for 7*7 filter mask
as there are multiplexers that are difficult to make them parameterize for the time being
*/

module filter_mask
  #( 
    parameter PIX_BIT=8,     //# pixel bits
               MASK_WIDTH=7  // mask width
    )
   (
    input wire clk,reset,     // clk reset signals
    input wire [PIX_BIT*MASK_WIDTH-1:0] sngl_col_masked_pixs_in,  // pixels coming from each row of the buffers & the incoming pixel (one pixel each)
    input wire [1:0] sel_right_col, // selector signal to deal with pixels along the most right column through mirror without duplicate scheme
    input wire sel_left_col,        // selector signal to deal with pixels along the most left  column through mirror without duplication scheme
    output wire [PIX_BIT*(MASK_WIDTH**2)-1:0] masked_pixs_out // actual/mirrored pixels to be routed to the filter function
   );
   
   
   // Signal Declaration
   // Actual pixel holders
   reg [PIX_BIT-1:0] win_pix_reg [0:MASK_WIDTH-1][0:MASK_WIDTH-1]; 
   wire [PIX_BIT-1:0] win_pix_next[0:MASK_WIDTH-1][0:MASK_WIDTH-1];
   // temporary pixel holders to allow image border scheme
   reg [PIX_BIT-1:0] tmp_win_pix_reg [0:MASK_WIDTH-1][0:((MASK_WIDTH-1)/2)-1];
   wire [PIX_BIT-1:0] tmp_win_pix_next[0:MASK_WIDTH-1][0:((MASK_WIDTH-1)/2)-1];
   // muxes-related signals to deal with image borders using mirror-no-duplicate scheme, for 7*7 filter
   wire [PIX_BIT-1:0] pix_o_col_0 [0:MASK_WIDTH-1];
   wire[PIX_BIT-1:0] pix_o_col_1 [0:MASK_WIDTH-1];
   wire[PIX_BIT-1:0] pix_o_col_2 [0:MASK_WIDTH-1];
   wire[PIX_BIT-1:0] pix_o_col_3 [0:MASK_WIDTH-1];
   wire[PIX_BIT-1:0] pix_o_col_4 [0:MASK_WIDTH-1];
   wire[PIX_BIT-1:0] pix_o_col_5 [0:MASK_WIDTH-1];
   wire[PIX_BIT-1:0] pix_o_col_6 [0:MASK_WIDTH-1];
   //looping counters
   genvar j;
   
   
   
   // Mux-s to deal with image border using mirror -no duplicate scheme:
   //=====================================================================
   

   generate
     for (j=0;j<MASK_WIDTH;j=j+1)
     begin : pixels_columns
      // pix_o_col_0
  //    always@(sngl_col_masked_pixs_in[PIX_BIT*(j+1)-1:PIX_BIT*j],win_pix_reg[j])
  //      begin
  //        case(sel_right_col)
  //        2'd0: pix_o_col_0[j]= sngl_col_masked_pixs_in[PIX_BIT*(j+1)-1:PIX_BIT*j]; // default taking incoming pixels
  //        2'd1: pix_o_col_0[j]= win_pix_reg[j][1]; // for 3rd last row
  //        2'd2: pix_o_col_0[j]= win_pix_reg[j][3]; // for 2nd last row
  //        2'd3: pix_o_col_0[j]= win_pix_reg[j][5]; // for last row
		assign pix_o_col_0[j]= (sel_right_col==2'd0)? sngl_col_masked_pixs_in[PIX_BIT*(j+1)-1:PIX_BIT*j]: // default taking incoming pixels
									  (sel_right_col==2'd1)? win_pix_reg[j][1]: // for 3rd last row
									  (sel_right_col==2'd2)? win_pix_reg[j][3]: // for 2nd last row
									  win_pix_reg[j][5]; // for last row
  //        endcase // endcase
  //     end // always
       // pix_o_col_1
       assign pix_o_col_1[j]=(sel_left_col)? win_pix_reg[j][0] : tmp_win_pix_reg[j][0]; 
       // pix_o_col_2
       assign pix_o_col_2[j]=(sel_left_col)? win_pix_reg[j][1] : tmp_win_pix_reg[j][1]; 
       // pix_o_col_3
       assign pix_o_col_3[j]=(sel_left_col)? win_pix_reg[j][2] : tmp_win_pix_reg[j][2]; // win_pix_reg[j][2]
       // pix_o_col_4
       assign pix_o_col_4[j]=(sel_left_col)? win_pix_reg[j][1] :win_pix_reg[j][3] ; 
       // pix_o_col_5
       assign pix_o_col_5[j]=(sel_left_col)? win_pix_reg[j][0] :win_pix_reg[j][4] ; 
       // pix_o_col_6
       assign pix_o_col_6[j]=(sel_left_col)? sngl_col_masked_pixs_in[PIX_BIT*(j+1)-1:PIX_BIT*j] :win_pix_reg[j][5] ; 
     end//for
   endgenerate//generate         
   //=====================================================================
   //Sequential Circuit:
   generate
     for(j=0;j<MASK_WIDTH;j=j+1)
      begin : sequential_circuit_upper
        genvar i; 
        for(i=0;i<MASK_WIDTH;i=i+1)
          begin: sequential_circuit_inner
            always@(posedge clk)
             // if(reset)
             //   begin
             //     win_pix_reg[j][i]     <= 0;
            //    end
            //  else
                begin
                  win_pix_reg[j][i]     <= win_pix_next[j][i];
                end
          end// inner
      end// upper
    endgenerate
    

	 generate
     for(j=0;j<MASK_WIDTH;j=j+1)
      begin : sequential_circuit_upper_1
        genvar i; 
        for(i=0;i<((MASK_WIDTH-1)/2);i=i+1)
          begin: sequential_circuit_inner_1
            always@(posedge clk)
            //  if(reset)
            //    begin
            //      tmp_win_pix_reg[j][i] <= 0;
            //    end
            //  else
                begin
                  tmp_win_pix_reg[j][i] <= tmp_win_pix_next[j][i];
                end
          end// inner1
      end// upper1
    endgenerate
                
   //=====================================================================
   
   //=====================================================================
   // Next-state Logic:
   generate 
     for(j=0;j<MASK_WIDTH;j=j+1)
     begin: next_state_logic
  //    always@(pix_o_col_0[j],pix_o_col_1[j],pix_o_col_2[j],sngl_col_masked_pixs_in[PIX_BIT*(j+1)-1:PIX_BIT*j],win_pix_reg[j],pix_o_col_4[j],pix_o_col_5[j],pix_o_col_6[j])
  //      begin
          // temp registers
         assign tmp_win_pix_next[j][0]=pix_o_col_0[j];
         assign tmp_win_pix_next[j][1]=pix_o_col_1[j];
         assign tmp_win_pix_next[j][2]=pix_o_col_2[j];
          // incoming pixels
         assign win_pix_next    [j][0]=sngl_col_masked_pixs_in[PIX_BIT*(j+1)-1:PIX_BIT*j];
          //direct routing
         assign win_pix_next    [j][1]=win_pix_reg[j][0];
         assign win_pix_next    [j][2]=win_pix_reg[j][1]; 
         assign win_pix_next    [j][3]=win_pix_reg[j][2];
          // mux input 
         assign win_pix_next    [j][4]=pix_o_col_4[j];
         assign win_pix_next    [j][5]=pix_o_col_5[j];
         assign win_pix_next    [j][6]=pix_o_col_6[j];
   //     end//always
    end//for
  endgenerate//generate
  

  //output logic to filter function
  generate
    for (j=0;j<MASK_WIDTH;j=j+1)
    begin: output_logic_upper
      genvar i;
      for(i=0;i<MASK_WIDTH;i=i+1) 
      begin: output_logic_inner
        if(i< (MASK_WIDTH-1)/2)
           assign masked_pixs_out[((i+1)*PIX_BIT+j*MASK_WIDTH*PIX_BIT)-1:i*PIX_BIT+j*MASK_WIDTH*PIX_BIT]=tmp_win_pix_reg[j][i];
        else
           assign masked_pixs_out[((i+1)*PIX_BIT+j*MASK_WIDTH*PIX_BIT)-1:i*PIX_BIT+j*MASK_WIDTH*PIX_BIT]=win_pix_reg[j][i];
      end //output_logic_inner
    end//output_logic_upper
  endgenerate
  
     
endmodule
     