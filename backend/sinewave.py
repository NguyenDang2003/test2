from flask import Flask, request, jsonify
import threading
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

app = Flask(__name__)

# Biến toàn cục lưu dữ liệu động cơ
engine_speed = 1000  # Tốc độ động cơ (rpm)
teeth = 36           # Số răng lý tưởng
gap_teeth = 0        # Số răng khuyết

# Biến lưu dữ liệu để vẽ đồ thị
x_data = np.array([])
y_data = np.array([])
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

    new_x = np.linspace(t, t + 0.005, 100)
    T = 1 / (engine_speed / 60 * teeth)  # Chu kỳ của sóng sin theo tốc độ động cơ

    if z % teeth < gap_teeth:
        new_y = np.zeros_like(new_x)
    else:
        new_y = np.sin(2 * np.pi * (1 / T) * new_x)

    if np.all(new_y == 0):
        z += 1

    x_data = np.append(x_data, new_x)
    y_data = np.append(y_data, new_y)
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
plt.show(block = False)
