import 'package:flutter/material.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base width for scaling

    return Scaffold(
      body: Stack(
        children: [
          // Blue background
          Container(color: const Color(0xFF276181)),

          // Image at the top (centered)
          Positioned(
            top: 30 * scaleFactor,
            left:
                (screenWidth - 200 * scaleFactor) / 2, // Centered horizontally
            child: Image.asset(
              'assets/images/verificationpic.png', // Your image path
              width: 200 * scaleFactor,
              height: 200 * scaleFactor,
              fit: BoxFit.contain,
            ),
          ),

          // White container with rounded top corners
          Positioned(
            top: 230 * scaleFactor, // Adjusted for image
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
                  vertical: 30 * scaleFactor,
                ),
                child: Column(
                  children: [
                    // Title
                    Text(
                      'VERIFY',
                      style: TextStyle(
                        fontFamily: 'DavidLibre',
                        fontWeight: FontWeight.bold,
                        fontSize: 40 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),
                    SizedBox(height: 10 * scaleFactor),

                    // Subtitle
                    Text(
                      'Account\nVerification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Commissioner',
                        fontWeight: FontWeight.bold,
                        fontSize: 30 * scaleFactor,
                        color: const Color(0xFF276181),
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),

                    // Instruction text
                    Text(
                      'Please enter the 4 digit code sent to\nYour Email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Commissioner',
                        fontSize: 18 * scaleFactor,
                        color: const Color(0xFFA6A6A6),
                      ),
                    ),
                    SizedBox(height: 40 * scaleFactor),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        4,
                        (index) => SizedBox(
                          width: 60 * scaleFactor,
                          child: TextField(
                            controller: _codeControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: 24 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  15 * scaleFactor,
                                ),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5588A4),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  15 * scaleFactor,
                                ),
                                borderSide: const BorderSide(
                                  color: Color(0xFF5588A4),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length == 1 && index < 3) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_focusNodes[index + 1]);
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(_focusNodes[index - 1]);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * scaleFactor),

                    // Resend code text button
                    TextButton(
                      onPressed: () {
                        // Handle resend code
                      },
                      child: Text(
                        'Resend code',
                        style: TextStyle(
                          fontFamily: 'Commissioner',
                          fontSize: 16 * scaleFactor,
                          color: const Color(0xFF5588A4),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 40 * scaleFactor),

                    // Verify button
                    Center(
                      child: SizedBox(
                        width: 195 * scaleFactor,
                        height: 63 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle verification
                            final verificationCode =
                                _codeControllers
                                    .map((controller) => controller.text)
                                    .join();
                            print('Verification code: $verificationCode');
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
                            'Verify',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
