import 'package:flutter/material.dart';
// import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SimulatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SimulateUIstate();
  }
}

class _SimulateUIstate extends State<SimulatePage> {
  double crankValue = 1500;
  double abs1 = 0;
  double abs2 = 0;
  double abs3 = 0;
  double abs4 = 0;
  double ana1 = 0;
  double ana2 = 0;
  double ana3 = 0;
  double ana4 = 0;
  TextEditingController teethController = TextEditingController();
  TextEditingController gapteethController = TextEditingController();
  TextEditingController indefteethController = TextEditingController();
  TextEditingController exdefteethController = TextEditingController();
  TextEditingController gap1teethController = TextEditingController();
  TextEditingController gap11teethController = TextEditingController();
  TextEditingController gap2teethController = TextEditingController();
  TextEditingController gap22teethController = TextEditingController();
  TextEditingController gap3teethController = TextEditingController();
  TextEditingController gap33teethController = TextEditingController();
  TextEditingController gap4teethController = TextEditingController();
  TextEditingController gap44teethController = TextEditingController();
  TextEditingController gap5teethController = TextEditingController();
  TextEditingController gap55teethController = TextEditingController();

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
              const SizedBox(height: 20),
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
                      onChanged: (value) {
                        setState(() {
                          crankValue = value;
                        });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SEND DATA'),
                  Switch(value: false, onChanged: (val) {}),
                ],
              ),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                      onChanged: (value) {
                        setState(() {
                          abs1 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs1.toInt()} km/h', style: TextStyle(fontSize: 18)),
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
                      onChanged: (value) {
                        setState(() {
                          abs2 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs2.toInt()} km/h', style: TextStyle(fontSize: 18)),
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
                      onChanged: (value) {
                        setState(() {
                          abs3 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs3.toInt()} km/h', style: TextStyle(fontSize: 18)),
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
                      onChanged: (value) {
                        setState(() {
                          abs4 = value;
                        });
                      },
                    ),
                  ),
                  Text('${abs4.toInt()} km/h', style: TextStyle(fontSize: 18)),
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
                      onChanged: (value) {
                        setState(() {
                          ana1 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana1.toInt()} V', style: TextStyle(fontSize: 18)),
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
                      onChanged: (value) {
                        setState(() {
                          ana2 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana2.toInt()} V', style: TextStyle(fontSize: 18)),
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
                      onChanged: (value) {
                        setState(() {
                          ana3 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana3.toInt()} V', style: TextStyle(fontSize: 18)),
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
                      onChanged: (value) {
                        setState(() {
                          ana4 = value;
                        });
                      },
                    ),
                  ),
                  Text('${ana4.toInt()} V', style: TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
