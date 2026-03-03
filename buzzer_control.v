`timescale 1ns / 1ps

module buzzer_control(
    input clk,
    input reset,
    input btnD,      // 문 열림/닫힘 버튼

    output door,     // LED0 (문 상태 표시)
    output reg buzzer
    );

    // --- 음계 주파수 (100MHz 기준 카운트 값) ---
    localparam DO  = 22'd191_112; 
    localparam RE  = 22'd170_265; 
    localparam MI  = 22'd151_855; 
    localparam SOL = 22'd127_551;
    localparam OFF = 22'd0; // 무음

    // --- 타이머 설정 ---
    localparam T250MS = 26'd25_000_000;

    // --- 상태 정의 ---
    reg [2:0] state;
    localparam S_INTRO = 3'd0; // 전원 켜질 때 (솔레도솔미)
    localparam S_IDLE  = 3'd1; // 대기 상태
    localparam S_OPEN  = 3'd2; // 문 여는 중 (도솔)
    localparam S_OPENED= 3'd3; // 문 열려있음 (대기)
    localparam S_CLOSE = 3'd4; // 문 닫는 중 (솔도)

    reg [25:0] r_timer;
    reg [2:0]  r_note_idx;    // 멜로디 순서 카운터
    reg [21:0] r_target_cnt;  // 현재 출력할 음의 카운트값
    reg [21:0] r_clk_cnt;     // 주파수 생성용 카운터
    
    // 버튼 엣지 감지 (한 번 누를 때 한 번만 동작)
    reg btnD_reg;
    wire btnD_push = (btnD && !btnD_reg);
    always @(posedge clk) btnD_reg <= btnD;

    // LED 제어 (문이 열린 상태들에서 켜짐)
    assign door = (state == S_OPEN || state == S_OPENED);

    // 1. 상태 및 멜로디 순서 제어
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= S_INTRO;
            r_timer <= 0;
            r_note_idx <= 0;
        end else begin
            case(state)
                S_INTRO: begin // 솔-레-도-솔-미 (5음)
                    if(r_timer < T250MS) r_timer <= r_timer + 1;
                    else begin
                        r_timer <= 0;
                        if(r_note_idx < 4) r_note_idx <= r_note_idx + 1;
                        else begin r_note_idx <= 0; state <= S_IDLE; end
                    end
                end

                S_IDLE: begin // 문 닫힌 채 대기
                    if(btnD_push) begin 
                        state <= S_OPEN; 
                        r_timer <= 0; 
                        r_note_idx <= 0; 
                    end
                end

                S_OPEN: begin // 도-솔 (2음)
                    if(r_timer < T250MS) r_timer <= r_timer + 1;
                    else begin
                        r_timer <= 0;
                        if(r_note_idx < 1) r_note_idx <= r_note_idx + 1;
                        else begin r_note_idx <= 0; state <= S_OPENED; end
                    end
                end

                S_OPENED: begin // 문 열린 채 대기
                    if(btnD_push) begin 
                        state <= S_CLOSE; 
                        r_timer <= 0; 
                        r_note_idx <= 0; 
                    end
                end

                S_CLOSE: begin // 솔-도 (2음)
                    if(r_timer < T250MS) r_timer <= r_timer + 1;
                    else begin
                        r_timer <= 0;
                        if(r_note_idx < 1) r_note_idx <= r_note_idx + 1;
                        else begin r_note_idx <= 0; state <= S_IDLE; end
                    end
                end
            endcase
        end
    end

    // 2. 상태별 음계 할당
    always @(*) begin
        case(state)
            S_INTRO: begin
                case(r_note_idx)
                    0: r_target_cnt = SOL; 1: r_target_cnt = RE; 2: r_target_cnt = DO;
                    3: r_target_cnt = SOL; 4: r_target_cnt = MI; default: r_target_cnt = OFF;
                endcase
            end
            S_OPEN: begin
                case(r_note_idx)
                    0: r_target_cnt = DO; 1: r_target_cnt = SOL; default: r_target_cnt = OFF;
                endcase
            end
            S_CLOSE: begin
                case(r_note_idx)
                    0: r_target_cnt = SOL; 1: r_target_cnt = DO; default: r_target_cnt = OFF;
                endcase
            end
            default: r_target_cnt = OFF;
        endcase
    end

    // 3. 실제 부저 출력 신호 생성 (Square Wave)
    always @(posedge clk) begin
        if(r_target_cnt == OFF) begin
            buzzer <= 0;
            r_clk_cnt <= 0;
        end else begin
            if(r_clk_cnt < r_target_cnt) begin
                r_clk_cnt <= r_clk_cnt + 1;
            end else begin
                r_clk_cnt <= 0;
                buzzer <= ~buzzer;
            end
        end
    end

endmodule