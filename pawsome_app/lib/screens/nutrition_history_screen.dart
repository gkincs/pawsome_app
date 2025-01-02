import 'package:flutter/material.dart';

class NutritionItem {
  final String type;
  final String amount;

  NutritionItem({required this.type, required this.amount});
}

class NutritionHistoryWidget extends StatefulWidget {
  const NutritionHistoryWidget({super.key});

  @override
  _NutritionHistoryWidgetState createState() => _NutritionHistoryWidgetState();
}

class _NutritionHistoryWidgetState extends State<NutritionHistoryWidget> {
  final List<NutritionItem> nutritionItems = [
    NutritionItem(type: 'Dry food', amount: 'Medium'),
    NutritionItem(type: 'Other', amount: 'Small'),
    NutritionItem(type: 'Canned', amount: 'Large'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            _buildHistorySection(),
            const Spacer(),
            _buildAddButton(),
            const SizedBox(height:160),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
            //color: const Color(0xFF65558F),
          ),
          const Expanded(  // Add Expanded widget
          child: Text(
            'Feeding Informations',
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              //color: Color(0xFF65558F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'History',
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nutritionItems.length,
            itemBuilder: (context, index) {
              return _buildNutritionCard(nutritionItems[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(NutritionItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFFEADDFF),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.type,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: ${item.amount}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildAddButton() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Center(  // Wrap with Center widget
      child: SizedBox(
        width: 120,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEADDFF),
            foregroundColor: Color(0xFF65558F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: const Text('Add'),
        ),
      ),
    ),
  );
}


  Widget _buildNavItem(String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF65558F) : Colors.grey,
            fontSize: 14,
          ),
        ),
        if (isSelected)
          Container(
            width: 32,
            height: 2,
            margin: const EdgeInsets.only(top: 4),
            color: const Color(0xFF65558F),
          ),
      ],
    );
  }
}
