// 2-D array memory (18 x 120)
//    bit-width  :  18bits 
//        depth  :  120

module mem_wrp (
                 input                       clk,
                 input                       rstb,
                 input                       done,
                 input                [ 8:0] SAT9_i,
                 input                [ 8:0] SAT9_q,
                 input                       SAT9_en,
                 output reg                  out_done,
                 output reg           [ 8:0] out_data_i,
                 output reg           [ 8:0] out_data_q,
                 output reg                  out_data_en  );


reg [ 8:0] SAT9_i_reg;
reg [ 8:0] SAT9_q_reg;
reg        d_SAT9_en;
reg [17:0] mem_18x120 [0:119];
reg [ 6:0] read_ptr, write_ptr;
integer N;

parameter ST_IDLE  = 1'b0,
          ST_READ  = 1'b1;

reg       STATE_R;

always @ (posedge clk) begin
   if (!rstb) begin
      SAT9_i_reg <= 9'b0;
   end
   else begin
      SAT9_i_reg <= SAT9_i;
   end 
end

always @ (posedge clk) begin
   if (!rstb) begin
      SAT9_q_reg <= 9'b0;
   end
   else begin
      SAT9_q_reg <= SAT9_q;
   end 
end

always @ (posedge clk) begin
   if (!rstb) begin
      d_SAT9_en <= 1'b0;
   end
   else begin
      d_SAT9_en <= SAT9_en;
   end 
end


// WRITE
always @ (posedge clk) begin
   if (!rstb) begin
      write_ptr <= 7'b0;
      for (N=0;N<120;N=N+1) begin // initialize_memory
         mem_18x120[N] <= 18'b0;
      end
   end
   else begin
      if (d_SAT9_en) begin
         mem_18x120[write_ptr] <= {SAT9_i_reg,SAT9_q_reg};
         if (write_ptr == 7'b1110111) // end-of-memory
            write_ptr <= 7'b0;
         else
            write_ptr <= write_ptr + 7'b0000001;
      end
      else begin
         write_ptr <= write_ptr;
      end
   end
end

// READ FSM
always @ (posedge clk) begin
   if (!rstb) begin
      STATE_R <= ST_IDLE;
      out_data_en <= 1'b0;
      out_done <= 1'b0;
      out_data_i <= 9'b0;
      out_data_q <= 9'b0;
      read_ptr  <= 7'b0;
   end
   else begin
      case (STATE_R)
      ST_IDLE : begin
                   out_done <= 1'b0;
                   out_data_en <= 1'b0;
                   out_data_i <= 9'b0;
                   out_data_q <= 9'b0;
                   read_ptr <= 7'b0;
                   if (done == 1) begin
                      STATE_R <= ST_READ;
                   end
                   else begin
                      STATE_R <= ST_IDLE;
                   end
                end
      ST_READ : begin
                   out_data_en <= 1'b1;
                   out_data_i <= mem_18x120[read_ptr][17:9];
                   out_data_q <= mem_18x120[read_ptr][ 8:0];
                   if (read_ptr == 7'b1110111) begin // end-of-memory
                      STATE_R <= ST_IDLE;
                      read_ptr <= 7'b0;
                      out_done <= 1'b1;
                   end
                   else begin
                      STATE_R <= ST_READ;
                      read_ptr <= read_ptr + 7'b0000001;
                      out_done <= 1'b0;
                   end
                end
      default : STATE_R <= ST_IDLE; 
      endcase      
   end
end

endmodule
