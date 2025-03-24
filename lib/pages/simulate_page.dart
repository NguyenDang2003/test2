import 'package:flutter/material.dart';
import 'package:test_toolbar/graph/graph_abs1.dart';
import 'package:test_toolbar/graph/graph_abs2.dart';
import 'package:test_toolbar/graph/graph_abs3.dart';
import 'package:test_toolbar/graph/graph_abs4.dart';
import 'package:test_toolbar/graph/graph_ana1.dart';
import 'package:test_toolbar/graph/graph_ana2.dart';
import 'package:test_toolbar/graph/graph_ana3.dart';
import 'package:test_toolbar/graph/graph_ana4.dart';
import 'package:test_toolbar/graph/graph_camshaft.dart';
import 'package:test_toolbar/graph/graph_enginespeed.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'variables.dart';

class NetworkService {
  static const String baseUrl = "http://127.0.0.1:5000";

  // Gửi dữ liệu cập nhật
  static Future<void> updateEngineData(
    double speed,
    int teeth,
    int gapTeeth,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/update_engine_data'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "speed": speed,
          "teeth": teeth,
          "gapTeeth": gapTeeth,
        }),
      );

      if (response.statusCode == 200) {
        print("Server response: ${response.body}");
      } else {
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}

class SimulatePage extends StatefulWidget {
  const SimulatePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SimulateUIstate();
  }
}

