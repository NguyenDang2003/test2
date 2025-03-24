import threading
import numpy as np
import spidev
import time
from flask import Flask, request, jsonify

app = Flask(__name__)

spi = spidev.SpiDev()
spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
spi.max_speed_hz = 5000000  # Tăng tốc độ SPI lên 5 MHz để giảm độ trễ

# Biến toàn cục lưu thông số động cơ
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng
gap_teeth = 0        # Số răng khuyết

# Số mẫu trên mỗi răng
samples_per_tooth = 1000

def generate_sine_buffer():
    """Tạo buffer chứa dữ liệu sóng sin cho một răng."""
    buffer = []
    for i in range(samples_per_tooth):
        phase_angle = 2 * np.pi * i / samples_per_tooth
        value = int((np.sin(phase_angle) + 1) * 2047)  # Chuyển đổi về dải 0-4095
        buffer.append(value >> 8)  # Byte cao
        buffer.append(value & 0xFF)  # Byte thấp
    return buffer

sine_buffer = generate_sine_buffer()

def send_buffer(buffer):
    """Gửi toàn bộ buffer đến DAC qua SPI."""
    try:
        spi.xfer2(buffer)
    except Exception as e:
        print(f"SPI Error: {e}")

def spi_loop():
    global engine_speed, teeth, gap_teeth
    last_speed = engine_speed
    last_teeth = teeth
    last_gap_teeth = gap_teeth
    
    while True:
        tooth_freq = engine_speed / 60  # Tần số vòng quay (Vòng/giây)
        full_cycle_freq = tooth_freq * teeth  # Tần số của một răng (Răng/giây)
        tooth_period = 1 / full_cycle_freq  # Chu kỳ của một răng
        sample_period = tooth_period / samples_per_tooth  # Thời gian giữa các mẫu

        print(f"Running SPI loop: Engine speed = {engine_speed} rpm, Teeth = {teeth}, "
              f"Tooth period = {tooth_period:.6f}s, Sample period = {sample_period:.6f}s")
        
        cycle_start_time = time.time()
        
        for tooth in range(teeth):
            if tooth < gap_teeth:
                send_buffer([0] * (samples_per_tooth * 2))  # Gửi buffer toàn 0 cho răng khuyết
            else:
                send_buffer(sine_buffer)
            
            next_tooth_time = cycle_start_time + (tooth + 1) * tooth_period
            time_to_wait = max(0, next_tooth_time - time.time())
            if time_to_wait > 0:
                time.sleep(time_to_wait)
            
            if engine_speed != last_speed or teeth != last_teeth or gap_teeth != last_gap_teeth:
                break

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
        print("Program terminated")
