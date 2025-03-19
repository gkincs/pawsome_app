import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<bool> isFirstLogin(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      return !userDoc.exists;
    } catch (e) {
      throw Exception("Failed to check first login status: ${e.toString()}");
    }
  }

  Future<void> saveUserData(String uid, String email, String name, List<String> petIds) async {
    try {
      List<DocumentReference> petRefs = petIds.isEmpty
          ? []
          : petIds.map((petId) => _firestore.collection('pets').doc(petId)).toList();

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'pets': petRefs,
        'registrationDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to save user data: ${e.toString()}");
    }
  }
}