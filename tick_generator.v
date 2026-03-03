`timescale 1ns / 1ps
module tick_generator(
    
    input clk,
    input reset,
    output reg tick
);

    parameter INPUT_FREQUENCY = 100_000_000; // 100MHz
    parameter TICK_Hz = 1000; // 1kHz
    parameter TICK_COUNT = INPUT_FREQUENCY / TICK_Hz; // 100,000

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter = 0;

    always @(posedge clk or posedge reset) begin
        // 초기화
        if (reset) begin
            tick <= 0;
            r_tick_counter <= 0;
        end 

        // 카운팅 완료
        else if (r_tick_counter == TICK_COUNT-1) begin
            r_tick_counter <= 0;
            tick <= 1'b1;          // 1클럭 폭 펄스
        end 

        // r_counter 증가
        else begin
            r_tick_counter <= r_tick_counter + 1;
            tick <= 1'b0;
        end
    end

endmodule
