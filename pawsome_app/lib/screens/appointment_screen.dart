import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentWidget extends StatefulWidget {
  final String petId;

  const AppointmentWidget({super.key, required this.petId});

  @override
  _AppointmentWidgetState createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  bool _reminder = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildTimeField(),
                      const SizedBox(height: 16),
                      _buildVetNameField(),
                      const SizedBox(height: 16),
                      _buildPurposeField(),
                      const SizedBox(height: 16),
                      _buildReminderField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Appointments',
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
  
  Widget _buildVetNameField() {
    return TextField(
      controller: _vetNameController,
      decoration: InputDecoration(
        labelText: 'Vet Name',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF65558F)),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF65558F)),
        ),
        child: Text(
          DateFormat('yyyy.MM.dd').format(selectedDate),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time, color: Color(0xFF65558F)),
        ),
        child: Text(
          selectedTime.format(context),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPurposeField() {
    return TextField(
      controller: _purposeController,
      decoration: InputDecoration(
        labelText: 'Purpose',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF65558F)),
        ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildReminderField() {
    return Row(
      children: [
        Checkbox(
          value: _reminder,
          onChanged: (value) {
            setState(() {
              _reminder = value ?? false;
            });
          },
          activeColor: Color(0xFF65558F),
        ),
        Text('Set reminder'),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _saveAppointment,
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

  void _saveAppointment() async {
    try {
      await FirebaseFirestore.instance
          .collection('vetAppointments')
          .add({
        'date': Timestamp.fromDate(DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        )),
        'petId': FirebaseFirestore.instance.doc('pets/${widget.petId}'),
        'purpose': _purposeController.text,
        'reminder': true,
        'vetName': _vetNameController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving appointment: $e')),
      );
    }
  }

}
