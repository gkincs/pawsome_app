import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:pawsome_app/screens/home_screen.dart';
import 'package:pawsome_app/screens/new_account_screen.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in both fields.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      
      if (credential.user != null) {
        _showMessage('Login successful!', success: true);

        bool isFirstLogin = await _isFirstLogin(credential.user!.uid);
        if (isFirstLogin) {
          _navigateToFirstStep();
        } else {
          _navigateToHome();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'user-not-found') {
        _showMessage('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showMessage('Wrong password provided.');
      } else {
        _showMessage('Login failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('An error occurred. Please try again later.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  void _showMessage(String message, {bool success = false}) {
    final color = success ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _navigateToFirstStep() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FirststepWidget()),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeWidget()),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewAccountWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Login to your account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _emailController,
                          'Email',
                          false,
                          TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _passwordController,
                          'Password',
                          true,
                          TextInputType.text,
                        ),
                        const SizedBox(height: 10),
                        _buildRememberMeAndForgotPassword(),
                        const SizedBox(height: 20),
                        _buildLoginButton(),
                        const SizedBox(height: 20),
                        _buildSignUpSection(),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isPassword,
    TextInputType inputType,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () {
            // Forgot password logic
          },
          child: const Text('Forgot password?'),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _performLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF65558F),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Login'),
    );
  }

  Widget _buildSignUpSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?"),
        TextButton(
          onPressed: _navigateToSignUp,
          child: const Text(
            'Sign up',
            style: TextStyle(
              color: Color(0xFF65558F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}