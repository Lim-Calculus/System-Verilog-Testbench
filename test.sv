// Code your testbench here
// or browse Examples
// Assignment G20  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// System Verilog Testbench
// ~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//`timescale 1ns/1ps
program automatic test_fifo(fifo_io.TB fifo);
parameter    depth = 2;
parameter MAX_COUNT = (1<<depth);
  
reg [3:0] count_checker;
reg check_last;
reg [7:0] src_rand;
reg [7:0] dst_rand;
reg [31:0] data_rand;


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Generate random number
// ~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
task gen_random();
src_rand=$urandom;
dst_rand=$urandom;
data_rand=$urandom;
endtask




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Reset
// ~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  task reset();
$display("Reset");
 repeat(5)begin
   fifo.cb.rstp<=1;
   fifo.cb.src_in <= 0;
   fifo.cb.dst_in <= 0;
   fifo.cb.data_in <= 0;
   fifo.cb.writep <= 0;
   fifo.cb.readp<=0;   
    @(fifo.cb);
    end
    fifo.cb.rstp<=0;
    @(fifo.cb);
  endtask

task task3;
begin
reset();
$display("Task 3 : Concurrently write and read operations");
// Concurrently but sequentially
fork
repeat(5)
 begin
gen_random();
write(src_rand,dst_rand,data_rand);
read;
end
join
//Concurrently but concurrently
fork 
gen_random();
repeat(5)
 begin
write_concurrent(src_rand,dst_rand,data_rand);
read_concurrent;
end
join
$display("TASK 3 DONE");
end
endtask

task read_concurrent;
  
begin
  @(fifo.cb); //negedge edge
   fifo.cb.readp <= 1;
   
  @(fifo.cb)//posedge edge
   // decrement counter on read if not empty and not writing.
   
  if((fifo.cb.emptyp==1)&&(fifo.cb.fullp==0)&&(fifo_test_top.dut.writep==0)&& (fifo_test_top.dut.readp==1)&&(fifo_test_top.dut.count==0))
   
    begin
      $display("At time %t,Nothing to read, Waiting new data to be written,Only %h is read from FIFO, count=%h",$realtime,{fifo.cb.src_out,fifo.cb.dst_out,fifo.cb.data_out},fifo_test_top.dut.count);    
    end
  else begin
    $display ("At time %t Read %0h from FIFO", $realtime, {fifo.cb.src_out,fifo.cb.dst_out,fifo.cb.data_out});
  end
   #5
   fifo.cb.readp<=0;
   
end
endtask

task write_concurrent (input [7:0] src,input [7:0] dst,
              input [31:0] data);
begin
  @(fifo.ncb);
   fifo.cb.src_in <= src;
   fifo.cb.dst_in <= dst;
   fifo.cb.data_in <= data;
   fifo.cb.writep <= 1;
  
  @(fifo.cb);
   // increment counter on write if not full and not reading.
  

  
  $display ("At time %t, Write %0h to FIFO", $realtime, {src,dst,data});
    if(fifo.cb.fullp==1)
     begin
       $display("Warning : At time %t The content is full, Unable to write %h to memory,count=%h",$realtime,{src,dst,data},fifo_test_top.dut.count);     
     end
   #5;
   fifo.cb.src_in <= 8'b0;
   fifo.cb.dst_in <= 8'b0;
   fifo.cb.data_in <= 32'b0;
   fifo.cb.writep <= 0;
end
endtask

  
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Tasks used to Write and Read to/from FIFO 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
task read;
  
begin
  @(fifo.cb); //negedge edge
   fifo.cb.readp <= 1;
   fifo.cb.writep<=0;
  @(fifo.cb)//posedge edge
   // decrement counter on read if not empty and not writing.
   
  if((fifo.cb.emptyp==1)&&(fifo.cb.fullp==0)&&(fifo_test_top.dut.writep==0)&& (fifo_test_top.dut.readp==1)&&(fifo_test_top.dut.count==0))
   
    begin
      $display("At time %t,Nothing to read, Waiting new data to be written,Only %h is read from FIFO, count=%h",$realtime,{fifo.cb.src_out,fifo.cb.dst_out,fifo.cb.data_out},fifo_test_top.dut.count);    
    end
  else begin
    $display ("At time %t Read %0h from FIFO", $realtime, {fifo.cb.src_out,fifo.cb.dst_out,fifo.cb.data_out});
  end
   #5
   fifo.cb.readp<=0;
   
end
endtask
   
  task write (input [7:0]	src,input [7:0]	dst,
              input [31:0] data);
