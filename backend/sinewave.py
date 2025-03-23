import pigpio
import numpy as np
import threading
import time
from flask import Flask, request, jsonify

# Khởi tạo Flask
app = Flask(__name__)

# Kết nối với pigpio daemon
pi = pigpio.pi()
SPI_CHANNEL = 0
SPI_SPEED = 5000000  # 5 MHz

# Biến toàn cục lưu thông số động cơ
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng
gap_teeth = 4        # Số răng khuyết
samples_per_tooth = 1000  # Số mẫu trên mỗi răng (để mượt hơn)

def generate_sine(samples=1000):
    """Tạo dữ liệu sóng sine dưới dạng buffer gửi SPI."""
    sine_wave = np.sin(np.linspace(0, 2 * np.pi, samples))  # 1000 mẫu sine
    sine_values = ((sine_wave + 1) / 2 * 4095).astype(int)  # Chuyển [-1,1] -> [0, 4095]

    spi_data = []
    for value in sine_values:
        high_byte = (0x30 | (value >> 8)) & 0xFF  # MCP4921 config
        low_byte = value & 0xFF
        spi_data.append(high_byte)
        spi_data.append(low_byte)

    return bytes(spi_data)

def spi_loop():
    global engine_speed, teeth, gap_teeth
    last_speed, last_teeth, last_gap_teeth = engine_speed, teeth, gap_teeth

    while True:
        T = 1 / (engine_speed / 60 * teeth)  # Chu kỳ của một răng
        cycle_time = T / samples_per_tooth  # Khoảng thời gian giữa 2 mẫu
        sine_data = generate_sine(samples_per_tooth)  # Tạo dữ liệu sóng sine

        print(f"Running SPI loop: Engine speed = {engine_speed} rpm, Teeth = {teeth}, T = {T:.6f}s")

        while True:
            start_time = time.perf_counter()

            for tooth in range(teeth):
                if tooth < gap_teeth:  # Nếu là răng khuyết, gửi 0
                    pi.spi_write(SPI_CHANNEL, bytes([0x30, 0x00] * samples_per_tooth))
                else:  # Nếu là răng có sóng sine
                    pi.spi_write(SPI_CHANNEL, sine_data)

                while (time.perf_counter() - start_time) < cycle_time:
                    pass  # Đợi cho đến khi hoàn thành chu kỳ

                start_time += cycle_time

            # Kiểm tra nếu thông số thay đổi thì cập nhật
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
