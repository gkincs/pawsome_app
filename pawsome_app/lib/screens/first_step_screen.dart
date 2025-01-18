import 'package:flutter/material.dart';
import 'package:pawsome_app/screens/pet_prof_screen.dart';

class FirststepWidget extends StatefulWidget {
  const FirststepWidget({super.key});

  @override
  _FirststepWidgetState createState() => _FirststepWidgetState();
}

class _FirststepWidgetState extends State<FirststepWidget> {
  bool _isLoading = false;

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
                        const SizedBox(height: 120),
                        _buildSubtitle(),
                        const SizedBox(height: 40),
                        _buildAddButton(context),
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

  Widget _buildSubtitle() {
    return const Text(
      'Add your first pet!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        color: Color.fromRGBO(0, 0, 0, 0.9),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PetProfileWidget(petId: null)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEADDFF),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Add'),
    );
  }
}