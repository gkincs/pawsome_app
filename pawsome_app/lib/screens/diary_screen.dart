import 'package:flutter/material.dart';

class DiaryWidget extends StatefulWidget {
  const DiaryWidget({Key? key}) : super(key: key);

  @override
  _DiaryWidgetState createState() => _DiaryWidgetState();
}

class _DiaryWidgetState extends State<DiaryWidget> {
  int _selectedIndex = 2; // Default to Diary

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(child: _buildDiaryItems()),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFEDF2FB).withOpacity(0.25),
      child: Row(
        children: [
          _buildIconButton(Icons.menu),
          const SizedBox(width: 16),
          const Text(
            'Diary',
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontFamily: 'Roboto',
              fontSize: 22,
              fontWeight: FontWeight.normal,
            ),
          ),
          const Spacer(),
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
      child: Icon(icon, color: Colors.black),
    );
  }

  Widget _buildDiaryItems() {
    final items = [
      ('Nutrition Diary', const Color(0xFFEDF2FB)),
      ('Activity Screen', const Color(0xFFE2EAFC)),
      ('Appointments', const Color(0xFFE2EAFC)),
      ('Health Info', const Color(0xFFD7E3FC)),
      ('Expenses', const Color(0xFFCCDBFD)),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildDiaryItem(items[index].$1, items[index].$2);
      },
    );
  }

  Widget _buildDiaryItem(String title, Color color) {
    return ElevatedButton(
      onPressed: () {
        // Add your button action here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color(0xFF65558F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: const BorderSide(color: Colors.black),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      color: const Color(0xFFF0F3FA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('Home', 0),
          _buildNavItem('Pets', 1),
          _buildNavItem('Diary', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF65558F) : const Color(0xFF49454F),
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                width: 29,
                height: 3,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF65558F),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
          ],
        ),
      ),
    );
  }
}