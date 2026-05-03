
typedef enum logic [3:0] {
    LS0=0, LS1=1, LS2=2, LS3=3, LS4=4, LS5=5, LS6=6, LS7=7,
    INIT=8, OPEN=9, ALARM=10
} state_t;


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
