import 'package:flutter/material.dart';

class HealthInfoWidget extends StatefulWidget {
  const HealthInfoWidget({super.key});

  @override
  _HealthInfoWidgetState createState() => _HealthInfoWidgetState();
}

class _HealthInfoWidgetState extends State<HealthInfoWidget> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Expanded(child: _buildInputField(_frequencyController, 'Frequency', hintText: 'daily')),
                ],
              ),
              SizedBox(height: 16),
              _buildDatePicker('Start Date', _startDate, (date) => setState(() => _startDate = date)),
              SizedBox(height: 16),
              _buildDatePicker('End Date', _endDate, (date) => setState(() => _endDate = date)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back navigation
          },
        ),
        SizedBox(width: 8),
        Text(
          'Medications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {String? hintText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          suffixIcon: Icon(Icons.calendar_today, size: 16),
        ),
        child: Text(
          date != null ? "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}" : "yyyy.mm.dd",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}