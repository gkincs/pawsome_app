import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:pawsome_app/screens/activity_history_screen.dart';
import 'package:pawsome_app/screens/activity_screen.dart';
import 'package:pawsome_app/screens/appointment_history_screen.dart';
import 'package:pawsome_app/screens/appointment_screen.dart';
import 'package:pawsome_app/screens/diary_screen.dart';
import 'package:pawsome_app/screens/expenses_history_screen.dart';
import 'package:pawsome_app/screens/expenses_screen.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:pawsome_app/screens/health_info_screen.dart';
import 'package:pawsome_app/screens/home_screen.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/medication_history_screen.dart';
import 'package:pawsome_app/screens/new_account_screen.dart';
import 'package:pawsome_app/screens/nutrition_diary.dart';
import 'package:pawsome_app/screens/nutrition_history_screen.dart';
import 'package:pawsome_app/screens/pet_prof_screen.dart';
import 'package:pawsome_app/screens/pet_screen.dart';
import 'package:pawsome_app/screens/signin_screen.dart';
import 'package:pawsome_app/services/auth_service.dart';


class ScreenManager extends StatelessWidget {
  final AuthService _authService = AuthService();

  ScreenManager({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _isFirstLogin(snapshot.data!.uid),
            builder: (context, loginSnapshot) {
              if (loginSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (loginSnapshot.hasData) {
                if (loginSnapshot.data!) {
                  return const FirststepWidget();
                } else {
                  return const HomeWidget();
                }
              }

              return const LoginWidget();
            },
          );
        } else {
          return const SigninWidget();
        }
      },
    );
  }

  Future<bool> _isFirstLogin(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'firstLogin': false});
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking first login: $e');
      return false;
    }
  }

  List<Widget> _getWidgets() {
    return const [
      SigninWidget(),
      LoginWidget(),
      NewAccountWidget(),
      FirststepWidget(),
      PetProfileWidget(petId: null),
      HomeWidget(),
      PetScreenWidget(),
      DiaryWidget(),
      NutritionDiaryWidget(),
      NutritionHistoryWidget(),
      ActivityScreenWidget(),
      ActivityHistoryWidget(),
      ExpensesWidget(),
      ExpensesHistoryWidget(),
      AppointmentWidget(),
      AppointmentHistoryWidget(),
      HealthInfoWidget(),
      MedicationHistoryWidget(),
    ];
  }
}

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return BottomNavigationBar(
          currentIndex: state.currentIndex,
          onTap: (index) {
            context.read<BottomNavigationBloc>().add(UpdateIndex(index));
            context.read<BottomNavigationBloc>().add(UpdateContent(index));
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Diary'),
          ],
        );
      },
    );
  }
}