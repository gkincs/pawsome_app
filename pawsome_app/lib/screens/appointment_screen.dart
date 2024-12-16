import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentWidget extends StatefulWidget {
  const AppointmentWidget({super.key});

  @override
  _AppointmentWidgetState createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event),
          SizedBox(width: 8),
          Text(
            'Appointments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVetNameField() {
    return TextField(
      controller: _vetNameController,
      decoration: InputDecoration(
        labelText: 'Vet Name',
        border: OutlineInputBorder(),
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
          suffixIcon: Icon(Icons.calendar_today),
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
          suffixIcon: Icon(Icons.access_time),
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
      ),
      maxLines: 3,
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