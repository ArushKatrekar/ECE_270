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

  hc74_reset ff_reset (.c  (pb[0]),.rn (pb[16]),.d  (pb[1]),.q  (right[0]),.qn ());
  hc74_set ff_set (.c  (pb[0]),.sn (pb[16]),.d  (pb[1]),.q  (right[1]),.qn ());

endmodule


module hc74_reset (input  logic d,input  logic c,input  logic rn,output logic q,output logic qn);
  always @(posedge c, negedge rn) begin
    if (~rn)
      q <= 1'b0;
    else
      q <= d;
  end

  assign qn = ~q;
endmodule

module hc74_set (input  logic d,input  logic c,input  logic sn,output logic q,output logic qn);
  always @(posedge c, negedge sn) begin
    if (~sn)
      q <= 1'b1;
    else
      q <= d;
  end

  assign qn = ~q;
endmodule