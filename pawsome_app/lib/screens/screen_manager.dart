import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:pawsome_app/screens/main_screen.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/signin_screen.dart';

/// Ez az osztály felelős az alkalmazás kezdőképernyőjének kezeléséért.
/// A felhasználó állapotától függően navigál a megfelelő képernyőre:
/// Ha a felhasználó nincs bejelentkezve, a `SigninWidget` jelenik meg.
/// Ha a felhasználó be van jelentkezve, de ez az első bejelentkezése, a `FirststepWidget` jelenik meg.
/// Ha a felhasználó már bejelentkezett korábban, a `MainScreen` jelenik meg.
class ScreenManager extends StatelessWidget {
  const ScreenManager({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _isFirstLogin(snapshot.data!.uid),
            builder: (context, loginSnapshot) {
              if (loginSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (loginSnapshot.hasData) {
                if (loginSnapshot.data!) {
                  return const FirststepWidget();
                } else {
                  return MainScreen();
                }
              }

              return LoginWidget();
            },
          );
        }

        return const SigninWidget();
      },
    );
  }

  Future<bool> _isFirstLogin(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return !userDoc.exists;
    } catch (e) {
      debugPrint('Error checking first login: $e');
      return false;
    }
  }
}