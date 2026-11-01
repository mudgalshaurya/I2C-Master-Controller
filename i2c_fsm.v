`timescale 1ns / 1ps
module i2c_fsm (
    input clk,
    input rst_n,
    input start,
    input rw,
    input [6:0] addr,
    input [7:0] tx_data,
    input i2c_tick,
    input sda_in,
    
    output reg sda_out,
    output reg scl_out,
    output reg [7:0] rx_data,
    output reg done,
    output reg ack_err,
    output reg active
);

    localparam IDLE      = 4'd0;
    localparam START1    = 4'd1;
    localparam START2    = 4'd2;
    localparam ADDR      = 4'd3;
    localparam RW_BIT    = 4'd4;
    localparam WACK_ADDR = 4'd5;
    localparam TX_DATA   = 4'd6;
    localparam WACK_TX   = 4'd7;
    localparam RX_DATA   = 4'd8;
    localparam TX_ACK    = 4'd9;
    localparam STOP1     = 4'd10;
    localparam STOP2     = 4'd11;
    localparam DONE      = 4'd12;

    reg [3:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_rx;
    reg [6:0] saved_addr;
    reg [7:0] saved_tx;
    reg saved_rw;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            scl_out <= 1'b1;
            sda_out <= 1'b1;
            done <= 1'b0;
            ack_err <= 1'b0;
            active <= 1'b0;
            bit_cnt <= 3'd0;
            shift_rx <= 8'd0;
            rx_data <= 8'd0;
            saved_addr <= 7'd0;
            saved_tx <= 8'd0;
            saved_rw <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    scl_out <= 1'b1;
                    sda_out <= 1'b1;
                    done <= 1'b0;
                    active <= 1'b0;
                    if (start) begin
                        saved_addr <= addr;
                        saved_tx <= tx_data;
                        saved_rw <= rw;
                        ack_err <= 1'b0;
                        active <= 1'b1;
                        state <= START1;
                    end
                end

                START1: begin
                    if (i2c_tick) begin
                        sda_out <= 1'b0;
                        state <= START2;
                    end
                end

                START2: begin
                    if (i2c_tick) begin
                        scl_out <= 1'b0;
                        bit_cnt <= 3'd6;
                        state <= ADDR;
                    end
                end

                ADDR: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= saved_addr[bit_cnt];
                            scl_out <= 1'b1;
                        end else begin
                            scl_out <= 1'b0;
                            if (bit_cnt == 3'd0) begin
                                state <= RW_BIT;
                            end else begin
                                bit_cnt <= bit_cnt - 1'd1;
                            end
                        end
                    end
                end

                RW_BIT: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= saved_rw;
                            scl_out <= 1'b1;
                        end else begin
                            scl_out <= 1'b0;
                            state <= WACK_ADDR;
                        end
                    end
                end

                WACK_ADDR: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= 1'b1;
                            scl_out <= 1'b1;
                        end else begin
                            ack_err <= sda_in;
                            scl_out <= 1'b0;
                            if (saved_rw) begin
                                bit_cnt <= 3'd7;
                                state <= RX_DATA;
                            end else begin
                                bit_cnt <= 3'd7;
                                state <= TX_DATA;
                            end
                        end
                    end
                end

                TX_DATA: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= saved_tx[bit_cnt];
                            scl_out <= 1'b1;
                        end else begin
                            scl_out <= 1'b0;
                            if (bit_cnt == 3'd0) begin
                                state <= WACK_TX;
                            end else begin
                                bit_cnt <= bit_cnt - 1'd1;
                            end
                        end
                    end
                end

                WACK_TX: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= 1'b1;
                            scl_out <= 1'b1;
                        end else begin
                            ack_err <= ack_err | sda_in;
                            scl_out <= 1'b0;
                            state <= STOP1;
                        end
                    end
                end

                RX_DATA: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= 1'b1;
                            scl_out <= 1'b1;
                        end else begin
                            shift_rx <= {shift_rx[6:0], sda_in};
                            scl_out <= 1'b0;
                            if (bit_cnt == 3'd0) begin
                                state <= TX_ACK;
                            end else begin
                                bit_cnt <= bit_cnt - 1'd1;
                            end
                        end
                    end
                end

                TX_ACK: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= 1'b1;
                            scl_out <= 1'b1;
                        end else begin
                            scl_out <= 1'b0;
                            state <= STOP1;
                        end
                    end
                end

                STOP1: begin
                    if (i2c_tick) begin
                        if (scl_out == 1'b0) begin
                            sda_out <= 1'b0;
                            scl_out <= 1'b1;
                        end else begin
                            state <= STOP2;
                        end
                    end
                end

                STOP2: begin
                    if (i2c_tick) begin
                        sda_out <= 1'b1;
                        state <= DONE;
                    end
                end

                DONE: begin
                    done <= 1'b1;
                    active <= 1'b0;
                    if (saved_rw) begin
                        rx_data <= shift_rx;
                    end
                    state <= IDLE;
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule