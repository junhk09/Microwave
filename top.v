`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input btnD,      
    input btnU,
    input [1:0] motor_direction, // XDC의 스위치 V17, V16

    output door,     
    output buzzer,   
    output pwm_out,              // 서보모터용 (JC2)
    
    // DC 모터 관련 출력 (XDC 이름과 일치시킴)
    output PWM_OUT,              // JA1
    output [1:0] in1_in2,        // JA2, JA3 (방향 제어)
    output PWM_OUT_LED,          // PWM 동작 확인용 LED (U16)
    
    output [3:0] an,
    output [7:0] seg
);

    // --- 버튼 디바운서 ---
    wire w_btnD, w_btnU; 
    debouncer u_btnD_debouncer(.clk(clk), .reset(reset), .noisy_btn(btnD), .clean_btn(w_btnD));
    debouncer u_btnU_debouncer(.clk(clk), .reset(reset), .noisy_btn(btnU), .clean_btn(w_btnU));

    // --- 서보모터 및 문 상태 ---
    wire w_door_state; 
    servo_control u_servo_control (
        .clk(clk), .reset(reset), .btnD(w_btnD),
        .pwm_out(pwm_out),
        .door_state(w_door_state) 
    );

    // --- 타이머 및 DC 모터 제어 신호 ---
    wire [9:0] w_time_sec;
    wire w_alarm_on;
    wire w_motor_run; // 타이머가 RUN 상태일 때 1이 됨

    microwave_timer u_timer (
        .clk(clk),
        .reset(reset),
        .btnU(w_btnU),
        .door_open(w_door_state),
        .time_sec(w_time_sec),
        .alarm_on(w_alarm_on),
        .motor_run(w_motor_run)
    );

    // DC 모터 PWM 제어
    pwm_duty_control u_pwm (
        .clk(clk),
        .reset(reset),
        .run_en(w_motor_run),
        .PWM_OUT(PWM_OUT),
        .PWM_OUT_LED(PWM_OUT_LED),
        .DUTY_CYCLE()
    );

    // 모터 방향 제어
    assign in1_in2 = (w_motor_run) ? motor_direction : 2'b00;

    // --- FND 제어 ---
    fnd_controller u_fnd (
        .clk(clk), .reset(reset),
        .door_open(w_door_state),
        .time_sec(w_time_sec),
        .an(an), .seg(seg)
    );

    // --- 부저 신호 생성 모듈들 ---
    wire w_alarm_buzzer; // 완료 알람 (삐- 삐- 삐-)
    wire w_beep_on, w_beep_out; // 버튼 클릭음 (삑)
    wire w_base_buzzer; // 문 열림/닫힘 및 인트로 멜로디 (도-솔 / 솔-도)

    // 1. 완료 알람 모듈
    microwave_alarm u_alarm (.clk(clk), .reset(reset), .alarm_on(w_alarm_on), .buzzer_out(w_alarm_buzzer));
    
    // 2. 버튼 클릭음 모듈
    button_beep u_beep(.clk(clk), .reset(reset), .btn(w_btnU), .beep_on(w_beep_on), .beep_out(w_beep_out));
    
    // 3. 문 상태 및 인트로 멜로디 모듈 (추가된 부분)
    buzzer_control u_buzzer_control(
        .clk(clk),
        .reset(reset),
        .btnD(w_btnD),       // 문 버튼 입력
        .door(),             // 내부 LED 제어는 생략하거나 비워둠
        .buzzer(w_base_buzzer)
    );

    // --- 부저 최종 출력 (우선순위 결정) ---
    // 완료 알람이 1순위, 버튼음이 2순위, 문 멜로디가 3순위입니다.
    assign buzzer = (w_alarm_on) ? w_alarm_buzzer : 
                    (w_beep_on)  ? w_beep_out     : 
                                   w_base_buzzer;

    assign door = w_door_state; // LED로 문 상태 표시

endmodule