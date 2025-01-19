import 'package:flutter/material.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';
import 'package:pawsome_app/screens/nutrition_diary.dart';
import 'package:pawsome_app/screens/activity_screen.dart';
import 'package:pawsome_app/screens/appointment_screen.dart';
import 'package:pawsome_app/screens/health_info_screen.dart';
import 'package:pawsome_app/screens/expenses_screen.dart';

class DiaryWidget extends StatefulWidget {
  const DiaryWidget({super.key});

  @override
  _DiaryWidgetState createState() => _DiaryWidgetState();
}

class _DiaryWidgetState extends State<DiaryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(child: _buildDiaryItems()),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFEADDFF).withOpacity(0.25),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Diary',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildIconButton(Icons.search),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(icon, color: const Color(0xFF65558F)),
    );
  }

  Widget _buildDiaryItems() {
    final items = [
      ('Nutrition Diary', const Color.fromARGB(255, 220, 205, 243), NutritionDiaryWidget()),
      ('Activity Screen', const Color(0xFFD0BCFF), ActivityScreenWidget()),
      ('Appointments', const Color(0xFFD0BCFF), AppointmentWidget()),
      ('Health Info', const Color(0xFFB69DF8), HealthInfoWidget()),
      ('Expenses', const Color(0xFF9A82DB), ExpensesWidget()),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final (title, color, widget) = items[index];
        return ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => widget),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}