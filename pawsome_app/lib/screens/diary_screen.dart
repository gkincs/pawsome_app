import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawsome_app/screens/activity_history_screen.dart';
import 'package:pawsome_app/screens/nutrition_history_screen.dart';
import 'package:pawsome_app/screens/appointment_history_screen.dart';
import 'package:pawsome_app/screens/medication_history_screen.dart';
import 'package:pawsome_app/screens/expenses_history_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Az a képernyő, amely lehetővé teszi a különböző naplózási funkciókat.
/// például táplálkozási, tevékenységi, egészségügyi és kiadási előzményeket.
/// A kisállatok listája a Firestore-ból kerül betöltésre.
class DiaryWidget extends StatefulWidget {
  const DiaryWidget({super.key});

  @override
  _DiaryWidgetState createState() => _DiaryWidgetState();
}

class _DiaryWidgetState extends State<DiaryWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> pets = [];

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    try {
      final CollectionReference petsCollection = _firestore.collection('pets');
      var querySnapshot = await petsCollection.where('userId', isEqualTo: userId).get();

      setState(() {
        pets = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['petId'] = doc.id;
          data['imageUrl'] = data['imageUrl'] ?? '';
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching pets: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildHeader(l10n),
        const Divider(color: Color(0xFFCAC4D0)),
        Expanded(child: _buildDiaryItems(l10n)),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFEADDFF).withOpacity(0.25),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.diary,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildIconButton(Icons.search),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(icon, color: const Color(0xFF65558F)),
    );
  }

  Widget _buildDiaryItems(AppLocalizations l10n) {
    final items = [
      (l10n.nutrition, const Color.fromARGB(255, 220, 205, 243), (String petId) => NutritionHistoryWidget(petId: petId)),
      (l10n.activities, const Color(0xFFD0BCFF), (String petId) => ActivityHistoryWidget(petId: petId)),
      (l10n.appointments, const Color(0xFFD0BCFF), (String petId) => AppointmentHistoryWidget(petId: petId)),
      (l10n.health, const Color(0xFFB69DF8), (String petId) => MedicationHistoryWidget(petId: petId)),
      (l10n.expenses, const Color(0xFF9A82DB), (String petId) => ExpensesHistoryWidget(petId: petId)),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final (title, color, widgetBuilder) = items[index];
        return ElevatedButton(
          onPressed: () => _showPetSelectionDialog(title, widgetBuilder, l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: const Color(0xFF65558F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  void _showPetSelectionDialog(String title, Function(String) widgetBuilder, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.selectPet} $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF65558F),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: pets.length,
                    itemBuilder: (BuildContext context, int index) {
                      final pet = pets[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: pet['imageUrl'].isNotEmpty
                                ? NetworkImage(pet['imageUrl'])
                                : null,
                            child: pet['imageUrl'].isEmpty
                                ? Text(pet['name'][0].toUpperCase())
                                : null,
                          ),
                          title: Text(pet['name']),
                          subtitle: Text(pet['breed']),
                          onTap: () {
                            Navigator.of(context).pop();
                            _navigateToScreen(widgetBuilder, pet['petId']);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToScreen(Function(String) widgetBuilder, String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widgetBuilder(petId),
      ),
    );
  }
}
