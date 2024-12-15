import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Felhasználó bejelentkezése
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  // Felhasználó adatainak mentése a Firestore-ba, kisállatok hivatkozásával
  Future<void> saveUserData(String uid, String email, String name, List<String> petIds) async {
    try {
      // A kisállatok hivatkozásait az 'pets' mezőbe mentjük
      List<DocumentReference> petRefs = petIds.map((petId) {
        return _firestore.collection('Pets').doc(petId);
      }).toList();

      await _firestore.collection('Users').doc(uid).set({
        'email': email,
        'name': name,
        'pets': petRefs, // Kisállatok hivatkozásainak mentése
        'registrationDate': FieldValue.serverTimestamp(), // Regisztráció időpontja
      });
    } catch (e) {
      throw Exception("Failed to save user data: ${e.toString()}");
    }
  }

  // Kisállat hozzáadása egy felhasználóhoz
  Future<void> addPetToUser(String userId, String petId) async {
    try {
      // A petId hozzáadása a felhasználó pets mezőjéhez
      DocumentReference petRef = _firestore.collection('Pets').doc(petId);
      await _firestore.collection('Users').doc(userId).update({
        'pets': FieldValue.arrayUnion([petRef]),
      });
    } catch (e) {
      throw Exception("Failed to add pet to user: ${e.toString()}");
    }
  }
}
