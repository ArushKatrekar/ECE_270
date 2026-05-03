`default_nettype none

module top (input logic hz100,reset,input logic[20:0] pb, output logic [7:0] left, right,
           ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
    output logic red, green, blue,
    output logic [7:0] txdata,
    input  logic [7:0] rxdata,
    output logic txclk, rxclk,
    input  logic txready, rxready
);
  mux4to1 m(.d(pb[3:0]), .sel(pb[5:4]), .y(right[0]));  
endmodule
module mux4to1(input logic [3:0] d, input logic [1:0] sel,output logic y);
    assign y =d[sel];
endmodule

