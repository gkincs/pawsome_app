import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/expenses_screen.dart';
import 'package:intl/intl.dart';

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
        SnackBar(content: Text('Error loading expenses: $e')),
      );
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    try {
      await FirebaseFirestore.instance.collection('expenses').doc(expenseId).delete();
      _fetchExpenses();
    } catch (e) {
      print("Error deleting expense: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting expense: $e')),
      );
    }
  }

  void _confirmDelete(String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExpense(expenseId);
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Expenses',
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
                    'Date: ${DateFormat('MMM d, y').format(expense['date'])}',
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
    return const Center(
      child: Text(
        'No expenses added yet',
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
        child: const Text('Add', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}