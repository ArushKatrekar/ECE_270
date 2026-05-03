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
  logic [3:0] enc_out;
  logic strobe;

  //prienc16to4 pe(.in(pb[15:0]), .out(enc_out), .strobe(strobe));
  ssdec sd(.in(enc_out), .enable(strobe), .out(ss0[6:0]));

  // Your code goes here...
  
endmodule

module ssdec(input logic [3:0] in, input logic enable, output logic [6:0] out);
  //assign {ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0} = enable ? (8'b00000001 << in) : 8'b00000000;
assign out = enable ?(
    in == 4'b0000 ? 7'b0111111 :
    in == 4'b0001 ? 7'b0000110 :
    in == 4'b0010 ? 7'b1011011 :
    in == 4'b0011 ? 7'b1001111 :
    in == 4'b0100 ? 7'b1100110 :
    in == 4'b0101 ? 7'b1101101 :
    in == 4'b0110 ? 7'b1111101 :
    in == 4'b0111 ? 7'b0000111 :
    in == 4'b1000 ? 7'b1111111 :
    in == 4'b1001 ? 7'b1100111 :
    in == 4'b1010 ? 7'b1110111 :
    in == 4'b1011 ? 7'b1111100 :
    in == 4'b1100 ? 7'b0111001 :
    in == 4'b1101 ? 7'b1011110 :
    in == 4'b1110 ? 7'b1111001 :
                    7'b1110001 ):
    7'b0000000;
endmodule
