import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/screen_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Pawsome());
}


class Pawsome extends StatelessWidget {
  const Pawsome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScreenManager(),
    );
  }
}
