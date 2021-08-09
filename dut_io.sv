interface dut_io(input bit clk);
    //logic          clk;
    logic          rstb;
    //logic          start;
    logic  [11:0] in_data_i, in_data_q;
    logic  [ 8:0] out_data_i, out_data_q;
    logic  [ 3:0] in_w_i, in_w_q;
    logic        in_en, out_en;
    logic        done;
    logic        out_done;
    //logic        finish;

    clocking cb @(posedge clk);
        default input #1ns output #1ns;
        output  rstb;
        output  in_data_i, in_data_q;
        output  in_w_i, in_w_q;
        output  in_en;
        output  done;
        input   out_done;
        input   out_data_i, out_data_q;
        input   out_en;        
    endclocking: cb

    modport TB(clocking cb, output rstb);

endinterface: dut_io
