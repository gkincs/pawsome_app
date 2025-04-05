import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pawsome_app/screens/activity_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Az a képernyő, amely megjeleníti egy adott kisállat tevékenységeinek előzményeit.
/// A tevékenységek Firestore-ból kerülnek betöltésre, és időrendben jelennek meg.
class ActivityHistoryWidget extends StatefulWidget {
  final String petId;

  const ActivityHistoryWidget({super.key, required this.petId});

  @override
  _ActivityHistoryWidgetState createState() => _ActivityHistoryWidgetState();
}

class _ActivityHistoryWidgetState extends State<ActivityHistoryWidget> {
  late Stream<QuerySnapshot> _activitiesStream;

  @override
  void initState() {
    super.initState();
    _initActivitiesStream();
  }

  void _initActivitiesStream() {
    _activitiesStream = FirebaseFirestore.instance
        .collection('activityLogs')
        .where('petId', isEqualTo: FirebaseFirestore.instance.doc('pets/${widget.petId}'))
        .orderBy('date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(l10n),
                const Divider(color: Color(0xFFCAC4D0)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _activitiesStream,
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
                          Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                          return _buildActivityCard(data, l10n);
                        },
                      );
                    },
                  ),
                ),
                _buildAddButton(l10n),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        l10n.activityInformation,
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

  Widget _buildActivityCard(Map<String, dynamic> activity, AppLocalizations l10n) {
    final Timestamp? date = activity['date'] as Timestamp?;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: ListTile(
        title: Text(activity['activityType']?.toString().capitalize() ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.duration}: ${activity['duration']} minutes'),
            if (date != null)
              Text('${l10n.date}: ${DateFormat('yyyy-MM-dd').format(date.toDate())}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showDeleteConfirmation(activity['activityType'], l10n),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String activityType, AppLocalizations l10n) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteEntry),
          content: Text(l10n.confirmDelete),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.delete),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteActivity(activityType, l10n);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteActivity(String activityType, AppLocalizations l10n) async {
    try {
      await FirebaseFirestore.instance
          .collection('activityLogs')
          .where('activityType', isEqualTo: activityType)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteEntry)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.noActivities,
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
        child: Text(l10n.add, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
