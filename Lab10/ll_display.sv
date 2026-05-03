module ll_display(input  logic clk, rst,input  logic land, crash,input  logic [3:0]  disp_ctrl,input  logic [15:0] alt, vel, fuel, thrust,output logic [7:0]ss7, ss6, ss5,output logic [7:0]ss3, ss2, ss1, ss0,output logic red, green);
  logic [1:0] mode;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      mode <= 2'd0;
    end else begin
      if (disp_ctrl[3]) mode <= 2'd0;
      else if(disp_ctrl[2]) mode <= 2'd1;
      else if(disp_ctrl[1]) mode <= 2'd2;
      else if(disp_ctrl[0]) mode <= 2'd3;
    end
  end
  logic [15:0] disp_val;
  always_comb begin
    case (mode)
      2'd0: disp_val= alt;
      2'd1: disp_val =vel;
      2'd2: disp_val= fuel;
      2'd3: disp_val =thrust;
      default: disp_val= alt;
    endcase
  end
  always_comb begin
    case (mode)
      2'd0: {ss7,ss6,ss5} =24'b01110111_00111000_01111000;
      2'd1: {ss7,ss6,ss5} =24'b00111110_01111001_00111000;
      2'd2: {ss7,ss6,ss5} =24'b01101111_01110111_01101101;
      2'd3: {ss7,ss6,ss5} =24'b01111000_01110110_01010000;
      default: {ss7,ss6,ss5} =24'b01110111_00111000_01111000;
    endcase
  end
  logic [15:0] final_val;
  assign final_val = disp_val;
  logic is_negative;
  assign is_negative = (final_val[15:12] == 4'd9);
  logic [15:0] abs_val;
  bcdaddsub4 get_abs(.a(16'h0000), .b(final_val), .op(1'b1), .s(abs_val));
  logic [15:0] show_val;
  assign show_val = is_negative ? abs_val : final_val;
  logic en3, en2, en1, en0;
  assign en3 =(show_val[15:12]!= 4'd0);
  assign en2 =(show_val[15:12]!= 4'd0)||(show_val[11:8]!=4'd0);
  assign en1 =(show_val[15:12]!= 4'd0)||(show_val[11:8]!=4'd0)||(show_val[7:4]!= 4'd0);
  assign en0 =1'b1;
  logic en2_neg, en1_neg;
  assign en2_neg = (abs_val[11:8] != 4'd0);
  assign en1_neg = en2_neg || (abs_val[7:4] != 4'd0);
  logic [6:0] seg3_out, seg2_out, seg1_out, seg0_out;
  logic [6:0] neg2_out, neg1_out, neg0_out;
  ssdec sd3(.in(show_val[15:12]),.out(seg3_out),.enable(en3));
  ssdec sd2(.in(show_val[11:8]),.out(seg2_out),.enable(en2));
  ssdec sd1(.in(show_val[7:4]),.out(seg1_out),.enable(en1));
  ssdec sd0(.in(show_val[3:0]),.out(seg0_out),.enable(en0));
  ssdec nd2(.in(abs_val[11:8]),.out(neg2_out),.enable(en2_neg));
  ssdec nd1(.in(abs_val[7:4]),.out(neg1_out),.enable(en1_neg));
  ssdec nd0(.in(abs_val[3:0]),.out(neg0_out),.enable(1'b1));
  assign ss3 = is_negative ?8'b01000000: {1'b0,seg3_out};
  assign ss2 = is_negative ?{1'b0,neg2_out}:{1'b0,seg2_out};
  assign ss1 = is_negative ?{1'b0,neg1_out}:{1'b0,seg1_out};
  assign ss0 = is_negative ?{1'b0,neg0_out}:{1'b0,seg0_out};
  assign green = land;
  assign red = crash;
endmodule
