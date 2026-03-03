`timescale 1ns / 1ps

module servo_control (
    input clk,
    input reset,
    input btnD,           // 디바운싱된 버튼 신호
    output reg pwm_out,
    output reg door_state // ★ 핵심: 현재 문 상태를 밖으로 출력
);

    localparam PERIOD_20MS = 21'd2_000_000;
    localparam DO180       = 21'd200_000;
    localparam DO90        = 21'd150_000;

    reg [20:0] cnt;
    reg btn_reg;

    // 20ms 카운터
    always @(posedge clk or posedge reset) begin
        if (reset) cnt <= 21'd0;
        else if (cnt >= PERIOD_20MS - 1) cnt <= 21'd0;
        else cnt <= cnt + 1'b1;
    end

    // 버튼 토글 로직 (한 번 누를 때마다 상태 반전)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_reg <= 1'b0;
            door_state <= 1'b0; // 초기 상태: 닫힘(C)
        end else begin
            btn_reg <= btnD;
            // 버튼을 누르는 상승 에지 순간에만 상태 변경
            if (btnD == 1'b1 && btn_reg == 1'b0) begin
                door_state <= ~door_state; 
            end
        end
    end

    // 모터 각도 제어
    always @(posedge clk or posedge reset) begin
        if (reset) pwm_out <= (cnt < DO180); 
        else begin
            if (door_state == 1'b0) pwm_out <= (cnt < DO180); // 닫힘 (0도)
            else                    pwm_out <= (cnt < DO90);  // 열림 (90도)
        end
    end
endmodule