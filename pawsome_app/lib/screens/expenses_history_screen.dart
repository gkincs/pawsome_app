import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/expenses_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpensesHistoryWidget extends StatefulWidget {
  final String petId;

  const ExpensesHistoryWidget({super.key, required this.petId});

  @override
  _ExpensesHistoryWidgetState createState() => _ExpensesHistoryWidgetState();
}

class _ExpensesHistoryWidgetState extends State<ExpensesHistoryWidget> {
  List<Map<String, dynamic>> expenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      isLoading = true;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('petId', isEqualTo: widget.petId)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        expenses = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'description': data['description'] ?? '',
            'amount': data['amount'] ?? '',
            'date': (data['date'] as Timestamp).toDate(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching expenses: $e");
      setState(() {
        isLoading = false;
        expenses = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e')),
      );
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await FirebaseFirestore.instance.collection('expenses').doc(expenseId).delete();
      _fetchExpenses();
    } catch (e) {
      print("Error deleting expense: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e')),
      );
    }
  }

  void _confirmDelete(String expenseId) {
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
              _deleteExpense(expenseId);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : expenses.isEmpty
                      ? _buildEmptyState()
                      : _buildHistorySection(),
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

  Widget _buildHistorySection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return _buildExpenseCard(expenses[index]);
      },
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    final l10n = AppLocalizations.of(context)!;
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
                    expense['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF65558F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.date}: ${DateFormat('MMM d, y').format(expense['date'])}',
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
                  expense['amount'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _confirmDelete(expense['id']),
                ),
              ],
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
        l10n.noExpenses,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpensesWidget(petId: widget.petId),
            ),
          ).then((_) => _fetchExpenses());
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