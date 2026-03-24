import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Uniway Dashboard",
      theme: ThemeData(fontFamily: "Poppins"),
      home: LoginScreen(),
    );
  }
}
