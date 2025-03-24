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
    """Gửi giá trị đến DAC MCP4921 qua SPI với định dạng chính xác."""
    # Chuyển đổi giá trị [-1, 1] thành [0, 4095]
    dac_value = int(((value + 1) / 2) * 4095)
    dac_value = max(0, min(4095, dac_value))  # Clamp giá trị

    # Tạo header theo datasheet MCP4921:
    # bit 15: 0 (Single mode)
    # bit 14: 0 (!Buffered)
    # bit 13: 1 (Gain = 1x)
    # bit 12: 1 (!Shutdown)
    header = 0x3000  # 0011 0000 0000 0000 in binary
    
    # Kết hợp header và dữ liệu 12-bit
    data = header | dac_value
    
    # Chia thành 2 byte
    high_byte = (data >> 8) & 0xFF
    low_byte = data & 0xFF
    
    try:
        spi.xfer2([high_byte, low_byte])
    except Exception as e:
        print(f"SPI Error: {e}")


def spi_loop():
    global engine_speed, teeth, gap_teeth, samples_per_tooth
    
    # Precompute sine wave values (tối ưu hiệu năng)
    sine_wave = np.sin(2 * np.pi * np.arange(samples_per_tooth) / samples_per_tooth)
    zero_wave = np.zeros(samples_per_tooth)
    
    # Biến lưu trạng thái trước đó
    last_params = (engine_speed, teeth, gap_teeth)
    
    while True:
        # Tính toán lại các tham số khi có thay đổi
        tooth_period = 1 / (engine_speed * teeth / 60)
        sample_interval = tooth_period / samples_per_tooth
        
        print(f"New parameters: RPM={engine_speed}, Sample interval={sample_interval:.6f}s")
        
        # Hàm sleep chính xác sử dụng busy waiting
        def precise_wait(target_time):
            while time.perf_counter() < target_time:
                pass
        
        try:
            while True:
                cycle_start = time.perf_counter()
                
                for tooth in range(teeth):
                    # Chọn dạng sóng phù hợp
                    waveform = zero_wave if tooth < gap_teeth else sine_wave
                    
                    for sample_idx, value in enumerate(waveform):
                        target_time = cycle_start + (
                            (tooth * samples_per_tooth + sample_idx + 1) * sample_interval
                        )
                        
                        send_to_dac(value)
                        precise_wait(target_time)
                        
                        # Kiểm tra thay đổi tham số sau mỗi sample
                        if last_params != (engine_speed, teeth, gap_teeth):
                            raise StopIteration
                
                # Kiểm tra timing tổng thể
                actual_duration = time.perf_counter() - cycle_start
                expected_duration = tooth_period * teeth
                if actual_duration > expected_duration * 1.05:
                    print(f"Timing drift: {actual_duration/expected_duration:.2%}")

        except StopIteration:
            print("Parameters changed, updating...")
            # Cập nhật lại các giá trị precomputed nếu cần
            if last_params[1] != teeth or last_params[2] != gap_teeth:
                sine_wave = np.sin(2 * np.pi * np.arange(samples_per_tooth) / samples_per_tooth)
                zero_wave = np.zeros(samples_per_tooth)
            last_params = (engine_speed, teeth, gap_teeth)

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