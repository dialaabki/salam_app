import 'dart:math';
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
    final screenHeight = MediaQuery.of(context).size.height;

    // Base dimensions (for an average iPhone 11/12/13/14/15 size reference)
    const double baseWidth = 375;
    const double baseHeight = 812;

    final widthFactor = screenWidth / baseWidth;
    final heightFactor = screenHeight / baseHeight;
    final scaleFactor = min(widthFactor, heightFactor);

    return Scaffold(
      body: Stack(
        children: [
          // Blue background
          Container(color: const Color(0xFF276181)),

          // Image at the top (centered)
          Positioned(
            top: 20 * heightFactor,
            left: (screenWidth - 287 * widthFactor) / 2,
            child: Image.asset(
              'assets/images/loginpic.png',
              width: 287 * widthFactor,
              height: 253 * heightFactor,
              fit: BoxFit.contain,
            ),
          ),

          // White container with rounded top corners
          Positioned(
            top: (20 + 253) * heightFactor,
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
                padding: EdgeInsets.symmetric(horizontal: 24 * widthFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30 * heightFactor),

                    Padding(
                      padding: EdgeInsets.only(left: 6 * widthFactor),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontFamily: 'DavidLibre',
                          fontWeight: FontWeight.bold,
                          fontSize: 48 * scaleFactor,
                          color: const Color(0xFF276181),
                        ),
                      ),
                    ),

                    SizedBox(height: 35 * heightFactor),
                    _buildLabel('Email', widthFactor, heightFactor),
                    _buildTextField(_emailController, widthFactor, heightFactor),

                    SizedBox(height: 40 * heightFactor),
                    _buildLabel('Password', widthFactor, heightFactor),
                    _buildTextField(_passwordController, widthFactor, heightFactor, obscureText: true),

                    SizedBox(height: 55 * heightFactor),
                    _buildLoginButton(widthFactor, heightFactor),

                    SizedBox(height: 8 * heightFactor),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontFamily: 'Commissioner',
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * scaleFactor,
                            color: const Color(0xFFA79D9D),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 52 * heightFactor),
                    _buildSignupText(widthFactor, scaleFactor),

                    SizedBox(height: 20 * heightFactor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, double widthFactor, double heightFactor) {
    return Padding(
      padding: EdgeInsets.only(left: 8 * widthFactor),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Commissioner',
          fontWeight: FontWeight.bold,
          fontSize: 20 * heightFactor,
          color: const Color(0xFFA6A6A6),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, double widthFactor, double heightFactor, {bool obscureText = false}) {
    return Container(
      margin: EdgeInsets.only(left: 20 * widthFactor),
      width: 335 * widthFactor,
      height: 50 * heightFactor,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20 * widthFactor),
        ),
      ),
    );
  }

  Widget _buildLoginButton(double widthFactor, double heightFactor) {
    return Center(
      child: SizedBox(
        width: 195 * widthFactor,
        height: 55 * heightFactor,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5588A4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            'Log in',
            style: TextStyle(
              fontFamily: 'Commissioner',
              fontWeight: FontWeight.bold,
              fontSize: 20 * heightFactor,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupText(double widthFactor, double scaleFactor) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              fontFamily: 'Commissioner',
              fontWeight: FontWeight.bold,
              fontSize: 12 * scaleFactor,
              color: const Color(0xFFA79D9D),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontFamily: 'Commissioner',
                fontWeight: FontWeight.bold,
                fontSize: 14 * scaleFactor,
                color: const Color(0xFF398BB7),
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
