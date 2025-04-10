// File: lib/screens/activities/walking_activity_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed

class WalkingActivityScreen extends StatefulWidget {
  const WalkingActivityScreen({super.key}); // Use Key?

  @override
  State<WalkingActivityScreen> createState() => _WalkingActivityScreenState();
}

class _WalkingActivityScreenState extends State<WalkingActivityScreen> {
  int _selectedDuration = 30;
  int _remainingSeconds = 0;
  Timer? _timer;
  Timer? _navTimer; // Timer specifically for nav bar if needed
  int _screenState = 0; // 0: Selection, 1: Timer, 2: Completion

  @override
  void dispose() {
    _timer?.cancel();
    _navTimer?.cancel(); // Cancel nav timer too
    super.dispose();
  }

  void _startTimer() {
    if (!mounted) return;
    setState(() {
      _remainingSeconds = _selectedDuration * 60;
      _screenState = 1;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _screenState = 2;
          _remainingSeconds = 0;
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildBody() {
    switch (_screenState) {
      case 1:
        return _buildTimerScreen();
      case 2:
        return _buildCompletionScreen();
      case 0:
      default:
        return _buildDurationSelectionScreen();
    }
  }

  Color _getAppBarIconColor() {
    switch (_screenState) {
      case 1:
      case 2:
        return const Color(0xFF5588A4); // Timer/Completion screens
      case 0:
      default:
        return Colors.white; // Selection screen (with image bg)
    }
  }

  // Handles back navigation based on current screen state
  void _handleBackButton() {
    if (!mounted) return;
    _timer?.cancel(); // Always cancel activity timer on back

    setState(() {
      if (_screenState == 1 || _screenState == 2) {
        // If on Timer or Completion, go back to Duration Selection
        _screenState = 0;
        _remainingSeconds = 0;
        // _selectedDuration = 30; // Optionally reset duration
      } else {
        // If on Duration Selection, pop the entire screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows body to go behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: _getAppBarIconColor(),
          ), // Consistent back icon
          tooltip: 'Back',
          onPressed: _handleBackButton, // Use the back handler logic
        ),
      ),
      body: _buildBody(), // Builds content based on _screenState
      // --- FIXED Bottom Nav Bar Call ---
      bottomNavigationBar: AppBottomNavBar(
        navigationTimer: _navTimer,
      ), // Use external widget
      // --- END FIX ---
    );
  }

  // Screen 1: Duration Selection (_screenState == 0)
  Widget _buildDurationSelectionScreen() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/walking_background.png',
          ), // Ensure path is correct
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        // Add SafeArea here for content
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Walking Activity',
                style: GoogleFonts.cormorant(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5588A4),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Every step you take is progress!',
                style: TextStyle(fontSize: 16, color: Color(0xFF5588A4)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Walk Duration',
                style: TextStyle(fontSize: 20, color: Color(0xFF5588A4)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove,
                      color: Color(0xFF5588A4),
                      size: 30,
                    ),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        if (_selectedDuration > 5) {
                          _selectedDuration -= 5;
                        }
                      });
                    },
                  ),
                  Text(
                    '$_selectedDuration min',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5588A4),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF5588A4),
                      size: 30,
                    ),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        if (_selectedDuration < 120) {
                          _selectedDuration += 5;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5588A4),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Screen 2: Timer Running (_screenState == 1)
  Widget _buildTimerScreen() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        // Add SafeArea here
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5588A4),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'REMINDER!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF5588A4),
                    // Replace with GoogleFonts or ensure font is in assets/pubspec
                    fontFamily: 'Times New Roman', // Example placeholder
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Every step you take is a step toward\na healthier, happier you.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorant(
                    fontSize: 18,
                    color: const Color.fromARGB(255, 48, 202, 233),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  // Allow image to take remaining space
                  child: Image.asset(
                    'assets/images/W_activity_image.png', // Ensure path is correct
                    fit: BoxFit.contain, // Contain ensures whole image fits
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Error loading image',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Space below image
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Screen 3: Completion Screen (_screenState == 2)
  Widget _buildCompletionScreen() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        // Add SafeArea here
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Well done!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5588A4),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Every step you take matters! \n Stay hydrated',
                  textAlign: TextAlign.center, // Center align text
                  style: TextStyle(fontSize: 20, color: Color(0xFF5588A4)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  // Allow image to take remaining space
                  child: Image.asset(
                    'assets/images/WW_activity_image.png', // Ensure path is correct
                    fit: BoxFit.contain, // Use contain to ensure visibility
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Error loading image',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _screenState = 0;
                      _remainingSeconds = 0;
                      // _selectedDuration = 30; // Optionally reset duration
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5588A4),
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20), // Space below button
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Removed internal _buildBottomNavBar method
}
