`ifndef SCOREBOARD
`define SCOREBOARD

`include "transaction.sv"
//gets the packet from monitor, Generated the expected result and compares with the //actual result recived from Monitor

class scoreboard;
   
  //creating mailbox handle
  mailbox mon2scb;
  
  //used to count the number of transactions
  int no_transactions;
  
  //array to use as local memory
  bit [7:0] mem[4];
  
  //constructor
  function new(mailbox mon2scb);
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
    foreach(mem[i]) mem[i] = 8'hFF;
  endfunction
  
  //stores wdata and compare rdata with stored data
  task main;
    transaction trans;
    forever begin
      #50;
      mon2scb.get(trans);
      if(trans.rd_en) begin
        if(mem[trans.addr] != trans.rdata) 
          $error("[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.addr,mem[trans.addr],trans.rdata);
        else 
          $display("[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.addr,mem[trans.addr],trans.rdata);
      end
      else if(trans.wr_en)
        mem[trans.addr] = trans.wdata;

      no_transactions++;
    end
  endtask
  
endclass
`endif