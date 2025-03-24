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

# Số mẫu trên mỗi răng
samples_per_tooth = 50

def send_to_dac(value):
    """Gửi giá trị đến DAC MCP4921 qua SPI bằng pigpio."""
    value = (value + 1) / 2  # Chuyển [-1,1] thành [0,1]
    value = int(value * 4095)  # Chuyển thành dải 0 - 4095
    value = max(0, min(4095, value))  # Đảm bảo không vượt quá phạm vi

    high_byte = (0x30 | (value >> 8)) & 0xFF  # MCP4921: Cấu hình byte cao
    low_byte = value & 0xFF  # Byte thấp
    
    pi.spi_write(spi, [high_byte, low_byte])  # Gửi qua SPI

def spi_loop():
    global engine_speed, teeth, gap_teeth

    last_speed = engine_speed
    last_teeth = teeth
    last_gap_teeth = gap_teeth
    
    phase = 0.0  # Pha sóng sin

    while True:
        # Tính toán các giá trị dựa vào engine_speed
        tooth_freq = engine_speed / 60  # Số răng / giây (Hz)
        full_cycle_freq = tooth_freq * teeth  # Tần số của một chu kỳ đầy đủ (Hz)
        if full_cycle_freq == 0:
            time.sleep(0.1)
            continue

        tooth_period = 1 / full_cycle_freq  # Chu kỳ của một răng (s)
        sample_period = tooth_period / samples_per_tooth  # Thời gian giữa các mẫu (s)
        
        print(f"Running SPI loop: Engine speed = {engine_speed} rpm, Teeth = {teeth}, "
              f"Tooth period = {tooth_period:.6f}s, Sample period = {sample_period:.6f}s")

        cycle_start_time = time.time()

        for tooth in range(teeth):
            if tooth < gap_teeth:  # Răng khuyết
                for _ in range(samples_per_tooth):
                    send_to_dac(0)

                    next_sample_time = cycle_start_time + (_ + 1) * sample_period
                    time_to_wait = max(0, next_sample_time - time.time())
                    if time_to_wait > 0:
                        time.sleep(time_to_wait)
            else:
                for i in range(samples_per_tooth):
                    phase_angle = phase + 2 * np.pi * i / samples_per_tooth
                    value = np.sin(phase_angle)
                    send_to_dac(value)

                    next_sample_time = cycle_start_time + (tooth * samples_per_tooth + i + 1) * sample_period
                    time_to_wait = max(0, next_sample_time - time.time())
                    if time_to_wait > 0:
                        time.sleep(time_to_wait)
            
            phase += 2 * np.pi  # Cập nhật pha

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
        pi.spi_close(spi)  # Đóng SPI
        pi.stop()  # Dừng pigpio
        print("Program terminated")
