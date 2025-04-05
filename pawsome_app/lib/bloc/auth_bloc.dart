import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';

///Az AuthBloc osztály kezeli a felhasználói hitelesítést és az állapotváltozásokat.
///Ez a fájl tartalmazza az AuthState és AuthEvent osztályokat is, amelyek a Bloc állapotát és eseményeit definiálják.
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

  LoginEvent({
    required this.email,
    required this.password,
  });
}

class CheckFirstLoginEvent extends AuthEvent {
  final User user;

  CheckFirstLoginEvent(this.user);
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository;

  AuthBloc(this._userRepository) : super(AuthState()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckFirstLoginEvent>(_onCheckFirstLogin);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState(isLoading: true));
      User? user = await _userRepository.signIn(event.email, event.password);
      
      if (user != null) {
        bool isFirstLogin = await _userRepository.isFirstLogin(user.uid);
        emit(AuthState(user: user, isFirstLogin: isFirstLogin));
      } else {
        emit(AuthState(errorMessage: "Login failed"));
      }
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));
    }
  }

  Future<void> _onCheckFirstLogin(CheckFirstLoginEvent event, Emitter<AuthState> emit) async {
    try {
      bool isFirstLogin = await _userRepository.isFirstLogin(event.user.uid);
      emit(AuthState(user: event.user, isFirstLogin: isFirstLogin));
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

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      User? currentUser = _userRepository.getCurrentUser();
      if (currentUser != null) {
        bool isFirstLogin = await _userRepository.isFirstLogin(currentUser.uid);
        emit(AuthState(user: currentUser, isFirstLogin: isFirstLogin));
      } else {
        emit(AuthState());
      }
    } catch (e) {
      emit(AuthState(errorMessage: e.toString()));
    }
  }
}