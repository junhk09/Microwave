`timescale 1ns / 1ps

module button_beep(
    input clk,
    input reset,
    input btn,          // 디바운싱된 버튼 신호 (w_btnU)
    output reg beep_on, // 현재 소리가 나고 있는지 상태 출력
    output reg beep_out // 실제 부저 펄스파 출력
);

    // 100MHz 기준 시간 계산
    localparam T_50MS = 23'd5_000_000; // 50ms 동안 소리 유지
    localparam FREQ_2K = 17'd25_000;   // 2KHz 주파수 (전자레인지 특유의 고음 삑!)

    reg [22:0] timer;
    reg [16:0] freq_cnt;
    
    // 버튼 엣지 검출
    reg btn_reg;
    wire btn_push = (btn & ~btn_reg);
    
    always @(posedge clk) begin
        if (reset) btn_reg <= 1'b0;
        else       btn_reg <= btn;
    end

    // 삑 소리 제어 로직
    always @(posedge clk) begin
        if (reset) begin
            timer <= 0;
            freq_cnt <= 0;
            beep_on <= 0;
            beep_out <= 0;
        end else begin
            // 버튼이 눌리면 타이머 시작
            if (btn_push) begin
                beep_on <= 1'b1;
                timer <= 0;
            end
            
            // 소리가 켜져 있을 때 (50ms 동안 유지)
            if (beep_on) begin
                if (timer < T_50MS) begin
                    timer <= timer + 1;
                    
                    // 2KHz 주파수 생성
                    if (freq_cnt < FREQ_2K) freq_cnt <= freq_cnt + 1;
                    else begin
                        freq_cnt <= 0;
                        beep_out <= ~beep_out; // 소리 출력 토글
                    end
                end else begin
                    // 50ms가 지나면 소리 끄기
                    beep_on <= 1'b0;
                    beep_out <= 1'b0;
                end
            end else begin
                beep_out <= 1'b0; // 안 켜져있을 땐 무음
            end
        end
    end

endmodule