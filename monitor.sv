`ifndef MONITOR
`define MONITOR

`include "transaction.sv"
//Samples the interface signals, captures into transaction packet and send the packet to scoreboard.

`define MON_IF mem_vif.MONITOR.monitor_cb
class monitor;
  
  //creating virtual interface handle
  virtual mem_intf mem_vif;
  
  //creating mailbox handle
  mailbox mon2scb;
  
  //constructor
  function new(virtual mem_intf mem_vif,mailbox mon2scb);
    //getting the interface
    this.mem_vif = mem_vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
    forever begin
      transaction trans;
      trans = new();

      @(posedge mem_vif.MONITOR.clk);
      wait(`MON_IF.rd_en || `MON_IF.wr_en);
        trans.addr  = `MON_IF.addr;
        trans.wr_en = `MON_IF.wr_en;
        trans.wdata = `MON_IF.wdata;
        if(`MON_IF.rd_en) begin
          trans.rd_en = `MON_IF.rd_en;
          @(posedge mem_vif.MONITOR.clk);
          @(posedge mem_vif.MONITOR.clk);
          trans.rdata = `MON_IF.rdata;
        end      
        mon2scb.put(trans);
    end
  endtask
  
endclass
`endif
