module fifo_test_top; 
  parameter simulation_cycle = 100; 
 
  bit SystemClock; 
  fifo_io top_io(SystemClock); 
  test_fifo t(top_io); 
   
 
  fifo dut( 
    .clk (top_io.clk), 
    .rstp (top_io.rstp), 
    .src_in (top_io.src_in), 
    .dst_in (top_io.dst_in), 
    .data_in (top_io.data_in), 
    .readp (top_io.readp), 
    .writep (top_io.writep), 
    .src_out (top_io.src_out), 
    .dst_out (top_io.dst_out), 
    .data_out (top_io.data_out), 
    .emptyp (top_io.emptyp), 
    .fullp (top_io.fullp) 
  ); 
 
  initial begin 
  $timeformat (-9, 1, "ns", 10); 
    SystemClock = 0; 
    forever begin 
      #(simulation_cycle/2) 
        SystemClock = ~SystemClock; 
    end 
  end 
 
endmodule
