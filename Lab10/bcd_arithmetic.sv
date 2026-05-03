module fa(input  logic a, b, ci, output logic s, co);
  assign s  = a ^ b ^ ci;
  assign co = (a & b) | (a & ci) | (b & ci);
endmodule
module fa4(input  logic [3:0] a, b,input  logic ci,output logic [3:0] s,output logic co);
  logic c1, c2, c3;
  fa f0(.a(a[0]),.b(b[0]), .ci(ci), .s(s[0]), .co(c1));
  fa f1(.a(a[1]), .b(b[1]), .ci(c1),.s(s[1]),.co(c2));
  fa f2(.a(a[2]),.b(b[2]), .ci(c2), .s(s[2]),.co(c3));
  fa f3(.a(a[3]), .b(b[3]), .ci(c3),.s(s[3]), .co(co));
endmodule
module bcdadd1(input  logic [3:0] a, b,input  logic ci,output logic [3:0] s,output logic co);
  logic [3:0] tmp_s;
  logic tmp_co, unused_co;
  logic correction;
  fa4 first_add(.a(a), .b(b), .ci(ci), .s(tmp_s), .co(tmp_co));
  assign correction = tmp_co|(tmp_s[3] & tmp_s[2])|(tmp_s[3] & tmp_s[1]);
  assign co = correction;
  fa4 second_add(.a(tmp_s), .b(correction ? 4'b0110 : 4'b0000), .ci(1'b0), .s(s), .co(unused_co));
endmodule
module bcdadd4(input  logic [15:0] a, b,input  logic ci,output logic [15:0] s,output logic co);
  logic c1, c2, c3, unused_co;
  bcdadd1 d0(.a(a[3:0]),.b(b[3:0]),.ci(ci),.s(s[3:0]),.co(c1));
  bcdadd1 d1(.a(a[7:4]),.b(b[7:4]),.ci(c1),.s(s[7:4]),.co(c2));
  bcdadd1 d2(.a(a[11:8]),.b(b[11:8]),.ci(c2),.s(s[11:8]),.co(c3));
  bcdadd1 d3(.a(a[15:12]), .b(b[15:12]), .ci(c3), .s(s[15:12]), .co(unused_co));
  assign co = unused_co;
endmodule
module bcd9comp1(
  input  logic [3:0] in,
  output logic [3:0] out
);
  always_comb begin
    case(in)
      4'd0: out = 4'd9;
      4'd1: out = 4'd8;
      4'd2: out = 4'd7;
      4'd3: out = 4'd6;
      4'd4: out = 4'd5;
      4'd5: out = 4'd4;
      4'd6: out = 4'd3;
      4'd7: out = 4'd2;
      4'd8: out = 4'd1;
      4'd9: out = 4'd0;
      default: out = 4'd0;
    endcase
  end
endmodule
module bcdaddsub4(input  logic[15:0]a,b,input logic op,output logic[15:0]s);
  logic [3:0] comp0, comp1, comp2, comp3;
  logic [15:0] b_used;
  bcd9comp1 c0(.in(b[3:0]),.out(comp0));
  bcd9comp1 c1(.in(b[7:4]),.out(comp1));
  bcd9comp1 c2(.in(b[11:8]),.out(comp2));
  bcd9comp1 c3(.in(b[15:12]),.out(comp3));
  assign b_used = op ? {comp3,comp2,comp1,comp0}:b;
  bcdadd4 adder(.a(a),.b(b_used),.ci(op),.s(s),.co());
endmodule