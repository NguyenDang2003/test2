import 'package:flutter/material.dart';
import 'variables.dart';

class DataStreamPage extends StatefulWidget {
  const DataStreamPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DataStreamState();
  }
}

class _DataStreamState extends State<DataStreamPage> {
  // Cập nhật dữ liệu thay đổi ở backend để hiện thị lên giao diện
  void updateValue() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CAN",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.cyan,
                child: Text(
                  'CONNECTION',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color:
                      isConnectedData
                          ? Colors.green
                          : Colors.red, // Màu nền theo trạng thái
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isConnectedData ? 'Connected' : 'Disconnected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8), // Khoảng cách giữa trạng thái và nút
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Thực hiện kết nối
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: const Text('Connect'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Ngắt kết nối
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: const Text('Disconnect'),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ), // Đảm bảo khoảng cách hợp lý giữa các phần tử

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.teal,
                child: Text(
                  'VEHICLE OPERATING PARAMETERS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Viền đen
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ), // Căn lề
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Căn trái & phải
                  children: [
                    Text(
                      "Shifter",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      shifter, // Dữ liệu từ backend
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Viền đen
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ), // Căn lề
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Căn trái & phải
                  children: [
                    Text(
                      "Parking Break",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      parkingbreak, // Dữ liệu từ backend
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Viền đen
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ), // Căn lề
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Căn trái & phải
                  children: [
                    Text(
                      "ACC/IG",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      accig, // Dữ liệu từ backend
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Viền đen
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ), // Căn lề
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Căn trái & phải
                  children: [
                    Text(
                      "Engine Speed",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '$enginespeed rpm', // Dữ liệu từ backend
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Viền đen
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ), // Căn lề
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Căn trái & phải
                  children: [
                    Text(
                      "Vehicle Speed",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '$vehiclespeed km/h', // Dữ liệu từ backend
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Viền đen
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ), // Căn lề
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Căn trái & phải
                  children: [
                    Text(
                      "Coolant Temp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '$coolanttemp ℃', // Dữ liệu từ backend
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Viền đen
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ), // Căn lề
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Căn trái & phải
                  children: [
                    Text(
                      "Fuel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '$fuel L', // Dữ liệu từ backend
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
