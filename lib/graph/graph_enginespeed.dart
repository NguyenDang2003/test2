import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphEnginespeed extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphEnginespeed> {
  // Danh sách chứa các điểm dữ liệu trên đồ thị
  List<FlSpot> _dataPoints = List.generate(
    50,
    (index) => FlSpot(index.toDouble(), 0),
  );

  double _xIndex = 50; // Chỉ mục trục X, bắt đầu từ 50 để dữ liệu cố định
  Timer? _timer; // Timer để cập nhật dữ liệu tự động

  @override
  void initState() {
    super.initState();
    _startUpdatingData(); // Bắt đầu cập nhật dữ liệu khi mở màn hình
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy Timer khi thoát màn hình
    super.dispose();
  }

  // Hàm chạy Timer để cập nhật dữ liệu liên tục
  void _startUpdatingData() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _addDataPoint(_generateMockData()); // Thêm dữ liệu mới vào đồ thị
    });
  }

  // Giả lập dữ liệu dao động từ -10V đến 10V
  double _generateMockData() {
    return -10 + 20 * (DateTime.now().millisecond % 100) / 100;
  }

  // Cập nhật dữ liệu mới vào danh sách
  void _addDataPoint(double voltage) {
    setState(() {
      _dataPoints.removeAt(0); // Xóa điểm cũ nhất
      _dataPoints.add(
        FlSpot(_xIndex, voltage),
      ); // Thêm điểm mới vào cuối danh sách
      _xIndex += 1; // Dịch chuyển trục X
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Oscilloscope Graph')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true, // Hiển thị lưới
              drawVerticalLine: true, // Hiển thị đường dọc
              drawHorizontalLine: true, // Hiển thị đường ngang
              verticalInterval: 2, // Khoảng cách mỗi ô theo trục Y là 2V
              horizontalInterval: 5, // Khoảng cách mỗi ô theo trục X
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true, // Hiển thị số trục Y
                  interval: 2, // Mỗi ô trên trục Y là 2V
                  reservedSize: 30, // Kích thước khoảng trống bên trái
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}V',
                      style: TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // Ẩn số trên trục X
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ), // Ẩn trục phải
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ), // Ẩn trục trên
            ),
            borderData: FlBorderData(show: true), // Hiển thị viền đồ thị
            minY: -12, // Điện áp tối thiểu
            maxY: 12, // Điện áp tối đa
            lineBarsData: [
              LineChartBarData(
                spots: _dataPoints, // Dữ liệu của đồ thị
                isCurved: true, // Đường cong mượt hơn
                color: Colors.blue, // Màu của đường đồ thị
                barWidth: 2, // Độ dày đường vẽ
                isStrokeCapRound: true, // Làm tròn điểm giao nhau
              ),
            ],
          ),
        ),
      ),
    );
  }
}
