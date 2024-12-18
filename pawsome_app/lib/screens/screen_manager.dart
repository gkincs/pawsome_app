import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/new_account_screen.dart';
import 'package:pawsome_app/screens/signin_screen.dart';


class ScreenManager extends StatelessWidget {
  const ScreenManager({super.key});

  @override
  Widget build(BuildContext context) {
    // Az aktuális index lekérése a Bloc állapotából
    final currentIndex = context.select(
      (BottomNavigationBloc bloc) => bloc.state.currentIndex,
    );

    // A képernyők listája
    final List<Widget> screens = [
      SigninWidget(),
      LoginWidget(),
      NewAccountWidget(),
      // Add other screens here
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens, // A képernyők listája
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Esemény küldése a Bloc-nak az index frissítéséhez
          context.read<BottomNavigationBloc>().add(UpdateIndex(index));
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Sign in'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'New Account'),
          // Add other navigation items here
        ],
      ),
    );
  }
}