import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        throw Exception("Incorrect password.");
      } else {
        throw Exception("Login failed: ${e.message}");
      }
    } catch (e) {
      throw Exception("An unknown error occurred: ${e.toString()}");
    }
  }

  // Felhasználó adatainak mentése a Firestore-ba, kisállatok hivatkozásával
  Future<void> saveUserData(String uid, String email, String name, List<String> petIds) async {
    try {
      // Pet ID-k listázása dokumentum referenciák formájában
      List<DocumentReference> petRefs = petIds.isEmpty
          ? [] // Ha nincs kisállat, akkor üres lista
          : petIds.map((petId) => _firestore.collection('pets').doc(petId)).toList();

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'name': name,
          'pets': petRefs,
          'registrationDate': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('users').doc(uid).update({
          'email': email,
          'name': name,
          'pets': petRefs,
        });
      }
    } on FirebaseException catch (e) {
      throw Exception("Failed to save user data: ${e.message}");
    } catch (e) {
      throw Exception("An unknown error occurred: ${e.toString()}");
    }
  }

  // Kisállat hozzáadása egy felhasználóhoz
  Future<void> addPetToUser(String userId, String petId) async {
    try {
      DocumentReference petRef = _firestore.collection('pets').doc(petId);
      DocumentSnapshot petSnapshot = await petRef.get();
      
      if (petSnapshot.exists) {
        await _firestore.collection('users').doc(userId).update({
          'pets': FieldValue.arrayUnion([petRef]),
        });
      } else {
        throw Exception("Pet with ID $petId does not exist.");
      }
    } on FirebaseException catch (e) {
      throw Exception("Failed to add pet to user: ${e.message}");
    } catch (e) {
      throw Exception("An unknown error occurred: ${e.toString()}");
    }
  }
}