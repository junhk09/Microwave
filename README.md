# Microwave
Verilog와 Basys3를 이용한 전자레인지 기능 구현
<div align="center">
 
  
  <h1> 🎛️ Basys3 Microwave Controller </h1>
  <p>
    <b>Verilog를 활용한 FPGA 기반 전자레인지 시스템 구현 프로젝트</b>
  </p>

  <img src="https://img.shields.io/badge/Verilog-000000?style=for-the-badge&logo=verilog&logoColor=white">
  <img src="https://img.shields.io/badge/Xilinx_Vivado-E31837?style=for-the-badge&logo=xilinx&logoColor=white">
  <img src="https://img.shields.io/badge/Basys3-0055A5?style=for-the-badge">
</div>

<br/>

<details>
  <summary><b>📚 목차 보기 (클릭!)</b></summary>
  <ol>
    <li><a href="#-project-overview">프로젝트 개요</a></li>
    <li><a href="#-features">주요 기능</a></li>
    <li><a href="#-hardware-setup">하드웨어 구성</a></li>
  </ol>
</details>

<hr/>

<h2 id="-features">✨ 주요 기능 (Features)</h2>
<table>
  <tr>
    <td align="center">⏲️ <b>타이머 및 FND 디스플레이</b></td>
    <td align="center">🚪 <b>서보모터 도어 제어</b></td>
  </tr>
  <tr>
    <td>남은 시간을 <b>분:초</b> 형태로 7-Segment(FND)에 출력하며, 카운트다운을 진행합니다.</td>
    <td>버튼 입력을 통해 전자레인지 문 상태(열림/닫힘)를 토글하고 서보모터로 제어합니다.</td>
  </tr>
  <tr>
    <td align="center">🎵 <b>부저 알람 (Buzzer)</b></td>
    <td align="center">⚙️ <b>회전판 DC 모터 구동</b></td>
  </tr>
  <tr>
    <td>조리 시작, 도어 개폐, 조리 완료 시 상황에 맞는 각기 다른 멜로디와 경고음을 출력합니다.</td>
    <td>전자레인지가 작동하는(RUN) 동안 회전판이 돌아가도록 PWM 신호로 DC 모터를 제어합니다.</td>
  </tr>
</table>

<br/>

<h2 id="-hardware-setup">🛠 하드웨어 구성 (Hardware Setup)</h2>
<blockquote>
  <p>본 프로젝트는 <b>Basys3 FPGA 보드</b>를 기반으로 동작하며, 외부 모터 모듈 연결이 필요합니다.</p>
</blockquote>

<ul>
  <li><b>Main Board:</b> Digilent Basys3 (Artix-7 FPGA)</li>
  <li><b>Actuators:</b> 
    <ul>
      <li>서보모터 (도어 개폐 시뮬레이션 용)</li>
      <li>DC 모터 (내부 회전판 구동 용 - PWM 50% 듀티비 제어)</li>
    </ul>
  </li>
  <li><b>Input/Output:</b> On-board Buttons (디바운싱 적용), 4-Digit FND, LEDs, Buzzer</li>
</ul>

<br/>

<h2 id="-demo">🎥 동작 데모 (Demo)</h2>
<p align="center">
  <i>여기에 동작하는 GIF 이미지나 데모 영상 링크를 추가하세요!</i><br>
 (https://youtu.be/kJlUGPp_sK8)
</p>
