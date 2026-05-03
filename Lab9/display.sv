typedef enum logic [3:0] {
    LS0=0, LS1=1, LS2=2, LS3=3, LS4=4, LS5=5, LS6=6, LS7=7,
    INIT=8, OPEN=9, ALARM=10
} state_t;

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