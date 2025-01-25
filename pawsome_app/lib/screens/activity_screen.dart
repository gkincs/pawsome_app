import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';
import 'package:pawsome_app/screens/activity_history_screen.dart';

class ActivityScreenWidget extends StatefulWidget {
  final String? petId;

  const ActivityScreenWidget({super.key, required this.petId});

  @override
  _ActivityScreenWidgetState createState() => _ActivityScreenWidgetState();
}

class _ActivityScreenWidgetState extends State<ActivityScreenWidget> {
  String? selectedActivityType;
  String? selectedDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const Divider(color: Color(0xFFCAC4D0)),
                _buildActivityTypeSection(),
                const Divider(color: Color(0xFFCAC4D0)),
                _buildDurationSection(),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 2),
    );
  }

Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Activity Information',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildActivityTypeSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Activity Type',
            style: TextStyle(
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
          children: ['Walk', 'Play', 'Training', 'Other'].map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: selectedActivityType == type,
              selectedColor: const Color(0xFFEADDFF),
              onSelected: (selected) {
                setState(() {
                  selectedActivityType = selected ? type : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Duration',
            style: TextStyle(
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
          children: ['< 30 min', '30 min', '1 hour', '1+ hour'].map((duration) {
            return ChoiceChip(
              label: Text(duration),
              selected: selectedDuration == duration,
              selectedColor: const Color(0xFFEADDFF),
              onSelected: (selected) {
                setState(() {
                  selectedDuration = selected ? duration : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveActivityInfo,
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

  void _saveActivityInfo() async {
    if (widget.petId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No pet selected')),
      );
      return;
    }

    if (selectedActivityType == null || selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both activity type and duration')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('activityLogs').add({
        'activityType': selectedActivityType!.toLowerCase(),
        'date': FieldValue.serverTimestamp(),
        'duration': _parseDuration(selectedDuration!),
        'petId': FirebaseFirestore.instance.doc('pets/${widget.petId}'),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity information saved successfully')),
      );

      // Navigate back to ActivityHistoryWidget
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityHistoryWidget(petId: widget.petId!),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving activity information: $e')),
      );
    }
  }

  int _parseDuration(String duration) {
    switch (duration) {
      case '< 30 min':
        return 15;
      case '30 min':
        return 30;
      case '1 hour':
        return 60;
      case '1+ hour':
        return 90;
      default:
        return 0;
    }
  }
}