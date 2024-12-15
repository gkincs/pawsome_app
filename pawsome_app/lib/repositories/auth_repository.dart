import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  // Bejelentkezés és felhasználói adat mentése
  Future<void> loginAndSaveUser(String email, String password, String name, List<String> petIds) async {
    final user = await _authService.loginUser(email, password);
    if (user != null) {
      // Felhasználói adatokat mentünk és hozzáadjuk a kisállatokat
      await _authService.saveUserData(user.uid, email, name, petIds);
    }
  }

  // Kisállat hozzáadása a felhasználóhoz
  Future<void> addPetToUser(String userId, String petId) async {
    await _authService.addPetToUser(userId, petId);
  }
}
