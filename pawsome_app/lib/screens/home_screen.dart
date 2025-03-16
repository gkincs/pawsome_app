import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/pet_screen.dart';
import 'package:intl/intl.dart';

class Pet {
  final String id;
  final String name;
  final String breed;
  final String? profileImageUrl;

  Pet({required this.id, required this.name, required this.breed, this.profileImageUrl});

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      profileImageUrl: data['profileImageUrl'],
    );
  }
}

class RecentActivity {
  final String petId;
  final String petName;
  final String type;
  final String description;
  final DateTime date;

  RecentActivity({
    required this.petId,
    required this.petName,
    required this.type,
    required this.description,
    required this.date,
  });
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Pet> allPets = [];
  List<Pet> visiblePets = [];
  bool isLoading = false;
  String? userId;
  int currentPage = 0;
  int petsPerPage = 3;
  List<RecentActivity> recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchPets();
    _loadRecentActivities();
  }

  Future<void> _fetchPets() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      List<Pet> fetchedPets = snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
      setState(() {
        allPets = fetchedPets;
        visiblePets = _getPetsForPage(currentPage);
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching pets: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Pet> _getPetsForPage(int page) {
    int startIndex = page * petsPerPage;
    int endIndex = startIndex + petsPerPage;
    return allPets.sublist(startIndex, endIndex < allPets.length ? endIndex : allPets.length);
  }

  void _goToNextPage() {
    if ((currentPage + 1) * petsPerPage < allPets.length) {
      setState(() {
        currentPage++;
        visiblePets = _getPetsForPage(currentPage);
      });
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        visiblePets = _getPetsForPage(currentPage);
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginWidget()),
    );
  }

  Future<List<RecentActivity>> _fetchRecentActivities() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');

      List<RecentActivity> allActivities = [];

      // Lekérjük a felhasználó összes kisállatát
      QuerySnapshot petsSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('userId', isEqualTo: userId)
          .get();

      if (petsSnapshot.docs.isEmpty) {
        print('No pets found for user');
        return [];
      }

      // Készítünk egy Map-et a kisállatok nevének gyors eléréséhez
      Map<String, String> petNames = {};
      List<String> petIds = [];
      
      for (var doc in petsSnapshot.docs) {
        String petId = doc.id;
        petIds.add(petId);
        petNames[petId] = (doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown Pet';
      }

      print('Found ${petIds.length} pets'); // Debug print

      // Időpontok lekérése
      var appointmentsQuery = await FirebaseFirestore.instance
          .collection('vetAppointments')
          .where('petRef', whereIn: petIds)
          .get();

      for (var doc in appointmentsQuery.docs) {
        var data = doc.data();
        if (data['date'] != null && data['petRef'] != null) {
          allActivities.add(RecentActivity(
            petId: data['petRef'],
            petName: petNames[data['petRef']] ?? 'Unknown Pet',
            type: 'appointment',
            description: data['purpose'] ?? 'No purpose specified',
            date: (data['date'] as Timestamp).toDate(),
          ));
        }
      }

      // Kiadások lekérése
      var expensesQuery = await FirebaseFirestore.instance
          .collection('expenses')
          .where('petId', whereIn: petIds)
          .get();

      for (var doc in expensesQuery.docs) {
        var data = doc.data();
        if (data['date'] != null && data['petId'] != null) {
          allActivities.add(RecentActivity(
            petId: data['petId'],
            petName: petNames[data['petId']] ?? 'Unknown Pet',
            type: 'expense',
            description: '${data['description']} - ${data['amount']}',
            date: (data['date'] as Timestamp).toDate(),
          ));
        }
      }

      // Etetések lekérése
      var feedingQuery = await FirebaseFirestore.instance
          .collection('feedingLogs')
          .where('petRef', whereIn: petIds)
          .get();

      for (var doc in feedingQuery.docs) {
        var data = doc.data();
        if (data['date'] != null && data['petRef'] != null) {
          allActivities.add(RecentActivity(
            petId: data['petRef'],
            petName: petNames[data['petRef']] ?? 'Unknown Pet',
            type: 'feeding',
            description: '${data['foodType']} - ${data['amount']}',
            date: (data['date'] as Timestamp).toDate(),
          ));
        }
      }

      // Aktivitások lekérése
      var activityQuery = await FirebaseFirestore.instance
          .collection('activityLogs')
          .where('petId', whereIn: petIds)
          .get();

      for (var doc in activityQuery.docs) {
        var data = doc.data();
        if (data['date'] != null && data['petId'] != null) {
          allActivities.add(RecentActivity(
            petId: data['petId'],
            petName: petNames[data['petId']] ?? 'Unknown Pet',
            type: 'activity',
            description: '${data['activityType']} - ${data['duration']} minutes',
            date: (data['date'] as Timestamp).toDate(),
          ));
        }
      }

      // Gyógyszerek lekérése
      var medicationsQuery = await FirebaseFirestore.instance
          .collection('medications')
          .where('petId', whereIn: petIds)
          .get();

      for (var doc in medicationsQuery.docs) {
        var data = doc.data();
        if (data['startDate'] != null && data['petId'] != null) {
          allActivities.add(RecentActivity(
            petId: data['petId'],
            petName: petNames[data['petId']] ?? 'Unknown Pet',
            type: 'medication',
            description: '${data['medicationName']} - ${data['dosage']}',
            date: (data['startDate'] as Timestamp).toDate(),
          ));
        }
      }

      print('Total activities found: ${allActivities.length}'); // Debug print

      // Rendezzük az összes aktivitást dátum szerint csökkenő sorrendbe
      allActivities.sort((a, b) => b.date.compareTo(a.date));

      // Visszaadjuk a két legfrissebb aktivitást
      var result = allActivities.take(2).toList();
      print('Returning ${result.length} activities'); // Debug print
      return result;
    } catch (error) {
      print('Error in _fetchRecentActivities: $error');
      return [];
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      List<RecentActivity> activities = await _fetchRecentActivities();
      setState(() {
        recentActivities = activities;
      });
    } catch (error) {
      print('Error loading recent activities: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            _buildPetsSection(),
            _buildNavigationButtons(),
            const SizedBox(height: 16),
            _buildRecentActivitiesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, color: Colors.black, size: 16),
              onPressed: _goToPreviousPage,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, color: Colors.black, size: 16),
              onPressed: _goToNextPage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsSection() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: visiblePets.length,
        itemBuilder: (context, index) {
          return _buildPetCard(visiblePets[index]);
        },
      ),
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
      child: ListTile(
        leading: _buildPetAvatar(pet),
        title: Text(
          pet.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF65558F),
          ),
        ),
        subtitle: Text(
          pet.breed,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF65558F),
          size: 20,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetScreenWidget(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetAvatar(Pet pet) {
    if (pet.profileImageUrl != null && pet.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(pet.profileImageUrl!),
        radius: 20,
      );
    } else {
      return CircleAvatar(
        backgroundColor: const Color(0xFFEADDFF),
        radius: 20,
        child: Text(
          pet.name[0].toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF65558F),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Color(0xFF65558F)),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activities',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF65558F)),
                onPressed: _loadRecentActivities,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildRecentActivitiesList(),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesList() {
    List<RecentActivity> activities = List.from(recentActivities);
              
    // Ha nincs aktivitás, üres kártyák
    while (activities.length < 2) {
      activities.add(RecentActivity(
        petId: '',
        petName: '',
        type: 'empty',
        description: '',
        date: DateTime.now(),
      ));
    }

    return Column(
      children: activities.map((activity) {
        if (activity.type == 'empty') {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color(0xFFEADDFF),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFEADDFF),
                child: Icon(
                  Icons.info_outline,
                  color: const Color(0xFF65558F),
                ),
              ),
              title: Text(
                'No Activity Yet',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                'Add your first activity to see it here',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        IconData activityIcon;
        String activityText = '';

        switch (activity.type) {
          case 'appointment':
            activityIcon = Icons.calendar_today;
            activityText = 'Appointment: ${activity.description}';
            break;
          case 'expense':
            activityIcon = Icons.attach_money;
            activityText = 'Expense: ${activity.description}';
            break;
          case 'feeding':
            activityIcon = Icons.restaurant;
            activityText = 'Feeding: ${activity.description}';
            break;
          case 'activity':
            activityIcon = Icons.directions_run;
            activityText = 'Activity: ${activity.description}';
            break;
          case 'medication':
            activityIcon = Icons.medical_services;
            activityText = 'Medication: ${activity.description}';
            break;
          default:
            activityIcon = Icons.info_outline;
            activityText = activity.description;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFEADDFF),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEADDFF),
              child: Icon(
                activityIcon,
                color: const Color(0xFF65558F),
              ),
            ),
            title: Text(
              activity.petName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activityText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Date: ${DateFormat('MMM d, y').format(activity.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}