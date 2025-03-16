import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pawsome_app/screens/nutrition_diary.dart';

class NutritionHistoryWidget extends StatefulWidget {
  final String petId;

  const NutritionHistoryWidget({super.key, required this.petId});

  @override
  _NutritionHistoryWidgetState createState() => _NutritionHistoryWidgetState();
}

class _NutritionHistoryWidgetState extends State<NutritionHistoryWidget> {
  late Stream<QuerySnapshot> _nutritionItemsStream;

  @override
  void initState() {
    super.initState();
    _initNutritionItemsStream();
  }

  void _initNutritionItemsStream() {
    _nutritionItemsStream = FirebaseFirestore.instance
        .collection('feedingLogs')
        .where('petId', isEqualTo: FirebaseFirestore.instance.doc('pets/${widget.petId}'))
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
                stream: _nutritionItemsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildHistorySection(snapshot.data!.docs);
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
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: const Text(
        'Feeding Information',
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

  Widget _buildHistorySection(List<QueryDocumentSnapshot> documents) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
        String docId = documents[index].id;
        return _buildNutritionCard(data, docId);
      },
    );
  }

  Widget _buildNutritionCard(Map<String, dynamic> item, String docId) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          item['foodType'].toString().capitalize(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF65558F),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Amount: ${item['amount']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${item['date'] != null ? DateFormat('MMM d, y HH:mm').format((item['date'] as Timestamp).toDate()) : 'No Date'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _confirmDelete(docId),
        ),
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this feeding entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteEntry(docId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(String docId) {
    FirebaseFirestore.instance.collection('feedingLogs').doc(docId).delete();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No information added yet',
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
              builder: (context) => NutritionDiaryWidget(petId: widget.petId),
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
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
