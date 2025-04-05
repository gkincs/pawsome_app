import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pawsome_app/screens/appointment_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Az a képernyő, amely megjeleníti egy adott kisállat időpontjainak előzményeit.
/// Az időpontok Firestore-ból kerülnek betöltésre, és időrendben jelennek meg.
class AppointmentHistoryWidget extends StatefulWidget {
  final String petId;

  const AppointmentHistoryWidget({super.key, required this.petId});

  @override
  _AppointmentHistoryWidgetState createState() => _AppointmentHistoryWidgetState();
}

class _AppointmentHistoryWidgetState extends State<AppointmentHistoryWidget> {
  late Stream<QuerySnapshot> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    _initAppointmentsStream();
  }

  void _initAppointmentsStream() {
    _appointmentsStream = FirebaseFirestore.instance
        .collection('vetAppointments')
        .where('petId', isEqualTo: widget.petId)
        .orderBy('date', descending: true)
        .snapshots();
  }

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
              child: StreamBuilder<QuerySnapshot>(
                stream: _appointmentsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildAppointmentSection(snapshot.data!.docs);
                },
              ),
            ),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
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

  Widget _buildAppointmentSection(List<QueryDocumentSnapshot> documents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
        return _buildAppointmentCard(data, documents[index].id);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, String appointmentId) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFEADDFF), width: 1),
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
                    appointment['purpose'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF65558F)),
                  ),
                  const SizedBox(height: 4),
                  if (appointment['date'] != null)
                    Text(
                      '${l10n.date}: ${DateFormat('MMM d, y HH:mm').format((appointment['date'] as Timestamp).toDate())}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.veterinarian}: ${appointment['vetName'] ?? ''}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _confirmDelete(appointmentId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.noAppointments,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildAddButton() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentWidget(petId: widget.petId),
            ),
          );
          // A lista automatikusan frissül a StreamBuilder miatt
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEADDFF),
          foregroundColor: const Color(0xFF65558F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(l10n.add, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await FirebaseFirestore.instance.collection('vetAppointments').doc(appointmentId).delete();
      // A lista automatikusan frissül a StreamBuilder miatt
    } catch (e) {
      print("Error deleting appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e')),
      );
    }
  }

  void _confirmDelete(String appointmentId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointmentId);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
