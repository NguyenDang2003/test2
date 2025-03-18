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

# Biến toàn cục
engine_speed = 1000  # rpm
teeth = 36
gap_teeth = 0
z = 0  # Đánh dấu răng hiện tại
spi_buffer = []  # Lưu trữ dữ liệu gửi SPI

# Biến đồ thị
x_data = np.array([])
y_data = np.array([])
t = 0
fig, ax = plt.subplots()
line, = ax.plot([], [], lw=2)

ax.set_ylim(-1.2, 1.2)
ax.set_xlim(0, 0.01)  
ax.set_xlabel("Thời gian (s)")
ax.set_ylabel("Biên độ")
ax.set_title("Sóng Sin động")
ax.grid()

# Hàm cập nhật dữ liệu trên đồ thị
def update_graph(frame):
    global x_data, y_data, spi_buffer, t, z, engine_speed, teeth, gap_teeth

    T = 1 / (engine_speed / 60 * teeth)  # Chu kỳ của 1 răng
    new_x = np.linspace(t, t + T, 1000)

    if z % teeth < gap_teeth:
        new_y = np.zeros_like(new_x)  # Xung răng khuyết
    else:
        new_y = np.sin(2 * np.pi * (1 / T) * new_x)  # Xung sine

    # Cập nhật đồ thị
    x_data = np.append(x_data, new_x)
    y_data = np.append(y_data, new_y)

    # Cập nhật buffer SPI
    spi_buffer = list(new_y)

    t += T  # Cập nhật thời gian
    z = (z + 1) % teeth  # Chuyển sang răng tiếp theo

    line.set_data(x_data, y_data)
    ax.set_xlim(t - 0.01, t)
    
    return line,

# Animation
ani = animation.FuncAnimation(fig, update_graph, interval=10)

@app.route('/update_engine_data', methods=['POST'])
def update_engine_data():
    global engine_speed, teeth, gap_teeth
    data = request.get_json()

    if "speed" in data and "teeth" in data and "gapTeeth" in data:
        engine_speed = float(data["speed"])
        teeth = int(data["teeth"])
        gap_teeth = int(data["gapTeeth"])
        return jsonify({"message": "Data updated"})

    return jsonify({"error": "Invalid request"}), 400

def run_flask():
    app.run(host='127.0.0.1', port=5000, debug=False, use_reloader=False)

flask_thread = threading.Thread(target=run_flask, daemon=True)
flask_thread.start()

plt.show(block=False)

def send_to_dac(value):
    """ Chuyển giá trị [-1,1] thành tín hiệu DAC 12-bit """
    value = int((value + 1) * 2047.5)  
    high_byte = (0x30 | (value >> 8)) & 0xFF  
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

spi_thread = threading.Thread(target=spi_loop, daemon=True)
spi_thread.start()
