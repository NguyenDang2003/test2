from flask import Flask, request, jsonify
import threading
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import spidev
import time

app = Flask(__name__)

spi = spidev.SpiDev()
spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
spi.max_speed_hz = 1000000  # 1 MHz

# Biến toàn cục lưu dữ liệu động cơ
engine_speed = 1500  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng lý tưởng
gap_teeth = 4        # Số răng khuyết

# Bộ đệm dữ liệu để gửi SPI
spi_buffer = []

def generate_waveform():
    """Tạo dữ liệu sóng sine cho mỗi chu kỳ của răng."""
    global spi_buffer, engine_speed, teeth, gap_teeth
    spi_buffer.clear()
    
    samples_per_tooth = 1000  # Số điểm dữ liệu trên mỗi răng
    T = 1 / (engine_speed / 60 * teeth)  # Chu kỳ của 1 răng
    time_values = np.linspace(0, T, samples_per_tooth, endpoint=False)
    
    for tooth in range(teeth):
        if tooth < gap_teeth:  # Răng khuyết
            spi_buffer.extend([0] * samples_per_tooth)
        else:  # Răng có sóng sine
            sine_wave = np.sin(2 * np.pi / T * time_values)
            spi_buffer.extend(sine_wave)

def send_to_dac(value):
    """Gửi giá trị đến DAC MCP4921 qua SPI."""
    value = int((value + 1) * 2047.5)  # Chuyển [-1,1] thành [0, 4095]
    value = value & 0xFFF  # Giới hạn 12-bit
    high_byte = (0x30 | (value >> 8)) & 0xFF  # Cấu hình MCP4921
    low_byte = value & 0xFF
    
    try:
        spi.xfer2([high_byte, low_byte])
    except Exception as e:
        print(f"SPI Error: {e}")

# Chạy luồng gửi SPI song song
def spi_loop():
    global spi_buffer, engine_speed, teeth
    while True:
        if len(spi_buffer) > 0:
            T = 1 / (engine_speed / 60 * teeth)  # Chu kỳ của 1 răng
            delay = T / 1000  # Điều chỉnh tốc độ gửi SPI

            for value in spi_buffer:
                send_to_dac(value)
                time.sleep(delay)

@app.route('/update_engine_data', methods=['POST'])
def update_engine_data():
    global engine_speed, teeth, gap_teeth
    data = request.get_json()
    
    if "speed" in data and "teeth" in data and "gapTeeth" in data:
        engine_speed = float(data["speed"])
        teeth = int(data["teeth"])
        gap_teeth = int(data["gapTeeth"])
        
        generate_waveform()  # Cập nhật lại sóng sine
        
        print(f"Updated: Speed = {engine_speed} rpm, Teeth = {teeth}, GapTeeth = {gap_teeth}")
        return jsonify({"message": "Data updated", "speed": engine_speed, "teeth": teeth, "gapTeeth": gap_teeth})
    
    return jsonify({"error": "Invalid request"}), 400

# Chạy Flask server trong luồng riêng
def run_flask():
    app.run(host='127.0.0.1', port=5000, debug=False, use_reloader=False)

flask_thread = threading.Thread(target=run_flask)
flask_thread.daemon = True
flask_thread.start()

# Khởi tạo dữ liệu ban đầu
generate_waveform()

# Chạy luồng SPI
spi_thread = threading.Thread(target=spi_loop, daemon=True)
spi_thread.start()
