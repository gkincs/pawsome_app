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


class ScreenManager extends StatelessWidget {
  const ScreenManager({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.contentIndex,
            children: [
              SigninWidget(),
              LoginWidget(),
              NewAccountWidget(),
              FirststepWidget(),
              PetProfileWidget(),
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
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<BottomNavigationBloc>().add(UpdateIndex(index));
              context.read<BottomNavigationBloc>().add(UpdateContent(index));
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Diary'),
              // További navigációs elemek itt
            ],
          ),
        );
      },
    );
  }
}