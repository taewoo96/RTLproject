// SIGNAL GENERATOR


module sig_gen (
                 input               clk,
                 input               rstb,
                 input               start,
                 input        [ 8:0] out_data_i,
                 input        [ 8:0] out_data_q,
                 input               out_en,
                 input               out_done,
                 output reg   [11:0] in_data_i,
                 output reg   [11:0] in_data_q,
                 output reg   [ 3:0] in_w_i,
                 output reg   [ 3:0] in_w_q,
                 output reg          in_en,
                 output reg          done, 
                 output reg          finish );

reg [1:0] CNT_4CLK;
reg [3:0] CNT_12CLK;
reg [5:0] CNT_50CLK;
reg [3:0] CNT_10TIMES;


parameter ST_IDLE       = 3'b000,
          ST_DOUT       = 3'b001,
          ST_WAIT_4CLK  = 3'b010,
          ST_WAIT_50CLK = 3'b011,
          ST_DONE       = 3'b100;
reg [2:0] STATE;

/////////////////////// FOR DUMPING ////////////////////////////////
//integer f_data_i;
//integer f_data_q;
integer f_out_i;
integer f_out_q;
//integer f_w_i;
//integer f_w_q;

initial begin
   //f_data_i = $fopen("in_data_i.txt","w");
   //f_data_q = $fopen("in_data_q.txt","w");
   //f_w_i = $fopen("in_weight_i.txt","w");
   //f_w_q = $fopen("in_weight_q.txt","w");
   f_out_i = $fopen("../SIM/output_vec/out_data_i.txt","w");
   f_out_q = $fopen("../SIM/output_vec/out_data_q.txt","w");
end

/*
always @ (posedge clk) begin
   if (in_en) begin
      $fwriteh (f_data_i,"%h\n",in_data_i);
      $fwriteh (f_data_q,"%h\n",in_data_q);
      $fwriteh (f_w_i,"%h\n",in_w_i);
      $fwriteh (f_w_q,"%h\n",in_w_q);
   end
end
*/

reg d_out_done;
always @ (posedge clk) begin
   if(!rstb) begin
      d_out_done <= 1'b0;
      finish <= 0;
   end
   else begin
      d_out_done <= out_done;
      finish <= d_out_done;
   end   
end

always @ (posedge clk) begin
   if (out_en) begin
      $fwriteh (f_out_i,"%h\n",out_data_i);
      $fwriteh (f_out_q,"%h\n",out_data_q);
   end
end

always @ (posedge clk) begin
   if (d_out_done) begin
      $fclose(f_out_i);
      $fclose(f_out_q);
      //$fclose(f_data_i);
      //$fclose(f_data_q);
      //$fclose(f_w_i);
      //$fclose(f_w_q);
   end
end
/////////////////////////////////////////////////////////////////////
`ifdef TAKE_INFILE
reg [11:0] data_i [0:119];
reg [11:0] data_q [0:119];
reg [ 3:0] weight_i [0:119];
reg [ 3:0] weight_q [0:119];
reg [ 6:0] cnt;

initial begin
   $display("TAKE_INFILE IS DEFINED\n");
   $readmemh("../SIM/input_vec/in_data_i.txt", data_i); 
   $readmemh("../SIM/input_vec/in_data_q.txt", data_q); 
   $readmemh("../SIM/input_vec/in_weight_i.txt", weight_i); 
   $readmemh("../SIM/input_vec/in_weight_q.txt", weight_q); 
end
`endif
/////////////////////////////////////////////////////////////////////
always @ (posedge clk) begin
   if (!rstb) begin
      STATE       <= ST_IDLE;
      in_data_i   <= 0;
      in_data_q   <= 0;
      in_w_i      <= 0;
      in_w_q      <= 0;
      done        <= 0;
      in_en       <= 0;
      CNT_4CLK    <= 0;
      CNT_12CLK   <= 0;
      CNT_50CLK   <= 0;
      CNT_10TIMES <= 0;
      `ifdef TAKE_INFILE
         cnt         <= 0;
      `endif
   end
   else begin
      case (STATE)
      ST_IDLE       : begin
                         if (start) begin
                            CNT_10TIMES <= 4'b0001;
                            STATE       <= ST_DOUT;
                         end 
                         else begin
                            CNT_10TIMES <= 4'b0000;
                            STATE       <= ST_IDLE;
                         end
                      end      
      ST_DOUT       : begin // DATA OUT FOR 12 CLK
                         if (CNT_12CLK == 4'b1100) begin
                            in_en <= 0;
                            if (CNT_10TIMES == 4'b1010) begin
                               STATE     <= ST_WAIT_50CLK;
                               CNT_50CLK <= 6'b000000;
                            end
                            else begin
                               CNT_10TIMES <= CNT_10TIMES + 4'b0001;
                               STATE       <= ST_WAIT_4CLK;
                               CNT_4CLK    <= 2'b00;
                            end
                         end
                         else begin
                            STATE       <= ST_DOUT;
                            in_en       <= 1;
                            `ifdef TAKE_INFILE
                               in_data_i   <= data_i[cnt];
                               in_data_q   <= data_q[cnt];
                               in_w_i      <= weight_i[cnt];
                               in_w_q      <= weight_q[cnt];
                               cnt         <= cnt + 1;
                            `else
                               in_data_i   <= $random();
                               in_data_q   <= $random();
                               in_w_i      <= $random();
                               in_w_q      <= $random();
                            `endif
                            CNT_12CLK   <= CNT_12CLK + 4'b0001;
                         end
                      end
      ST_WAIT_4CLK  : begin
                         if (CNT_4CLK == 2'b10) begin
                            CNT_12CLK <= 4'b0000;
                            STATE     <= ST_DOUT;
                         end
                         else begin
                            STATE    <= ST_WAIT_4CLK;
                            CNT_4CLK <= CNT_4CLK + 2'b01;
                         end 
                      end
      ST_WAIT_50CLK : begin
                         if (CNT_50CLK == 6'b110001) begin //49
                            done       <= 1;
                            STATE      <= ST_DONE;
                            CNT_50CLK  <= 6'b000000;
                         end
                         else begin
                            STATE     <= ST_WAIT_50CLK;
                            CNT_50CLK <= CNT_50CLK + 6'b000001;
                         end                         
                      end
      ST_DONE       : begin
                         done  <= 0;
                         STATE <= ST_DONE;
                      end
      default       : STATE <= ST_IDLE;
      endcase      
   end
end

endmodule
