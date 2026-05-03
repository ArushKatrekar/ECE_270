`default_nettype none
// Empty top module
typedef enum logic [3:0] {
LS0=0, LS1=1, LS2=2, LS3=3, LS4=4, LS5=5, LS6=6, LS7=7,
INIT=8, OPEN=9, ALARM=10
} state_t;

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

  // Declare internal signals
  logic [4:0] keycode;
  logic strobe;

  // Instantiate clock_psc — lim=49 gives 1Hz flash from 100Hz clock
  //clock_psc psc1 (.clk(hz100),.rst(reset),.lim(8'd49),.hzX(red));


  keysync sk1 (.clk(hz100),.rst(reset),.keyin(pb[19:0]),.keyout(keycode),.keyclk(strobe));

  //assign right[0]   = strobe;
  //assign right[5:1] = keycode;
  // Your code goes here...
logic [7:0] seq;

sequence_sr sr1 (.clk(strobe),.rst(reset),.en(~|keycode[4:1] & (state == 4'd8)),.button(keycode[0]),.seq(seq));
assign right = seq;
logic [3:0] state;
fsm lock_fsm(.clk(strobe),.rst(reset),.keyout(keycode),.seq(seq),.state(state));
logic [63:0] ss;
logic hz2;

// 2Hz clock for alarm flashing
clock_psc psc2 (.clk(hz100),
    .rst(reset),
    .lim(8'd24),
    .hzX(hz2)
);

// Display module
display disp1 (
    .hzX(hz2),
    .state(state),
    .ss(ss),
    .red(red),
    .green(green),
    .blue(blue)
);

assign {ss7,ss6,ss5,ss4,ss3,ss2,ss1,ss0} = ss;
endmodule
module clock_psc (input logic clk,input  logic rst,input  logic [7:0]lim,output logic hzX);
    logic [7:0]ctr;
    logic hzX_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ctr <= 8'd0;
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

module keysync (input  logic clk,input  logic rst,input  logic [19:0]keyin,output logic [4:0]keyout,output logic keyclk);
    logic any_key;
    logic sync1, sync2;

    // Combinational encoder
    assign keyout[0] = keyin[1]|keyin[3]|keyin[5]|keyin[7]|keyin[9]|keyin[11]|keyin[13]|keyin[15]|keyin[17]|keyin[19];
    assign keyout[1] = keyin[2]|keyin[3]|keyin[6]|keyin[7]|keyin[10]|keyin[11]|keyin[14]|keyin[15]|keyin[18]|keyin[19];
    assign keyout[2] = keyin[4]|keyin[5]|keyin[6]|keyin[7]|keyin[12]|keyin[13]|keyin[14]|keyin[15];
    assign keyout[3] = keyin[8]|keyin[9]|keyin[10]|keyin[11]|keyin[12]|keyin[13]|keyin[14]|keyin[15];
    assign keyout[4] = keyin[16]|keyin[17]|keyin[18]|keyin[19];

    // Strobe = OR of all inputs
    assign any_key = |keyin;

    // Two-FF synchronizer for keyclk
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sync1  <= 1'b0;
            sync2  <= 1'b0;
            keyclk <= 1'b0;
        end else begin
            sync1  <= any_key;
            sync2  <= sync1;
            keyclk <= sync2;
        end
    end
endmodule

module sequence_sr (input  logic clk,input  logic rst,input  logic en,input  logic  button, output logic [7:0]seq);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            seq <= 8'b0;
        end else begin
            if (en) begin
                seq <= {seq[6:0], button};
            end
        end
    end

endmodule

module fsm (input  logic  clk,input  logic rst,input  logic [4:0] keyout,input  logic [7:0] seq,output logic [3:0] state);
    state_t lockstate, n_lockstate;
    logic M, R;
    assign state = lockstate;
    assign M = (keyout[0] == seq[~lockstate[2:0]]);
    assign R = (keyout == 5'b10000);
    always_ff @(posedge clk, posedge rst) begin
        if (rst == 1'b1)
            lockstate <= INIT;
        else
            lockstate <= n_lockstate;
    end
    always_comb begin
        case (lockstate)
            INIT:
                if(R == 1)n_lockstate = LS0;
                else              n_lockstate = INIT;

            LS0:
                if(R == 1)n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = LS1;
                else n_lockstate = ALARM;

            LS1:
                if(R == 1)n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = LS2;
                else n_lockstate = ALARM;

            LS2:
                if(R == 1)n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = LS3;
                else                          n_lockstate = ALARM;

            LS3:
                if (R == 1) n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = LS4;
                else n_lockstate = ALARM;

            LS4:
                if (R == 1)n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = LS5;
                else                          n_lockstate = ALARM;

            LS5:
                if(R == 1) n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = LS6;
                else                          n_lockstate = ALARM;

            LS6:
                if(R == 1) n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = LS7;
                else n_lockstate = ALARM;

            LS7:
                if(R == 1)n_lockstate = LS0;
                else if ((R == 0) & (M == 1)) n_lockstate = OPEN;
                else  n_lockstate = ALARM;

            OPEN:
                if (R == 1) n_lockstate = LS0;
                else  n_lockstate = OPEN;

            ALARM:
                n_lockstate = ALARM;
            default:
                n_lockstate = INIT;
        endcase
    end

endmodule

  module display (input  logic  hzX,input  logic [3:0]  state,output logic [63:0] ss,output logic red,output logic green,output logic blue);

      always_comb begin
          case (state)
              INIT: begin
                  ss    = 64'b0;
                  red   = 0;
                  green = 0;
                  blue  = 0;
              end
              LS0: begin
                  ss    = 64'h00006D79393E5079 | 64'h8000000000000000;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end
              LS1: begin
                  ss    = 64'h00006D79393E5079 | 64'h0080000000000000;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end

              LS2: begin
                  ss    = 64'h00006D79393E5079 | 64'h0000800000000000;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end
              LS3: begin
                  ss    = 64'h00006D79393E5079 | 64'h0000008000000000;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end
              LS4: begin
                  ss    = 64'h00006D79393E5079 | 64'h0000000080000000;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end
              LS5: begin
                  ss    = 64'h00006D79393E5079 | 64'h0000000000800000;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end
              LS6: begin
                  ss    = 64'h00006D79393E5079 | 64'h0000000000008000;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end
              LS7: begin
                  ss    = 64'h00006D79393E5079 | 64'h0000000000000080;
                  red   = 0;
                  green = 0;
                  blue  = 1;
              end
              OPEN: begin
                  ss    = 64'h000000003F737954;
                  red   = 0;
                  green = 1;
                  blue  = 0;
              end
              ALARM: begin
                  ss    = 64'h3977383800670606;
                  red   = hzX;
                  green = 0;
                  blue  = 0;
              end
              default: begin
                  ss    = 64'b0;
                  red   = 0;
                  green = 0;
                  blue  = 0;
              end
          endcase
      end
  endmodule
  // Add more modules down here...