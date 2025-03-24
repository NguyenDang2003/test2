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
    
    # Tần số cơ bản của tín hiệu (Hz)
    # Tần số này phải tỷ lệ với engine_speed
    signal_frequency = engine_speed / 60  # Chuyển rpm thành Hz
    
    # Bộ đếm mẫu để theo dõi vị trí trong chu kỳ
    sample_counter = 0
    
    while True:
        # Cập nhật tần số khi engine_speed thay đổi
        signal_frequency = engine_speed / 60  # Tần số (Hz)
        
        # Tính toán thời gian mỗi chu kỳ và thời gian mỗi mẫu
        cycle_time = 1 / signal_frequency        # Thời gian một chu kỳ của tín hiệu (s)
        time_per_tooth = cycle_time / teeth      # Thời gian mỗi răng (s)
        sample_time = time_per_tooth / samples_per_tooth  # Thời gian mỗi mẫu (s)
        
        print(f"Engine speed = {engine_speed} rpm, Signal frequency = {signal_frequency} Hz")
        print(f"Teeth = {teeth}, Gap teeth = {gap_teeth}")
        print(f"Cycle time = {cycle_time:.6f}s, Sample time = {sample_time:.6f}s")
        
        # Tạo và gửi mẫu tín hiệu
        for tooth in range(teeth):
            if tooth < gap_teeth:
                # Răng khuyết - gửi giá trị 0
                for i in range(samples_per_tooth):
                    send_to_dac(0)
                    time.sleep(sample_time)
            else:
                # Răng bình thường - gửi tín hiệu sine
                for i in range(samples_per_tooth):
                    # Tính toán vị trí trong chu kỳ sóng sine (0 đến 2π)
                    # Quan trọng: Tần số phải dựa vào engine_speed
                    phase = 2 * np.pi * signal_frequency * sample_counter * sample_time
                    value = np.sin(phase)
                    send_to_dac(value)
                    time.sleep(sample_time)
                    sample_counter += 1
            
            # Kiểm tra nếu có thay đổi thông số
            if engine_speed != last_speed or teeth != last_teeth or gap_teeth != last_gap_teeth:
                last_speed = engine_speed
                last_teeth = teeth
                last_gap_teeth = gap_teeth
                # Đặt lại bộ đếm mẫu khi thay đổi thông số
                sample_counter = 0
                break

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