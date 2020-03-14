`ifndef DEFAULT_TEST
`define DEFAULT_TEST

`include "environment.sv"
program test(mem_intf intf);
  
  class my_trans extends transaction;
    
    bit [1:0] count;
    
    function void pre_randomize();
      wr_en.rand_mode(0);
      rd_en.rand_mode(0);
      addr.rand_mode(0);
        wr_en = 0;
        rd_en = 1;
        addr  = cnt;
      cnt++;
    endfunction
    
  endclass
    
  //declaring environment instance
  environment env;
  my_trans my_tr;
  
  initial begin
    //creating environment
    env = new(intf);
    
    my_tr = new();
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.gen.repeat_count = 4;
    
    env.gen.trans = my_tr;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram

`endif