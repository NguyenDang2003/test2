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

# Số mẫu trên mỗi răng - cố định
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
    
    # phase = 0.0  # Ghi nhớ pha của sóng

    while True:
        # Tính toán các giá trị dựa vào engine_speed
        tooth_freq = engine_speed / 60  # Số răng / giây (Hz)
        full_cycle_freq = tooth_freq * teeth  # Tần số của một chu kỳ đầy đủ (Hz)
        tooth_period = 1 / full_cycle_freq  # Chu kỳ của một răng (s)
        sample_period = tooth_period / samples_per_tooth  # Thời gian giữa các mẫu (s)
        
        print(f"Running SPI loop: Engine speed = {engine_speed} rpm, Teeth = {teeth}, "
              f"Tooth period = {tooth_period:.6f}s, Sample period = {sample_period:.6f}s")

        # Thời gian bắt đầu chu kỳ
        cycle_start_time = time.time()

        # Tạo sóng sine cho từng răng
        for tooth in range(teeth):
            if tooth < gap_teeth:  # Răng khuyết
                for i in range(samples_per_tooth):
                    send_to_dac(0)
                    
                    # Tính thời điểm mẫu tiếp theo
                    next_sample_time = cycle_start_time + (tooth * samples_per_tooth + i + 1) * sample_period
                    
                    # Đợi đến thời điểm đó
                    time_to_wait = max(0, next_sample_time - time.time())
                    if time_to_wait > 0:
                        time.sleep(time_to_wait)
            else:
                # Tạo sóng sine cho răng bình thường
                for i in range(samples_per_tooth):
                    # Tính góc pha dựa vào vị trí mẫu
                    phase_angle = 2 * np.pi * i / samples_per_tooth
                    value = np.sin(phase_angle)
                    send_to_dac(value)
                    
                    # Tính thời điểm mẫu tiếp theo
                    next_sample_time = cycle_start_time + (tooth * samples_per_tooth + i + 1) * sample_period
                    
                    # Đợi đến thời điểm đó
                    time_to_wait = max(0, next_sample_time - time.time())
                    if time_to_wait > 0:
                        time.sleep(time_to_wait)
            
            # Cập nhật pha cho răng tiếp theo
            # phase += 2 * np.pi
            
            # Kiểm tra nếu tham số thay đổi
            if engine_speed != last_speed or teeth != last_teeth or gap_teeth != last_gap_teeth:
                break

        # Cập nhật tham số nếu có thay đổi
        last_speed = engine_speed
        last_teeth = teeth
        last_gap_teeth = gap_teeth

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
    app.run(host='0.0.0.0', port=5000, debug=False, use_reloader=False)

if __name__ == "__main__":
    # Chạy luồng Flask
    flask_thread = threading.Thread(target=run_flask, daemon=True)
    flask_thread.start()

    # Chạy luồng SPI
    spi_thread = threading.Thread(target=spi_loop, daemon=True)
    spi_thread.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Program terminated")