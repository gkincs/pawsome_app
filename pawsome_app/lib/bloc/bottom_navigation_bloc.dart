import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class BottomNavigationEvent {}

class UpdateIndex extends BottomNavigationEvent {
  final int index;
  UpdateIndex(this.index);
}

// State
class BottomNavigationState {
  final int currentIndex;
  BottomNavigationState(this.currentIndex);
}

// BLoC
class BottomNavigationBloc extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(BottomNavigationState(0)) {
    on<UpdateIndex>((event, emit) {
      emit(BottomNavigationState(event.index));
    });
  }
}
