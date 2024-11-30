import 'package:flutter/material.dart';

class FirststepWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'PawSome',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.normal, // Normal style
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40), // Increased space below the title (2x)
            // Subtitle
            Text(
              'Add your first pet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: Color.fromRGBO(0, 0, 0, 0.9),
              ),
            ),
            SizedBox(height: 40), // Space before the button
            // Add Button
            ElevatedButton(
              onPressed: () {
                // Add button action
              },
              child: Text('Add'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48), // Button width
                backgroundColor: Color.fromRGBO(78, 130, 255, 0.9), // Button color
                foregroundColor: Colors.white, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100), // Rounded corners
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}