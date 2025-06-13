module tb_fifo_synch;
    // DUT inputs
    logic clk; 
    logic rst; 
    logic wr_en; 
    logic rd_en; 
    logic [7:0] din ;
    
    // DUT outputs
    logic [7:0] dout; 
    logic isfull; 
    logic isempty; 
    
    // Instantiate DUT
    fifo_synch dut(
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .isfull(isfull),
        .isempty(isempty)
    );
    
    // Model queue to track expected output (test 2 mixed rates r/w)
    byte model[$];  
    byte expected; //temp 
    byte next_din; 
    
    // Inputs for test 2 mixed rates r/w
    integer write_interval = 2; // write every write_interval cycles
    integer read_interval = 3;  // read every read_interval cycles
    integer num_cycles = 10;   // number of clock cycles
    
    // Internal counters for stimulus control in test 2
    integer write_counter = 0; 
    integer read_counter = 0; 
    
            
    // Generate clock 
    always #5 clk = ~clk; 
    
    initial begin
        $display("Starting sycnh FIFO simulation..."); 
        // Apply rest
        clk = 0;
        rst = 1; 
        wr_en = 0;
        rd_en = 0; 
        din = 0; 
        
        #20 rst = 0; 
        
        // ------------------------------------------------------
        // Test 1: Fill FIFO, then empty FIFO
        // ------------------------------------------------------
        $display("Test 1: Fill FIFO, then empty FIFO"); 
        // Write to FIFO
        repeat (16) begin
            @(posedge clk);
            wr_en = 1; 
            din = din + 1; 
        end
        @(posedge clk); 
        wr_en = 0; 
        
        // Read FIFO
        repeat (16) begin
            @(posedge clk); 
            rd_en = 1; 
        end
        // Wait for empty flag to update
        @(posedge clk); 
        rd_en = 0; 
        @(posedge clk); 
        
        //Check empty
        assert(isempty) else $fatal("Test 1 failed: FIFO should be empty after 16 reads"); 
        $display("Test 1 passed"); 
        
        
        // ------------------------------------------------------
        // Test 2: Mixed-rate read/write
        // ------------------------------------------------------
        $display("Test 2: Mixed rate/write"); 
        
        // Reset DUT (for easier waveform analysis)
        rst = 1; 
        wr_en = 0; 
        rd_en = 0; 
        din = 0; 
        @(posedge clk); 
        rst = 0; 
        @(posedge clk);
        
        repeat(num_cycles) begin
            @(posedge clk);
            // Default
            wr_en = 0; 
            rd_en = 0; 
            
            // Write to FIFO (every write_interval cycles)
            if(!isfull && (write_counter % write_interval == 0)) begin 
                wr_en = 1; 
                next_din = din + 1; 
                din = next_din;  
                model.push_back(next_din); // Track expected output
                //$display("  Wrote din=%0d", next_din); 
            end 
            
            // Read FIFO (read at every read_interval cycles)
            if(!isempty && (read_counter % read_interval == 0)) begin
                rd_en = 1; 
            end 
            
            // Compare dout to expected output
            if(rd_en) begin
                #1; 
                if(model.size() > 0) begin
                    expected = model.pop_front(); 
                    //$display("  Read dout=%0d", dout); 
                    assert(dout == expected) else $fatal("Mismatch: expected: %0d, dout: %0d", expected, dout);      
                end else begin
                    $fatal("Unexpected read - model empty"); 
                end
            end
            
            write_counter++; 
            read_counter++; 
        end
        
        wr_en = 0; 
        rd_en = 0;  
        
        // Empty FIFO
        $display("Emptying FIFO in test 2 (mixed rate r/w)"); 
        while(model.size() > 0) begin
            rd_en = 1;  
            @(posedge clk);
            #1
            expected = model.pop_front(); 
            $display("Emptying check: dout=%0d, expected=%0d", dout, expected); 
            assert(dout == expected) else $fatal("Empyting FAILED: Expected %0d, got %0d", expected, dout); 
        end
        
        rd_en = 0; 
        
        // Allow flags to settle
        @(posedge clk); 
        @(posedge clk); 
        // Final checks
        assert (model.size() == 0) else $fatal("Test 2 FAILED: Model queue not empty, model contains at least: %0d", model.pop_front()); 
        assert (isempty) else $fatal("Test 2 FAILED: FIFO not empty"); 

        $display("Test 2 PASSED: All data matched.");
        $display("All tests PASSED"); 
        $finish; 
        
    end
endmodule
