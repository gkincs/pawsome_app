import 'package:flutter/material.dart';

class NutritionDiaryWidget extends StatefulWidget {
  const NutritionDiaryWidget({Key? key}) : super(key: key);

  @override
  _NutritionDiaryWidgetState createState() => _NutritionDiaryWidgetState();
}

class _NutritionDiaryWidgetState extends State<NutritionDiaryWidget> {
  String selectedFoodType = 'Raw';
  String selectedAmount = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(),
            _buildFoodTypeSection(),
            const Divider(),
            _buildAmountSection(),
            const Spacer(),
            _buildSaveButton()
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Icon(Icons.pets),
          SizedBox(width: 8),
          Text(
            'Feeding Information',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        onPressed: () {
          // Implement save functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4E82FF),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Save', style: TextStyle(color: Colors.white)),
      ),
    );
  }

}