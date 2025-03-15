import 'package:flutter/material.dart';
import 'about_us.dart';
import 'simulate_page.dart';
import 'can_page.dart';
import 'data_stream.dart';
import 'can_door.dart';
import 'online_service.dart';

// Biến của main_ui
int selectedIndex = 0;

final List<String> titles = [
  "SIMULATE",
  "CAN DASHBOARD",
  "CAN DOOR",
  "DATA STREAM",
  "ABOUT US",
  "ONLINE SERVICE",
];
final List<Widget> pages = [
  SimulatePage(),
  CanPage(),
  CanDoor(),
  DataStreamPage(),
  AboutUsPage(),
  OnlineService(),
];

// Biến dùng cho dashboard
bool isConnectedDashboard = false;
bool isActive = false;
bool isActive1 = false;
bool isActive2 = false;
bool isActive3 = false;
bool isActive4 = false;
bool isActive5 = false;
bool isActive6 = false;
bool isActive7 = false;
bool isActive8 = false;
bool isActive9 = false;
TextEditingController engineSpeedController = TextEditingController();

// Biến dùng cho door
bool isConnectedCarDoor = false;
// Biến dùng cho simulate
bool isSending = false;
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
// Biến dùng cho DataStream
bool isConnectedData = false;
String shifter = 'P';
String parkingbreak = 'OFF';
String accig = 'OFF';
double enginespeed = 0;
double vehiclespeed = 0;
double coolanttemp = 0;
double fuel = 0;
