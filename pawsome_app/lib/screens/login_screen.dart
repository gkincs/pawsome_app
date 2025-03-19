import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawsome_app/screens/first_step_screen.dart';
import 'package:pawsome_app/screens/new_account_screen.dart';
import 'package:pawsome_app/screens/main_screen.dart';
import 'package:pawsome_app/widgets/language_switcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('saved_email') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', _emailController.text.trim());
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('saved_email');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_isLoading) return;

    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage(l10n.fillAllFields);
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
        await _saveRememberMe();
        _showMessage(l10n.success, success: true);

        bool isFirstLogin = await _isFirstLogin(credential.user!.uid);
        if (isFirstLogin) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const FirststepWidget()),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'user-not-found') {
        _showMessage(l10n.error);
      } else if (e.code == 'wrong-password') {
        _showMessage(l10n.error);
      } else {
        _showMessage(l10n.error);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(l10n.error);
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
      MaterialPageRoute(builder: (_) => MainScreen()),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewAccountWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LanguageSwitcher(),
          SizedBox(width: 8),
        ],
      ),
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
                        Text(
                          l10n.loginToAccount,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _emailController,
                          l10n.email,
                          false,
                          TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _passwordController,
                          l10n.password,
                          true,
                          TextInputType.text,
                        ),
                        const SizedBox(height: 10),
                        _buildRememberMeAndForgotPassword(l10n),
                        const SizedBox(height: 20),
                        _buildLoginButton(l10n),
                        const SizedBox(height: 20),
                        _buildSignUpSection(l10n),
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

  Widget _buildRememberMeAndForgotPassword(AppLocalizations l10n) {
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
            Text(l10n.rememberMe),
          ],
        ),
        TextButton(
          onPressed: () {
            // Forgot password logic
          },
          child: Text(l10n.forgotPassword),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
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
          : Text(l10n.login),
    );
  }

  Widget _buildSignUpSection(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.dontHaveAccount),
        TextButton(
          onPressed: _navigateToSignUp,
          child: Text(
            l10n.signUp,
            style: const TextStyle(
              color: Color(0xFF65558F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
