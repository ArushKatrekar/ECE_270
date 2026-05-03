module clock_psc (input logic clk,input  logic rst,input  logic [7:0]lim,output logic hzX);
    logic [7:0]ctr;
    logic hzX_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ctr <= 8'd0;
            hzX_reg <= 1'b0;
        end else begin
            if (ctr == lim) begin
                hzX_reg <= ~hzX_reg;
                ctr     <= 8'd0;
            end else begin
                ctr <= ctr + 1;
            end
        end
    end

    assign hzX = (lim == 8'd0) ? clk : hzX_reg;
endmodule