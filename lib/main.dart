import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'pages/main_ui.dart';
// import 'package:process_run/process_run.dart';
import 'dart:io';

void startBackend() async {
  String scriptPath = '${Directory.current.path}/backend/candoor_be.py';

  if (Platform.isWindows) {
    await Process.start('python', [scriptPath]);
  } else if (Platform.isMacOS || Platform.isLinux) {
    await Process.start('python3', [scriptPath]);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setMinimumSize(const Size(1600, 900));
    await windowManager.setSize(
      const Size(1600, 900),
    ); // Đặt kích thước ban đầu
    windowManager.setAspectRatio(16 / 9);
    await windowManager.setResizable(true);
    await windowManager.show();
  });
  startBackend(); // Chạy backend khi app khởi động
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
