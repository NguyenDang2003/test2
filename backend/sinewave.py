import threading
import numpy as np
import spidev
import time
from flask import Flask, request, jsonify

app = Flask(__name__)

# Khởi tạo SPI
spi = spidev.SpiDev()
spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
spi.max_speed_hz = 1000000  # 1 MHz

# Biến toàn cục lưu thông số động cơ
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng
gap_teeth = 0        # Số răng khuyết

# Số mẫu trên mỗi răng - cố định
samples_per_tooth = 100


def generate_waveform():
    """Tạo dữ liệu sóng sine và buffer gửi SPI"""
    global engine_speed, teeth, gap_teeth, samples_per_tooth
    
    # Mảng chứa dữ liệu toàn bộ chu kỳ
    total_samples = teeth * samples_per_tooth
    waveform_buffer = np.zeros(total_samples, dtype=np.uint16)

    # Tạo sóng sine trước
    sine_wave = np.sin(2 * np.pi * np.arange(samples_per_tooth) / samples_per_tooth)
    
    # Điền dữ liệu vào buffer
    for tooth in range(teeth):
        if tooth < gap_teeth:
            waveform_buffer[tooth * samples_per_tooth : (tooth + 1) * samples_per_tooth] = 2048  # Trung bình (0V)
        else:
            values = ((sine_wave + 1) / 2 * 4095).astype(np.uint16)
            waveform_buffer[tooth * samples_per_tooth : (tooth + 1) * samples_per_tooth] = values
    
    return waveform_buffer


def spi_loop():
    """Vòng lặp gửi tín hiệu qua SPI"""
    global engine_speed, teeth, gap_teeth, samples_per_tooth

    last_params = (engine_speed, teeth, gap_teeth)
    waveform_buffer = generate_waveform()

    while True:
        # Tính toán lại thời gian lấy mẫu
        tooth_period = 1 / (engine_speed * teeth / 60)
        sample_interval = tooth_period / samples_per_tooth

        print(f"New parameters: RPM={engine_speed}, Sample interval={sample_interval:.6f}s")

        # Kiểm tra thay đổi thông số và cập nhật buffer
        if last_params != (engine_speed, teeth, gap_teeth):
            waveform_buffer = generate_waveform()
            last_params = (engine_speed, teeth, gap_teeth)

        def precise_wait(target_time):
            while time.perf_counter() < target_time:
                pass

        try:
            while True:
                cycle_start = time.perf_counter()

                for i in range(len(waveform_buffer)):
                    target_time = cycle_start + (i + 1) * sample_interval
                    dac_value = waveform_buffer[i]

                    # Gửi một lần buffer thay vì từng mẫu riêng lẻ
                    high_byte = (dac_value >> 8) & 0xFF
                    low_byte = dac_value & 0xFF
                    spi.xfer2([high_byte, low_byte])

                    precise_wait(target_time)

                    # Kiểm tra nếu tham số thay đổi
                    if last_params != (engine_speed, teeth, gap_teeth):
                        raise StopIteration

        except StopIteration:
            print("Parameters changed, updating waveform buffer...")
            waveform_buffer = generate_waveform()
            last_params = (engine_speed, teeth, gap_teeth)


@app.route('/update_engine_data', methods=['POST'])
def update_engine_data():
    """API cập nhật tốc độ động cơ và số răng"""
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
