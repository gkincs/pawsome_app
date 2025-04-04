import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/activity_history_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Az a képernyő, amely lehetővé teszi a tevékenységi adatok megadását egy adott kisállathoz.
/// A tevékenységek típusa és időtartama kiválasztható, majd elmenthető Firestore-ba.
class ActivityScreenWidget extends StatefulWidget {
  final String petId;

  const ActivityScreenWidget({super.key, required this.petId});

  @override
  _ActivityScreenWidgetState createState() => _ActivityScreenWidgetState();
}

class _ActivityScreenWidgetState extends State<ActivityScreenWidget> {
  String? selectedActivityType;
  String? selectedDuration;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(l10n),
                const Divider(color: Color(0xFFCAC4D0)),
                _buildActivityTypeSection(l10n),
                const Divider(color: Color(0xFFCAC4D0)),
                _buildDurationSection(l10n),
                const SizedBox(height: 24),
                _buildSaveButton(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.activityInformation,
            style: const TextStyle(
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

  Widget _buildActivityTypeSection(AppLocalizations l10n) {
    final List<String> activityTypes = [
      l10n.walk,
      l10n.play,
      l10n.training,
      l10n.other
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            l10n.activityType,
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
          children: activityTypes.map((type) {
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

  Widget _buildDurationSection(AppLocalizations l10n) {
    final List<String> durations = [
      l10n.lessThan30Min,
      l10n.thirtyMin,
      l10n.oneHour,
      l10n.moreThanOneHour
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            l10n.duration,
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
          children: durations.map((duration) {
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

  Widget _buildSaveButton(AppLocalizations l10n) {
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
      child: Text(l10n.save, style: const TextStyle(fontSize: 16)),
    );
  }

  void _saveActivityInfo() async {
    final l10n = AppLocalizations.of(context)!;
    if (selectedActivityType == null || selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectActivityAndDuration)),
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
        SnackBar(content: Text(l10n.activitySaved)),
      );

      // Return to previous screen (Diary widget)
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSavingActivity(e.toString()))),
      );
    }
  }

  int _parseDuration(String duration) {
    final l10n = AppLocalizations.of(context)!;
    if (duration == l10n.lessThan30Min) return 15;
    if (duration == l10n.thirtyMin) return 30;
    if (duration == l10n.oneHour) return 60;
    if (duration == l10n.moreThanOneHour) return 90;
    return 0;
  }
}