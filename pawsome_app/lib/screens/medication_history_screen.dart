import 'package:flutter/material.dart';

class MedicationItem {
  final String name;
  final String dosage;

  MedicationItem({required this.name, required this.dosage});
}

class MedicationHistoryWidget extends StatefulWidget {
  const MedicationHistoryWidget({super.key});

  @override
  _MedicationHistoryWidgetState createState() => _MedicationHistoryWidgetState();
}

class _MedicationHistoryWidgetState extends State<MedicationHistoryWidget> {
  final List<MedicationItem> medications = [
    MedicationItem(name: 'Antibiotic', dosage: '1 pill'),
    MedicationItem(name: 'Vitamin', dosage: '2 pills'),
    MedicationItem(name: 'Pain killer', dosage: '1/2 pill'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMedicationSection(),
                    _buildAddButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
            color: const Color(0xFF65558F),
          ),
          const Expanded(
            child: Text(
              'Medications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMedicationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'History',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              return _buildMedicationCard(medications[index]);
            },
          ),
        ],
      ),
    );
  }

 Widget _buildMedicationCard(MedicationItem medication) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(
        color: Color(0xFFEADDFF),
        width: 1,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF65558F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosage: ${medication.dosage}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: const Color(0xFF65558F),
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {},
                color: const Color(0xFF65558F),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEADDFF),
              foregroundColor: Color(0xFF65558F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Text('Add'),
          ),
        ),
      ),
    );
  }
}
