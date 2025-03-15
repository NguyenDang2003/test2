import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GraphAbs1 extends StatelessWidget {
  // Hàm tạo dữ liệu xung sine
  List<FlSpot> generateSineWave({
    int points = 100,
    double amplitude = 2.0,
    double period = 500,
  }) {
    List<FlSpot> spots = [];
    for (int i = 0; i < points; i++) {
      double x = i * (period / points); // Trục thời gian, mỗi ô là 500us
      double y =
          amplitude * sin(2 * pi * i / points); // Giá trị điện áp (trục tung)
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Graph - Engine Speed')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine:
                  (value) => FlLine(color: Colors.grey, strokeWidth: 1),
              getDrawingVerticalLine:
                  (value) => FlLine(color: Colors.grey, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}V',
                      style: TextStyle(fontSize: 10),
                    );
                  },
                  interval: 2, // Mỗi ô trên trục tung là 2V
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}µs',
                      style: TextStyle(fontSize: 10),
                    );
                  },
                  interval: 500, // Mỗi ô trên trục hoành là 500 us
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: generateSineWave(), // Dữ liệu xung sine
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
