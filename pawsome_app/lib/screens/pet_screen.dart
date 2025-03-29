import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawsome_app/screens/pet_prof_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PetScreenWidget extends StatefulWidget {
  final String? petId;

  const PetScreenWidget({super.key, this.petId});

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            const Divider(color: Color(0xFFCAC4D0)),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : pets.isNotEmpty
                      ? _buildPetsList(l10n)
                      : _buildEmptyState(l10n),
            ),
            _buildAddPetButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
            color: const Color(0xFF65558F),
          ),
          Expanded(
            child: Text(
              l10n.pets,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 48), // For symmetry
        ],
      ),
    );
  }

  Widget _buildPetsList(AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: _buildPetAvatar(pet),
            title: Text(pet['name']),
            subtitle: Text(pet['breed']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _navigateToPetProfile(pet['petId']),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(pet['petId'], pet['name'], l10n),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetAvatar(Map<String, dynamic> pet) {
    if (pet['profileImageUrl'] != null && pet['profileImageUrl'].isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(pet['profileImageUrl']),
        radius: 20,
      );
    } else {
      return CircleAvatar(
        backgroundColor: const Color(0xFFEADDFF),
        radius: 20,
        child: Text(
          pet['name'][0].toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF65558F),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pets,
            size: 64,
            color: Color(0xFF65558F),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noPets,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _navigateToPetProfile(null),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF65558F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(l10n.add),
      ),
    );
  }

  void _navigateToPetProfile(String? petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetProfileWidget(petId: petId),
      ),
    ).then((_) => _fetchPets());
  }

  Future<void> _showDeleteConfirmation(String petId, String petName, AppLocalizations l10n) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deletePet),
          content: Text('${l10n.deletePetConfirmation} $petName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePet(petId, l10n);
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePet(String petId, AppLocalizations l10n) async {
    try {
      await FirebaseFirestore.instance.collection('pets').doc(petId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.petDeleted)),
      );
      _fetchPets(); // Frissítjük a listát
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToDelete(e.toString()))),
      );
    }
  }
}