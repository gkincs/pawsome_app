import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Widget, amely a BottomNavigationBar-t jeleníti meg, és kezeli a navigációt a különböző képernyők között.
class BottomNavigationBarWidget extends StatelessWidget {
/// A gombok megnyomásakor meghívott callback függvény.
  final Function(int) onTabTapped;

// Konstruktor, amely megkapja a gombok megnyomásakor meghívott callback függvényt.
  const BottomNavigationBarWidget({
    super.key,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return BottomNavigationBar(
          currentIndex: state.currentIndex,
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.pets),
              label: l10n.pets,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book),
              label: l10n.diary,
            ),
          ],
          selectedItemColor: const Color(0xFF65558F),
          unselectedItemColor: Colors.grey,
        );
      },
    );
  }
}

