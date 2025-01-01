import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Login & Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),  // Page de login par défaut
    );
  }
}
