import 'package:flutter/material.dart';

class ActivityScreenWidget extends StatefulWidget {
  const ActivityScreenWidget({super.key});

  @override
  _ActivityScreenWidgetState createState() => _ActivityScreenWidgetState();
}

class _ActivityScreenWidgetState extends State<ActivityScreenWidget> {
  String? selectedActivityType;
  String? selectedDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const Divider(),
                        _buildActivityTypeSection(),
                        const Divider(),
                        _buildDurationSection(),
                        const Spacer(),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets),
          SizedBox(width: 8),
          Text(
            'Activity Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
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