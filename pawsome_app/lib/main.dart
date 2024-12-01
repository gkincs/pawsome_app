import 'package:flutter/material.dart';
import 'package:pawsome_app/screens/health_info_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:HealthInfoWidget(), 
    );
  }
}