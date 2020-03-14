`ifndef RANDOM_TEST
`define RANDOM_TEST

`include "environment.sv"
program test(mem_intf intf);
  
  //declaring environment instance
  environment env;
  
  initial begin
    //creating environment
    env = new(intf);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.gen.repeat_count = 4;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram
`endif