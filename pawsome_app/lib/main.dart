import 'package:flutter/material.dart';
import 'screens/signin_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SigninWidget(),
      ),
    );
  }
}

