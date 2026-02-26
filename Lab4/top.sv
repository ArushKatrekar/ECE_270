`default_nettype none
   module top (
    // I/O ports
   input  logic hz100, reset,
   input  logic [20:0] pb,
   output logic [7:0] left, right,
   ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
   output logic red, green, blue,
    // UART ports
   output logic [7:0] txdata,
   input  logic [7:0] rxdata,
   output logic txclk, rxclk,
   input  logic txready, rxready
   );

   // Your code goes here...

   assign ss0[0] = pb[0];
   assign ss0[1] = pb[1];
   assign ss0[2] = pb[2];
   assign ss0[3] = pb[3];
   assign ss0[4] = pb[4];
   assign ss0[5] = pb[5];
   assign ss0[6] = pb[6];
   //assign ss0[7] = pb[7];

bargraph v1 (.in (pb[15:0]), .out({left[7:0], right[7:0]}));
decode3to8 v2 (.in (pb[2:0]), .out({ss7[7], ss6[7], ss5[7], ss4[7], ss3[7], ss2[7], ss1[7], ss0[7]}));
endmodule

module bargraph(input logic [15:0] in, output logic [15:0] out);
// If any two inputs are '1', the output should be '1'.
//input logic [15:0] in;
//output logic [15:0] out;

//out[0] = in[0];
//assign out[0]  = in[0] | in[0] & in[1];

assign out[0]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7] | in[6] | in[5] | in[4] | in[3] | in[2] | in[1] | in[0];
assign out[1]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7] | in[6] | in[5] | in[4] | in[3] | in[2] | in[1];
assign out[2]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7] | in[6] | in[5] | in[4] | in[3] | in[2];
assign out[3]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7] | in[6] | in[5] | in[4] | in[3];
assign out[4]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7] | in[6] | in[5] | in[4];
assign out[5]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7] | in[6] | in[5];
assign out[6]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7] | in[6];
assign out[7]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8] | in[7];
assign out[8]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9] | in[8];
assign out[9]  = in[15] | in[14] | in[13] | in[12] | in[11] | in[10] | in[9];
assign out[10] = in[15] | in[14] | in[13] | in[12] | in[11] | in[10];
assign out[11] = in[15] | in[14] | in[13] | in[12] | in[11];
assign out[12] = in[15] | in[14] | in[13] | in[12];
assign out[13] = in[15] | in[14] | in[13];
assign out[14] = in[15] | in[14];
assign out[15] = in[15];
//assign out[0]  = (in[1] | in[0]);

//assign left[1]  | = pb[1]


endmodule


module decode3to8 (input logic [2:0] in, output logic [7:0] out);

assign out[0] = (in[2:0] == 3'b000);
assign out[1] = (in[2:0] == 3'b001);
assign out[2] = (in[2:0] == 3'b010);
assign out[3] = (in[2:0] == 3'b011);
assign out[4] = (in[2:0] == 3'b100);
assign out[5] = (in[2:0] == 3'b101);
assign out[6] = (in[2:0] == 3'b110);
assign out[7] = (in[2:0] == 3'b111);


endmodule

(~((~(~w) | ~(x & ~(~y | ~z) | ~x & ~(y | ~z)) | ~w )) | (~(x & ~z)))




