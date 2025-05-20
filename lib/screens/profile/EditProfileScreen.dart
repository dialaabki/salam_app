// lib/screens/user/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

// Using colors from UserProfileScreen for consistency
const Color mainAppColor = Color(0xFF5588A4);
const Color darkTextColor = Color(0xFF30394F);
const Color lightTextColor = Color(0xFF6A7185);
const Color lightBgColor = Colors.white;

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  String? _gender;
  DateTime? _selectedBirthDate;
  String _birthDateDisplay = 'DD/MM/YYYY';

  // MODIFIED: Gender options limited to Male and Female
  final List<String> _genderOptions = ['Male', 'Female'];

  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.userData['firstName'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.userData['lastName'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userData['phoneNumber'] ?? '',
    );

    _gender = widget.userData['gender'];
    // Ensure that if the existing gender is not 'Male' or 'Female', it defaults or is handled.
    // For simplicity here, if it's something else, the dropdown might not show it as selected
    // or you might want to set it to null or one of the valid options.
    if (_gender != null && !_genderOptions.contains(_gender)) {
      _gender = null; // Or _genderOptions.first;
    }

    if (widget.userData['birthDate'] != null &&
        widget.userData['birthDate'] is Timestamp) {
      _selectedBirthDate = (widget.userData['birthDate'] as Timestamp).toDate();
      _birthDateDisplay = DateFormat('dd/MM/yyyy').format(_selectedBirthDate!);
    } else {
      _birthDateDisplay = 'Select Date of Birth';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // ... (no changes in _selectDate method) ...
    if (_isLoading) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: mainAppColor,
              onPrimary: Colors.white,
              onSurface: darkTextColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: mainAppColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      if (mounted) {
        setState(() {
          _selectedBirthDate = picked;
          _birthDateDisplay = DateFormat('dd/MM/yyyy').format(picked);
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    // ... (no changes in _saveProfile method's logic for saving data) ...
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    Map<String, dynamic> updatedData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'fullName':
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      'phoneNumber': _phoneController.text.trim(),
      'gender': _gender, // This will be "Male" or "Female"
      'birthDate':
          _selectedBirthDate != null
              ? Timestamp.fromDate(_selectedBirthDate!)
              : null,
    };

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(updatedData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      print("Error updating profile: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    // ... (no changes in _buildTextField method) ...
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isOptional ? " (Optional)" : " *"),
        labelStyle: const TextStyle(color: lightTextColor),
        prefixIcon: Icon(icon, color: mainAppColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mainAppColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if (!isOptional && (value == null || value.trim().isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
      style: const TextStyle(color: darkTextColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainAppColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      backgroundColor: lightBgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isOptional: true,
              ),
              const SizedBox(height: 20),

              // Gender Dropdown (MODIFIED to use the updated _genderOptions)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender *',
                  labelStyle: const TextStyle(color: lightTextColor),
                  prefixIcon: Icon(Icons.wc_outlined, color: mainAppColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: mainAppColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                value: _gender,
                items:
                    _genderOptions.map((String value) {
                      // Uses the limited _genderOptions
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: darkTextColor),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 20),

              // Date of Birth Picker
              TextFormField(
                // ... (no changes in Date of Birth TextFormField) ...
                readOnly: true,
                controller: TextEditingController(text: _birthDateDisplay),
                decoration: InputDecoration(
                  labelText: 'Date of Birth *',
                  labelStyle: const TextStyle(color: lightTextColor),
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: mainAppColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: mainAppColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (_selectedBirthDate == null) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                // ... (no changes in ElevatedButton) ...
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainAppColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
