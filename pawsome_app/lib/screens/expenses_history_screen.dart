import 'package:flutter/material.dart';

class ExpenseItem {
  final String type;
  final String amount;

  ExpenseItem({required this.type, required this.amount});
}

class ExpensesHistoryWidget extends StatefulWidget {
  const ExpensesHistoryWidget({super.key});

  @override
  _ExpensesHistoryWidgetState createState() => _ExpensesHistoryWidgetState();
}

class _ExpensesHistoryWidgetState extends State<ExpensesHistoryWidget> {
  final List<ExpenseItem> expenses = [
    ExpenseItem(type: 'Food - Nutrition', amount: '£15'),
    ExpenseItem(type: 'Healthcare', amount: '20'),
    ExpenseItem(type: 'Food - Nutrition', amount: '£5'),
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
                    _buildHistorySection(),
                    //_buildTotalAmount(),
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
              'Expenses',
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

  Widget _buildHistorySection() {
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
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return _buildExpenseCard(expenses[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseItem expense) {
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
            Text(
              expense.type,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
            Text(
              expense.amount,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildTotalAmount() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: const [
  //         Text(
  //           'This month: 40',
  //           style: TextStyle(
  //             fontSize: 14,
  //             color: Colors.grey,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
    );
  }
}
