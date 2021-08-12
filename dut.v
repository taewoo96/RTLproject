// DUT TOP MODULE

module dut (
              input                      clk,
              input                      rstb,
              input              [11:0]  in_data_i,
              input              [11:0]  in_data_q,
              input              [ 3:0]  in_w_i,
              input              [ 3:0]  in_w_q,
              input                      in_en,
              input                      done,
              output reg                 out_done,
              output reg                 out_en,
              output reg         [ 8:0]  out_data_i,
              output reg         [ 8:0]  out_data_q );

wire             CM_en;
wire      [16:0] CM_i;
wire      [16:0] CM_q;
wire             RS4_RND12_en;
wire      [12:0] RS4_RND12_i;
wire      [12:0] RS4_RND12_q;
wire             SAT9_en;
wire      [ 8:0] SAT9_i;
wire      [ 8:0] SAT9_q;
wire      [ 8:0] d_out_data_i;
wire      [ 8:0] d_out_data_q;
wire             d_out_en;
wire             d_out_done;

complex_mult U_COMPLEX_MULT(
                             .clk          (clk      ),
                             .rstb         (rstb     ),
                             .in_data_i    (in_data_i),
                             .in_data_q    (in_data_q),
                             .in_w_i       (in_w_i   ),
                             .in_w_q       (in_w_q   ),
                             .in_en        (in_en    ),
                             .CM_en        (CM_en    ),
                             .CM_out_i     (CM_i     ),
                             .CM_out_q     (CM_q     )  );
                             

right_shift4_rnd12 U_RIGHT_SHIFT4_RND12(
                          .clk            (clk         ),
                          .rstb           (rstb        ),
                          .CM_data_i      (CM_i        ),
                          .CM_data_q      (CM_q        ),
                          .CM_en          (CM_en       ),
                          .RS4_RND12_i    (RS4_RND12_i ),
                          .RS4_RND12_q    (RS4_RND12_q ),
                          .RS4_RND12_en   (RS4_RND12_en)  );

sat9 U_SAT9 (
              .clk            (clk         ),
              .rstb           (rstb        ),
              .RS4_RND12_i    (RS4_RND12_i ),
              .RS4_RND12_q    (RS4_RND12_q ),
              .RS4_RND12_en   (RS4_RND12_en), 
              .SAT9_en        (SAT9_en     ), 
              .SAT9_i         (SAT9_i      ), 
              .SAT9_q         (SAT9_q      )  );
                
mem_wrp U_MEM_WRP (
                    .clk            (clk         ),
                    .rstb           (rstb        ),
                    .done           (done        ),
                    .SAT9_en        (SAT9_en     ), 
                    .SAT9_i         (SAT9_i      ), 
                    .SAT9_q         (SAT9_q      ),
                    .out_done       (d_out_done  ),
                    .out_data_en    (d_out_en    ),
                    .out_data_i     (d_out_data_i),
                    .out_data_q     (d_out_data_q)   );

always @ (posedge clk) begin
   if (!rstb) begin
      out_data_i  <= 9'b0;
      out_data_q  <= 9'b0;
      out_en      <= 1'b0;
      out_done    <= 1'b0;
   end
   else begin
      out_data_i  <= d_out_data_i;
      out_data_q  <= d_out_data_q;
      out_en      <= d_out_en;
      out_done    <= d_out_done;
   end
end

endmodule
