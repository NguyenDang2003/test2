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
samples_per_tooth = 1000

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
        # Tính toán lại chu kỳ của một răng
        T = 1 / (engine_speed / 60 * teeth)
        dt = T / samples_per_tooth  # Khoảng thời gian giữa 2 mẫu
        omega = 2 * np.pi / T  # Tần số góc

        print(f"Running SPI loop: Engine speed = {engine_speed}, Teeth = {teeth}, T = {T:.6f}s, dt = {dt:.6f}s")

        while True:
            start_time = time.time()

            for tooth in range(teeth):
                if tooth < gap_teeth:  # Nếu là răng khuyết, gửi 0
                    for _ in range(samples_per_tooth):
                        send_to_dac(0)
                        time.sleep(dt)
                else:  # Nếu là răng có sóng sine
                    min_vl, max_vl = float('inf'), float('-inf')
                    for i in range(samples_per_tooth):
                        value = np.sin(omega * i * dt)  # Tạo giá trị sóng sine
                        min_vl = min(min,value)
                        max_vl = max(max,value)
                        send_to_dac(value)
                        time.sleep(dt)
                    print(f"Min value: {min_vl}, Max value: {max_vl}")

            # Nếu có thay đổi thông số thì dừng vòng lặp để cập nhật lại
            if engine_speed != last_speed or teeth != last_teeth or gap_teeth != last_gap_teeth:
                last_speed, last_teeth, last_gap_teeth = engine_speed, teeth, gap_teeth
                break  # Cập nhật lại thông số và tính toán lại

            

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

# Chạy Flask server trong luồng riêng
def run_flask():
    app.run(host='127.0.0.1', port=5000, debug=False, use_reloader=False)

flask_thread = threading.Thread(target=run_flask, daemon=True)
flask_thread.start()

# Chạy luồng SPI
spi_thread = threading.Thread(target=spi_loop, daemon=True)
spi_thread.start()

while True:
    time.sleep(1)
