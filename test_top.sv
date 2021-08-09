`timescale 1ns/100ps

module dut_test_top;
  parameter simulation_cycle = 100;

  bit SystemClock = 0;

  dut_io top_io(SystemClock);
  
  test t(top_io);

  dut dut1(
    .rstb  (top_io.rstb),
    .clk    (top_io.clk),
    .in_data_i (top_io.in_data_i),
    .in_data_q (top_io.in_data_q),
    .in_w_i (top_io.in_w_i),
    .in_w_q (top_io.in_w_q),
    .in_en (top_io.in_en),
    .done (top_io.done),
    .out_done (top_io.out_done),
    .out_en (top_io.out_en),
    .out_data_i (top_io.out_data_i),
    .out_data_q (top_io.out_data_q)
  );

  initial begin
    $timeformat(-9, 1, "ns", 10);
	  $fsdbDumpfile("my.fsdb");
    $fsdbDumpvars(0,dut_test_top);
  end

  always begin
    #(simulation_cycle/2) SystemClock = ~SystemClock;
  end

endmodule
