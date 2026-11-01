`timescale 1ns / 1ps
module top_i2c (
    input clk,
    input rst_n,
    input start,
    input rw,
    input [6:0] addr,
    input [7:0] tx_data,
    input [15:0] clk_div,
    
    inout sda,
    inout scl,
    output [7:0] rx_data,
    output done,
    output ack_err
);

    wire i2c_tick;
    wire active;
    wire sda_out;
    wire scl_out;

    assign sda = (sda_out == 1'b0) ? 1'b0 : 1'bz;
    assign scl = (scl_out == 1'b0) ? 1'b0 : 1'bz;

    i2c_clk_divider clk_div_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(active),
        .clk_div(clk_div),
        .i2c_tick(i2c_tick)
    );

    i2c_fsm fsm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .rw(rw),
        .addr(addr),
        .tx_data(tx_data),
        .i2c_tick(i2c_tick),
        .sda_in(sda),
        .sda_out(sda_out),
        .scl_out(scl_out),
        .rx_data(rx_data),
        .done(done),
        .ack_err(ack_err),
        .active(active)
    );

endmodule