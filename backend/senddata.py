import spidev
import time
import numpy as np
import sinewave

# Cấu hình SPI
spi = spidev.SpiDev()
spi.open(0, 0)  # SPI bus 0, device 0 (CE0)
spi.max_speed_hz = 1000000  # 1 MHz

# Hàm gửi dữ liệu đến MCP4921
def send_to_dac(value):
    value = int(value) & 0xFFF  # Giới hạn 12-bit
    high_byte = (0x30 | (value >> 8)) & 0xFF  # Cấu hình MCP4921
    low_byte = value & 0xFF
    spi.xfer2([high_byte, low_byte])  # Gửi dữ liệu

# Thông số sóng sin
frequency = 10  # Hz
sampling_rate = 1000  # Số mẫu mỗi giây
amplitude = 2047  # Biên độ (tương đương 3.3V)
offset = 2048  # Dịch lên để giá trị luôn dương

frequency = 1/T  # Hz
sampling_rate = 1000  # Số mẫu mỗi giây
amplitude = 2047  # Biên độ (tương đương 3.3V)
offset = 2048  # Dịch lên để giá trị luôn dương

# Vòng lặp phát sóng sin
try:
    while True:
        for i in range(sampling_rate // frequency):
            angle = 2 * np.pi * i / (sampling_rate // frequency)
            sine_value = int(amplitude * np.sin(angle) + offset)
            send_to_dac(sine_value)
            time.sleep(1 / sampling_rate)
except KeyboardInterrupt:
    spi.close()
    print("SPI Closed")
