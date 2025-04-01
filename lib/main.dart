import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:salam_app/screens/DoctorDirectory/DoctorDirectoryScreen.dart';
=======
import 'package:flutter_application_2/screens/auth/DoctorSignUpScreen.dart';
>>>>>>> d571bf647aec9e6ccb0e2cc94db9992a7936356b

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
<<<<<<< HEAD
      home: DoctorDirectoryScreen(),
=======
      home: const DoctorSignUpScreen(),
>>>>>>> d571bf647aec9e6ccb0e2cc94db9992a7936356b
    );
  }
}
