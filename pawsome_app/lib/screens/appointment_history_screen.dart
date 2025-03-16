import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pawsome_app/screens/appointment_screen.dart';

class AppointmentHistoryWidget extends StatefulWidget {
  final String petId;

  const AppointmentHistoryWidget({super.key, required this.petId});

  @override
  _AppointmentHistoryWidgetState createState() => _AppointmentHistoryWidgetState();
}

class _AppointmentHistoryWidgetState extends State<AppointmentHistoryWidget> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => isLoading = true);

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vetAppointments')
          .where('petId', isEqualTo: widget.petId)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        appointments = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'purpose': data['purpose'] ?? '',
            'date': (data['date'] as Timestamp).toDate(),
            'vetName': data['vetName'] ?? '',
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching appointments: $e");
      setState(() {
        isLoading = false;
        appointments = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: $e')),
      );
    }
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance.collection('vetAppointments').doc(appointmentId).delete();
      _fetchAppointments();
    } catch (e) {
      print("Error deleting appointment: $e");
    }
  }

  void _confirmDelete(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Appointment"),
        content: const Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointmentId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : appointments.isEmpty
                      ? _buildEmptyState()
                      : _buildAppointmentSection(),
            ),
            _buildAddButton(),
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

  Widget _buildAppointmentSection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(appointments[index]);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
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
                    appointment['purpose'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF65558F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('MMM d, y HH:mm').format(appointment['date'])}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Place/Name: ${appointment['vetName']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _confirmDelete(appointment['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No appointments added yet',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentWidget(petId: widget.petId),
            ),
          );
          if (result == true) {
            _fetchAppointments();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEADDFF),
          foregroundColor: const Color(0xFF65558F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Add', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
