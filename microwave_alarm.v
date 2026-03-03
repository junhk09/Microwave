`timescale 1ns / 1ps

module microwave_alarm(
    input clk,          // 100MHz 기준
    input reset,
    input alarm_on,
    output reg buzzer_out
);
    localparam T_500MS = 26'd50_000_000; 
    localparam TARGET_FREQ = 17'd25_000; 

    reg [25:0] toggle_timer;
    reg sound_enable;        
    reg [16:0] freq_cnt;     
    reg [2:0] beep_count;    // 울린 횟수를 저장 (0~7까지 표현 가능)
    reg done;                // 3번 울림이 끝났음을 표시하는 플래그

    always @(posedge clk) begin
        if (reset || !alarm_on) begin
            toggle_timer <= 0;
            sound_enable <= 1;
            freq_cnt <= 0;
            buzzer_out <= 0;
            beep_count <= 0;
            done <= 0;
        end else if (!done) begin // 아직 3번 다 안 울렸을 때만 작동
            // 1. "삐- 삐-" 구간 반복 및 횟수 체크
            if (toggle_timer < T_500MS) begin
                toggle_timer <= toggle_timer + 1;
            end else begin
                toggle_timer <= 0;
                
                if (sound_enable) begin
                    // 소리가 나던 중(On) 타이머가 다 되면 무음(Off)으로 전환
                    sound_enable <= 0;
                    beep_count <= beep_count + 1; // 한 번의 '삐-'가 끝났으므로 카운트 증가
                end else begin
                    // 무음(Off) 상태에서 타이머가 다 되면 다시 소리(On) 발생
                    sound_enable <= 1;
                end
            end

            // 3번 울렸는지 확인 (삐- 무음 삐- 무음 삐- 무음 완료 시 멈춤)
            if (beep_count == 3) begin
                done <= 1;
                sound_enable <= 0;
            end

            // 2. 실제 주파수 생성 로직
            if (sound_enable) begin
                if (freq_cnt < TARGET_FREQ) begin
                    freq_cnt <= freq_cnt + 1;
                end else begin
                    freq_cnt <= 0;
                    buzzer_out <= ~buzzer_out;
                end
            end else begin
                freq_cnt <= 0;
                buzzer_out <= 0;
            end
        end else begin
            // 3번 울림이 끝난 후 정지 상태 유지
            buzzer_out <= 0;
        end
    end
endmodule