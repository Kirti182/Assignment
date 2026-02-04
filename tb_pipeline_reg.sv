module tb_pipeline_register;

    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10;
    
    logic                    clk;
    logic                    rst_n;
    logic                    in_valid;
    logic                    in_ready;
    logic [DATA_WIDTH-1:0]   in_data;
    logic                    out_valid;
    logic                    out_ready;
    logic [DATA_WIDTH-1:0]   out_data;
    

    pipeline_register #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (.*);
    

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
 
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pipeline_register);
    end
    
    // Test stimulus
    initial begin
        $display("Starting Pipeline Register Test\n");
        

        rst_n = 0;
        in_valid = 0;
        in_data = 0;
        out_ready = 0;
        
 
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        // Test 1: Basic transfer
        $display("Test 1: Basic Transfer");
        in_valid = 1;
        in_data = 32'hDEADBEEF;
        @(posedge clk);  
        in_valid = 0;
        @(posedge clk); 
        
        if (out_valid && out_data == 32'hDEADBEEF)
            $display("  PASS: Data transferred\n");
        else
            $display("  FAIL: Expected 0x%h, got 0x%h\n", 32'hDEADBEEF, out_data);
        
        out_ready = 1;
        @(posedge clk);
        out_ready = 0;
        @(posedge clk);
        
        // Test 2: Backpressure 
        $display("Test 2: Backpressure Handling");
        in_valid = 1;
        in_data = 32'h12345678;
        out_ready = 0;  
        @(posedge clk); 
        @(posedge clk); 
        
        if (out_valid && out_data == 32'h12345678 && !in_ready)
            $display("  PASS: Data held during backpressure\n");
        else
            $display("  FAIL: Backpressure not handled correctly\n");
        
        in_valid = 0;
        @(posedge clk);
        
        if (out_valid && out_data == 32'h12345678)
            $display("  PASS: No data loss\n");
        else
            $display("  FAIL: Data lost\n");
        
        out_ready = 1;
        @(posedge clk);
        out_ready = 0;
        @(posedge clk);
        
        // Test 3: No duplication
        $display("Test 3: No Duplication");
        in_valid = 1;
        in_data = 32'hAAAABBBB;
        out_ready = 1;
        @(posedge clk); 
        in_valid = 0;
        out_ready = 0;
        @(posedge clk);
        @(posedge clk); 
        
        if (!out_valid)
            $display("  PASS: Data consumed, no duplication\n");
        else
            $display("  FAIL: Data duplicated\n");

        
        // Test 4: Reset to empty
        $display("Test 4: Reset Functionality");
        in_valid = 1;
        in_data = 32'hFFFFFFFF;
        @(posedge clk);
        in_valid = 0;
        
        rst_n = 0;
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        if (!out_valid && in_ready)
            $display("  PASS: Reset to empty state\n");
        else
            $display("  FAIL: Reset failed\n");
        
        repeat(5) @(posedge clk);
        $display("All tests completed!");
        $finish;
    end

endmodule
