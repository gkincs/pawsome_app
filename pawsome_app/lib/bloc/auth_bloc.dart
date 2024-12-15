import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// AuthBloc állapotok
class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  AuthState({this.isLoading = false, this.user, this.errorMessage});
}

// AuthBloc események
class AuthEvent {
  final String email;
  final String password;
  final String name;
  final List<String> petIds;

  AuthEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.petIds,
  });
}

class AuthBloc extends Cubit<AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthState());

  // Bejelentkezés
  Future<void> login(AuthEvent event) async {
    try {
      emit(AuthState(isLoading: true));  // Betöltési állapot

      // Bejelentkezés a Firebase-be
      User? user = await _authService.loginUser(event.email, event.password);

      if (user != null) {
        // Adatok mentése a Firestore-ba
        await _authService.saveUserData(
          user.uid,
          event.email,
          event.name,
          event.petIds,
        );
        emit(AuthState(user: user));  // Sikeres bejelentkezés
      } else {
        emit(AuthState(errorMessage: "Bejelentkezés sikertelen"));
      }
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));  // Hiba esetén
    }
  }

  // // Kijelentkezés
  // Future<void> logout() async {
  //   try {
  //     await _authService.logoutUser();
  //     emit(AuthState());  // Visszaállítjuk az alapállapotot
  //   } catch (e) {
  //     emit(AuthState(errorMessage: e.toString()));
  //   }
  // }
}
