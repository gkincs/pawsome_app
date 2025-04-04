import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/pet_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Ez az osztály egy kisállat adatait reprezentálja, amelyeket a Firestore-ból töltünk be.
class Pet {
  final String id;
  final String name;
  final String breed;
  final String? profileImageUrl;

///Konstruktor
  Pet({required this.id, required this.name, required this.breed, this.profileImageUrl});

/// A Firestore-ból való betöltéshez szükséges konstruktor
/// egy Firestore dokumentumból hoz létre egy Pet objektumot.
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

///Egy kisállathoz kapcsolódó legutóbbi tevékenységet reprezentáló osztály.
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

/// Az a képernyő, amely a felhasználó kisállatainak listáját és a legutóbbi tevékenységeket jeleníti meg.
/// A felhasználó navigálhat a kisállatok részletes képernyőire, valamint megtekintheti a legutóbbi eseményeket
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
  int petsPerPage = 2;
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
        String petRef = data['petRef'] as String;
        if (data['date'] != null && petRef != null) {
          allActivities.add(RecentActivity(
            petId: petRef,
            petName: petNames[petRef] ?? 'Unknown Pet',
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
        String petId = data['petId'] as String;
        if (data['date'] != null && petId != null) {
          allActivities.add(RecentActivity(
            petId: petId,
            petName: petNames[petId] ?? 'Unknown Pet',
            type: 'expense',
            description: '${data['description']} - ${data['amount']} ${data['currency'] ?? 'Ft'}',
            date: (data['date'] as Timestamp).toDate(),
          ));
        }
      }

      // Etetések lekérése
      var feedingQuery = await FirebaseFirestore.instance
          .collection('feedingLogs')
          .where('petId', whereIn: petIds)
          .get();

      print('Found ${feedingQuery.docs.length} feeding logs'); // Debug print

      for (var doc in feedingQuery.docs) {
        var data = doc.data();
        print('Feeding log data: $data'); // Debug print
        String petId = data['petId'] as String;
        if (data['date'] != null && petId != null) {
          print('Adding feeding activity for pet: $petId'); // Debug print
          allActivities.add(RecentActivity(
            petId: petId,
            petName: petNames[petId] ?? 'Unknown Pet',
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
        String petId = data['petId'] as String;
        if (data['date'] != null && petId != null) {
          allActivities.add(RecentActivity(
            petId: petId,
            petName: petNames[petId] ?? 'Unknown Pet',
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
        String petId = data['petId'] as String;
        if (data['startDate'] != null && petId != null) {
          allActivities.add(RecentActivity(
            petId: petId,
            petName: petNames[petId] ?? 'Unknown Pet',
            type: 'medication',
            description: '${data['medicationName']} - ${data['dosage']}',
            date: (data['startDate'] as Timestamp).toDate(),
          ));
        }
      }

      print('Total activities before sorting: ${allActivities.length}'); // Debug print

      // Rendezzük az összes aktivitást dátum szerint csökkenő sorrendbe
      allActivities.sort((a, b) => b.date.compareTo(a.date));

      // Visszaadjuk a két legfrissebb aktivitást
      var result = allActivities.take(2).toList();
      print('Final activities: ${result.map((a) => '${a.type} - ${a.petName}').join(', ')}'); // Debug print
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const Divider(color: Color(0xFFCAC4D0)),
            _buildNavigationButtons(),
            _buildPetsSection(l10n),
            const SizedBox(height: 16),
            _buildRecentActivitiesSection(l10n),
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
        alignment: Alignment.center,
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

  Widget _buildPetsSection(AppLocalizations l10n) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (allPets.isEmpty) {
      return Center(child: Text(l10n.noPets));
    }
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
      elevation: 4,
      shadowColor: const Color(0xFF65558F).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFEADDFF),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFEADDFF),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Egyenlő térköz a jobb oldali ikon miatt
          Expanded(
            child: Center(
              child: Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF65558F),
                ),
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
                child: Text(l10n.logout),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.recentActivities,
                style: const TextStyle(
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
          Container(
            width: double.infinity,
            height: 2,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEADDFF),
              borderRadius: BorderRadius.all(Radius.circular(1)),
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildRecentActivitiesList(l10n),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesList(AppLocalizations l10n) {
    List<RecentActivity> activities = List.from(recentActivities);
              
    if (activities.isEmpty) {
      return Column(
        children: [
          _buildEmptyActivityCard(l10n),
          const SizedBox(height: 8),
          _buildEmptyActivityCard(l10n),
        ],
      );
    }

    // Ha csak 1 aktivitás van, adjunk hozzá egy üres kártyát
    if (activities.length == 1) {
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
          return _buildEmptyActivityCard(l10n);
        }

        return _buildActivityCard(activity, l10n);
      }).toList(),
    );
  }

  Widget _buildActivityCard(RecentActivity activity, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 4,
      shadowColor: const Color(0xFF65558F).withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFFEADDFF),
          width: 2,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          activity.petName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF65558F),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              _getActivityTitle(activity.type, l10n),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              activity.description,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(activity.date, l10n),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65558F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivityCard(AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 2,
      shadowColor: const Color(0xFF65558F).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: Color(0xFFF3E8FD),
          width: 1,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          l10n.noActivitiesAdded,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF65558F),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final activityDate = DateTime(date.year, date.month, date.day);

    if (activityDate == DateTime(now.year, now.month, now.day)) {
      return '${l10n.today}, ${DateFormat('HH:mm').format(date)}';
    } else if (activityDate == yesterday) {
      return '${l10n.yesterday}, ${DateFormat('HH:mm').format(date)}';
    }
    return DateFormat('yyyy.MM.dd. HH:mm').format(date);
  }

  String _getActivityTitle(String type, AppLocalizations l10n) {
    switch (type) {
      case 'feeding':
        return l10n.nutrition;
      case 'activity':
        return l10n.activities;
      case 'medication':
        return l10n.medications;
      case 'empty':
        return l10n.noActivities; 
      default:
        return type;
    }
  }
}