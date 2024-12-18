import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'screens/screen_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BottomNavigationBloc>(
          create: (context) => BottomNavigationBloc(),
        ),
      ],
      child: const Pawsome(),
    ),
  );
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