class _SimulateUIstate extends State<SimulatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SIMULATE - ENGINE",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Tiêu đề "Engine Setup"
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.red,
                child: Text(
                  'ENGINE SETUP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child:
                      isSending
                          ? CircularProgressIndicator(
                            color: Colors.white,
                          ) // Hiển thị loading
                          : Text('SEND DATA'),
                ),
              ),
              const SizedBox(height: 10),
              // Tiêu đề "Engine Speed"
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.blueGrey[300],
                child: Text(
                  'Engine Speed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Thanh kéo tốc độ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Speed', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: crankValue,
                      min: 0,
                      max: 6000,
                      divisions: 120,
                      label: crankValue.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          crankValue = value;
                        });
                        NetworkService.updateEngineData(
                          crankValue,
                          int.tryParse(teethController.text) ?? 36,
                          int.tryParse(gapteethController.text) ?? 0,
                        );
                      },
                    ),
                  ),
                  Text(
                    '${crankValue.toInt()} rpm',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),

              // CRANKSHAFT GEAR SETUP
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.blueGrey[300],
                child: Text(
                  'CRANKSHAFT GEAR SETUP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Nhập số teeth
              Center(
                child: SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Number Of Ideal TEETH',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: teethController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: '36'),
                          onSubmitted: (value) {
                            NetworkService.updateEngineData(
                              crankValue,
                              int.tryParse(value) ?? 36,
                              int.tryParse(gapteethController.text) ?? 0,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gap TEETH', style: TextStyle(fontSize: 18)),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: gapteethController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: '0'),
                          onSubmitted: (value) {
                            NetworkService.updateEngineData(
                              crankValue,
                              int.tryParse(teethController.text) ?? 36,
                              int.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GraphEnginespeed(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Button vuông
                    ),
                  ),
                  child: Text(
                    'Graph',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.blueGrey[300],
                child: Text(
                  'CAMPSHAFT GEAR SETUP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Nhập số teeth
              Center(
                child: SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CampIn_Crk_TeethDef',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: indefteethController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: '72'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CampEx_Crk_TeethDef',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: exdefteethController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: '72'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Teeth_Gap_1', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 500,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: gap1teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                controller: gap11teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Teeth_Gap_2', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 500,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: gap2teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                controller: gap22teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Teeth_Gap_3', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 500,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: gap3teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                controller: gap33teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Teeth_Gap_4', style: TextStyle(fontSize: 18)),
                      SizedBox(
                        width: 500,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: gap4teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                controller: gap44teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Teeth_Gap_5', style: TextStyle(fontSize: 18)),
                      SizedBox(
                        width: 500,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: gap5teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                controller: gap55teethController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: '0'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GraphCamshaft()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Button vuông
                    ),
                  ),
                  child: Text(
                    'Graph',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // // Dropdown chọn gap teeth
              const SizedBox(height: 20),
              // DANH SÁCH ABS & ANALOG
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.blueGrey[300],
                child: Text(
                  'ABS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Column(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text('ABS1', style: TextStyle(fontSize: 18)),
              //         SizedBox(
              //           height: 300,
              //           child: Expanded(
              //             child: SleekCircularSlider(
              //               initialValue: 0,
              //               min: 0,
              //               max: 150,
              //               appearance: CircularSliderAppearance(
              //                 size: 250,
              //                 infoProperties: InfoProperties(
              //                   modifier: (value) {
              //                     return '${value.toInt()} km/h';
              //                   },
              //                 ),
              //               ),
              //               onChange: (value) {
              //                 setState(() {
              //                   abs1 = value;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //         // Text('${abs1.toInt()} km/h', style: TextStyle(fontSize: 18)),
              //       ],
              //     ),
              //     Column(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text('ABS2', style: TextStyle(fontSize: 18)),
              //         SizedBox(
              //           height: 300,
              //           child: Expanded(
              //             child: SleekCircularSlider(
              //               initialValue: 0,
              //               min: 0,
              //               max: 150,
              //               appearance: CircularSliderAppearance(
              //                 size: 250,
              //                 infoProperties: InfoProperties(
              //                   modifier: (value) {
              //                     return '${value.toInt()} km/h';
              //                   },
              //                 ),
              //               ),
              //               onChange: (value) {
              //                 setState(() {
              //                   abs2 = value;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //         // Text('${abs1.toInt()} km/h', style: TextStyle(fontSize: 18)),
              //       ],
              //     ),
              //     Column(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text('ABS1', style: TextStyle(fontSize: 18)),
              //         SizedBox(
              //           height: 300,
              //           child: Expanded(
              //             child: SleekCircularSlider(
              //               initialValue: 0,
              //               min: 0,
              //               max: 150,
              //               appearance: CircularSliderAppearance(
              //                 size: 250,
              //                 infoProperties: InfoProperties(
              //                   modifier: (value) {
              //                     return '${value.toInt()} km/h';
              //                   },
              //                 ),
              //               ),
              //               onChange: (value) {
              //                 setState(() {
              //                   abs3 = value;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //         // Text('${abs1.toInt()} km/h', style: TextStyle(fontSize: 18)),
              //       ],
              //     ),
              //     Column(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text('ABS1', style: TextStyle(fontSize: 18)),
              //         SizedBox(
              //           height: 300,
              //           child: Expanded(
              //             child: SleekCircularSlider(
              //               initialValue: 0,
              //               min: 0,
              //               max: 150,
              //               appearance: CircularSliderAppearance(
              //                 size: 250,
              //                 infoProperties: InfoProperties(
              //                   modifier: (value) {
              //                     return '${value.toInt()} km/h';
              //                   },
              //                 ),
              //               ),
              //               onChange: (value) {
              //                 setState(() {
              //                   abs4 = value;
              //                 });
              //               },
              //             ),
              //           ),
              //         ),
              //         // Text('${abs1.toInt()} km/h', style: TextStyle(fontSize: 18)),
              //       ],
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ABS1', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: abs1,
                      min: 0,
                      max: 150,
                      divisions: 150,
                      label: abs1.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt

                      onChanged: (value) {
                        setState(() {
                          abs1 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs1.toInt()} km/h', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAbs1()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ABS2', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: abs2,
                      min: 0,
                      max: 150,
                      divisions: 150,
                      label: abs2.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          abs2 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs2.toInt()} km/h', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAbs2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ABS3', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: abs3,
                      min: 0,
                      max: 150,
                      divisions: 150,
                      label: abs3.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          abs3 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs3.toInt()} km/h', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAbs3()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ABS4', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: abs4,
                      min: 0,
                      max: 150,
                      divisions: 150,
                      label: abs4.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          abs4 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs4.toInt()} km/h', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAbs4()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Phần Analog
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: Colors.blueGrey[300],
                child: Text(
                  'ANALOG',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ANALOG1', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: ana1,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: ana1.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          ana1 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana1.toInt()} V', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAna1()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ANALOG2', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: ana2,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: ana2.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          ana2 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana2.toInt()} V', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAna2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ANALOG3', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: ana3,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: ana3.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          ana3 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana3.toInt()} V', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAna3()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ANALOG4', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Slider(
                      value: ana4,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: ana4.toInt().toString(),
                      activeColor: Colors.red, // Màu của phần đã trượt
                      inactiveColor:
                          Colors.red.shade100, // Màu của phần chưa trượt
                      onChanged: (value) {
                        setState(() {
                          ana4 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana4.toInt()} V', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GraphAna4()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Button vuông
                        ),
                      ),
                      child: Text(
                        'Graph',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
