import 'package:flutter/material.dart';

class Pet {
  final String name;
  final String breed;

  Pet({required this.name, required this.breed});
}

class Activity {
  final String type;
  final String details;

  Activity({required this.type, required this.details});
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final List<Pet> pets = [
    Pet(name: 'Rocky', breed: 'Labrador Retriever'),
    Pet(name: 'Bella', breed: 'Bengal cat'),
  ];

  final List<Activity> recentActivities = [
    Activity(type: 'Walk', details: 'Duration: 1 hour'),
    Activity(type: 'Feeding', details: 'Amount: Medium'),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPetsSection(),
                      const SizedBox(height: 24),
                      _buildRecentActivitiesSection(),
                    ],
                  ),
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
            'PawSome',
            textAlign: TextAlign.center,  // Középre igazítás
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black,  // Fekete szín
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
          color: Colors.black,
        ),
      ],
    ),
  );
}

Widget _buildPetsSection() {
  return Column(
    children: [
      const Center(  // Wrap with Center widget
        child: Text(
          'My Pets',
          textAlign: TextAlign.center,  // Center align the text
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(height: 16),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          return _buildPetCard(pets[index]);
        },
      ),
    ],
  );
}

  Widget _buildPetCard(Pet pet) {
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
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF65558F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.breed,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF65558F),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildRecentActivitiesSection() {
  return Column(
    children: [
      const Center(  // Wrap with Center widget
        child: Text(
          'Recent Activities',
          textAlign: TextAlign.center,  // Center align the text
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(height: 16),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentActivities.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(recentActivities[index]);
        },
      ),
    ],
  );
}

  Widget _buildActivityCard(Activity activity) {
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
              activity.details,
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
}
