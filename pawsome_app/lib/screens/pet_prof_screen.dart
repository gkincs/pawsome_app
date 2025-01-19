import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawsome_app/widgets/bottom_navigation_widget.dart';

class PetProfileWidget extends StatefulWidget {
  final String? petId;

  const PetProfileWidget({Key? key, required this.petId}) : super(key: key);

  @override
  _PetProfileWidgetState createState() => _PetProfileWidgetState();
}

class _PetProfileWidgetState extends State<PetProfileWidget> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedSpecies;
  String? _selectedBreed;
  DateTime? _selectedDate;
  bool _isFemale = true;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String? _userId;
  bool _isEditing = false;

final List<String> _species = ['Dog', 'Cat', 'Bird', 'Fish', 'Reptile', 'Small Mammal', 'Horse', 'Farm Animal', 'Exotic'];

final Map<String, List<String>> _breeds = {
  'Dog': [
    'Labrador Retriever', 'German Shepherd', 'Golden Retriever', 'French Bulldog', 'Bulldog',
    'Poodle', 'Beagle', 'Rottweiler', 'Dachshund', 'Yorkshire Terrier', 'Boxer', 'Siberian Husky',
    'Great Dane', 'Doberman Pinscher', 'Shih Tzu', 'Chihuahua', 'Pug', 'Border Collie'
  ],
  'Cat': [
    'Persian', 'Maine Coon', 'British Shorthair', 'Siamese', 'Ragdoll', 'Sphynx', 'Bengal',
    'Scottish Fold', 'Abyssinian', 'Russian Blue', 'Norwegian Forest Cat', 'Burmese',
    'Siberian', 'Birman', 'American Shorthair', 'Oriental Shorthair', 'Exotic Shorthair'
  ],
  'Bird': [
    'Parrot', 'Canary', 'Finch', 'Cockatiel', 'Budgerigar', 'Lovebird', 'Cockatoo',
    'African Grey', 'Macaw', 'Conure', 'Dove', 'Pigeon', 'Quaker Parrot', 'Eclectus'
  ],
  'Fish': [
    'Goldfish', 'Betta', 'Guppy', 'Angelfish', 'Neon Tetra', 'Molly', 'Platy', 'Discus',
    'Clownfish', 'Oscar', 'Zebrafish', 'Swordtail', 'Corydoras', 'Rainbowfish'
  ],
  'Reptile': [
    'Bearded Dragon', 'Leopard Gecko', 'Ball Python', 'Corn Snake', 'Chameleon',
    'Green Iguana', 'Red-Eared Slider', 'Blue-Tongued Skink', 'Crested Gecko'
  ],
  'Small Mammal': [
    'Hamster', 'Rabbit', 'Guinea Pig', 'Ferret', 'Gerbil', 'Rat', 'Mouse', 'Chinchilla',
    'Hedgehog', 'Sugar Glider', 'Degu', 'Dwarf Hamster'
  ],
  'Horse': [
    'Arabian', 'Quarter Horse', 'Thoroughbred', 'Appaloosa', 'Morgan', 'Paint',
    'Friesian', 'Clydesdale', 'Shetland Pony', 'Andalusian'
  ],
  'Farm Animal': [
    'Llama', 'Alpaca', 'Chicken', 'Cow', 'Pig', 'Sheep', 'Goat', 'Duck', 'Turkey'
  ],
  'Exotic': [
    'Fennec Fox', 'Capybara', 'Axolotl', 'Kinkajou', 'Serval', 'Wallaby'
  ]
};

  @override
  void initState() {
    super.initState();
    _getUserId();
    if (widget.petId != null) {
      _fetchPetData();
    }
  }

  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _fetchPetData() async {
    try {
      DocumentSnapshot petDoc = await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.petId)
          .get();
      if (petDoc.exists) {
        Map<String, dynamic> data = petDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'];
          _selectedSpecies = data['animalType'];
          _selectedBreed = data['breed'];
          _selectedDate = DateTime.now().subtract(Duration(days: data['age'] * 365));
          _isFemale = data['gender'] == 'Female';
        });
      }
    } catch (e) {
      print("Error fetching pet data: $e");
    }
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  Future<void> _savePetProfile() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final String name = _nameController.text.trim();
    if (name.isEmpty || _selectedSpecies == null || _selectedBreed == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    final Map<String, dynamic> petData = {
      'name': name,
      'animalType': _selectedSpecies,
      'breed': _selectedBreed,
      'age': DateTime.now().year - _selectedDate!.year,
      'gender': _isFemale ? 'Female' : 'Male',
      'userId': _userId,
    };

    try {
      if (widget.petId != null) {
        await FirebaseFirestore.instance.collection('pets').doc(widget.petId).update(petData);
      } else {
        await FirebaseFirestore.instance.collection('pets').add(petData);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet profile saved successfully!')),
      );
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save pet profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.settings),
            onPressed: () {
              if (_isEditing) {
                _savePetProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfilePicture(),
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Name'),
            const SizedBox(height: 16),
            _buildDropdown('Species', _species, _selectedSpecies, (value) {
              setState(() {
                _selectedSpecies = value;
                _selectedBreed = null;
              });
            }),
            const SizedBox(height: 16),
              _buildDropdown(
                'Breed', 
                _selectedSpecies != null && _breeds.containsKey(_selectedSpecies) 
                  ? _breeds[_selectedSpecies]! 
                  : [], 
                _selectedBreed, 
                (value) {
                  setState(() {
                    _selectedBreed = value;
                  });
                }
              ),
            const SizedBox(height: 16),
            _buildDatePicker(context),
            const SizedBox(height: 24),
            _buildGenderSelector(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 1),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: _image != null
                ? ClipOval(
                    child: Image.file(
                      File(_image!.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person_outline, size: 80, color: Colors.grey),
          ),
          if (_isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Icon(Icons.add, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      enabled: _isEditing,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: _isEditing ? onChanged : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: _isEditing ? () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      } : null,
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: _selectedDate != null
                ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                : "",
          ),
          decoration: InputDecoration(
            labelText: 'Age',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: const Icon(Icons.calendar_today, size: 16),
          ),
          enabled: false,
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _isEditing ? () => setState(() => _isFemale = true) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isFemale ? const Color(0xFF65558F) : null,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isFemale) const Icon(Icons.check, color: Colors.white, size: 16),
                    if (_isFemale) const SizedBox(width: 4),
                    Text(
                      'Female',
                      style: TextStyle(color: _isFemale ? Colors.white : null),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _isEditing ? () => setState(() => _isFemale = false) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isFemale ? const Color(0xFF65558F) : null,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isFemale) const Icon(Icons.check, color: Colors.white, size: 16),
                    if (!_isFemale) const SizedBox(width: 4),
                    Text(
                      'Male',
                      style: TextStyle(color: !_isFemale ? Colors.white : null),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}