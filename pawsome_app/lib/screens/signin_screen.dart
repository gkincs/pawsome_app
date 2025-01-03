import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';

class SigninWidget extends StatefulWidget {
  const SigninWidget({super.key});

  @override
  _SigninWidgetState createState() => _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget> {
  @override
  Widget build(BuildContext context) {
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
                        _buildSignInButton(),
                        const SizedBox(height: 16),
                        //_buildCreateAccountButton(),
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

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: () {
        context.read<BottomNavigationBloc>().add(UpdateIndex(1));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEADDFF), 
        foregroundColor: Color(0xFF65558F),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Sign in'),
    );
  }

  // Widget _buildCreateAccountButton() {
  //   return ElevatedButton(
  //     onPressed: () {
  //       context.read<BottomNavigationBloc>().add(UpdateIndex(2));
  //     },
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: const Color(0xFF65558F),
  //       foregroundColor: Colors.white,
  //       minimumSize: const Size(double.infinity, 48),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //     ),
  //     child: const Text('Create an account'),
  //   );
  // }
}
