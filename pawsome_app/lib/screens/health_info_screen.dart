import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pawsome_app/screens/medication_history_screen.dart';

class HealthInfoWidget extends StatefulWidget {
  final String petId;

  const HealthInfoWidget({super.key, required this.petId});

  @override
  _HealthInfoWidgetState createState() => _HealthInfoWidgetState();
}

class _HealthInfoWidgetState extends State<HealthInfoWidget> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  String _selectedFrequency = '/day';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _reminder = false;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(l10n),
              const SizedBox(height: 24),
              _buildInputField(_medicineNameController, l10n.medicationName),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField(_dosageController, l10n.dosage, hintText: '2 tabs')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFrequencyDropdown(l10n)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDatePicker(l10n.startDate, _startDate, (date) => setState(() => _startDate = date)),
              const SizedBox(height: 16),
              _buildDatePicker(l10n.endDate, _endDate, (date) => setState(() => _endDate = date)),
              const SizedBox(height: 16),
              _buildReminderCheckbox(l10n),
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
      alignment: Alignment.center,
      child: Text(
        l10n.medications,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {String? hintText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFrequencyDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: _selectedFrequency,
      decoration: InputDecoration(
        labelText: l10n.frequency,
        border: const OutlineInputBorder(),
      ),
      items: ['/day', '/week', '/month'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedFrequency = newValue;
          });
        }
      },
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate) : '',
        ),
      ),
    );
  }

  Widget _buildReminderCheckbox(AppLocalizations l10n) {
    return CheckboxListTile(
      title: Text(l10n.reminder),
      value: _reminder,
      onChanged: (bool? value) {
        if (value != null) {
          setState(() {
            _reminder = value;
          });
        }
      },
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () => _saveMedication(l10n),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEADDFF),
        foregroundColor: const Color(0xFF65558F),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(l10n.save),
    );
  }

  Future<void> _saveMedication(AppLocalizations l10n) async {
    if (_medicineNameController.text.isEmpty || _dosageController.text.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fillAllFields)),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('medications').add({
        'petId': FirebaseFirestore.instance.doc('pets/${widget.petId}'),
        'medicationName': _medicineNameController.text,
        'dosage': _dosageController.text,
        'frequency': _selectedFrequency,
        'startDate': _startDate,
        'endDate': _endDate,
        'reminder': _reminder,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.medicationSaved)),
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