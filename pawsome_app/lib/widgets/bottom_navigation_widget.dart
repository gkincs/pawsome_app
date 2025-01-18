import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

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