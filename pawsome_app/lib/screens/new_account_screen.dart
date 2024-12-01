import 'package:flutter/material.dart';

class NewAccountWidget extends StatefulWidget {
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
                        _buildInputField(_emailController, 'Email'),
                        _buildInputField(_passwordController, 'Password', isPassword: true),
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

  Widget _buildInputField(TextEditingController controller, String label, {bool isPassword = false}) {
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
      onPressed: () {
        // Add your account creation logic here
      },
      child: Text('Create Account'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(78, 130, 255, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
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
            // Add your sign-in navigation logic here
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