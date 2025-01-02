import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PetProfileWidget extends StatefulWidget {
  const PetProfileWidget({super.key});

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

  final List<String> _species = ['Dog', 'Cat', 'Bird', 'Fish', 'Other'];
  final Map<String, List<String>> _breeds = {
    'Dog': ['Labrador', 'German Shepherd', 'Bulldog', 'Poodle'],
    'Cat': ['Persian', 'Siamese', 'Maine Coon', 'British Shorthair'],
    'Bird': ['Parrot', 'Canary', 'Finch', 'Cockatiel'],
    'Fish': ['Goldfish', 'Betta', 'Guppy', 'Angelfish'],
    'Other': ['Hamster', 'Rabbit', 'Guinea Pig', 'Ferret'],
  };

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pet Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildProfilePicture(),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Name'),
              const SizedBox(height: 16),
              _buildDropdown(
                'Species',
                _species,
                _selectedSpecies,
                (value) {
                  setState(() {
                    _selectedSpecies = value;
                    _selectedBreed = null; // Reset breed when species changes
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Breed',
                _selectedSpecies != null ? _breeds[_selectedSpecies]! : [],
                _selectedBreed,
                (value) {
                  setState(() {
                    _selectedBreed = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDatePicker(context),
              const SizedBox(height: 24),
              _buildGenderSelector(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
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
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
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
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
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
      },
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
              onTap: () => setState(() => _isFemale = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isFemale ? Colors.blue : null,
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
              onTap: () => setState(() => _isFemale = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isFemale ? Colors.blue : null,
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        // Implement save functionality
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}