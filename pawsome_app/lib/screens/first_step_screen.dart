import 'package:flutter/material.dart';

class FirststepWidget extends StatefulWidget {
  @override
  _FirststepWidgetState createState() => _FirststepWidgetState();
}

class _FirststepWidgetState extends State<FirststepWidget> {
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
                        _buildTitle(),
                        SizedBox(height: 40),
                        _buildSubtitle(),
                        SizedBox(height: 40),
                        _buildAddButton(),
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

  Widget _buildTitle() {
    return Text(
      'PawSome',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Add your first pet',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        color: Color.fromRGBO(0, 0, 0, 0.9),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: () {
        // Add button action
      },
      child: Text('Add'),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 48),
        backgroundColor: Color.fromRGBO(78, 130, 255, 0.9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}