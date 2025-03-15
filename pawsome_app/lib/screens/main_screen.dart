import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/screens/home_screen.dart';
import 'package:pawsome_app/screens/pet_screen.dart';
import 'package:pawsome_app/screens/diary_screen.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _screens = [
    const HomeWidget(key: PageStorageKey('HomeWidget')),
    const PetScreenWidget(key: PageStorageKey('PetScreenWidget')),
    const DiaryWidget(key: PageStorageKey('DiaryWidget')),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: PageStorage(
            bucket: _bucket,
            child: IndexedStack(
              index: state.currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: BottomNavigationBarWidget(
            onTabTapped: (index) {
              context.read<BottomNavigationBloc>().add(ChangeTabEvent(index));
            },
          ),
        );
      },
    );
  }
}
