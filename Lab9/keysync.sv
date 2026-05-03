module keysync (input  logic clk,input  logic rst,input  logic [19:0] keyin,output logic [4:0]  keyout,output logic keyclk);
    logic any_key;
    logic sync1, sync2;

    assign keyout[0] = keyin[1]|keyin[3]|keyin[5]|keyin[7]|keyin[9]|keyin[11]|keyin[13]|keyin[15]|keyin[17]|keyin[19];
    assign keyout[1] = keyin[2]|keyin[3]|keyin[6]|keyin[7]|keyin[10]|keyin[11]|keyin[14]|keyin[15]|keyin[18]|keyin[19];
    assign keyout[2] = keyin[4]|keyin[5]|keyin[6]|keyin[7]|keyin[12]|keyin[13]|keyin[14]|keyin[15];
    assign keyout[3] = keyin[8]|keyin[9]|keyin[10]|keyin[11]|keyin[12]|keyin[13]|keyin[14]|keyin[15];
    assign keyout[4] = keyin[16]|keyin[17]|keyin[18]|keyin[19];
    assign any_key = |keyin;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sync1 <= 1'b0;
            sync2 <= 1'b0;
        end else begin
            sync1 <= any_key;
            sync2 <= sync1;
        end
    end
    assign keyclk = sync2;
endmodule