// Right shift 4 & round up to 12-bit
// Right shift 4 & round up to 13-bit

module right_shift4_rnd12 (
                           input                   clk,
                           input                   rstb,
                           input           [16:0]  CM_data_i,
                           input           [16:0]  CM_data_q,
                           input                   CM_en,
                           output reg      [12:0]  RS4_RND12_i,
                           output reg      [12:0]  RS4_RND12_q,
                           output reg              RS4_RND12_en  );


always @ (posedge clk) begin
   if (!rstb) begin
      RS4_RND12_en <= 1'b0;
   end
   else begin
      RS4_RND12_en <= CM_en;
   end
end

always @ (posedge clk) begin
   if (!rstb) begin
      RS4_RND12_i <= 13'b0;
   end
   else begin
      if (CM_en) begin
         RS4_RND12_i <= FUNC_RS4_RND12(CM_data_i);
      end
      else begin
         RS4_RND12_i <= 13'b0;
      end
   end
end

always @ (posedge clk) begin
   if (!rstb) begin
      RS4_RND12_q <= 13'b0;
   end
   else begin
      if (CM_en) begin
         RS4_RND12_q <= FUNC_RS4_RND12(CM_data_q);
      end
      else begin
         RS4_RND12_q <= 13'b0;
      end
   end
end

// positive value : [3:0] = 1111~1000 : round up   (+1)
//                        = 0111~0000 : no round up
// negative value : [3:0] = 1111~1001 : round up   (+1)
//                        = 1000~0000 : no round up
// ex) -4.0 ~ -3.0
// 1101 0000 : -3.0
// 1100 1111 : -3.0625
// 1100 1110 : -3.125
// 1100 1101 : -3.1875
// 1100 1100 : -3.25
// 1100 1011 : -3.3125
// 1100 1010 : -3.375
// 1100 1001 : -3.4375   => to -3.0
// -----------------------------------
// 1100 1000 : -3.5      => to -4.0
// 1100 0111 : -3.5625
// 1100 0110 : -3.625
// 1100 0101 : -3.6875
// 1100 0100 : -3.75
// 1100 0011 : -3.8125
// 1100 0010 : -3.875
// 1100 0001 : -3.9375
// 1100 0000 : -4.0

function [12:0] FUNC_RS4_RND12;
   input [16:0] data_in;
   begin
      if (data_in[16] == 1'b0) begin //positive value
         if (data_in[15:4] == 11'b11111111111) begin // defense overflow
            FUNC_RS4_RND12 = data_in[16:4];
         end
         else begin
            if (data_in[3] == 1'b1) begin
               FUNC_RS4_RND12 = data_in[16:4] + 13'b0000000000001;
            end
            else begin
               FUNC_RS4_RND12 = data_in[16:4];
            end
         end
      end
      else begin //negative value
         if (data_in[3] == 1'b0) begin
            FUNC_RS4_RND12 = data_in[16:4];
         end
         else begin
            if ( !(|data_in[2:0]) ) begin // if data_in[2:0] == 3'b000
               FUNC_RS4_RND12 = data_in[16:4];
            end
            else begin
               FUNC_RS4_RND12 = data_in[16:4] + 13'b0000000000001;
            end
         end
      end
   end
endfunction

endmodule
