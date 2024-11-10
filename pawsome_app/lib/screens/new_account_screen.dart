import 'package:flutter/material.dart';

class NewAccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Allow scrolling if content overflows
      child: Container(
        width: 360,
        padding: EdgeInsets.all(16), // Add padding for better layout
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildHeader(),
            SizedBox(height: 40), // Space between header and input fields
            _buildInputField('Full name'),
            _buildInputField('Email'),
            _buildInputField('Password'),
            SizedBox(height: 30), // Space before button
            _buildCreateAccountButton(),
            SizedBox(height: 20), // Space before sign-in text
            _buildSignInText(),
          ],
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
    );
  }

  Widget _buildInputField(String label) {
    return Container(
      width: 294, // Set a specific width for the input fields
      margin: EdgeInsets.symmetric(vertical: 10), // Vertical margin for spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        color: Color.fromRGBO(255, 255, 255, 1), // Use solid white
        border: Border.all(color: Colors.black, width: 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return Container(
      width: double.infinity, // Make button full width
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Color.fromRGBO(78, 130, 255, 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: TextButton(
        onPressed: () {}, // Add your onPressed logic here
        child: Text(
          'Create Account',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 14,
            letterSpacing: 0.1,
            fontWeight: FontWeight.normal,
          ),
        ),
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
            fontFamily: 'Roboto',
            fontSize: 12,
            letterSpacing: 0.4,
            fontWeight: FontWeight.normal,
          ),
        ),
        TextButton(
          onPressed: () {
            // Add your sign-in logic here
          },
          child: Text(
            'Sign in',
            style: TextStyle(
              color: Color.fromRGBO(0, 0, 0, 1),
              fontFamily: 'Roboto',
              fontSize: 12,
              letterSpacing: 0.4,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

