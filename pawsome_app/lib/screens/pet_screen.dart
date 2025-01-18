import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawsome_app/screens/home_screen.dart';
import 'package:pawsome_app/screens/pet_prof_screen.dart';

class PetScreenWidget extends StatefulWidget {
  const PetScreenWidget({Key? key}) : super(key: key);

  @override
  _PetScreenWidgetState createState() => _PetScreenWidgetState();
}

class _PetScreenWidgetState extends State<PetScreenWidget> {
  final CollectionReference petsCollection = FirebaseFirestore.instance.collection('Pets');
  List<Map<String, dynamic>> pets = [];
  late String userId;

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
        pets = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error fetching pets: $e");
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
              child: pets.isNotEmpty ? _buildPetsList() : _buildEmptyState(),
            ),
            _buildAddPetButton(),
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
            onPressed: () => Navigator.pop(context),
            color: const Color(0xFF65558F),
          ),
          const Text(
            'PawSome',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xFF65558F),
            ),
          ),
        ],
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
        trailing: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF65558F),
            size: 20,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetProfileWidget(petId: pet['petId']),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddPetButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetProfileWidget(petId: null),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEADDFF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Color(0xFF65558F),
              ),
              SizedBox(width: 8),
              Text(
                'Add a new pet',
                style: TextStyle(
                  color: Color(0xFF65558F),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            color: Color(0xFFCAC4D0),
            size: 100,
          ),
          const SizedBox(height: 16),
          const Text(
            'No pets added yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}