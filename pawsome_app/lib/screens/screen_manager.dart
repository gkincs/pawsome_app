import 'package:flutter/material.dart';
// import 'package:pawsome_app/screens/appointment_screen.dart';
// import 'package:pawsome_app/screens/expenses_screen.dart';
// import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/new_account_screen.dart';
//mport 'package:pawsome_app/screens/nutrition_diary.dart';
//import 'activity_screen.dart';
import 'signin_screen.dart';
// import 'expenses_screen.dart';
// import 'appointment_screen.dart';
//import 'activity_history_screen.dart';

class ScreenManager extends StatefulWidget {
  const ScreenManager({super.key});

  @override
  _ScreenManagerState createState() => _ScreenManagerState();
}

class _ScreenManagerState extends State<ScreenManager> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    
    SigninWidget(),
    LoginWidget(),
    NewAccountWidget()

    //FirststepWidget(),
    //NutritionDiaryWidget(),
    //ActivityScreenWidget(),
    //ExpensesWidget(),
    //AppointmentWidget()
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
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Sign in'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'New Account'),
          // Add other navigation items here
        ],
      ),
    );
  }
}