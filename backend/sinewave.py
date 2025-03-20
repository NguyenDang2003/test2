from flask import Flask, request, jsonify
import threading
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
# import spidev
import time

app = Flask(__name__)

# spi = spidev.SpiDev()
# spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
# spi.max_speed_hz = 1000000  # 1 MHz

# Biến toàn cục lưu dữ liệu động cơ
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36       # Số răng lý tưởng
gap_teeth = 2      # Số răng khuyết

# Biến lưu dữ liệu để vẽ đồ thị - sử dụng deque để giới hạn kích thước
max_points = 5000
x_data = deque(maxlen=max_points)
y_data = deque(maxlen=max_points)
t = 0
fig, ax = plt.subplots()
line, = ax.plot([], [], lw=2)

# Cấu hình đồ thị
ax.set_ylim(-1.2, 1.2)
ax.set_xlim(0.01, 0.02)  
ax.set_xlabel("Thời gian (s)")
ax.set_ylabel("Biên độ")
ax.set_title("Sóng Sin động")
ax.grid()

# Hàm cập nhật dữ liệu trên đồ thị
def update_graph(frame):
    global x_data, y_data, t, engine_speed, teeth, gap_teeth

    T = 1 / (engine_speed / 60 * teeth)
    
    new_x = np.linspace(t, t + 0.001, 1000)  # Giảm số điểm từ 1000 xuống 100 để giảm tải
    
    # Tính toán vị trí trong chu kỳ răng - tối ưu hóa so với code ban đầu
    z = int(t / T)
    current_tooth = z % teeth
    
    # Tạo tín hiệu dựa trên vị trí răng
    if current_tooth < gap_teeth:
        new_y = np.zeros_like(new_x)
    else:
        new_y = np.sin(2 * np.pi * (1 / T) * new_x)
    
    # Thêm dữ liệu mới vào deque
    x_data.extend(new_x)
    y_data.extend(new_y)
    t += 0.001

    # Cập nhật đồ thị
    line.set_data(list(x_data), list(y_data))
    ax.set_xlim(t - 0.01, t)
    
    return line,

# Tạo animation với blit=True để tối ưu hóa hiệu suất
ani = animation.FuncAnimation(fig, update_graph, interval=10, blit=True)

# API nhận dữ liệu từ Flutter
@app.route('/update_engine_data', methods=['POST'])
def update_engine_data():
    global engine_speed, teeth, gap_teeth
    data = request.get_json()

    if "speed" in data and "teeth" in data and "gapTeeth" in data:
        engine_speed = float(data["speed"])
        teeth = int(data["teeth"])
        gap_teeth = int(data["gapTeeth"])

        print(f"Updated: Speed = {engine_speed} rpm, Teeth = {teeth}, GapTeeth = {gap_teeth}")
        return jsonify({"message": "Data updated", "speed": engine_speed, "teeth": teeth, "gapTeeth": gap_teeth})

    return jsonify({"error": "Invalid request"}), 400

# Chạy Flask server trong luồng riêng
def run_flask():
    app.run(host='127.0.0.1', port=5000, debug=False, use_reloader=False)

# Điểm khởi đầu chương trình
if __name__ == '__main__':
    # Khởi chạy Flask trong luồng riêng
    flask_thread = threading.Thread(target=run_flask)
    flask_thread.daemon = True  # Đảm bảo luồng Flask sẽ tắt khi chương trình chính kết thúc
    flask_thread.start()
    
    # Hiển thị thông báo khi server đã sẵn sàng
    print("Flask server started on http://127.0.0.1:5000")
    print("Engine simulation running. Press Ctrl+C to stop.")
    
    try:
        # Chạy Matplotlib trong luồng chính
        plt.show()
    except KeyboardInterrupt:
        print("Program terminated by user.")