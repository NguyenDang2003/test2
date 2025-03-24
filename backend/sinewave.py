import threading
import numpy as np
import spidev
import time
from flask import Flask, request, jsonify

app = Flask(__name__)

# Configure SPI interface
spi = spidev.SpiDev()
spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
spi.max_speed_hz = 1000000  # 1 MHz

# Global variables for engine parameters
engine_speed = 1000  # Engine speed in RPM
teeth = 36          # Number of teeth on wheel
gap_teeth = 0       # Number of missing teeth

# Fixed sample rate parameters
samples_per_tooth = 100  # Number of samples per tooth

def send_to_dac(value):
    """Send value to MCP4921 DAC via SPI."""
    # Convert from [-1,1] to [0,4095]
    value = (value + 1) / 2  # Convert from [-1,1] to [0,1]
    value = int(value * 4095)  # Convert to 0-4095 range
    value = max(0, min(4095, value))  # Ensure within range
    
    # Configure MCP4921 (bit 15-12: control bits, bit 11-0: data)
    high_byte = (0x30 | (value >> 8)) & 0xFF
    low_byte = value & 0xFF
    
    try:
        spi.xfer2([high_byte, low_byte])
    except Exception as e:
        print(f"SPI Error: {e}")

def spi_loop():
    global engine_speed, teeth, gap_teeth
    
    # Time tracking variables
    current_time = 0.0
    
    while True:
        # Calculate frequencies and timing
        rpm_hz = engine_speed / 60.0  # Convert RPM to Hz
        tooth_period = 1.0 / (rpm_hz * teeth)  # Time for one tooth
        sample_period = tooth_period / samples_per_tooth  # Time per sample
        
        print(f"Engine: {engine_speed} RPM, Freq: {rpm_hz} Hz, Period: {tooth_period:.6f}s")
        print(f"Teeth: {teeth}, Gap teeth: {gap_teeth}")
        
        # Generate waveform for each tooth
        for tooth in range(teeth):
            # Check if this is a gap tooth (gap teeth are at the end)
            is_gap = tooth >= (teeth - gap_teeth)
            
            # Process samples for this tooth
            for sample in range(samples_per_tooth):
                start_time = time.time()
                
                if is_gap:
                    # Gap tooth - output 0
                    send_to_dac(0)
                else:
                    # Regular tooth - calculate sine value
                    # Frequency of sine wave is directly proportional to engine_speed
                    value = np.sin(2 * np.pi * rpm_hz * current_time)
                    send_to_dac(value)
                
                # Update virtual time counter
                current_time += sample_period
                
                # Calculate precise wait time
                elapsed = time.time() - start_time
                wait_time = max(0, sample_period - elapsed)
                if wait_time > 0:
                    time.sleep(wait_time)
            
            # Check if parameters have changed
            if engine_speed != last_speed or teeth != last_teeth or gap_teeth != last_gap_teeth:
                # Update tracking variables
                last_speed = engine_speed
                last_teeth = teeth
                last_gap_teeth = gap_teeth
                # Don't reset current_time to maintain phase continuity
                break

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

# Run Flask server in a separate thread
def run_flask():
    app.run(host='0.0.0.0', port=5000, debug=False, use_reloader=False)

if __name__ == "__main__":
    # Initialize tracking variables
    last_speed = engine_speed
    last_teeth = teeth
    last_gap_teeth = gap_teeth
    
    # Start Flask thread
    flask_thread = threading.Thread(target=run_flask, daemon=True)
    flask_thread.start()

    # Start SPI thread
    spi_thread = threading.Thread(target=spi_loop, daemon=True)
    spi_thread.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Program terminated")