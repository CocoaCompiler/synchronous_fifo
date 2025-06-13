// Synchronous FIFO (Data width = 8-bits, Depth = 16, address width = 4)
module fifo_synch(
    input clk,                  // System clock
    input rst,                  // Synchronous reset 
    input wr_en,                // Write enable - write din to FIFO if not full
    input [7:0] din,            // 8-bit data input 
    input rd_en,                // Read enable - reads data from FIFO if not empty
    output reg [7:0] dout,      // 8-bit data output
    output reg isfull,          // FIFO is full - don't write
    output reg isempty          // FIFO is empty - don't read
    );
    reg [7:0] mem [0:15];       // 16 entries of 8-bit each
    reg [3:0] rdptr, wrptr;     // read and write pointers 
    
    always @(posedge clk) begin
        if(rst) begin
            dout <= 8'b0; 
            isempty <= 1; 
            isfull <= 0; 
            rdptr <= 0; 
            wrptr <= 0; 
            //count <= 0; 
        end else begin
            if(wr_en && !isfull) begin
                $display("           wrote mem[%0d] = %0d", wrptr, din); 
                mem[wrptr] <= din;
                wrptr <= (wrptr + 1) & 4'b1111; // wrap to 0 after 15 
            end 
            if(rd_en && !isempty) begin
                $display("           read dout = mem[%0d] = %0d", rdptr, mem[rdptr]); 
                dout <= mem[rdptr];
                rdptr <= (rdptr + 1) & 4'b1111; // wrap to 0 after 15
            end
        end
         //$display("wrptr+1=%0d, rdptr=%0d", wrptr+1, rdptr);
         isfull <= ((wrptr+1) == rdptr); 
         isempty <= (wrptr == rdptr); 
    end
endmodule
