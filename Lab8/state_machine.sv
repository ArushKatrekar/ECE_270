`default_nettype none
module top (input logic hz100,reset,input logic[20:0] pb,output logic[7:0] left, right, ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,output logic red, green, blue,output logic[7:0] txdata,input logic[7:0] rxdata,output logic txclk, rxclk,input  logic txready, rxready);
  logic [2:0] q;
  logic [2:0] next_q;
  logic [1:0] f;
  logic [7:0] p;

  // pb[0] = clock, pb[1] = async reset to state 6
  always @(posedge pb[0],posedge pb[1]) begin
    if (pb[1])
      q <= 3'b110;
    else
      q <= next_q;
  end

  hc138 decode (.a(q),.e1(1'b0),.e2(1'b0),.e3(1'b1),.y(p));
  hc151 mux1 (.i(8'b10110010),.s(q),.e(1'b1),.z(f[0]));
  hc151 mux2 (.i(8'b10010000),.s(q),.e(1'b1),.z(f[1]));

  assign next_q[0] = ~(p[0] & p[1] & p[2] & p[5]);
  assign next_q[1] = ~(p[0] & p[4] & p[5] & p[6]);
  assign next_q[2] = ~(p[0] & p[1] & p[4] & p[7]);

  assign right[2:0] = q;
  assign left[2:0]  = next_q;
  assign right[7:6] = f;
endmodule


module hc138 (input  logic[2:0] a,input logic e1, e2, e3,output logic[7:0] y);
  always @(*) begin
    if (e1 | e2 | ~e3)
      y = 8'hFF;
    else
      y = ~(8'b1 << a);
  end
endmodule

module hc151 (input logic[7:0] i,input logic[2:0] s,input logic e,output logic z);
  always @(*) begin
    if (~e)
      z = 1'b0;
    else
      z = i[s];
  end
endmodule