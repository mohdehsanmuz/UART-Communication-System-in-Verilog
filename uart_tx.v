module uart_tx (
    input clk,
    input start,
    input [7:0] data_in,
    output reg tx,
    output reg done
);

// States
parameter IDLE  = 2'b00,
          START = 2'b01,
          DATA  = 2'b10,
          STOP  = 2'b11;

parameter BAUD_DIV = 5;  // small for simulation

reg [1:0] state = IDLE;
reg [3:0] bit_index = 0;
reg [7:0] data;

reg [7:0] baud_cnt = 0;
reg baud_tick;

reg start_sync;

// 🔴 Baud generator
always @(posedge clk) begin
    if (baud_cnt == BAUD_DIV) begin
        baud_cnt <= 0;
        baud_tick <= 1;
    end else begin
        baud_cnt <= baud_cnt + 1;
        baud_tick <= 0;
    end
end

// 🔴 Synchronize start
always @(posedge clk) begin
    start_sync <= start;
end

// 🔴 UART FSM (ONLY runs on baud_tick)
always @(posedge clk) begin
    if (baud_tick) begin
        case(state)

            IDLE: begin
                tx <= 1;
                done <= 0;

                if (start_sync) begin
                    data <= data_in;
                    state <= START;
                end
            end

            START: begin
                tx <= 0;
                bit_index <= 0;
                state <= DATA;
            end

            DATA: begin
                tx <= data[bit_index];

                if (bit_index == 7)
                    state <= STOP;
                else
                    bit_index <= bit_index + 1;
            end

            STOP: begin
                tx <= 1;
                done <= 1;
                state <= IDLE;
            end

        endcase
    end
end

endmodule