
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NOTE Verilog Synchronous FIFO 
//         4 x 16 bit words
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

module fifo (clk, rstp, src_in, dst_in, data_in, writep, readp, 
	src_out, dst_out, data_out, emptyp, fullp);
  
parameter	DEPTH = 2,		// 2 bits, e.g. 4 words in the FIFO.
			MAX_COUNT = (1<<DEPTH);	// topmost address in FIFO.
input		clk;
input		rstp;
input [7:0]	src_in;
input [7:0]	dst_in;
input [31:0]	data_in;
input		readp;
input		writep;
output [7:0]	src_out;
output [7:0]	dst_out;
output [31:0]	data_out;
output		emptyp;
output		fullp;
reg [47:0] fifomem[0:MAX_COUNT];

// Defines sizes in terms of bits.
//


reg 		emptyp;
reg		fullp;

// Registered output.
reg [7:0]	src_out;
reg [7:0]	dst_out;
reg [31:0]	data_out;

// Define the FIFO pointers.  A FIFO is essentially a circular queue.
//
reg [(DEPTH-1):0]	tail;
reg [(DEPTH-1):0]	head;

// Define the FIFO counter.  Counts the number of entries in the FIFO which
// is how we figure out things like Empty and Full.
//
reg [DEPTH:0]	count;

// Define our regsiter bank. 


//reg [47:0] fifomem[0:MAX_COUNT];

// Dout is registered and gets the value that tail points to RIGHT NOW.
//
integer i;
always @(posedge clk or posedge rstp) begin
   if (rstp == 1) begin
      src_out <= 8'b0;
      dst_out <= 8'b0;
      data_out <= 32'b0;
   end
   else begin
     {src_out,dst_out,data_out} <= fifomem[tail]; //src_out=fifomem[47:40],dst_out=fifomem[39:32],data_out=fifomem[31:0]
   end
end 
     
// Update FIFO memory.
  always @(posedge clk) //if writep==1 and fullp ==1, then fifomem[head]={src_in,dst_in,data_in}
   if (rstp == 1'b0) begin
     if (writep == 1'b1 && fullp == 1'b0)
      fifomem[head] <= {src_in,dst_in,data_in};
   end

// Update the head register.
//
always @(posedge clk) begin
   if (rstp == 1'b1) begin
      head <= 0; //if reset, then head=0;
   end
   else begin
     if (writep == 1'b1 && fullp == 1'b0) begin //if write happen, head=head+1
         // WRITE
         head <= head + 1;
      end
   end
end

// Update the tail register.
//
always @(posedge clk) begin
  if (rstp == 1'b1) begin //if reset happens, tail ==0;
      tail <= 0;
   end
   else begin
     if (readp == 1'b1 && emptyp == 1'b0) begin //if read happen, tail =tail+1
         // READ               
         tail <= tail + 1;
      end
   end
end

// Update the count regsiter.
//
always @(posedge clk) begin
   if (rstp == 1'b1) begin
      count <= 0;
   end
   else begin
      case ({readp, writep})
         2'b00: count <= count;
         2'b01: 
            // WRITE
            if (!fullp) 
               count <= count + 1;
         2'b10: 
            // READ
            if (!emptyp)
               count <= count - 1;
         2'b11:
            // Concurrent read and write.. no change in count
            count <= count;
      endcase
   end
end

         
// *** Update the flags
//
// First, update the empty flag.
//
always @(count) begin
   if (count == 0)
     emptyp = 1'b1;
   else
     emptyp = 1'b0;
end


// Update the full flag
//
always @(count) begin
   if (count < MAX_COUNT)
      fullp = 1'b0;
   else
      fullp = 1'b1;
end

endmodule



