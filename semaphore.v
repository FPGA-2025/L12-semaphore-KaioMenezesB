module Semaphore #(
    parameter CLK_FREQ = 100_000_000
) (
    input wire clk,
    input wire rst_n,

    input wire pedestrian,

    output wire green,
    output wire yellow,
    output wire red
);

localparam [2:0]
        STATE_RED    = 3'b100,
        STATE_YELLOW = 3'b010,
        STATE_GREEN  = 3'b001;

    localparam integer
        RED_CYCLES    = CLK_FREQ * 5,    // 5 segundos
        GREEN_CYCLES  = CLK_FREQ * 7,    // 7 segundos
        YELLOW_CYCLES = CLK_FREQ / 2;    // 0,5 segundo

    reg [2:0] state;
    reg [31:0] cnt; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_RED;
            cnt   <= 32'd0;
        end else begin
            case (state)
                STATE_RED: begin
                    if (cnt == RED_CYCLES-1) begin
                        state <= STATE_GREEN;
                        cnt   <= 32'd0;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                STATE_GREEN: begin
                    if (pedestrian) begin
                        state <= STATE_YELLOW;
                        cnt   <= 32'd0;
                    end else if (cnt == GREEN_CYCLES-1) begin
                        state <= STATE_YELLOW;
                        cnt   <= 32'd0;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                STATE_YELLOW: begin
                    if (cnt == YELLOW_CYCLES-1) begin
                        state <= STATE_RED;
                        cnt   <= 32'd0;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end

                default: begin
                    state <= STATE_RED;
                    cnt   <= 32'd0;
                end
            endcase
        end
    end

    assign red    = state[2];
    assign yellow = state[1];
    assign green  = state[0];

endmodule
