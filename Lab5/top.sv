`default_nettype none
module top (

input  logic hz100, reset,
input  logic [20:0] pb,
output logic [7:0] left, right,
ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
output logic red, green, blue,
output logic [7:0] txdata,
input  logic [7:0] rxdata,
output logic txclk, rxclk,
input  logic txready, rxready

);

logic R, S, T, U;
assign R = pb[3];
assign S = pb[2];
assign T = pb[1];
assign U = pb[0];
logic [7:0] p_low;
logic [7:0] p_high;
hc138 u1 (.a(U), .b(T), .c(S),.e1(1'b0), .e2(R), .e3(1'b1),.y(p_low));

hc138 u2 (.a(U), .b(T), .c(S),.e1(1'b0), .e2(1'b0), .e3(R),.y(p_high));
logic [15:0] p;
assign p[7:0]  = p_low;
assign p[15:8] = p_high;
assign right[0] = ~(p[5]  & p[10] & p[12]);
assign right[1] = ~(p[1]  & p[8]  & p[11]);
assign right[2] = ~(p[4]  & p[6]  & p[7]);
assign right[3] = ~(p[2]  & p[3]  & p[13]);
assign right[4] = ~(p[0]  & p[9]  & p[14]);
assign right[5] = p[9]  & p[14];
assign right[6] = p[0]  & p[3];
assign right[7] = p[2]  & p[13];
endmodule

module hc138 (input  logic a, b, c,input  logic e1, e2, e3,output logic [7:0] y);
logic enable;
logic [2:0] sel;
assign enable = ~e1 & ~e2 & e3;
assign sel = {c, b, a};
assign y[0] = ~(enable & (sel == 3'd0));
assign y[1] = ~(enable & (sel == 3'd1));
assign y[2] = ~(enable & (sel == 3'd2));
assign y[3] = ~(enable & (sel == 3'd3));
assign y[4] = ~(enable & (sel == 3'd4));
assign y[5] = ~(enable & (sel == 3'd5));
assign y[6] = ~(enable & (sel == 3'd6));
assign y[7] = ~(enable & (sel == 3'd7));
endmodule