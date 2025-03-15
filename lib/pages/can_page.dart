import 'package:flutter/material.dart';
import 'variables.dart';

class CanPage extends StatefulWidget {
  const CanPage({super.key});
  @override
  CanPageState createState() => CanPageState();
}

class CanPageState extends State<CanPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ảnh nền bảng đồng hồ
        Positioned.fill(
          child: Image.asset(
            "assets/images/dashboard.png", // Thay bằng ảnh bảng đồng hồ của bạn
            fit: BoxFit.cover,
          ),
        ),
        // Ở onTap để trống và sau này thêm lời gọi hàm để dùng ở backend
        // Đèn cảnh báo - Seatbelt
        Align(
          alignment: Alignment(1, -1), // Giữ nguyên vị trí
          child: Container(
            height: MediaQuery.of(context).size.width * 0.075,
            width: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Viền xung quanh
            ),
            padding: EdgeInsets.all(8), // Tạo khoảng cách giữa viền và nội dung
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONNECTION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ), // Khoảng cách giữa tiêu đề và trạng thái
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color:
                        isConnectedDashboard
                            ? Colors.green
                            : Colors.red, // Màu nền theo trạng thái
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isConnectedDashboard ? 'Connected' : 'Disconnected',
                    style: TextStyle(
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
                        child: Text('Connect'),
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
                        child: Text('Disconnect'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.85, 0.5), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive = !isActive),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive ? Colors.red : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/engine_oil.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.65, -0.1),
          child: GestureDetector(
            onTap: () => setState(() => isActive1 = !isActive1),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive1 ? Colors.red : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/brake.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height:
                    MediaQuery.of(context).size.width * 0.05, // Giữ tỷ lệ vuông
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.75, 0.65),
          child: GestureDetector(
            onTap: () => setState(() => isActive1 = !isActive1),
            child: SizedBox(
              height: MediaQuery.of(context).size.width * 0.04,
              width: MediaQuery.of(context).size.width * 0.15,
              child: Container(
                padding: EdgeInsets.all(10), // Khoảng cách bên trong
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Màu nền cho TextField
                ), // Bo góc
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: engineSpeedController,
                        decoration: InputDecoration(
                          label: Text(
                            "RPM",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          border: OutlineInputBorder(), // Viền ô nhập
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Button vuông
                          ),
                        ),
                        child: Text('Check'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.46, -0.52), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive2 = !isActive2),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive2 ? Colors.green : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/left.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(0.44, -0.52), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive3 = !isActive3),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive3 ? Colors.green : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/right.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.88, 0.3), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive4 = !isActive4),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive4 ? Colors.yellow : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/engine.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.9, 0.08), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive5 = !isActive5),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive5 ? Colors.yellow : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/tranmision.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.06, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.06,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.03, 0.4), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive6 = !isActive6),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive6 ? Colors.red : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/doorwarning.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.15, 0.4), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive7 = !isActive7),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive7 ? Colors.red : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/steering.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(0.08, 0.4), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive8 = !isActive8),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive8 ? Colors.red : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/tyrepressure.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.8, -0.1), // Điều chỉnh vị trí theo tỷ lệ
          child: GestureDetector(
            onTap: () => setState(() => isActive9 = !isActive9),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive9 ? Colors.red : Colors.grey,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                "assets/images/abs.png",
                width:
                    MediaQuery.of(context).size.width *
                    0.05, // 10% chiều rộng màn hình
                height: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
