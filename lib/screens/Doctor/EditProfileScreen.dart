// lib/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting -> Add intl package to pubspec.yaml

class EditProfileScreen extends StatefulWidget {
  // Pass initial data - using a Map for simplicity here
  // A dedicated ProfileModel class would be better
  final Map<String, dynamic> initialProfileData;

  const EditProfileScreen({super.key, required this.initialProfileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController; // Assuming doctor's profile

  String? _selectedGender;
  DateTime? _selectedBirthDate;

  final List<String> _genders = ['Male', 'Female', 'Other']; // Example genders

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProfileData['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialProfileData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialProfileData['phone'] ?? '',
    );
    _specialtyController = TextEditingController(
      text: widget.initialProfileData['specialty'] ?? 'Psychiatrist',
    ); // Default or from data
    _selectedGender = widget.initialProfileData['gender'];

    // Safely parse birth date
    final String? dobString = widget.initialProfileData['birthDate'];
    if (dobString != null) {
      try {
        _selectedBirthDate = DateFormat('dd/MM/yyyy').parse(dobString);
      } catch (e) {
        print("Error parsing initial birth date: $e");
        _selectedBirthDate = null; // Handle parsing error
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ??
          DateTime.now().subtract(
            const Duration(days: 365 * 30),
          ), // Default to 30 years ago approx
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Collect updated data into a Map
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'specialty': _specialtyController.text,
        'gender': _selectedGender,
        'birthDate':
            _selectedBirthDate != null
                ? DateFormat('dd/MM/yyyy').format(
                  _selectedBirthDate!,
                ) // Format date back to string
                : null,
      };
      Navigator.pop(context, updatedData); // Return the map
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF5A9AB8), // Match ProfileScreen header
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Changes',
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter your specialty' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items:
                    _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator:
                    (value) => value == null ? 'Please select a gender' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedBirthDate == null
                          ? 'No birth date selected'
                          : 'Birth Date: ${DateFormat('dd MMM yyyy').format(_selectedBirthDate!)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withOpacity(0.8),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              // Add validator logic externally or enhance the field if date is required
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter an email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004A99),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}