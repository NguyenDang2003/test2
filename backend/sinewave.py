import threading
import numpy as np
import pigpio
import time
from flask import Flask, request, jsonify

app = Flask(__name__)

# Khởi tạo pigpio và SPI
pi = pigpio.pi()
if not pi.connected:
    raise RuntimeError("Không thể kết nối với pigpio daemon!")

# Mở SPI với tốc độ 10 MHz
spi = pi.spi_open(0, 10000000, 0)  # CE0, tốc độ 10 MHz, mode 0

# Biến toàn cục lưu thông số động cơ
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng
gap_teeth = 0        # Số răng khuyết
samples_per_tooth = 50

def generate_spi_waveform():
    """Tạo và gửi tín hiệu sóng sin sử dụng pigpio wave_chain."""
    global engine_speed, teeth, gap_teeth
    
    pi.wave_clear()  # Xóa sóng cũ
    wave_ids = []
    
    tooth_freq = engine_speed / 60  # Hz
    full_cycle_freq = tooth_freq * teeth  # Hz
    sample_period = int(1e6 / (full_cycle_freq * samples_per_tooth))  # Microseconds
    
    for i in range(samples_per_tooth):
        value = np.sin(2 * np.pi * i / samples_per_tooth)
        value = (value + 1) / 2  # Chuyển [-1,1] thành [0,1]
        value = int(value * 4095)  # Chuyển thành dải 0 - 4095
        value = max(0, min(4095, value))  # Đảm bảo không vượt quá phạm vi
        
        high_byte = (0x30 | (value >> 8)) & 0xFF
        low_byte = value & 0xFF
        spi_data = [high_byte, low_byte]
        
        pi.wave_add_spi(channel=0, data=spi_data, spi_speed=10000000)
        wave_ids.append(pi.wave_create())
    
    pi.wave_chain(wave_ids * teeth)  # Lặp lại toàn bộ chu kỳ răng

def spi_loop():
    """Chạy vòng lặp cập nhật sóng khi có thay đổi."""
    global engine_speed, teeth, gap_teeth
    
    last_speed, last_teeth, last_gap_teeth = engine_speed, teeth, gap_teeth
    
    while True:
        if (engine_speed != last_speed or
            teeth != last_teeth or
            gap_teeth != last_gap_teeth):
            generate_spi_waveform()
            last_speed, last_teeth, last_gap_teeth = engine_speed, teeth, gap_teeth
        time.sleep(0.1)

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
    flask_thread = threading.Thread(target=run_flask, daemon=True)
    flask_thread.start()
    
    spi_thread = threading.Thread(target=spi_loop, daemon=True)
    spi_thread.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Shutting down...")
        pi.wave_tx_stop()
        pi.wave_clear()
        pi.spi_close(spi)
        pi.stop()
        print("Program terminated")
