import 'package:flutter/material.dart';
import 'package:btl/quangcao/gioithieu.dart'; // Import SplashScreen file

void main() {
  runApp(HeliaApp());
}

class HeliaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // Change home to SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
