module lunarlander #(parameter FUEL= 16'h800,parameter ALTITUDE= 16'h4500,parameter VELOCITY= 16'h0,parameter THRUST = 16'h5,parameter GRAVITY = 16'h5)(input  logic hz100, reset,input  logic [19:0] in,output logic [7:0] ss7, ss6, ss5,output logic [7:0]ss3, ss2, ss1, ss0,output logic red, green);
  logic keyclk;
  logic [4:0] keyout;
  logic [15:0] alt, vel, fuel, thrust;
  logic [15:0] alt_n, vel_n, fuel_n;
  logic [15:0] thrust_n;
  logic land, crash, wen;
  logic hz1;
  clock_psc psc(.clk(hz100),.rst(reset),.lim(8'd55),.hzX(hz1));
  keysync ks(.clk(hz100),.rst(reset),.keyin(in[19:0]),.keyout(keyout),.keyclk(keyclk));
  always_ff @(posedge hz100 or posedge reset) begin
    if (reset)
      thrust_n <= THRUST;
    else if (keyclk && ~keyout[4]&&(|in[15:0]))
      thrust_n <= {12'b0, keyout[3:0]};
end
  ll_memory #(.ALTITUDE(ALTITUDE),.VELOCITY(VELOCITY),.FUEL(FUEL),.THRUST(THRUST)) mem (.clk(hz1),.rst(reset),.wen(wen),.alt_n(alt_n),.vel_n(vel_n),.fuel_n(fuel_n),.thrust_n(thrust_n),.alt(alt),.vel(vel),.fuel(fuel),.thrust(thrust));
  ll_alu alu (.alt(alt),.vel(vel),.fuel(fuel),.thrust(thrust),.alt_n(alt_n),.vel_n(vel_n),.fuel_n(fuel_n));
  ll_control ctrl (.clk(hz1),.rst(reset),.alt(alt),.vel(vel),.land(land),.crash(crash),.wen(wen));
  ll_display disp (.clk(keyclk),.rst(reset),.land(land),.crash(crash),.disp_ctrl({keyout == 5'd19,keyout == 5'd18,keyout == 5'd17,keyout == 5'd16}),.alt(alt),.vel(vel),.fuel(fuel),.thrust(thrust),.ss7(ss7), .ss6(ss6), .ss5(ss5),.ss3(ss3), .ss2(ss2), .ss1(ss1), .ss0(ss0),.red(red),.green(green));
endmodule