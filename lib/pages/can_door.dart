import 'package:flutter/material.dart';
import 'package:test_toolbar/pages/variables.dart';
// import 'package:http/http.dart' as http;

class CanDoor extends StatefulWidget {
  const CanDoor({super.key});
  @override
  CanDoorStage createState() => CanDoorStage();
}

class CanDoorStage extends State<CanDoor> {
  // Trạng thái của đèn cảnh báo
  // Giá trị này sẽ được cập nhật từ backend

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ảnh nền bảng đồng hồ
        Positioned.fill(
          child: Image.asset(
            "assets/images/door.png",
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
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
              color: Colors.white,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ), // Khoảng cách giữa tiêu đề và trạng thái
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color:
                        isConnectedCarDoor
                            ? Colors.green
                            : Colors.red, // Màu nền theo trạng thái
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isConnectedCarDoor ? 'Connected' : 'Disconnected',
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
                        onPressed: () async {
                          // var url = Uri.parse(
                          //   'http://127.0.0.1:5000/connect',
                          // ); // Kết nối localhost
                          // try {
                          //   print("Đang gửi yêu cầu...");
                          //   var response = await http.post(url);
                          //   if (response.statusCode == 200) {
                          //     print('Connected to backend!');
                          //   } else {
                          //     print(
                          //       'Failed to connect: ${response.statusCode}',
                          //     );
                          //     print("Nội dung: ${response.body}");
                          //   }
                          // } catch (e) {
                          //   print('Error: $e');
                          // }
                        }, // Thực hiện kết nối
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
          alignment: Alignment(-0.25, -0.8), // Giữ nguyên vị trí
          child: Container(
            height: MediaQuery.of(context).size.width * 0.05,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Viền xung quanh
              borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
            ),
            padding: EdgeInsets.all(8), // Tạo khoảng cách giữa viền và nội dung
            child: Column(
              children: [
                Text(
                  'REAR LEFT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
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
                        child: Text('UP'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Button vuông
                          ),
                        ),
                        child: Text('DOWN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment(0.15, -0.8), // Giữ nguyên vị trí
          child: Container(
            height: MediaQuery.of(context).size.width * 0.05,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Viền xung quanh
              borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
            ),
            padding: EdgeInsets.all(8), // Tạo khoảng cách giữa viền và nội dung
            child: Column(
              children: [
                Text(
                  'FRONT LEFT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
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
                        child: Text('UP'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Button vuông
                          ),
                        ),
                        child: Text('DOWN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment(0.15, 0.8), // Giữ nguyên vị trí
          child: Container(
            height: MediaQuery.of(context).size.width * 0.05,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Viền xung quanh
              borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
            ),
            padding: EdgeInsets.all(8), // Tạo khoảng cách giữa viền và nội dung
            child: Column(
              children: [
                Text(
                  'FRONT RIGHT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
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
                        child: Text('UP'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Button vuông
                          ),
                        ),
                        child: Text('DOWN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.25, 0.8), // Giữ nguyên vị trí
          child: Container(
            height: MediaQuery.of(context).size.width * 0.05,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Viền xung quanh
              borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
            ),
            padding: EdgeInsets.all(8), // Tạo khoảng cách giữa viền và nội dung
            child: Column(
              children: [
                Text(
                  'REAR RIGHT',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
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
                        child: Text('UP'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // Button vuông
                          ),
                        ),
                        child: Text('DOWN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.95, 0), // Giữ nguyên vị trí
          child: Container(
            height: MediaQuery.of(context).size.width * 0.08,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ), // Viền xung quanh
              borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
            ),
            padding: EdgeInsets.all(8), // Tạo khoảng cách giữa viền và nội dung
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Căn trái tiêu đề nhỏ
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'LOCATION',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10), // Khoảng cách giữa tiêu đề và dữ liệu
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Đẩy dữ liệu qua phải
                  children: [
                    Text(
                      'Latitude:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '23.4567', // Dữ liệu từ backend
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Đẩy dữ liệu qua phải
                  children: [
                    Text(
                      'Longitude:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '100.7890', // Dữ liệu từ backend
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
