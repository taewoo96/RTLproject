// Saturation 13-bit => 9-bit

module sat9 (
             input                  clk,
             input                  rstb,
             input           [12:0] RS4_RND12_i,
             input           [12:0] RS4_RND12_q,
             input                  RS4_RND12_en,
             output reg      [ 8:0] SAT9_i,
             output reg      [ 8:0] SAT9_q,
             output reg             SAT9_en  );


always @ (posedge clk) begin
   if (!rstb) begin
      SAT9_en <= 1'b0;
   end
   else begin
      SAT9_en <= RS4_RND12_en;
   end
end

always @ (posedge clk) begin
   if (!rstb) begin
   end
   else begin
      if (RS4_RND12_en) begin
         SAT9_i <= FUNC_SAT9(RS4_RND12_i);
      end
      else begin
         SAT9_i <= 9'b0;
      end
   end
end

always @ (posedge clk) begin
   if (!rstb) begin
   end
   else begin
      if (RS4_RND12_en) begin
         SAT9_q <= FUNC_SAT9(RS4_RND12_q);
      end
      else begin
         SAT9_q <= 9'b0;
      end
   end
end

//positive value :  (> 255)?  255
//negative value : (< -256)? -256
//symmetric... -255 ~ 255
//asymmetric.. -256 ~ 255 <==

function [8:0] FUNC_SAT9;
   input  [12:0] data_in; 
   begin
      if (data_in[12] == 0) begin // positive value
         if (data_in[11:8] > 4'b0000) begin
            FUNC_SAT9 = 9'b011111111; // saturation 255
         end
         else begin
            FUNC_SAT9 = {1'b0, data_in[7:0]};
         end
      end
      else begin // negative value
         if ( &data_in[11:8] ) begin // data_in[10:8] == 4'b1111
            FUNC_SAT9 = data_in[8:0];
         end
         else begin
            //FUNC_SAT9 = 9'b100000000; // saturation -256
            FUNC_SAT9 = 9'b100000001; // saturation -255
         end
      end
   end
endfunction

endmodule
