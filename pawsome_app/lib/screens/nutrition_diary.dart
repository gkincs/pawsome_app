import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pawsome_app/screens/nutrition_history_screen.dart';

/// Az a képernyő, amely lehetővé teszi a felhasználó számára, hogy rögzítse a kisállat etetési adatait.
/// Az adatok, például az étel típusa, mennyisége és az etetés időpontja elmenthetőek Firestore-ba
class NutritionDiaryWidget extends StatefulWidget {
  final String petId;

  const NutritionDiaryWidget({super.key, required this.petId});

  @override
  _NutritionDiaryWidgetState createState() => _NutritionDiaryWidgetState();
}

class _NutritionDiaryWidgetState extends State<NutritionDiaryWidget> {
  String? selectedFoodType;
  String? selectedAmount;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(l10n),
              const Divider(color: Color(0xFFCAC4D0)),
              _buildFoodTypeSection(l10n),
              const SizedBox(height: 16),
              _buildAmountSection(l10n),
              const SizedBox(height: 16),
              _buildDateTimeSection(l10n),
              const SizedBox(height: 24),
              _buildSaveButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Text(
        l10n.feedingInformation,
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

  Widget _buildFoodTypeSection(AppLocalizations l10n) {
    final List<String> foodTypes = [l10n.raw, l10n.canned, l10n.dry, l10n.other];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.foodType,
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
          children: foodTypes.map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: selectedFoodType == type,
              selectedColor: const Color(0xFFEADDFF),
              onSelected: (selected) {
                setState(() {
                  selectedFoodType = selected ? type : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAmountSection(AppLocalizations l10n) {
    final List<String> amounts = [l10n.small, l10n.medium, l10n.large];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.amount,
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
          children: amounts.map((amount) {
            return ChoiceChip(
              label: Text(amount),
              selected: selectedAmount == amount,
              selectedColor: const Color(0xFFEADDFF),
              onSelected: (selected) {
                setState(() {
                  selectedAmount = selected ? amount : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.date,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF65558F),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDate),
              );
              if (time != null) {
                setState(() {
                  selectedDate = DateTime(
                    picked.year,
                    picked.month,
                    picked.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')} '
              '${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _saveFeedingLog(l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEADDFF),
          foregroundColor: const Color(0xFF65558F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(l10n.save),
      ),
    );
  }

  Future<void> _saveFeedingLog(AppLocalizations l10n) async {
    if (selectedFoodType == null || selectedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFields)),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('feedingLogs').add({
        'petId': widget.petId,
        'foodType': selectedFoodType,
        'amount': selectedAmount,
        'date': Timestamp.fromDate(selectedDate),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.feedingSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }
}