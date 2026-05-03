module sequence_sr (input  logic clk,input  logic rst,input  logic en,input  logic  button, output logic [7:0]seq);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            seq <= 8'b0;
        end else begin
            if (en) begin
                seq <= {seq[6:0], button};
            end
        end
    end

endmodule
