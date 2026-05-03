`timescale 1ns/1ps

module tb_uart;

reg clk, start;
reg [7:0] data_in;

wire tx;
wire [7:0] data_out;
wire done_tx, done_rx;

// TX
uart_tx tx_inst (
    .clk(clk),
    .start(start),
    .data_in(data_in),
    .tx(tx),
    .done(done_tx)
);

// RX
uart_rx rx_inst (
    .clk(clk),
    .rx(tx),   // 🔥 CONNECT TX → RX
    .data_out(data_out),
    .done(done_rx)
);

// Clock
always #5 clk = ~clk;

initial begin
    clk = 0;
    start = 0;
    data_in = 8'b10101010;

    #20 start = 1;
    #50 start = 0;

    #5000 $finish;
end

endmodule