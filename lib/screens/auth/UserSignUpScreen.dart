import 'package:flutter/material.dart';

class UserSignUpScreen extends StatefulWidget {
  const UserSignUpScreen({super.key});

  @override
  State<UserSignUpScreen> createState() => _UserSignUpScreenState();
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specifyController = TextEditingController();

  String? _gender;
  String? _substanceUse;
  String _birthDate = 'DD/MM/YYYY';

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
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'DavidLibre',
                          fontWeight: FontWeight.bold,
                          fontSize: 40 * scaleFactor,
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // First Name with red asterisk
                    _buildLabelWithAsterisk('First Name', scaleFactor),
                    _buildTextField(_firstNameController, scaleFactor),
                    SizedBox(height: 15 * scaleFactor),

                    // Last Name with red asterisk
                    _buildLabelWithAsterisk('Last Name', scaleFactor),
                    _buildTextField(_lastNameController, scaleFactor),
                    SizedBox(height: 15 * scaleFactor),

                    // Email with red asterisk
                    _buildLabelWithAsterisk('Email', scaleFactor),
                    _buildTextField(_emailController, scaleFactor),
                    SizedBox(height: 15 * scaleFactor),

                    // Password with red asterisk
                    _buildLabelWithAsterisk('Password', scaleFactor),
                    _buildTextField(
                      _passwordController,
                      scaleFactor,
                      isPassword: true,
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    // Phone Number (optional)
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
                    SizedBox(height: 15 * scaleFactor),

                    // Gender with red asterisk
                    Row(
                      children: [
                        Text(
                          'Gender',
                          style: TextStyle(
                            fontFamily: 'Commissioner',
                            fontWeight: FontWeight.bold,
                            fontSize: 20 * scaleFactor,
                            color: const Color(0xFFA6A6A6),
                          ),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20 * scaleFactor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5 * scaleFactor),
                    Row(
                      children: [
                        _buildRadioButton('Male', scaleFactor),
                        SizedBox(width: 20 * scaleFactor),
                        _buildRadioButton('Female', scaleFactor),
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    // Date of Birth with red asterisk
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
                    SizedBox(height: 15 * scaleFactor),

                    // Substance use question with red asterisk
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Commissioner',
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * scaleFactor,
                          color: const Color(0xFFA6A6A6),
                        ),
                        children: [
                          const TextSpan(
                            text: '* ',
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text:
                                'Do you currently use any substances or medications that can alter your mood, perception, or mental state?',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5 * scaleFactor),
                    Row(
                      children: [
                        _buildSubstanceRadioButton('Yes', scaleFactor),
                        SizedBox(width: 20 * scaleFactor),
                        _buildSubstanceRadioButton('No', scaleFactor),
                      ],
                    ),
                    SizedBox(height: 15 * scaleFactor),

                    if (_substanceUse == 'Yes') ...[
                      _buildTextField(
                        _specifyController,
                        scaleFactor,
                        hintText: 'please specify',
                      ),
                      SizedBox(height: 15 * scaleFactor),
                    ],

                    Center(
                      child: SizedBox(
                        width: 195 * scaleFactor,
                        height: 63 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {},
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
                              fontSize: 25 * scaleFactor * 0.8,
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
    String hintText = '',
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55 * scaleFactor,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
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

  Widget _buildRadioButton(String value, double scaleFactor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: _gender,
          onChanged: (String? newValue) {
            setState(() {
              _gender = newValue;
            });
          },
          activeColor: const Color(0xFF5588A4),
        ),
        Text(value, style: TextStyle(fontSize: 16 * scaleFactor)),
      ],
    );
  }

  Widget _buildSubstanceRadioButton(String value, double scaleFactor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: _substanceUse,
          onChanged: (String? newValue) {
            setState(() {
              _substanceUse = newValue;
            });
          },
          activeColor: const Color(0xFF5588A4),
        ),
        Text(value, style: TextStyle(fontSize: 16 * scaleFactor)),
      ],
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
        _birthDate = "${picked.day}/${picked.month}/${picked.year}";
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
    _specifyController.dispose();
    super.dispose();
  }
}
