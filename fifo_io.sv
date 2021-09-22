interface fifo_io(input bit clk);

logic rstp;
logic [7:0] src_in;
logic [7:0] dst_in;
logic [31:0] data_in;
logic readp;
logic writep;
logic [7:0] src_out;
logic [7:0] dst_out;
logic [31:0] data_out;
logic emptyp;
logic fullp;
  
  clocking cb @(posedge clk);
    default input #1 output #1;
    output rstp;
    output src_in;
    output dst_in;
    output data_in;
    output readp;
    output writep;
    input src_out;
    input dst_out;
    input data_out;
    input emptyp;
    input fullp;
  endclocking
  
  clocking ncb @(negedge clk);
    default input #1 output #1;
    output rstp;
    output src_in;
    output dst_in;
    output data_in;
    output readp;
    output writep;
    input src_out;
    input dst_out;
    input data_out;
    input emptyp;
    input fullp;
  endclocking

  modport TB(clocking cb, output rstp,clocking ncb);
endinterface
    