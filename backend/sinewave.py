import threading
import numpy as np
import spidev
import time
from flask import Flask, request, jsonify

app = Flask(__name__)

spi = spidev.SpiDev()
spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
spi.max_speed_hz = 1000000  # 1 MHz

# Biến toàn cục lưu thông số động cơ
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng
gap_teeth = 0        # Số răng khuyết

# Số mẫu trên mỗi răng
samples_per_tooth = 100

def send_to_dac(value):
    """Gửi giá trị đến DAC MCP4921 qua SPI."""
    value = (value + 1) / 2  # Chuyển [-1,1] thành [0,1]
    value = int(value * 4095)  # Chuyển thành dải 0 - 4095
    value = max(0, min(4095, value))  # Đảm bảo không vượt quá phạm vi
    
    high_byte = (0x30 | (value >> 8)) & 0xFF  # Cấu hình MCP4921
    low_byte = value & 0xFF
    
    try:
        spi.xfer2([high_byte, low_byte])
    except Exception as e:
        print(f"SPI Error: {e}")

def spi_loop():
    global engine_speed, teeth, gap_teeth

    last_speed = engine_speed
    last_teeth = teeth
    last_gap_teeth = gap_teeth

    while True:
        # Tính toán các thông số mới
        T = 1 / (engine_speed / 60 * teeth)  # Chu kỳ của một răng
        dt = T / samples_per_tooth           # Khoảng thời gian giữa 2 mẫu
        omega = 2 * np.pi / T                # Tần số góc

        print(f"Engine Speed = {engine_speed} rpm, Teeth = {teeth}, Gap Teeth = {gap_teeth}")
        print(f"Cycle Time = {T:.6f}s, Sample Time = {dt:.6f}s")

        cycle_start_time = time.time()  # Lưu thời gian bắt đầu vòng lặp
        
        # Lặp qua từng răng
        for tooth in range(teeth):
            for i in range(samples_per_tooth):
                target_time = cycle_start_time + (tooth * samples_per_tooth + i) * dt

                if tooth < gap_teeth:
                    send_to_dac(0)
                else:
                    time_since_start = i * dt  # Thời gian từ khi bắt đầu răng
                    value = np.sin(omega * time_since_start)  # Tính giá trị sóng sine
                    send_to_dac(value)

                # Chờ đến thời gian của mẫu tiếp theo
                while time.time() < target_time:
                    pass  

            # Kiểm tra nếu có thay đổi thông số
            if engine_speed != last_speed or teeth != last_teeth or gap_teeth != last_gap_teeth:
                last_speed = engine_speed
                last_teeth = teeth
                last_gap_teeth = gap_teeth
                break  # Reset lại vòng lặp để cập nhật thông số mới

@app.route('/update_engine_data', methods=['POST'])
def update_engine_data():
    global engine_speed, teeth, gap_teeth
    data = request.get_json()

    if "speed" in data and "teeth" in data and "gapTeeth" in data:
        engine_speed = int(data["speed"])
        teeth = int(data["teeth"])
        gap_teeth = int(data["gapTeeth"])

        print(f"Updated: Speed = {engine_speed} rpm, Teeth = {teeth}, GapTeeth = {gap_teeth}")
        return jsonify({"message": "Data updated", "speed": engine_speed, "teeth": teeth, "gapTeeth": gap_teeth})

    return jsonify({"error": "Invalid request"}), 400
