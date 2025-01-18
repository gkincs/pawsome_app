import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/pet_screen.dart';

class Pet {
  final String name;
  final String breed;

  Pet({required this.name, required this.breed});

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    return Pet(
      name: doc['name'] ?? '',
      breed: doc['breed'] ?? '',
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Pet> pets = [];
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('userId', isEqualTo: userId)
          .limit(10) 
          .get();
      
      List<Pet> fetchedPets = snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
      setState(() {
        pets = fetchedPets;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching pets: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginWidget()),
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Divider(color: Color(0xFFCAC4D0)),
                isLoading
                    ? const Expanded(child: Center(child: CircularProgressIndicator()))
                    : _buildPetsSection(),
              ],
            ),
          ),
        );
      },
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings, color: Colors.black),
          onSelected: (value) async {
            if (value == 'logout') {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginWidget()),
                );
              } catch (e) {
                print('Error during logout: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildPetsSection() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          return _buildPetCard(pets[index]);
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
}