`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // Ports from/to UART
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  prienc16to4 pe(.in(pb[15:0]), .out(right[3:0]), .strobe(right[4]));
  //ssdec sd(.in(enc_out), .enable(strobe), .out(ss0[6:0]));

  // Your code goes here...
  
endmodule

module prienc16to4 (
  input  logic [15:0] in,
  output logic [3:0]  out,
  output logic        strobe
);
  assign {out, strobe} =
    in[15] ? 5'b11111 :
    in[14] ? 5'b11101 :
    in[13] ? 5'b11011 :
    in[12] ? 5'b11001 :
    in[11] ? 5'b10111 :
    in[10] ? 5'b10101 :
    in[9]  ? 5'b10011 :
    in[8]  ? 5'b10001 :
    in[7]  ? 5'b01111 :
    in[6]  ? 5'b01101 :
    in[5]  ? 5'b01011 :
    in[4]  ? 5'b01001 :
    in[3]  ? 5'b00111 :
    in[2]  ? 5'b00101 :
    in[1]  ? 5'b00011 :
    in[0]  ? 5'b00001 :
             5'b00000;
endmodule