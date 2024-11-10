import 'package:flutter/material.dart';

class SigninWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max, // A maximális hely kitöltése
            mainAxisAlignment: MainAxisAlignment.center, // Középre igazítás
            crossAxisAlignment: CrossAxisAlignment.stretch, // Teljes szélesség kitöltése
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Text(
                    'PawSome',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100), // Hely a PawSome és a Sign in között
              ElevatedButton(
                onPressed: () {
                  // Sign in gomb esemény
                },
                child: Text('Sign in'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48), // Gomb szélessége
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                },
                child: Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
