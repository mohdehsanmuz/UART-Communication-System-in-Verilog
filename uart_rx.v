module uart_rx (
    input clk,
    input rx,
    output reg [7:0] data_out,
    output reg done
);

// States
parameter IDLE  = 2'b00,
          START = 2'b01,
          DATA  = 2'b10,
          STOP  = 2'b11;

parameter BAUD_DIV = 5;

reg [1:0] state = IDLE;
reg [3:0] bit_index = 0;
reg [7:0] data;

reg [7:0] clk_cnt = 0;
reg rx_d1, rx_d2;

// 🔴 Synchronize RX (VERY IMPORTANT)
always @(posedge clk) begin
    rx_d1 <= rx;
    rx_d2 <= rx_d1;
end

// UART RX FSM
always @(posedge clk) begin
    case(state)

        // ================= IDLE =================
        IDLE: begin
            done <= 0;
            clk_cnt <= 0;

            // detect falling edge (start bit)
            if (rx_d2 == 1 && rx_d1 == 0) begin
                state <= START;
            end
        end

        // ================= START =================
        START: begin
            if (clk_cnt == (BAUD_DIV/2)) begin
                if (rx_d2 == 0) begin
                    clk_cnt <= 0;
                    bit_index <= 0;
                    state <= DATA;
                end else begin
                    state <= IDLE;
                end
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end

        // ================= DATA =================
        DATA: begin
            if (clk_cnt == BAUD_DIV) begin
                clk_cnt <= 0;

                data[bit_index] <= rx_d2;

                if (bit_index == 7)
                    state <= STOP;
                else
                    bit_index <= bit_index + 1;

            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end

        // ================= STOP =================
        STOP: begin
            if (clk_cnt == BAUD_DIV) begin
                clk_cnt <= 0;

                if (rx_d2 == 1) begin
                    data_out <= data;
                    done <= 1;
                end

                state <= IDLE;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end

    endcase
end

endmodule