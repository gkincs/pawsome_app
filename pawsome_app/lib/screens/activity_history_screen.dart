import 'package:flutter/material.dart';

class ActivityHistoryWidget extends StatefulWidget {
  const ActivityHistoryWidget({Key? key}) : super(key: key);

  @override
  _ActivityHistoryWidgetState createState() => _ActivityHistoryWidgetState();
}

class _ActivityHistoryWidgetState extends State<ActivityHistoryWidget> {
  final List<ActivityItem> activities = [
    ActivityItem(type: 'Walk', duration: '1 hour'),
    ActivityItem(type: 'Play', duration: '< 30 min'),
    ActivityItem(type: 'Walk', duration: '1+ hour'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFEADDFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Divider(),
              _buildActivitySection(),
              const Spacer(),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0x40EDF2FB),
      child: Row(
        children: [
          //const Icon(Icons.pets, color: Color(0xFF65558F)),
          const SizedBox(width: 8),
          Text(
            'Activity Informations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Activity Type',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                return _buildActivityCard(activities[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityItem activity, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFFF3EEFF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF65558F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${activity.duration}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.remove_circle_outline, 
                  color: Color(0xFF65558F)),
                onPressed: () {
                  setState(() {
                    activities.removeAt(index);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          // Add new activity functionality
        },
        style: ElevatedButton.styleFrom(
          //backgroundColor: const Color(0xFF65558F),
          //foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Add'),
      ),
    );
  }

  Widget _buildNavItem(String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF65558F) : const Color(0xFF49454F),
            fontSize: 14,
          ),
        ),
        if (isSelected)
          Container(
            width: 32,
            height: 2,
            margin: const EdgeInsets.only(top: 4),
            //: const Color(0xFF65558F),
          ),
      ],
    );
  }
}

class ActivityItem {
  final String type;
  final String duration;

  ActivityItem({required this.type, required this.duration});
}