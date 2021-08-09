// Complex mult : (a+bi)*(c+di)


module complex_mult (
                      input                      clk,
                      input                      rstb,
                      input              [11:0]  in_data_i,
                      input              [11:0]  in_data_q,
                      input              [ 3:0]  in_w_i,
                      input              [ 3:0]  in_w_q,
                      input                      in_en,
                      output reg                 CM_en,
                      output reg         [16:0]  CM_out_i,
                      output reg         [16:0]  CM_out_q  );

reg        [11:0] in_data_i_reg;
reg        [11:0] in_data_q_reg;
reg        [ 3:0] in_w_i_reg;
reg        [ 3:0] in_w_q_reg;

reg d1_en, d2_en;

always @ (posedge clk) begin
   if (!rstb) begin
      d1_en <= 1'b0; 
      d2_en <= 1'b0;
      CM_en <= 1'b0;
   end
   else begin
      d1_en <= in_en;
      d2_en <= d1_en;
      CM_en <= d2_en;
   end 
end

always @ (posedge clk) begin
   if (!rstb) begin
      in_data_i_reg <= 12'b0;
      in_data_q_reg <= 12'b0;
      in_w_i_reg <= 4'b0;
      in_w_q_reg <= 4'b0;
   end
   else begin
      in_data_i_reg <= in_data_i;
      in_data_q_reg <= in_data_q;
      in_w_i_reg <= in_w_i;
      in_w_q_reg <= in_w_q;
   end
end

reg [16:0] temp_i1;
reg [16:0] temp_i2;
reg [16:0] temp_q1;
reg [16:0] temp_q2;

//step 1. MULT
always @ (posedge clk) begin
   if (!rstb) begin
      temp_i1 <= 17'b0;
      temp_i2 <= 17'b0;
      temp_q1 <= 17'b0;
      temp_q2 <= 17'b0;
   end
   else begin
      if (d1_en) begin
         temp_i1 <= $signed(in_data_i_reg) * $signed({1'b0,in_w_i_reg});
         temp_i2 <= $signed(in_data_q_reg) * $signed({1'b0,in_w_q_reg});
         temp_q1 <= $signed(in_data_i_reg) * $signed({1'b0,in_w_q_reg});
         temp_q2 <= $signed(in_data_q_reg) * $signed({1'b0,in_w_i_reg});
      end
      else begin
         temp_i1 <= 17'b0;
         temp_i2 <= 17'b0;
         temp_q1 <= 17'b0;
         temp_q2 <= 17'b0;
      end
   end
end

//step 2. ADD/SUB
always @ (posedge clk) begin
   if (!rstb) begin
      CM_out_i <= 17'b0;
      CM_out_q <= 17'b0;
   end
   else begin
      if (d2_en) begin
         CM_out_i <= $signed(temp_i1) - $signed(temp_i2);
         CM_out_q <= $signed(temp_q1) + $signed(temp_q2);
      end
      else begin
         CM_out_i <= 17'b0;
         CM_out_q <= 17'b0;
      end
   end
end

endmodule
