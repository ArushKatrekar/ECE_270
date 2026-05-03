module ll_alu (input  logic [15:0]alt,vel, fuel, thrust,output logic [15:0] alt_n, vel_n, fuel_n
);
  localparam GRAVITY = 16'h5;
  logic [15:0] alt_calc, vel_calc, fuel_calc, vel_step1, thrust_used;
  assign thrust_used = (fuel == 16'h0) ? 16'h0 : thrust;
  bcdaddsub4 alu_alt(.a(alt),.b(vel),.op(1'b0), .s(alt_calc));
  bcdaddsub4 alu_v1(.a(vel), .b(GRAVITY),.op(1'b1), .s(vel_step1));
  bcdaddsub4 alu_v2(.a(vel_step1),.b(thrust_used),.op(1'b0),.s(vel_calc));
  bcdaddsub4 alu_fuel(.a(fuel),.b(thrust),.op(1'b1), .s(fuel_calc));
  logic ground_reached_alu;
  assign ground_reached_alu = (alt_calc == 16'h0000) || (alt_calc[15:12] == 4'd9);
  assign alt_n  = ground_reached_alu ? 16'h0 : alt_calc;
  assign vel_n  = ground_reached_alu ? 16'h0 : vel_calc;
  assign fuel_n = (fuel_calc == 16'h0000 || fuel_calc[15:12] == 4'd9) ? 16'h0000 : fuel_calc;
endmodule