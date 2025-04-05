import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/appointment_history_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Az a képernyő, amely lehetővé teszi, hogy időpontot rőgzíthessen egy kisállathoz.
/// Az időpont adatai, például dátum, idő, hely és cél, elmenthetőek Firestore-ba.
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
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDateField(l10n),
                      const SizedBox(height: 16),
                      _buildTimeField(l10n),
                      const SizedBox(height: 16),
                      _buildVetNameField(l10n),
                      const SizedBox(height: 16),
                      _buildPurposeField(l10n),
                      const SizedBox(height: 16),
                      _buildReminderField(l10n),
                    ],
                  ),
                ),
              ),
            ),
            _buildSaveButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        l10n.appointments,
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
  
  Widget _buildVetNameField(AppLocalizations l10n) {
    return TextField(
      controller: _vetNameController,
      decoration: InputDecoration(
        labelText: l10n.veterinarian,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF65558F)),
        ),
      ),
    );
  }

  Widget _buildDateField(AppLocalizations l10n) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.date,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF65558F)),
        ),
        child: Text(
          DateFormat('yyyy.MM.dd').format(selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTimeField(AppLocalizations l10n) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.time,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time, color: Color(0xFF65558F)),
        ),
        child: Text(
          selectedTime.format(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPurposeField(AppLocalizations l10n) {
    return TextField(
      controller: _purposeController,
      decoration: InputDecoration(
        labelText: l10n.appointmentType,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF65558F)),
        ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildReminderField(AppLocalizations l10n) {
    return Row(
      children: [
        Checkbox(
          value: _reminder,
          onChanged: (value) {
            setState(() {
              _reminder = value ?? false;
            });
          },
          activeColor: const Color(0xFF65558F),
        ),
        Text(l10n.reminder),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _saveAppointment(l10n),
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

  void _saveAppointment(AppLocalizations l10n) async {
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
        'petId': widget.petId,
        'purpose': _purposeController.text,
        'reminder': _reminder,
        'vetName': _vetNameController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appointmentSaved)),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSavingAppointment(e.toString()))),
      );
    }
  }
}