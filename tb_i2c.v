`timescale 1ns / 1ps

module tb_i2c;

    reg clk;
    reg rst_n;
    reg start;
    reg rw;
    reg [6:0] addr;
    reg [7:0] tx_data;
    reg [15:0] clk_div;

    wire sda;
    wire scl;
    wire [7:0] rx_data;
    wire done;
    wire ack_err;

    pullup(sda);
    pullup(scl);

    top_i2c uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .rw(rw),
        .addr(addr),
        .tx_data(tx_data),
        .clk_div(clk_div),
        .sda(sda),
        .scl(scl),
        .rx_data(rx_data),
        .done(done),
        .ack_err(ack_err)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        rw = 1'b0;
        addr = 7'h5A;
        tx_data = 8'hC3;
        clk_div = 16'd2;

        #25;
        rst_n = 1'b1;
        #25;

        start = 1'b1;
        #10;
        start = 1'b0;

        @(posedge done);
        
        #100;
        $finish;
    end

endmodule