module pipeline_register #(
    parameter DATA_WIDTH = 32
) (
    input  logic                    clk,
    input  logic                    rst_n,
    

    input  logic                    in_valid,
    output logic                    in_ready,
    input  logic [DATA_WIDTH-1:0]   in_data,
    

    output logic                    out_valid,
    input  logic                    out_ready,
    output logic [DATA_WIDTH-1:0]   out_data
);

    logic [DATA_WIDTH-1:0] data_reg;
    logic                  valid_reg;
    
    // Ready when empty or being consumed
    assign in_ready = !valid_reg || out_ready;
    
    // Output from reg
    assign out_valid = valid_reg;
    assign out_data  = data_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_reg  <= '0;
        valid_reg <= 1'b0;
    end
    else begin
        // Update data when accepting input
        if (in_ready && in_valid) begin
            data_reg  <= in_data;
        end
        
        // Update valid
        if (in_ready && in_valid) begin
            valid_reg <= 1'b1;
        end
        else if (out_ready && out_valid) begin
            valid_reg <= 1'b0;
        end
    end
end
endmodule
