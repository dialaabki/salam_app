import 'package:flutter/material.dart';
import 'package:salam_app/screens/DoctorDirectory/DoctorDirectoryScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DoctorDirectoryScreen(),
    );
  }
}
