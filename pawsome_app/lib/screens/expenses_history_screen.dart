import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/expenses_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Az a képernyő, amely megjeleníti egy adott kisállat kiadásainak előzményeit.
/// A kiadások Firestore-ból kerülnek betöltésre, és időrendben jelennek meg.
class ExpensesHistoryWidget extends StatefulWidget {
  final String petId;

  const ExpensesHistoryWidget({super.key, required this.petId});

  @override
  _ExpensesHistoryWidgetState createState() => _ExpensesHistoryWidgetState();
}

class _ExpensesHistoryWidgetState extends State<ExpensesHistoryWidget> {
  late Stream<QuerySnapshot> _expensesStream;

  @override
  void initState() {
    super.initState();
    _initExpensesStream();
  }

  void _initExpensesStream() {
    _expensesStream = FirebaseFirestore.instance
        .collection('expenses')
        .where('petId', isEqualTo: widget.petId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _expensesStream,
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
                      return _buildExpenseCard(snapshot.data!.docs[index], l10n);
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
      child: Text(
        l10n.expenses,
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

  Widget _buildExpenseCard(DocumentSnapshot document, AppLocalizations l10n) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final date = data['date'] as Timestamp?;
    final currency = data['currency'] as String? ?? 'EUR';
    
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
                    data['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF65558F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.date}: ${date != null ? DateFormat('MMM d, y').format(date.toDate()) : ''}',
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
                Text(
                  '${data['amount'] ?? ''} $currency',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _confirmDelete(document.id, l10n),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Text(
        l10n.noExpenses,
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
              builder: (context) => ExpensesWidget(petId: widget.petId),
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

  Future<void> _deleteExpense(String expenseId, AppLocalizations l10n) async {
    try {
      await FirebaseFirestore.instance.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    }
  }

  void _confirmDelete(String expenseId, AppLocalizations l10n) {
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
              _deleteExpense(expenseId, l10n);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}