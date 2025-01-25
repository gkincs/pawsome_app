import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pawsome_app/screens/activity_screen.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';

class ActivityHistoryWidget extends StatefulWidget {
  final String petId;

  const ActivityHistoryWidget({super.key, required this.petId});

  @override
  _ActivityHistoryWidgetState createState() => _ActivityHistoryWidgetState();
}

class _ActivityHistoryWidgetState extends State<ActivityHistoryWidget> {
  List<Map<String, dynamic>> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('activityLogs')
          .where('petId', isEqualTo: FirebaseFirestore.instance.doc('pets/${widget.petId}'))
          .orderBy('date', descending: true)
          .get();

      setState(() {
        activities = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'activityType': data['activityType'],
            'duration': data['duration'],
            'date': (data['date'] as Timestamp).toDate(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching activities: $e");
      setState(() {
        isLoading = false;
      });
    }
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
                  : activities.isEmpty
                      ? _buildEmptyState()
                      : _buildActivitySection(),
            ),
            _buildAddButton(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Activity Information',
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

  Widget _buildActivitySection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return _buildActivityCard(activities[index]);
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity['activityType'].toString().capitalize(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${activity['duration']} minutes',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${DateFormat('MMM d, y HH:mm').format(activity['date'])}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No activities added yet',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityScreenWidget(petId: widget.petId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEADDFF),
          foregroundColor: const Color(0xFF65558F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Add', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}