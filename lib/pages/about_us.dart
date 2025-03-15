import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Us"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Giới thiệu ứng dụng
            Text(
              "Ứng dụng giả lập tín hiệu cảm biến động cơ ô tô kết hợp giao tiếp và điều khiển hệ thống CAN trên xe một cách dễ dàng. "
              "Với giao diện trực quan và các tính năng mạnh mẽ, bạn có thể theo dõi dữ liệu, điều khiển thiết bị và phân tích hệ thống một cách hiệu quả.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Nhóm phát triển
            Text(
              "👨‍💻 Nhóm phát triển",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("- Đặng Bùi Chí Nguyễn"),
            Text("- Nguyễn Đặng Tấn Phát"),
            Text("- Nguyễn Tâm Nhân"),
            SizedBox(height: 20),

            // Thông tin liên hệ
            Text(
              "📩 Thông tin liên hệ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Email: (Để sau)"),
            Text("Github: (Để sau)"),
            SizedBox(height: 20),

            // Phiên bản ứng dụng
            Text(
              "📌 Phiên bản ứng dụng: Version 1.0.0",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
