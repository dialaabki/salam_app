import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base width for scaling (iPhone 6/7/8)

    return Scaffold(
      body: Stack(
        children: [
          // Blue background
          Container(
            color: const Color(0xFF276181),
          ),

          // Image at the top (centered)
          Positioned(
            top: 19 * scaleFactor,
            left: (screenWidth - 287 * scaleFactor) / 2, // Centered horizontally
            child: Image.asset(
              'assets/images/login_image.png',
              width: 287 * scaleFactor,
              height: 253 * scaleFactor,
              fit: BoxFit.contain,
            ),
          ),

          // White container with rounded top corners
          Positioned(
            top: (19 + 253) * scaleFactor,
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
                padding: EdgeInsets.symmetric(horizontal: 24 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30 * scaleFactor),

                    // "Log in" text
                    Padding(
                      padding: EdgeInsets.only(left: 6 * scaleFactor),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontFamily: 'DavidLibre',
                          fontWeight: FontWeight.bold,
                          fontSize: 60 * scaleFactor * 0.8, // Slightly reduced
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),

                    SizedBox(height: 35 * scaleFactor),

                    // Email label
                    Padding(
                      padding: EdgeInsets.only(left: 8 * scaleFactor),
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: 'Commissioner',
                          fontWeight: FontWeight.bold,
                          fontSize: 25 * scaleFactor * 0.8,
                          color: const Color(0xFFA6A6A6),
                        ),
                      ),
                    ),

                    SizedBox(height: 28 * scaleFactor),

                    // Email input field
                    Container(
                      margin: EdgeInsets.only(left: 40 * scaleFactor),
                      width: 335 * scaleFactor,
                      height: 55 * scaleFactor,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEEEEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25 * scaleFactor),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * scaleFactor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 46 * scaleFactor),

                    // Password label
                    Padding(
                      padding: EdgeInsets.only(left: 14 * scaleFactor),
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontFamily: 'Commissioner',
                          fontWeight: FontWeight.bold,
                          fontSize: 25 * scaleFactor * 0.8,
                          color: const Color(0xFFA6A6A6),
                        ),
                      ),
                    ),

                    SizedBox(height: 25 * scaleFactor),

                    // Password input field
                    Container(
                      margin: EdgeInsets.only(left: 40 * scaleFactor),
                      width: 335 * scaleFactor,
                      height: 55 * scaleFactor,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFEEEEEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25 * scaleFactor),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20 * scaleFactor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 55 * scaleFactor),

                    // Login button
                    Center(
                      child: SizedBox(
                        width: 195 * scaleFactor,
                        height: 63 * scaleFactor,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle login
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5588A4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25 * scaleFactor),
                            ),
                          ),
                          child: Text(
                            'Log in',
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

                    SizedBox(height: 8 * scaleFactor),

                    // Forgot password text
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        child: Text(
                          'Forget you password?',
                          style: TextStyle(
                            fontFamily: 'Commissioner',
                            fontWeight: FontWeight.bold,
                            fontSize: 15 * scaleFactor * 0.8,
                            color: const Color(0xFFA79D9D),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 52 * scaleFactor),

                    // Don't have account text with Sign Up button
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontFamily: 'Commissioner',
                              fontWeight: FontWeight.bold,
                              fontSize: 15 * scaleFactor * 0.8,
                              color: const Color(0xFFA79D9D),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Handle sign up
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Commissioner',
                                fontWeight: FontWeight.bold,
                                fontSize: 17 * scaleFactor * 0.8,
                                color: const Color(0xFF398BB7),
                              ),
                            ),
                          ),
                        ],
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}