import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpensesWidget extends StatefulWidget {
  const ExpensesWidget({super.key});

  @override
  _ExpensesWidgetState createState() => _ExpensesWidgetState();
}

class _ExpensesWidgetState extends State<ExpensesWidget> {
  String selectedCategory = '';
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(),
            _buildCategoriesSection(),
            const Divider(),
            _buildPriceInput(),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets),
          SizedBox(width: 8),
          Text(
            'Expenses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip('Food - Nutrition'),
            _buildCategoryChip('Grooming - Hygiene'),
            _buildCategoryChip('Supplies'),
            _buildCategoryChip('Healthcare'),
            _buildCategoryChip('Toys - Accessories'),
            _buildCategoryChip('Other'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    return ChoiceChip(
      label: Text(category),
      selected: selectedCategory == category,
      onSelected: (selected) {
        setState(() {
          selectedCategory = selected ? category : '';
        });
      },
    );
  }

  Widget _buildPriceInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _priceController,
        decoration: const InputDecoration(
          labelText: 'Price',
          border: OutlineInputBorder(),
          prefixText: '€ ',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
      ),
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