import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/nutrition_history_screen.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';

class NutritionDiaryWidget extends StatefulWidget {
  final String? petId;

  const NutritionDiaryWidget({super.key, required this.petId});

  @override
  _NutritionDiaryWidgetState createState() => _NutritionDiaryWidgetState();
}

class _NutritionDiaryWidgetState extends State<NutritionDiaryWidget> {
  String selectedFoodType = 'Raw';
  String selectedAmount = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            _buildFoodTypeSection(),
            const Divider(color: Color(0xFFCAC4D0)),
            _buildAmountSection(),
            const Spacer(),
            _buildSaveButton()
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Feeding Information',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildFoodTypeSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Food Type',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF65558F),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: ['Raw', 'Canned', 'Dry', 'Other'].map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: selectedFoodType == type,
              selectedColor: const Color(0xFFEADDFF),
              onSelected: (selected) {
                setState(() {
                  selectedFoodType = type;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF65558F),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: ['Small', 'Medium', 'Large'].map((amount) {
            return ChoiceChip(
              label: Text(amount),
              selected: selectedAmount == amount,
              selectedColor: const Color(0xFFEADDFF),
              onSelected: (selected) {
                setState(() {
                  selectedAmount = amount;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _saveFeedingInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEADDFF),
          foregroundColor: const Color(0xFF65558F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Save', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _saveFeedingInfo() async {
    if (widget.petId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No pet selected')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('feedingLogs')
          .add({
        'amount': selectedAmount.toLowerCase(),
        'date': FieldValue.serverTimestamp(),
        'foodType': selectedFoodType.toLowerCase(),
        'petId': FirebaseFirestore.instance.doc('pets/${widget.petId}'),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feeding information saved successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionHistoryWidget(petId: widget.petId!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving feeding information: $e')),
      );
    }
  }
}