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

logic [15:0] s;
bcdaddsub4 bas4(.a(16'h0000), .b(16'h0001), .op(1), .s(s));
ssdec s0(.in(s[3:0]),   .out(ss0[6:0]), .enable(1));
ssdec s1(.in(s[7:4]),   .out(ss1[6:0]), .enable(1));
ssdec s2(.in(s[11:8]),  .out(ss2[6:0]), .enable(1));
ssdec s3(.in(s[15:12]), .out(ss3[6:0]), .enable(1));

endmodule

// ============================================================
// Full Adder
// ============================================================
module fa(
  input  logic a, b, ci,
  output logic s, co
);
  assign s  = a ^ b ^ ci;
  assign co = (a & b) | (a & ci) | (b & ci);
endmodule

// ============================================================
// 4-bit Full Adder
// ============================================================
module fa4(
  input  logic [3:0] a, b,
  input  logic ci,
  output logic [3:0] s,
  output logic co
);
  logic c1, c2, c3;
  fa f0(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]), .co(c1));
  fa f1(.a(a[1]), .b(b[1]), .ci(c1), .s(s[1]), .co(c2));
  fa f2(.a(a[2]), .b(b[2]), .ci(c2), .s(s[2]), .co(c3));
  fa f3(.a(a[3]), .b(b[3]), .ci(c3), .s(s[3]), .co(co));
endmodule

