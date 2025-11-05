// ========================
// MAIN.DART - Entry Point
// ========================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình cho ứng dụng web
  if (kIsWeb) {
    // Tắt một số tính năng mặc định của trình duyệt
    SystemChannels.textInput.invokeMethod('TextInput.clearClient');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Người Dùng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: const LoginScreen(),
    );
  }
}
