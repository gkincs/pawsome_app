import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewAccountWidget extends StatefulWidget {
  const NewAccountWidget({super.key});

  @override
  _NewAccountWidgetState createState() => _NewAccountWidgetState();
}

class _NewAccountWidgetState extends State<NewAccountWidget> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildHeader(),
                        SizedBox(height: 40),
                        _buildInputField(_fullNameController, 'Full name'),
                        _buildInputField(
                          _emailController,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildInputField(
                          _passwordController,
                          'Password',
                          isPassword: true,
                        ),
                        SizedBox(height: 30),
                        _buildCreateAccountButton(),
                        SizedBox(height: 20),
                        _buildSignInText(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Create a new account',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return ElevatedButton(
      onPressed: () async {
        String fullName = _fullNameController.text.trim();
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        if (fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
          try {
            // Firebase Authentication - Felhasználó létrehozása
            UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            String uid = userCredential.user!.uid;

            // Felhasználói adatok mentése a Firestore-be
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'uid': uid,
              'fullName': fullName,
              'email': email,
              'registrationDate': Timestamp.now(),
            });

            // Sikeres mentés üzenet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Account created successfully!')),
            );

            // Navigáció vissza a bejelentkezési oldalra
            Navigator.pushNamed(context, '/signin');
          } catch (e) {
            // Hibaüzenet
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        } else {
          // Figyelmeztetés, ha valami hiányzik
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please fill out all fields!')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(78, 130, 255, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text('Create Account'),
    );
  }

  Widget _buildSignInText() {
    return Column(
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signin'); // Navigate to sign-in page
          },
          child: Text(
            'Sign in',
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              letterSpacing: 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}