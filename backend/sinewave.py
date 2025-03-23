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
    value = int((value + 1) / 2 * 4095)  # Chuyển [-1,1] thành [0, 4095]
    value = max(0, min(4095, value))  # Giới hạn trong khoảng hợp lệ
    high_byte = (0x30 | (value >> 8)) & 0xFF  # MCP4921 config
    low_byte = value & 0xFF
    
    try:
        spi.xfer2([high_byte, low_byte])
    except Exception as e:
        print(f"SPI Error: {e}")

def spi_loop():
    global engine_speed, teeth, gap_teeth, samples_per_tooth
    last_speed = engine_speed
    last_teeth = teeth
    last_gap_teeth = gap_teeth
    
    # Precompute sine table
    sine_table = np.sin(2 * np.pi * np.arange(samples_per_tooth) / samples_per_tooth)
    
    # Precompute zero samples for gap teeth
    zero_samples = np.zeros(samples_per_tooth)
    
    while True:
        # Tính toán lại các tham số
        T = 1 / (engine_speed / 60 * teeth)
        dt = T / samples_per_tooth
        
        print(f"New params: speed={engine_speed}, T={T:.6f}, dt={dt:.6f}")

        # Hàm sleep chính xác
        def precise_sleep(duration):
            end = time.perf_counter() + duration
            while time.perf_counter() < end:
                pass

        # Lưu trạng thái hiện tại để phát hiện thay đổi
        current_params = (engine_speed, teeth, gap_teeth)
        
        try:
            while True:
                start_tooth = time.perf_counter()
                
                for tooth in range(teeth):
                    if tooth < gap_teeth:
                        samples = zero_samples
                    else:
                        samples = sine_table
                    
                    start_sample = time.perf_counter()
                    for i, sample in enumerate(samples):
                        send_to_dac(sample)
                        target_time = start_sample + (i + 1) * dt
                        while time.perf_counter() < target_time:
                            pass
                    
                    # Kiểm tra thay đổi sau mỗi răng
                    if current_params != (engine_speed, teeth, gap_teeth):
                        raise StopIteration
                        
                # Kiểm tra timing tổng thể
                actual_duration = time.perf_counter() - start_tooth
                if actual_duration > T * teeth:
                    print(f"Timing warning: {actual_duration:.6f} > {T * teeth:.6f}")
                
        except StopIteration:
            print("Parameter change detected, recalculating...")
            last_speed, last_teeth, last_gap_teeth = engine_speed, teeth, gap_teeth
            # Cập nhật lại bảng sine nếu cần
            if samples_per_tooth != len(sine_table):
                sine_table = np.sin(2 * np.pi * np.arange(samples_per_tooth) / samples_per_tooth)
                zero_samples = np.zeros(samples_per_tooth)

            

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