// ============================================================
// BCD 1-digit adder
// ============================================================
module bcdadd1(
  input  logic [3:0] a, b,
  input  logic ci,
  output logic [3:0] s,
  output logic co
);
  logic [3:0] tmp_s;
  logic tmp_co, unused_co;
  logic correction;

  fa4 first_add(.a(a), .b(b), .ci(ci), .s(tmp_s), .co(tmp_co));
  assign correction = tmp_co | (tmp_s[3] & tmp_s[2]) | (tmp_s[3] & tmp_s[1]);
  assign co = correction;
  fa4 second_add(.a(tmp_s), .b(correction ? 4'b0110 : 4'b0000), .ci(1'b0), .s(s), .co(unused_co));
endmodule

// ============================================================
// BCD 4-digit adder
// ============================================================
module bcdadd4(
  input  logic [15:0] a, b,
  input  logic ci,
  output logic [15:0] s,
  output logic co
);
  logic c1, c2, c3, unused_co;
  bcdadd1 d0(.a(a[3:0]),   .b(b[3:0]),   .ci(ci), .s(s[3:0]),   .co(c1));
  bcdadd1 d1(.a(a[7:4]),   .b(b[7:4]),   .ci(c1), .s(s[7:4]),   .co(c2));
  bcdadd1 d2(.a(a[11:8]),  .b(b[11:8]),  .ci(c2), .s(s[11:8]),  .co(c3));
  bcdadd1 d3(.a(a[15:12]), .b(b[15:12]), .ci(c3), .s(s[15:12]), .co(unused_co));
  assign co = unused_co;
endmodule

// ============================================================
// BCD 9's complement (1 digit)
// ============================================================
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

// ============================================================
// BCD Add/Subtract (4 digits)
// ============================================================
module bcdaddsub4(
  input  logic [15:0] a, b,
  input  logic op,
  output logic [15:0] s
);
  logic [3:0] comp0, comp1, comp2, comp3;
  logic [15:0] b_used;

  bcd9comp1 c0(.in(b[3:0]),   .out(comp0));
  bcd9comp1 c1(.in(b[7:4]),   .out(comp1));
  bcd9comp1 c2(.in(b[11:8]),  .out(comp2));
  bcd9comp1 c3(.in(b[15:12]), .out(comp3));

  assign b_used = op ? {comp3, comp2, comp1, comp0} : b;
  bcdadd4 adder(.a(a), .b(b_used), .ci(op), .s(s), .co());
endmodule

// ============================================================
// Memory
// ============================================================
module ll_memory #(
  parameter ALTITUDE = 16'h4500,
  parameter VELOCITY = 16'h0,
  parameter FUEL     = 16'h800,
  parameter THRUST   = 16'h5
)(
  input  logic        clk, rst, wen,
  input  logic [15:0] alt_n, vel_n, fuel_n, thrust_n,
  output logic [15:0] alt, vel, fuel, thrust
);
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      alt    <= ALTITUDE;
      vel    <= VELOCITY;
      fuel   <= FUEL;
      thrust <= THRUST;
    end else if (wen) begin
      alt    <= alt_n;
      vel    <= vel_n;
      fuel   <= fuel_n;
      thrust <= thrust_n;
    end
  end
endmodule

// ============================================================
// Arithmetic Unit
// ============================================================
module ll_alu (
  input  logic [15:0] alt, vel, fuel, thrust,
  output logic [15:0] alt_n, vel_n, fuel_n
);
  logic [15:0] alt_calc, vel_calc, fuel_calc, vel_step1, thrust_used;

  assign thrust_used = (fuel == 16'h0) ? 16'h0 : thrust;

  bcdaddsub4 alu_alt (.a(alt),       .b(vel),          .op(1'b0), .s(alt_calc));
  bcdaddsub4 alu_v1  (.a(vel),       .b(16'h5),        .op(1'b1), .s(vel_step1));
  bcdaddsub4 alu_v2  (.a(vel_step1), .b(thrust_used),  .op(1'b0), .s(vel_calc));
  bcdaddsub4 alu_fuel(.a(fuel),      .b(thrust),       .op(1'b1), .s(fuel_calc));

  logic ground_reached_alu;
  assign ground_reached_alu = (alt_calc == 16'h0000) || (alt_calc[15:12] == 4'd9);

  assign alt_n  = ground_reached_alu ? 16'h0 : alt_calc;
  assign vel_n  = ground_reached_alu ? vel : vel_calc;
  assign fuel_n = (fuel_calc == 16'h0000 || fuel_calc[15:12] == 4'd9) ? 16'h0000 : fuel_calc;
endmodule

// ============================================================
// Control Unit
// ============================================================
module ll_control(
  input  logic        clk, rst,
  input  logic [15:0] alt, vel,
  output logic        land, crash, wen
);
  logic reached_ground;
  assign reached_ground = (alt == 16'h0000);

  logic vel_negative;
  assign vel_negative = (vel[15:12] == 4'd9);

  logic vel_ge_neg30;
  assign vel_ge_neg30 =
      (vel[15:12] == 4'd9) &&
      (vel[11:8]  == 4'd9) &&
      (vel[7:4]   >= 4'd7);

  logic vel_safe;
  assign vel_safe = (vel == 16'h0000) || vel_ge_neg30;

  logic going_too_fast;
  assign going_too_fast = vel_negative && !vel_ge_neg30;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      land  <= 1'b0;
      crash <= 1'b0;
      wen   <= 1'b1;
    end else begin
      if (reached_ground && !land && !crash) begin
        land  <= vel_safe;
        crash <= going_too_fast;
        wen   <= 1'b0;
      end else if (!land && !crash) begin
        wen <= 1'b1;
      end
    end
  end
endmodule

// ============================================================
// Display Unit
// ============================================================
module ll_display(
  input  logic        clk, rst,
  input  logic        land, crash,
  input  logic [3:0]  disp_ctrl,
  input  logic [15:0] alt, vel, fuel, thrust,
  output logic [7:0]  ss7, ss6, ss5,
  output logic [7:0]  ss3, ss2, ss1, ss0,
  output logic        red, green
);
  logic [1:0] mode;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      mode <= 2'd0;
    end else begin
      if      (disp_ctrl[3]) mode <= 2'd0; // ALT
      else if (disp_ctrl[2]) mode <= 2'd1; // VEL
      else if (disp_ctrl[1]) mode <= 2'd2; // FUEL
      else if (disp_ctrl[0]) mode <= 2'd3; // THRUST
    end
  end

  logic [15:0] disp_val;
  always_comb begin
    case (mode)
      2'd0: disp_val = alt;
      2'd1: disp_val = vel;
      2'd2: disp_val = fuel;
      2'd3: disp_val = thrust;
      default: disp_val = alt;
    endcase
  end

  always_comb begin
    case (mode)
      2'd0: {ss7, ss6, ss5} = 24'b01110111_00111000_01111000; // ALT
      2'd1: {ss7, ss6, ss5} = 24'b00111110_01111001_00111000; // VEL
      2'd2: {ss7, ss6, ss5} = 24'b01101111_01110111_01101101; // GAS
      2'd3: {ss7, ss6, ss5} = 24'b01111000_01110110_01010000; // THR
      default: {ss7, ss6, ss5} = 24'b01110111_00111000_01111000;
    endcase
  end

  logic [15:0] final_val;
  assign final_val = disp_val;

  logic is_negative;
  assign is_negative = (final_val[15:12] == 4'd9);

  logic [15:0] abs_val;
  bcdaddsub4 get_abs(
    .a(16'h0000),
    .b(final_val),
    .op(1'b1),
    .s(abs_val)
  );

  logic [15:0] show_val;
  assign show_val = is_negative ? abs_val : final_val;

  logic en3, en2, en1, en0;
  assign en3 = (show_val[15:12] != 4'd0);
  assign en2 = (show_val[15:12] != 4'd0) || (show_val[11:8] != 4'd0);
  assign en1 = (show_val[15:12] != 4'd0) || (show_val[11:8] != 4'd0) || (show_val[7:4] != 4'd0);
  assign en0 = 1'b1;

  logic en2_neg, en1_neg;
  assign en2_neg = (abs_val[11:8] != 4'd0);
  assign en1_neg = en2_neg || (abs_val[7:4] != 4'd0);

  logic [6:0] seg3_out, seg2_out, seg1_out, seg0_out;
  logic [6:0] neg2_out, neg1_out, neg0_out;

  ssdec sd3(.in(show_val[15:12]), .out(seg3_out), .enable(en3));
  ssdec sd2(.in(show_val[11:8]),  .out(seg2_out), .enable(en2));
  ssdec sd1(.in(show_val[7:4]),   .out(seg1_out), .enable(en1));
  ssdec sd0(.in(show_val[3:0]),   .out(seg0_out), .enable(en0));

  ssdec nd2(.in(abs_val[11:8]), .out(neg2_out), .enable(en2_neg));
  ssdec nd1(.in(abs_val[7:4]),  .out(neg1_out), .enable(en1_neg));
  ssdec nd0(.in(abs_val[3:0]),  .out(neg0_out), .enable(1'b1));

  assign ss3 = is_negative ? 8'b01000000      : {1'b0, seg3_out};
  assign ss2 = is_negative ? {1'b0, neg2_out} : {1'b0, seg2_out};
  assign ss1 = is_negative ? {1'b0, neg1_out} : {1'b0, seg1_out};
  assign ss0 = is_negative ? {1'b0, neg0_out} : {1'b0, seg0_out};

  assign green = land;
  assign red   = crash;
endmodule

// ============================================================
// Top-level Lunar Lander
// ============================================================
module lunarlander #(
  parameter FUEL     = 16'h800,
  parameter ALTITUDE = 16'h4500,
  parameter VELOCITY = 16'h0,
  parameter THRUST   = 16'h5,
  parameter GRAVITY  = 16'h5
)(
  input  logic        hz100, reset,
  input  logic [19:0] in,
  output logic [7:0]  ss7, ss6, ss5,
  output logic [7:0]  ss3, ss2, ss1, ss0,
  output logic        red, green
);
  logic        keyclk;
  logic [4:0]  keyout;
  logic [15:0] alt, vel, fuel, thrust;
  logic [15:0] alt_n, vel_n, fuel_n;
  logic [15:0] thrust_n;
  logic        land, crash, wen;
  logic        hz1;

  clock_psc psc(
    .clk(hz100),
    .rst(reset),
    .lim(8'd24),
    .hzX(hz1)
  );

  keysync ks(
    .clk(hz100),
    .rst(reset),
    .keyin(in[19:0]),
    .keyout(keyout),
    .keyclk(keyclk)
  );

  always_ff @(posedge hz100 or posedge reset) begin
    if (reset)
      thrust_n <= THRUST;
    else if (keyclk && ~keyout[4])
      thrust_n <= {12'b0, keyout[3:0]};
  end

  ll_memory #(
    .ALTITUDE(ALTITUDE),
    .VELOCITY(VELOCITY),
    .FUEL(FUEL),
    .THRUST(THRUST)
  ) mem (
    .clk(hz1),
    .rst(reset),
    .wen(wen),
    .alt_n(alt_n),
    .vel_n(vel_n),
    .fuel_n(fuel_n),
    .thrust_n(thrust_n),
    .alt(alt),
    .vel(vel),
    .fuel(fuel),
    .thrust(thrust)
  );

  ll_alu alu (
    .alt(alt),
    .vel(vel),
    .fuel(fuel),
    .thrust(thrust),
    .alt_n(alt_n),
    .vel_n(vel_n),
    .fuel_n(fuel_n)
  );

  ll_control ctrl (
    .clk(hz1),
    .rst(reset),
    .alt(alt),
    .vel(vel),
    .land(land),
    .crash(crash),
    .wen(wen)
  );

  ll_display disp (
    .clk(keyclk),
    .rst(reset),
    .land(land),
    .crash(crash),
    .disp_ctrl({keyout == 5'd19,
                keyout == 5'd18,
                keyout == 5'd17,
                keyout == 5'd16}),
    .alt(alt),
    .vel(vel),
    .fuel(fuel),
    .thrust(thrust),
    .ss7(ss7), .ss6(ss6), .ss5(ss5),
    .ss3(ss3), .ss2(ss2), .ss1(ss1), .ss0(ss0),
    .red(red),
    .green(green)
  );
endmodule

// ============================================================
// Keysync
// ============================================================
module keysync (
  input  logic        clk, rst,
  input  logic [19:0] keyin,
  output logic [4:0]  keyout,
  output logic        keyclk
);
  logic any_key;
  logic sync1, sync2;

  assign keyout[0] = keyin[1]|keyin[3]|keyin[5]|keyin[7]|keyin[9]|keyin[11]|keyin[13]|keyin[15]|keyin[17]|keyin[19];
  assign keyout[1] = keyin[2]|keyin[3]|keyin[6]|keyin[7]|keyin[10]|keyin[11]|keyin[14]|keyin[15]|keyin[18]|keyin[19];
  assign keyout[2] = keyin[4]|keyin[5]|keyin[6]|keyin[7]|keyin[12]|keyin[13]|keyin[14]|keyin[15];
  assign keyout[3] = keyin[8]|keyin[9]|keyin[10]|keyin[11]|keyin[12]|keyin[13]|keyin[14]|keyin[15];
  assign keyout[4] = keyin[16]|keyin[17]|keyin[18]|keyin[19];
  assign any_key   = |keyin;

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

// ============================================================
// Clock Prescaler
// ============================================================
module clock_psc (
  input  logic clk,
  input  logic rst,
  input  logic [7:0] lim,
  output logic hzX
);
  logic [7:0] ctr;
  logic hzX_reg;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      ctr     <= 8'd0;
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

// ============================================================
// Seven-Segment Decoder
// ============================================================
module ssdec(
  input  logic [3:0] in,
  input  logic enable,
  output logic [6:0] out
);
  assign out = enable ? (
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
                    7'b1110001 ) :
    7'b0000000;
endmodule