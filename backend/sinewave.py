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
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng lý tưởng
gap_teeth = 0        # Số răng khuyết

# Biến lưu dữ liệu để vẽ đồ thị
x_data = np.array([])
y_data = np.array([])  # 🚀 Dữ liệu này sẽ được dùng để gửi SPI
t = 0
z = 0
fig, ax = plt.subplots()
line, = ax.plot([], [], lw=2)

# Cấu hình đồ thị
ax.set_ylim(-1.2, 1.2)
ax.set_xlim(0, 0.01)  
ax.set_xlabel("Thời gian (s)")
ax.set_ylabel("Biên độ")
ax.set_title("Sóng Sin động")
ax.grid()

# Hàm cập nhật dữ liệu trên đồ thị
def update_graph(frame):
    global x_data, y_data, t, z, engine_speed, teeth, gap_teeth

    new_x = np.linspace(t, t + 0.005, 1000)
    T = 1 / (engine_speed / 60 * teeth)  # Chu kỳ của sóng sin theo tốc độ động cơ

    if z % teeth < gap_teeth:
        new_y = np.zeros_like(new_x)
    else:
        new_y = np.sin(2 * np.pi * (1 / T) * new_x)

    if np.all(new_y == 0):
        z += 1

    x_data = np.append(x_data, new_x)
    y_data = new_y  # 🚀 Lưu lại dữ liệu để gửi SPI
    t += 0.005  

    line.set_data(x_data, y_data)
    ax.set_xlim(t - 0.005, t)
    
    return line,

# Tạo animation
ani = animation.FuncAnimation(fig, update_graph, interval=10)

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

# Chạy Flask server song song với đồ thị
flask_thread = threading.Thread(target=run_flask)
flask_thread.daemon = True
flask_thread.start()

# Hiển thị đồ thị
plt.show(block=False)

def send_to_dac(value):
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
    global y_data
    while True:
        if len(y_data) > 0:
            for i in range(len(y_data)):
                send_to_dac(y_data[i])
                time.sleep(1 / 1000)

spi_thread = threading.Thread(target=spi_loop, daemon=True)
spi_thread.start()
