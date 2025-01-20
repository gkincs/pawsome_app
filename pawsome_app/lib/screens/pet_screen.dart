import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawsome_app/screens/pet_prof_screen.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';

class PetScreenWidget extends StatefulWidget {
  final String? petId;

  const PetScreenWidget({Key? key, this.petId}) : super(key: key);

  @override
  _PetScreenWidgetState createState() => _PetScreenWidgetState();
}

class _PetScreenWidgetState extends State<PetScreenWidget> {
  final CollectionReference petsCollection = FirebaseFirestore.instance.collection('pets');
  List<Map<String, dynamic>> pets = [];
  late String userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      userId = FirebaseAuth.instance.currentUser!.uid;
      var querySnapshot = await petsCollection.where('userId', isEqualTo: userId).get();

      setState(() {
        pets = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['petId'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching pets: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : pets.isNotEmpty
                      ? _buildPetsList()
                      : _buildEmptyState(),
            ),
            _buildAddPetButton(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Pets',
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
  
  Widget _buildPetsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return _buildPetCard(pets[index]);
      },
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF65558F),
          child: Text(
            pet['name'][0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          pet['name'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF65558F),
          ),
        ),
        subtitle: Text(
          pet['breed'],
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
              builder: (context) => PetProfileWidget(petId: pet['petId']),
            ),
          );
        },
      ),
    );
  }

Widget _buildAddPetButton() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PetProfileWidget(petId: null),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEADDFF),
        foregroundColor: const Color(0xFF65558F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: const Size(120, 50),
      ),
      child: const Text(
        'Add',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No pets added yet!',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}