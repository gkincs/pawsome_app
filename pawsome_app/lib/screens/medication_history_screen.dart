import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/health_info_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MedicationHistoryWidget extends StatefulWidget {
  final String petId;

  const MedicationHistoryWidget({super.key, required this.petId});

  @override
  _MedicationHistoryWidgetState createState() => _MedicationHistoryWidgetState();
}

class _MedicationHistoryWidgetState extends State<MedicationHistoryWidget> {
  late Stream<QuerySnapshot> _medicationsStream;

  @override
  void initState() {
    super.initState();
    _initMedicationsStream();
  }

  void _initMedicationsStream() {
    _medicationsStream = FirebaseFirestore.instance
        .collection('medications')
        .where('petId', isEqualTo: FirebaseFirestore.instance.doc('pets/${widget.petId}'))
        .orderBy('startDate', descending: true)
        .snapshots();
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _medicationsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('${l10n.error}: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(l10n);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return _buildMedicationCard(snapshot.data!.docs[index], l10n);
                    },
                  );
                },
              ),
            ),
            _buildAddButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Text(
        l10n.medications,
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

  Widget _buildMedicationCard(QueryDocumentSnapshot document, AppLocalizations l10n) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
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
                    data['medicationName'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF65558F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.dosage}: ${data['dosage'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _confirmDelete(document.id, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMedication(String medicationId, AppLocalizations l10n) async {
    try {
      await FirebaseFirestore.instance.collection('medications').doc(medicationId).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  void _confirmDelete(String medicationId, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEntry),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMedication(medicationId, l10n);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.noMedications,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildAddButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthInfoWidget(petId: widget.petId),
            ),
          );
          // A lista automatikusan frissül a StreamBuilder miatt
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEADDFF),
          foregroundColor: const Color(0xFF65558F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(l10n.add, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}