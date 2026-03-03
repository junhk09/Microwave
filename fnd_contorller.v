`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    input door_open,      // 문 상태 (1:열림, 0:닫힘)
    input [9:0] time_sec, // 타이머 시간
    output [3:0] an,
    output [7:0] seg
);

    wire w_tick;
    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    // 1. 내부 1ms 틱 생성기
    tick_generator u_tick_gen(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    // 2. 자리 선택
    fnd_digit_select u_fnd_digit_select(
        .reset(reset),
        .tick(w_tick),
        .sel(w_sel)
    );

    // 3. 시간을 분:초 및 O/C 기호로 변환
    time2bcd u_time2bcd(
        .door_open(door_open),
        .time_sec(time_sec),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000)
    );

    // 4. 세그먼트 출력
    fnd_digit_display u_fnd_digit_display(
        .digit_sel(w_sel),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000),
        .an(an),
        .seg(seg)
    );

endmodule

// ==========================================
// 시간 -> 분:초 BCD 변환기
// ==========================================
module time2bcd(
    input door_open,
    input [9:0] time_sec,
    output [3:0] d1, d10, d100, d1000
);
    // 천의 자리: 문 열림(O=10), 닫힘(C=11)
    assign d1000 = door_open ? 4'd10 : 4'd11;

    wire [3:0] min = time_sec / 60;
    wire [5:0] sec = time_sec % 60;

    assign d100 = min % 10;
    assign d10  = sec / 10;
    assign d1   = sec % 10;
endmodule

// ==========================================
// FND 출력 및 자리 선택 (기존과 동일)
// ==========================================
module fnd_digit_display(
    input [1:0] digit_sel,
    input [3:0] d1, d10, d100, d1000,
    output reg [3:0] an,
    output reg [7:0] seg
);
    reg [3:0] bcd_data;
    always @(*) begin
        case(digit_sel)
            2'b00: begin bcd_data = d1;   an = 4'b1110; end
            2'b01: begin bcd_data = d10;  an = 4'b1101; end
            2'b10: begin bcd_data = d100; an = 4'b1011; end
            2'b11: begin bcd_data = d1000; an = 4'b0111; end
            default: begin bcd_data = 4'b0000; an = 4'b1111; end
        endcase
    end

    always @(*) begin
        case(bcd_data)
            4'd0: seg = 8'b11000000; 4'd1: seg = 8'b11111001;
            4'd2: seg = 8'b10100100; 4'd3: seg = 8'b10110000;
            4'd4: seg = 8'b10011001; 4'd5: seg = 8'b10010010;
            4'd6: seg = 8'b10000010; 4'd7: seg = 8'b11111000;
            4'd8: seg = 8'b10000000; 4'd9: seg = 8'b10010000;
            4'd10: seg = 8'b11000000; // 'O'
            4'd11: seg = 8'b11000110; // 'C'
            default: seg = 8'b11111111;
        endcase
    end
endmodule

module fnd_digit_select(
    input reset,
    input tick,
    output reg [1:0] sel
);
    always @(posedge reset or posedge tick) begin
        if (reset) sel <= 0;
        else sel <= sel + 1;
    end
endmodule

// (작성해주셨던 tick_generator 모듈도 이 파일 맨 아래나 별도 파일로 존재해야 합니다)