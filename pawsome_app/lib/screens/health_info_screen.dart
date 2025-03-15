import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildInputField(_medicineNameController, 'Medicine Name'),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField(_dosageController, 'Dosage', hintText: '2 tabs')),
                  SizedBox(width: 16),
                  Expanded(child: _buildFrequencyDropdown()),
                ],
              ),
              SizedBox(height: 16),
              _buildDatePicker('Start Date', _startDate, (date) => setState(() => _startDate = date)),
              SizedBox(height: 16),
              _buildDatePicker('End Date', _endDate, (date) => setState(() => _endDate = date)),
              SizedBox(height: 16),
              _buildReminderCheckbox(),
              SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Medications',
        style: TextStyle(
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF65558F)),
        ),
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedFrequency,
      decoration: InputDecoration(
        labelText: 'Frequency',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF65558F)),
        ),
      ),
      items: ['/day', '/week', '/month'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedFrequency = newValue!;
        });
      },
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime?) onDateSelected) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: Icon(Icons.calendar_today, size: 16, color: Color(0xFF65558F)),
        ),
        child: Text(
          date != null ? DateFormat('yyyy.MM.dd').format(date) : "yyyy.mm.dd",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildReminderCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _reminder,
          onChanged: (bool? value) {
            setState(() {
              _reminder = value!;
            });
          },
          activeColor: Color(0xFF65558F),
        ),
        Text('Set reminder'),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveMedication,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEADDFF),
        foregroundColor: const Color(0xFF65558F),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Save', style: TextStyle(fontSize: 16)),
    );
  }

  void _saveMedication() async {
    if (_medicineNameController.text.isEmpty || _dosageController.text.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('medications').add({
        'dosage': _dosageController.text + _selectedFrequency,
        'duration': '${_endDate!.difference(_startDate!).inDays} days',
        'endDate': Timestamp.fromDate(_endDate!),
        'medicationName': _medicineNameController.text,
        'petId': FirebaseFirestore.instance.doc('pets/${widget.petId}'),
        'reminder': _reminder,
        'startDate': Timestamp.fromDate(_startDate!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication saved successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving medication: $e')),
      );
    }
  }
}