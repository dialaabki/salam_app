import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DoctorSignUpScreen extends StatefulWidget {
  const DoctorSignUpScreen({super.key});

  @override
  State<DoctorSignUpScreen> createState() => _DoctorSignUpScreenState();
}

class _DoctorSignUpScreenState extends State<DoctorSignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();

  String? _gender;
  String _birthDate = 'DD/MM/YYYY';
  String? _selectedDocument;
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF276181)),
          Positioned(
            top: 50 * scaleFactor,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(70),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * scaleFactor,
                  vertical: 20 * scaleFactor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Doctor Sign Up',
                        style: TextStyle(
                          fontFamily: 'DavidLibre',
                          fontWeight: FontWeight.bold,
                          fontSize: 36 * scaleFactor,
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),

                    // Name Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabelWithAsterisk(
                                'First Name',
                                scaleFactor,
                              ),
                              _buildTextField(
                                _firstNameController,
                                scaleFactor,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15 * scaleFactor),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabelWithAsterisk('Last Name', scaleFactor),
                              _buildTextField(_lastNameController, scaleFactor),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // Email
                    _buildLabelWithAsterisk('Email', scaleFactor),
                    _buildTextField(_emailController, scaleFactor),
                    SizedBox(height: 20 * scaleFactor),

                    // Password
                    _buildLabelWithAsterisk('Password', scaleFactor),
                    _buildTextField(
                      _passwordController,
                      scaleFactor,
                      isPassword: true,
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // Phone Number
                    _buildLabel('Phone number', scaleFactor),
                    Row(
                      children: [
                        Container(
                          width: 70 * scaleFactor,
                          height: 55 * scaleFactor,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(
                              25 * scaleFactor,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+962',
                              style: TextStyle(
                                fontSize: 16 * scaleFactor,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10 * scaleFactor),
                        Expanded(
                          child: _buildTextField(_phoneController, scaleFactor),
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // Gender
                    _buildLabelWithAsterisk('Gender', scaleFactor),
                    Row(
                      children: [
                        _buildGenderOption('Male', scaleFactor),
                        SizedBox(width: 20 * scaleFactor),
                        _buildGenderOption('Female', scaleFactor),
                      ],
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // Date of Birth
                    _buildLabelWithAsterisk('Date of birth', scaleFactor),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: double.infinity,
                        height: 55 * scaleFactor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * scaleFactor,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(25 * scaleFactor),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _birthDate,
                            style: TextStyle(
                              fontSize: 16 * scaleFactor,
                              color:
                                  _birthDate == 'DD/MM/YYYY'
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // Document Upload
                    _buildLabelWithAsterisk('Upload Documents', scaleFactor),
                    Text(
                      'Proof of license, certifications, or ID',
                      style: TextStyle(
                        fontFamily: 'Commissioner',
                        fontSize: 14 * scaleFactor,
                        color: const Color(0xFFA6A6A6),
                      ),
                    ),
                    SizedBox(height: 10 * scaleFactor),
                    _buildDocumentDropdown(scaleFactor),
                    _buildUploadButton(scaleFactor),
                    _buildFilePreview(scaleFactor),
                    SizedBox(height: 30 * scaleFactor),

                    // Sign Up Button
                    Center(
                      child: SizedBox(
                        width: 195 * scaleFactor,
                        height: 63 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle sign up with file upload
                            if (_selectedFile != null) {
                              // Add your file upload logic here
                              _uploadFileAndSignUp();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please upload a document'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5588A4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                25 * scaleFactor,
                              ),
                            ),
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontFamily: 'Commissioner',
                              fontWeight: FontWeight.bold,
                              fontSize: 20 * scaleFactor,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFileAndSignUp() async {
    // Implement your file upload and sign up logic here
    // You can access the selected file with _selectedFile
    // and other form fields with their respective controllers

    // Example:
    // final firstName = _firstNameController.text;
    // final lastName = _lastNameController.text;
    // etc...

    // Then upload the file to your server along with other data
  }

  Future<void> _pickFile() async {
    if (_selectedDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a document type first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    if (_selectedDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a document type first')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _fileName = pickedFile.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildFilePreview(double scaleFactor) {
    if (_selectedFile == null) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10 * scaleFactor),
        Text(
          'Selected file:',
          style: TextStyle(
            fontFamily: 'Commissioner',
            fontSize: 14 * scaleFactor,
            color: const Color(0xFFA6A6A6),
          ),
        ),
        SizedBox(height: 5 * scaleFactor),
        Container(
          padding: EdgeInsets.all(10 * scaleFactor),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10 * scaleFactor),
          ),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file, size: 24 * scaleFactor),
              SizedBox(width: 10 * scaleFactor),
              Expanded(
                child: Text(
                  _fileName ?? 'Unknown file',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14 * scaleFactor),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20 * scaleFactor),
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _fileName = null;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10 * scaleFactor),
        ElevatedButton(
          onPressed: _isUploading ? null : _pickFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5588A4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25 * scaleFactor),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scaleFactor,
              vertical: 12 * scaleFactor,
            ),
          ),
          child:
              _isUploading
                  ? SizedBox(
                    width: 20 * scaleFactor,
                    height: 20 * scaleFactor,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file, size: 20 * scaleFactor),
                      SizedBox(width: 8 * scaleFactor),
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
        ),
        SizedBox(height: 5 * scaleFactor),
        Text(
          'or tap to take a photo',
          style: TextStyle(
            fontFamily: 'Commissioner',
            fontSize: 14 * scaleFactor,
            color: const Color(0xFFA6A6A6),
          ),
        ),
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Text(
            'Take Photo',
            style: TextStyle(
              fontFamily: 'Commissioner',
              fontSize: 14 * scaleFactor,
              color: const Color(0xFF5588A4),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Commissioner',
          fontWeight: FontWeight.bold,
          fontSize: 20 * scaleFactor,
          color: const Color(0xFFA6A6A6),
        ),
      ),
    );
  }

  Widget _buildLabelWithAsterisk(String text, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * scaleFactor, bottom: 5 * scaleFactor),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Commissioner',
              fontWeight: FontWeight.bold,
              fontSize: 20 * scaleFactor,
              color: const Color(0xFFA6A6A6),
            ),
          ),
          Text(
            ' *',
            style: TextStyle(color: Colors.red, fontSize: 20 * scaleFactor),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    double scaleFactor, {
    bool isPassword = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55 * scaleFactor,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25 * scaleFactor),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender, double scaleFactor) {
    return Row(
      children: [
        Radio<String>(
          value: gender,
          groupValue: _gender,
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
          activeColor: const Color(0xFF5588A4),
        ),
        Text(gender, style: TextStyle(fontSize: 16 * scaleFactor)),
      ],
    );
  }

  Widget _buildDocumentDropdown(double scaleFactor) {
    return Container(
      width: double.infinity,
      height: 55 * scaleFactor,
      padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(25 * scaleFactor),
      ),
      child: DropdownButton<String>(
        value: _selectedDocument,
        hint: Text(
          'Select document type',
          style: TextStyle(fontSize: 16 * scaleFactor, color: Colors.grey),
        ),
        isExpanded: true,
        underline: Container(),
        items:
            [
              'Medical License',
              'Specialty Certification',
              'ID Proof',
              'Other',
            ].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedDocument = newValue;
          });
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
}
