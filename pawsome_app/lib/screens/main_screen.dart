import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:pawsome_app/screens/home_screen.dart';
import 'package:pawsome_app/screens/pet_screen.dart';
import 'package:pawsome_app/screens/diary_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(state.contentIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<BottomNavigationBloc>().add(UpdateIndex(index));
              context.read<BottomNavigationBloc>().add(UpdateContent(index));
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeWidget();
      case 1:
        return const PetScreenWidget();
      case 2:
        return const DiaryWidget();
      default:
        return const HomeWidget();
    }
  }
}