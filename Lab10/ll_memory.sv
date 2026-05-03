module ll_memory #(parameter ALTITUDE = 16'h4500,parameter VELOCITY = 16'h0,parameter FUEL = 16'h800,parameter THRUST = 16'h5)(input  logic clk, rst, wen,input logic[15:0]alt_n,vel_n,fuel_n,thrust_n,output logic[15:0]alt,vel,fuel,thrust);
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      alt <= ALTITUDE;
      vel <= VELOCITY;
      fuel <= FUEL;
      thrust <= THRUST;
    end else if (wen) begin
      alt <= alt_n;
      vel <= vel_n;
      fuel<= fuel_n;
      thrust <= thrust_n;
    end
  end
endmodule