import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class BottomNavigationEvent {}

class ChangeTabEvent extends BottomNavigationEvent {
  final int index;
  ChangeTabEvent(this.index);
}

// States
class BottomNavigationState {
  final int currentIndex;
  final String currentScreen;

  BottomNavigationState({
    this.currentIndex = 0,
    this.currentScreen = 'Home',
  });

  BottomNavigationState copyWith({
    int? currentIndex,
    String? currentScreen,
  }) {
    return BottomNavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      currentScreen: currentScreen ?? this.currentScreen,
    );
  }
}

// Bloc
class BottomNavigationBloc extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(BottomNavigationState()) {
    on<ChangeTabEvent>((event, emit) {
      String screen = 'Home';
      switch (event.index) {
        case 0:
          screen = 'Home';
          break;
        case 1:
          screen = 'Pets';
          break;
        case 2:
          screen = 'Diary';
          break;
      }
      emit(state.copyWith(
        currentIndex: event.index,
        currentScreen: screen,
      ));
    });
  }
}
