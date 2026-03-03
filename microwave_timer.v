`timescale 1ns / 1ps

module microwave_timer (
    input clk,
    input reset,
    input btnU,         
    input door_open,    // ★ 서보모터에서 보내주는 문 상태 (1:열림, 0:닫힘)
    output reg [9:0] time_sec,
    output reg alarm_on,
    output motor_run
);

    localparam IDLE  = 2'd0; // 대기
    localparam RUN   = 2'd1; // 작동 (카운트다운)
    localparam PAUSE = 2'd2; // 일시정지 (문 열림)
    localparam DONE  = 2'd3; // 완료 (알람)

    reg [1:0] state;
    reg btnU_reg;
    wire btnU_push = (btnU & ~btnU_reg);
    
    always @(posedge clk) begin
        if(reset) btnU_reg <= 1'b0;
        else      btnU_reg <= btnU;
    end

    reg [26:0] sec_cnt;
    wire tick_1sec = (sec_cnt == 27'd99_999_999);
    always @(posedge clk) begin
        if (reset || tick_1sec) sec_cnt <= 0;
        else sec_cnt <= sec_cnt + 1;
    end

    reg [2:0] alarm_cnt;
    assign motor_run = (state == RUN);

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            time_sec <= 0;
            alarm_on <= 0;
            alarm_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    alarm_on <= 0;
                    alarm_cnt <= 0;
                    if (btnU_push) begin
                        time_sec <= 30; 
                        if (door_open) state <= PAUSE; // 문 열린 상태로 시간 넣으면 일시정지
                        else state <= RUN;             // 문 닫혀있으면 바로 카운트 시작
                    end
                end

                RUN: begin
                    if (door_open) begin
                        state <= PAUSE; // ★ 작동 중 문이 열리면 즉시 일시정지(시간 멈춤)
                    end else if (btnU_push) begin
                        if (time_sec + 30 > 599) time_sec <= 599;
                        else time_sec <= time_sec + 30;
                    end else if (tick_1sec) begin
                        if (time_sec > 1) time_sec <= time_sec - 1;
                        else begin
                            time_sec <= 0;
                            state <= DONE; 
                        end
                    end
                end

                PAUSE: begin
                    if (!door_open) state <= RUN; // ★ 문을 닫으면 멈춰있던 시간부터 다시 재개
                    else if (btnU_push) begin
                        if (time_sec + 30 > 599) time_sec <= 599;
                        else time_sec <= time_sec + 30;
                    end
                end

                DONE: begin
                    alarm_on <= 1; 
                    if (door_open) begin
                        state <= IDLE; // 문을 열어 음식을 꺼내면 초기화
                        alarm_on <= 0;
                    end else if (tick_1sec) begin
                        if (alarm_cnt < 3) alarm_cnt <= alarm_cnt + 1; 
                        else begin
                            state <= IDLE;
                            alarm_on <= 0;
                        end
                    end
                end
            endcase
        end
    end
endmodule