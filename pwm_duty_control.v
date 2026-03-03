`timescale 1ns / 1ps

module pwm_duty_control(
    input clk, 
    input reset,
    input duty_inc,       // 현재 로직에서는 사용되지 않지만 포트는 유지
    input duty_dec,
    input run_en,         // 타이머가 RUN 상태일 때 1

    output [3:0] DUTY_CYCLE,
    output PWM_OUT,
    output PWM_OUT_LED
    );

    // 기본값은 7로 설정 (필요 시 수정 가능)
    localparam FIXED_DUTY = 4'd7; 

    reg [3:0] r_counter_PWM;

    // 1. PWM 카운터 (0~9 반복)
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_counter_PWM <= 0;
        end else begin
            if(r_counter_PWM >= 4'd9) r_counter_PWM <= 0;
            else r_counter_PWM <= r_counter_PWM + 1;
        end
    end

    // 2. 출력 로직 수정
    // run_en이 1(타이머 동작 중)일 때만 FIXED_DUTY(7)를 기준으로 PWM 출력
    // run_en이 0일 때는 무조건 0 출력 (모터 정지)
    assign PWM_OUT = (run_en && (r_counter_PWM < FIXED_DUTY)) ? 1'b1 : 1'b0;
    
    assign PWM_OUT_LED = PWM_OUT;
    
    // FND에 표시될 값도 동작 중엔 7, 아닐 땐 0으로 표시되도록 설정
    assign DUTY_CYCLE = (run_en) ? FIXED_DUTY : 4'd0;

endmodule