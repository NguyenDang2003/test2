from flask import Flask, request, jsonify
import numpy as np
import spidev
import time

app = Flask(__name__)

# SPI setup
spi = spidev.SpiDev()
spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
spi.max_speed_hz = 1000000  # 1 MHz

# Global variables
engine_speed = 1500  # RPM
teeth = 36           # Số răng lý tưởng
gap_teeth = 4        # Số răng khuyết
running = True

def send_to_dac(value):
    """Gửi giá trị đến DAC MCP4921 qua SPI."""
    value = int((value + 1) / 2 * 4095)  # Chuyển [-1,1] thành [0, 4095]
    value = max(0, min(4095, value))  # Đảm bảo nằm trong khoảng hợp lệ
    high_byte = (0x30 | (value >> 8)) & 0xFF
    low_byte = value & 0xFF
    
    try:
        spi.xfer2([high_byte, low_byte])
    except Exception as e:
        print(f"SPI Error: {e}")

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

# Chạy Flask trong một quá trình riêng
from multiprocessing import Process

def run_flask():
    app.run(host='127.0.0.1', port=5000, debug=False, use_reloader=False)

# Hàm chính để tạo và gửi tín hiệu
def main():
    global engine_speed, teeth, gap_teeth
    
    # Khởi tạo vị trí hiện tại
    current_position = 0.0  # Vị trí góc (0-360 độ)
    last_time = time.time()
    
    print("Engine simulator running...")
    
    try:
        while True:
            # Tính toán thời gian đã trôi qua
            current_time = time.time()
            elapsed = current_time - last_time
            last_time = current_time
            
            # Tính toán vị trí góc mới dựa trên tốc độ động cơ
            rps = engine_speed / 60.0  # Số vòng quay mỗi giây
            angle_change = elapsed * rps * 360.0  # Thay đổi góc (độ)
            current_position = (current_position + angle_change) % 360.0
            
            # Xác định răng hiện tại
            total_teeth = teeth
            current_tooth = int((current_position / 360.0) * total_teeth)
            
            # Xác định xem răng hiện tại có phải là răng khuyết hay không
            is_gap_tooth = current_tooth < gap_teeth
            
            # Tạo giá trị đầu ra
            if is_gap_tooth:
                output_value = 0.0  # Răng khuyết - không có tín hiệu
            else:
                # Tính toán vị trí trong răng (0 đến 1)
                tooth_angle = 360.0 / total_teeth
                position_in_tooth = (current_position % tooth_angle) / tooth_angle
                
                # Tạo sóng sine cho răng này
                output_value = np.sin(2 * np.pi * position_in_tooth)
            
            # Gửi giá trị đến DAC
            send_to_dac(output_value)
            
            # Thời gian chờ nhỏ để không tải nặng CPU
            time.sleep(0.001)
            
    except KeyboardInterrupt:
        print("Shutting down...")
        spi.close()

if __name__ == "__main__":
    # Khởi động Flask trong một quá trình riêng
    flask_process = Process(target=run_flask)
    flask_process.daemon = True
    flask_process.start()
    
    # Chạy chức năng chính
    main()