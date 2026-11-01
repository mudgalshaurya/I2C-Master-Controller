`timescale 1ns / 1ps
module i2c_clk_divider (
    input clk,
    input rst_n,
    input en,
    input [15:0] clk_div,
    
    output reg i2c_tick
);

    reg [15:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 16'd0;
            i2c_tick <= 1'b0;
        end else if (en) begin
            if (counter >= clk_div) begin
                counter <= 16'd0;
                i2c_tick <= 1'b1;
            end else begin
                counter <= counter + 1'd1;
                i2c_tick <= 1'b0;
            end
        end else begin
            counter <= 16'd0;
            i2c_tick <= 1'b0;
        end
    end

endmodule
