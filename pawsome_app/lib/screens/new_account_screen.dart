import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.createNewAccount,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  _buildInputField(_fullNameController, l10n.fullName),
                  const SizedBox(height: 16),
                  _buildInputField(_emailController, l10n.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildInputField(_passwordController, l10n.password, isPassword: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65558F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(l10n.createAccount),
                  ),
                  const SizedBox(height: 20),
                  _buildSignInText(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSignInText(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginWidget()),
            );
          },
          child: Text(
            l10n.signIn,
            style: const TextStyle(
              color: Color(0xFF65558F),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createAccount() async {
    final l10n = AppLocalizations.of(context)!;
    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'fullName': fullName,
          'email': email,
          'registrationDate': Timestamp.now(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.success)),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FirststepWidget()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.fillAllFields)),
        );
      }
    }
  }
}