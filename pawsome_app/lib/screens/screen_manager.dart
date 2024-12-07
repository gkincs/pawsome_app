import 'package:flutter/material.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'signin_screen.dart';

class ScreenManager extends StatefulWidget {
  @override
  _ScreenManagerState createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    LoginWidget(),
    SigninWidget(),
    FirststepWidget(),
    // Add other screens here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Sign In'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Start'),
          // Add other navigation items here
        ],
      ),
    );
  }
}