import 'package:flutter/material.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Ez a kezdőképernyő, amely lehetővé teszi a felhasználó számára, hogy navigáljon a bejelentkezési képernyőre.
/// Az alkalmazás indításakor jelenik meg.
class SigninWidget extends StatefulWidget {
  const SigninWidget({super.key});

  @override
  _SigninWidgetState createState() => _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget> {
  final bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 100),
                        _buildSignInButton(context, l10n),
                        const SizedBox(height: 16),
                        if (_isSigningIn) const Center(child: CircularProgressIndicator()),
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

  Widget _buildLogo() {
    return const Text(
      'PawSome',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSignInButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginWidget()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEADDFF),
        foregroundColor: const Color(0xFF65558F),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(l10n.signIn),
    );
  }
}