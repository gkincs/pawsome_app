import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class BottomNavigationEvent {}

class UpdateIndex extends BottomNavigationEvent {
  final int index;
  UpdateIndex(this.index);
}

// Új esemény a tartalom frissítésére
class UpdateContent extends BottomNavigationEvent {
  final int index;
  UpdateContent(this.index);
}

// State
class BottomNavigationState {
  final int currentIndex; // Aktuális BottomNavigationBar index
  final int contentIndex; // Aktuális tartalom index (külön a navbar-tól)

  BottomNavigationState(this.currentIndex, this.contentIndex);
}

// BLoC
class BottomNavigationBloc extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(BottomNavigationState(0, 0)) {
    on<UpdateIndex>((event, emit) {
      emit(BottomNavigationState(event.index, state.contentIndex)); // Csak az index frissül
    });

    on<UpdateContent>((event, emit) {
      emit(BottomNavigationState(state.currentIndex, event.index)); // Csak a tartalom frissül
    });
  }
}