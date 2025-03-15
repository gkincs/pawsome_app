import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/auth_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:pawsome_app/repositories/user_repository.dart';
import 'package:pawsome_app/screens/main_screen.dart';
import 'package:pawsome_app/screens/signin_screen.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Pawsome());
}

class Pawsome extends StatelessWidget {
  const Pawsome({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(UserRepository()),
        ),
        BlocProvider<BottomNavigationBloc>(
          create: (context) => BottomNavigationBloc(),
        ),
      ],
      child: MaterialApp(
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state.user == null) {
              return const SigninWidget();
            }
            if (state.isFirstLogin) {
              return const FirststepWidget();
            }
            return MainScreen();
          },
        ),
      ),
    );
  }
}