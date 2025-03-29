import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/expenses_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpensesWidget extends StatefulWidget {
  final String? petId;

  const ExpensesWidget({super.key, required this.petId});

  @override
  _ExpensesWidgetState createState() => _ExpensesWidgetState();
}

class _ExpensesWidgetState extends State<ExpensesWidget> {
  String selectedCategory = '';
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            const Divider(color: Color(0xFFCAC4D0)),
            _buildCategoriesSection(l10n),
            const Divider(color: Color(0xFFCAC4D0)),
            _buildPriceInput(l10n),
            const Spacer(),
            _buildSaveButton(l10n)
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        l10n.expenses,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.category,
            style: const TextStyle(
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
          runSpacing: 8,
          children: [
            _buildCategoryChip(l10n.foodNutrition),
            _buildCategoryChip(l10n.groomingHygiene),
            _buildCategoryChip(l10n.supplies),
            _buildCategoryChip(l10n.healthcare),
            _buildCategoryChip(l10n.toysAccessories),
            _buildCategoryChip(l10n.other),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    return ChoiceChip(
      label: Text(category),
      selected: selectedCategory == category,
      selectedColor: const Color(0xFFEADDFF),
      onSelected: (selected) {
        setState(() {
          selectedCategory = selected ? category : '';
        });
      },
    );
  }

  Widget _buildPriceInput(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _priceController,
        decoration: InputDecoration(
          labelText: l10n.cost,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _saveExpense(l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEADDFF),
          foregroundColor: const Color(0xFF65558F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(l10n.save, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  void _saveExpense(AppLocalizations l10n) async {
    if (widget.petId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noPetSelected)),
      );
      return;
    }

    if (selectedCategory.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFields)),
      );
      return;
    }

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userNotLoggedIn)),
        );
        return;
      }

      await _firestore.collection('expenses').add({
        'amount': _priceController.text,
        'date': FieldValue.serverTimestamp(),
        'description': selectedCategory,
        'petId': widget.petId,
        'userId': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseSaved)),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSavingExpense(e.toString()))),
      );
    }
  }
}