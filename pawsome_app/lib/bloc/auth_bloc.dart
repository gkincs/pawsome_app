import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';

// Define AuthState
class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;
  final bool isFirstLogin;

  AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isFirstLogin = false,
  });
}

// Define AuthEvent
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final List<String> petIds;

  LoginEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.petIds,
  });
}

class LogoutEvent extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository;

  AuthBloc(this._userRepository) : super(AuthState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState(isLoading: true));

      User? user = await _userRepository.signIn(event.email, event.password);
      if (user != null) {
        bool isFirstLogin = await _userRepository.isFirstLogin(user.uid);
        await _userRepository.saveUserData(
          user.uid,
          event.email,
          event.name,
          event.petIds,
        );
        emit(AuthState(user: user, isFirstLogin: isFirstLogin));
      } else {
        emit(AuthState(errorMessage: "Login failed"));
      }
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _userRepository.signOut();
      emit(AuthState());
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));
    }
  }
}