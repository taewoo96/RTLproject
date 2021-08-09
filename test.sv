//`define TAKE_INFILE

class Gendata;
    rand    bit[11:0]    in_data_i;
    rand    bit[11:0]    in_data_q;
    rand    bit[3:0]     in_w_i;
    rand    bit[3:0]     in_w_q;

    covergroup fcov();
        coverpoint in_data_i {bins n[256] = {[0:12'hfff]};}
        coverpoint in_data_q {bins n[256] = {[0:12'hfff]};}
        coverpoint in_w_i;
        coverpoint in_w_q;
    endgroup
    function new();
        fcov = new();
    endfunction
endclass: Gendata

program automatic test(dut_io.TB io);

    logic        [11:0] data_i[0:119]; //loaded data
    logic        [11:0] data_q[0:119];
    logic        [ 3:0] w_i[0:119];
    logic        [ 3:0] w_q[0:119];
    logic        [6:0]  cnt;
    int          i, j, k, sim_cnt;

    logic[8:0] out_txt_i[0:119];
    logic[8:0] out_txt_q[0:119];
    logic[8:0] golden_txt_i[0:119];
    logic[8:0] golden_txt_q[0:119];

    integer f_out_i;
    integer f_out_q;

    integer f_in_d_i;
    integer f_in_d_q;
    integer f_in_w_i;
    integer f_in_w_q;
    
    real r, cov_perecnt;

    Gendata data;

    logic [8:0] data_out;
    logic [8:0] data_in;

    initial begin
        cov_perecnt = 0;
        sim_cnt =0;
        while(cov_perecnt!=100) begin
            sim_cnt++;
            reset();
            gendata();
            $system("./refC.out");
            loaddata();
            sig_drive();

            wait(io.cb.out_en);

            wrtfile();
            cmpfile();
        end        
        $display(">>>>>>>>>>>>>>>>>>>> Simulation Finished... \tSimCount : %3d", sim_cnt);                      
        $finish;
    end

    task sig_drive();
        for(j=0; j<9; j++) begin //9times
            clk12();
            clk4();
        end
        clk12(); //10times
        clk50();
        st_done();
    endtask: sig_drive

    task gendata();
        data = new();
        f_in_d_i = $fopen("../SIM/in_data_i.txt","w");
        f_in_d_q = $fopen("../SIM/in_data_q.txt","w");
        f_in_w_i = $fopen("../SIM/in_weight_i.txt","w");
        f_in_w_q = $fopen("../SIM/in_weight_q.txt","w");

        for(i=0; i<120; i++) begin                
            data.randomize(); //randomize
            data.fcov.sample();
            $fwriteh (f_in_d_i,"%h\n", data.in_data_i);
            $fwriteh (f_in_d_q,"%h\n", data.in_data_q);
            $fwriteh (f_in_w_i,"%h\n", data.in_w_i);
            $fwriteh (f_in_w_q,"%h\n", data.in_w_q);
            //@io.cb;
        end
        $fclose(f_in_d_i);
        $fclose(f_in_d_q);
        $fclose(f_in_w_i);
        $fclose(f_in_w_q);
    endtask: gendata

    task reset(); //reset task
        cnt <= 0;
        io.cb.rstb <= 1'b0;
        io.cb.in_en <= 1'b0;
        io.cb.done <= 1'b0;

        repeat(3) @io.cb;
        io.cb.rstb <= 1'b1;

        repeat(3) @io.cb;

    endtask: reset

    task loaddata();
        //$display("TAKE_INFILE IS DEFINED\n");
        $readmemh("../SIM/in_data_i.txt", data_i);
        $readmemh("../SIM/in_data_q.txt", data_q); 
        $readmemh("../SIM/in_weight_i.txt", w_i); 
        $readmemh("../SIM/in_weight_q.txt", w_q);
    endtask: loaddata

    task clk12();
        io.cb.in_en <= 1'b1;
        for(i=0; i<12; i++) begin            
            //`ifdef TAKE_INFILE
                io.cb.in_data_i   <= data_i[cnt];
                io.cb.in_data_q   <= data_q[cnt];
                io.cb.in_w_i      <= w_i[cnt];
                io.cb.in_w_q      <= w_q[cnt];                
            // `else
            //     io.cb.in_data_i   <= data.in_data_i[cnt];
            //     io.cb.in_data_q   <= data.in_data_q[cnt];
            //     io.cb.in_w_i      <= data.in_w_i[cnt];
            //     io.cb.in_w_q      <= data.in_w_q[cnt];
            // `endif
            cnt  <= cnt + 1;
            //$display("loop check %d\n", i);
            @io.cb;
        end
    endtask: clk12

    task clk4();
        io.cb.in_en <= 1'b0;
        repeat(4) @io.cb;
    endtask: clk4

    task clk50();
        io.cb.in_en <= 1'b0;
        repeat(50) @io.cb;
        io.cb.done <= 1'b1;
        @io.cb;   
    endtask: clk50

    task st_done();
        io.cb.done <= 1'b0;
        @io.cb;
    endtask: st_done
    
    task wrtfile();  //save output to txt
        f_out_i = $fopen("../SIM/out_data_i.txt","w");
        f_out_q = $fopen("../SIM/out_data_q.txt","w");
        for(i=0; i<120; i = i+1) begin
            $fwriteh (f_out_i,"%h\n", io.cb.out_data_i);
            $fwriteh (f_out_q,"%h\n", io.cb.out_data_q);
            @io.cb;
        end
        $fclose(f_out_i);
        $fclose(f_out_q);
    endtask: wrtfile

    task cmpfile();
        ///load golden data
        //$display("LOAD golden output data...");
        $readmemh("../SIM/out_golen_i.txt", golden_txt_i); 
        $readmemh("../SIM/out_golen_q.txt", golden_txt_q);

        ///load output data
        //$display("LOAD output data...");
        $readmemh("../SIM/out_data_i.txt", out_txt_i); 
        $readmemh("../SIM/out_data_q.txt", out_txt_q);
        
        cnt =0;
        r =0;
        for(i=0; i<120; i++) begin
            //$display("reference value : %h   test value : %h", golden_txt_i[i], out_txt_i[i]);
            if(golden_txt_i[i] == out_txt_i[i]) begin
                //$display(">>>>>>>>>>> Match");
                cnt = cnt + 1;
            end
        end
        r = (real'(cnt) / 120) * 100;
        cov_perecnt = $get_coverage ();
        //$display("match rate : %f %%", r);
        if(r == 100) $display(">>>>>>>>>>>>>>>>>>>> Simulation Complited... \tCoverage : %f... \tSimCount : %3d", cov_perecnt, sim_cnt);
        else begin
            $display(">>>>>>>>>>>>>>>>>>>> Simulation Failed!!!");
            $finish;
        end
        

    endtask: cmpfile

endprogram: test