begin
  @(fifo.ncb);
   fifo.cb.src_in <= src;
   fifo.cb.dst_in <= dst;
   fifo.cb.data_in <= data;
   fifo.cb.writep <= 1;
   fifo.cb.readp<=0;
  @(fifo.cb);
   // increment counter on write if not full and not reading.
  

  
  $display ("At time %t, Write %0h to FIFO", $realtime, {src,dst,data});
    if(fifo.cb.fullp==1)
     begin
       $display("Warning : At time %t The content is full, Unable to write %h to memory,count=%h",$realtime,{src,dst,data},fifo_test_top.dut.count);     
     end
   #5;
   fifo.cb.src_in <= 8'b0;
   fifo.cb.dst_in <= 8'b0;
   fifo.cb.data_in <= 32'b0;
   fifo.cb.writep <= 0;
end
endtask
///////////////////////
initial begin
  $vcdpluson;
 $vcdplusmemon;
  $vcdplusdeltacycleon;
end



initial begin
  
  $dumpfile("dump.vcd"); $dumpvars;
  
  reset();
  task1;
  fork
    begin
  task2;
    end
  join
   
  task3;
  @(fifo.cb);
   $finish;
 end


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// CDANOTE  Verilog Directed Task1
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

task task1;
begin
   fifo.cb.src_in <= 8'b0;
   fifo.cb.dst_in <= 8'b0;
   fifo.cb.data_in <= 32'b0;
   fifo.cb.writep <= 0;
   fifo.cb.readp <= 0;

  
   
  // ** Write 3 values.
   write(0,1,16'h1111);
   write(1,2,16'h2222);
   write(3,4,16'h3333);
   
   // ** Read 2 values
   read;
   read;
   
   // ** Write one more
   write(5,6,16'h4444);
   
   // ** Read a bunch of values
   repeat (6) begin
      read;
   end
   
   // *** Write a bunch more values
  for(int i=1;i<=10;i=i+1) begin
    write(0,1,i);
  end
   // ** Read a bunch of values
  for(int i=0;i<8;i=i+1) begin
      read;
    end
   
  $display ("Done TASK1");
end
endtask

// TEST2
//
// This test will operate the FIFO in an orderly manner the way it normally works.
// 2 threads are forked; a reader and a writer.  The writer writes a counter to
// the FIFO and obeys the fullp flag and delays randomly.  The reader likewise
// obeys the emptyp flag and reads at random intervals.  The result should be that
// the reader reads the incrementing counter out of the FIFO.  The empty/full flags
// should bounce around depending on the random delays.  The writer repeats some<
// fixed number of times and then terminates both threads and kills the sim.
//
task task2;

begin
   fifo.cb.src_in <= 8'b0;
   fifo.cb.dst_in <= 8'b0;
   fifo.cb.data_in <= 32'b0;
 
   fifo.cb.writep <= 0;
   fifo.cb.readp <= 0;

   // Reset
   fifo.rstp <= 1;
   #50;
   fifo.rstp <= 0;
   #50;
  
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// READ AND WRITE TASK
//          concurrently with random delays 
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   fork:write_watch_dog_timer
      // Writer
      begin
         repeat (500) begin
           @(fifo.ncb);
           if (fifo.cb.fullp == 1'b0) begin
               write($random,$random,$random);
               #5;
               
            end
            else begin
              $display ("WRITER is waiting..because of the memory content is full,count =%h",fifo_test_top.dut.count);
            end
            // Delay a random amount of time between 0ns and 100ns
            #(50 + ($random % 50));
         end
         $display ("Done with WRITER fork..");
         //#200 $finish;
      end     
  
     
      
   join_any: write_watch_dog_timer
  disable write_watch_dog_timer;
$display("Exit from write_watch_dog_timer");
      // Reader
  fork:read_watch_dog_timer
     begin
        
           @(fifo.ncb);
           if (fifo.cb.emptyp == 1'b0) begin
               read;
               read;
            end  
       else if (fifo.cb.emptyp==1'b1) begin
              $display ("READER is waiting.. because the content is empty,count =%h",fifo_test_top.dut.count);
            end
            // Delay a random amount of time between 0ns and 100ns
            #(50 + ($random % 50));
         end
  join_any:read_watch_dog_timer
  disable read_watch_dog_timer;
end
  

endtask
  
initial begin
forever begin
 @(fifo.cb) 
    begin
   $timeformat(-9,3," ps",5);
   $display ("time = %t", $realtime);
   end


@(fifo.cb) begin
 $display ("fullp = %0b", fifo.cb.fullp);
  
end
  
  
  
 
 @(fifo.cb) begin
   $display ("emptyp = %0b", fifo.cb.emptyp);
  end
  
  @(fifo_test_top.dut.count) begin
    $display ("count = %h", fifo_test_top.dut.count);
  end
    
  end
end
  

endprogram
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