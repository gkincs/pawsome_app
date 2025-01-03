import 'package:flutter/material.dart';

class ActivityItem {
  final String type;
  final String duration;

  ActivityItem({required this.type, required this.duration});
}

class ActivityHistoryWidget extends StatefulWidget {
  const ActivityHistoryWidget({super.key});

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
                    _buildActivitySection(),
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
              'Activity Informations',
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

  Widget _buildActivitySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Activity Type',
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
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(activities[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityItem activity) {
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
              activity.type,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${activity.duration}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
      child: Center(
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
      ),
    );
  }
}
