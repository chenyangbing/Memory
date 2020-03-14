`ifndef DRIVER
`define DRIVER
`include "transaction.sv"
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 

`define DRIV_IF mem_vif.DRIVER.driver_cb
class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual mem_intf mem_vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual mem_intf mem_vif,mailbox gen2driv);
    //getting the interface
    this.mem_vif = mem_vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(mem_vif.reset);
    $display("--------- [DRIVER] Reset Started ---------");
    `DRIV_IF.wr_en <= 0;
    `DRIV_IF.rd_en <= 0;
    `DRIV_IF.addr  <= 0;
    `DRIV_IF.wdata <= 0;        
    wait(!mem_vif.reset);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask
  
  //drivers the transaction items to interface signals
  task drive;
      transaction trans;
      `DRIV_IF.wr_en <= 0;
      `DRIV_IF.rd_en <= 0;
      gen2driv.get(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      @(posedge mem_vif.DRIVER.clk);
        `DRIV_IF.addr <= trans.addr;
      if(trans.wr_en) begin
        `DRIV_IF.wr_en <= trans.wr_en;
        `DRIV_IF.wdata <= trans.wdata;
        $display("\tADDR = %0h \tWDATA = %0h",trans.addr,trans.wdata);
        @(posedge mem_vif.DRIVER.clk);
      end
      if(trans.rd_en) begin
        `DRIV_IF.rd_en <= trans.rd_en;
        @(posedge mem_vif.DRIVER.clk);
        `DRIV_IF.rd_en <= 0;
        @(posedge mem_vif.DRIVER.clk);
        trans.rdata = `DRIV_IF.rdata;
        $display("\tADDR = %0h \tRDATA = %0h",trans.addr,`DRIV_IF.rdata);
      end
      $display("-----------------------------------------");
      no_transactions++;
  endtask
  
    
  //
  task main;
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          wait(mem_vif.reset);
        end
        //Thread-2: Calling drive task
        begin
          forever
            drive();
        end
      join_any
      disable fork;
    end
  endtask
        
endclass
`endif