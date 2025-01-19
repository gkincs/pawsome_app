import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawsome_app/bloc/bottom_navigation_bloc.dart';
import 'package:pawsome_app/screens/login_screen.dart';
import 'package:pawsome_app/screens/pet_screen.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';

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

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Pet> pets = [];
  bool isLoading = false;
  String? userId;
  DocumentSnapshot? lastDocument;
  bool hasMorePets = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchPets();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _fetchPets();
    }
  }

  Future<void> _fetchPets() async {
    if (isLoading || !hasMorePets) return;

    setState(() {
      isLoading = true;
    });

    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('No user logged in');

      Query query = FirebaseFirestore.instance
          .collection('pets')
          .where('userId', isEqualTo: userId)
          .limit(4);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        setState(() {
          hasMorePets = false;
          isLoading = false;
        });
        return;
      }

      List<Pet> fetchedPets = snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
      setState(() {
        pets.addAll(fetchedPets);
        lastDocument = snapshot.docs.last;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching pets: $error');
      setState(() {
        isLoading = false;
      });
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
                _buildPetsSection(),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 0,),
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
}