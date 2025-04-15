// File: lib/screens/activities/breathing_activity_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

// Import the completion screen and the shared bottom nav bar
import 'BreathingCompletionScreen.dart'; // Ensure filename case matches yours
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed

// Enum to represent the current breathing state
enum BreathingState { inhale, exhale, hold }

class BreathingActivityScreen extends StatefulWidget {
  // Optional: Add static const routeName = '/breathingActivity';

  // Add const constructor
  const BreathingActivityScreen({super.key});

  @override
  _BreathingActivityScreenState createState() =>
      _BreathingActivityScreenState();
}

class _BreathingActivityScreenState extends State<BreathingActivityScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller to manage the timing and progress of animations
  late AnimationController _controller;
  // Animation for the height of the vertical progress bar
  late Animation<double> _barAnimation;
  // Animation for subtle scaling/movement of the lung image
  late Animation<double> _lungAnimation;

  // State variables
  BreathingState _currentState = BreathingState.inhale; // Start with inhale
  int _breathCount = 0; // Counter for completed breaths
  final int _maxBreaths = 5; // Target number of breaths
  Timer? _activityTimer; // Timer to sequence breathing phases
  Timer? _navTimer; // Timer instance potentially passed to nav bar

  // Define durations for each phase (customize as needed)
  final Duration _inhaleDuration = Duration(seconds: 4);
  final Duration _exhaleDuration = Duration(seconds: 6);
  // Optional hold durations if you want to add pauses
  // final Duration _holdAfterInhaleDuration = Duration(seconds: 2);
  // final Duration _holdAfterExhaleDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(vsync: this); // Duration set dynamically

    // Define the bar animation (0.0 to 1.0 for height factor)
    _barAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ), // Add trailing comma
    ); // Add trailing comma

    // Define the lung animation (subtle scaling)
    _lungAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.08),
        weight: 50,
      ), // Scale up
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0),
        weight: 50,
      ), // Scale down
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    ); // Add trailing comma

    _startCycle(); // Begin the first breathing cycle
  }

  // Stops timers and cleans up resources before navigating away
  void _stopActivityAndNavigate(Function navigationAction) {
    _activityTimer?.cancel();
    _navTimer?.cancel();
    // Important: Dispose controller *after* potential navigation
    // to avoid errors if build is called during transition.
    // Alternatively, stop it here and dispose in dispose() method.
    _controller.stop();
    // Ensure navigation happens after current frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        navigationAction();
      }
    });
  }

  // Starts a new breathing cycle (inhale -> exhale -> next cycle/complete)
  void _startCycle() {
    // Ensure the widget is still mounted before proceeding
    if (!mounted) return;

    // Check if the target number of breaths is reached
    if (_breathCount >= _maxBreaths) {
      _stopActivityAndNavigate(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BreathingCompletionScreen(),
          ), // Add trailing comma
        ); // Add trailing comma
      });
      return; // Exit the function
    }

    // Start Inhale Phase
    if (mounted) {
      setState(
        () => _currentState = BreathingState.inhale,
      ); // Update state text/image
      _controller.duration = _inhaleDuration; // Set animation duration
      _controller.forward(from: 0.0); // Start animation (bar up, lungs expand)
    }

    // Schedule the start of the exhale phase after inhale duration
    _activityTimer = Timer(_inhaleDuration, _startExhale);
  }

  // Starts the exhale phase
  void _startExhale() {
    if (!mounted) return; // Check if mounted

    // Start Exhale Phase
    setState(
      () => _currentState = BreathingState.exhale,
    ); // Update state text/image
    _controller.duration = _exhaleDuration; // Set animation duration
    _controller.reverse(
      from: 1.0,
    ); // Reverse animation (bar down, lungs shrink)

    // Schedule the start of the *next* cycle after exhale duration
    _activityTimer = Timer(_exhaleDuration, () {
      if (!mounted) return;
      setState(() => _breathCount++); // Increment breath counter
      _startCycle(); // Start the next full inhale->exhale cycle
    }); // Add trailing comma
  }

  @override
  void dispose() {
    // Clean up resources when the screen is removed
    _controller.dispose(); // Dispose animation controller FIRST
    _activityTimer?.cancel(); // Cancel any active timers
    _navTimer?.cancel();
    super.dispose();
  }

  // Helper function to get the correct lung image based on the current state
  String _getLungImage() {
    switch (_currentState) {
      case BreathingState.inhale:
        return 'assets/images/lungs_inhale.png';
      case BreathingState.exhale:
        return 'assets/images/lungs_exhale.png';
      case BreathingState.hold:
        return 'assets/images/lungs_exhale.png'; // Choose appropriate hold image
    }
  }

  // Helper function to get the status text based on the current state
  String _getStatusText() {
    switch (_currentState) {
      case BreathingState.inhale:
        return 'Breathe In';
      case BreathingState.exhale:
        return 'Breathe Out';
      case BreathingState.hold:
        return 'Hold'; // Status text for hold state
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors used in this screen
    final Color primaryTextColor = Color(0xFF1E4B5F);
    final Color barColor = Color(0xFF3E8A9A);
    final Color circleBgColor = Color(0xFFCDEEFF).withOpacity(0.4);
    final Color outerCircleColor = Color(0xFFB6E0FF).withOpacity(0.5);
    // Use primary text color for back button for consistency
    final Color backButtonColor = primaryTextColor;

    return Scaffold(
      // Prevent back gesture while activity is running? Optional.
      // WillPopScope might be needed for more complex back handling.
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/breathing_bg.png',
              fit: BoxFit.cover,
            ), // Add trailing comma
          ), // Add trailing comma
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                // Main layout column
                children: [
                  Spacer(flex: 2), // Push content down from the top
                  // Central Circle containing animated lungs
                  Container(
                    width:
                        MediaQuery.of(context).size.width *
                        0.7, // Circle size relative to screen
                    height: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: outerCircleColor,
                        width: 15,
                      ), // Outer ring
                      color: circleBgColor, // Semi-transparent background
                    ), // Add trailing comma
                    child: Center(
                      // Use AnimatedBuilder to react to lung animation changes
                      child: AnimatedBuilder(
                        animation: _lungAnimation,
                        builder: (context, child) {
                          // Apply scaling transformation based on animation value
                          return Transform.scale(
                            scale: _lungAnimation.value,
                            child: Image.asset(
                              _getLungImage(), // Get the correct lung image for the state
                              height:
                                  MediaQuery.of(context).size.width *
                                  0.35, // Image size
                            ), // Add trailing comma
                          ); // Add trailing comma
                        }, // Add trailing comma
                      ), // Add trailing comma
                    ), // Add trailing comma
                  ), // Add trailing comma
                  Spacer(flex: 1), // Space below the circle
                  // Row containing the animated bar and status text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // Align bar to bottom
                    children: [
                      // Vertical Bar Container (acts as the track)
                      Container(
                        width: 25, // Bar width
                        height: 150, // Max bar height
                        decoration: BoxDecoration(
                          color: barColor.withOpacity(0.2), // Track color
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Add trailing comma
                        ), // Add trailing comma
                        alignment: Alignment.bottomCenter, // Fill from bottom
                        // Use AnimatedBuilder to react to bar animation changes
                        child: AnimatedBuilder(
                          animation: _barAnimation,
                          builder: (context, child) {
                            // Use FractionallySizedBox to control the height
                            return FractionallySizedBox(
                              heightFactor:
                                  _barAnimation
                                      .value, // Height based on animation
                              child: Container(
                                // The filled part of the bar
                                decoration: BoxDecoration(
                                  color: barColor, // Active bar color
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ), // Add trailing comma
                                ), // Add trailing comma
                              ), // Add trailing comma
                            ); // Add trailing comma
                          }, // Add trailing comma
                        ), // Add trailing comma
                      ), // Add trailing comma
                      SizedBox(width: 25), // Space between bar and text
                      // Status Text (Breathe In / Breathe Out / Hold)
                      Text(
                        _getStatusText(), // Get text based on current state
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ), // Add trailing comma
                      ), // Add trailing comma
                    ], // Add trailing comma
                  ), // Add trailing comma
                  Spacer(flex: 3), // Push content up from the bottom
                ], // Add trailing comma
              ), // Add trailing comma
            ), // Add trailing comma
          ), // Add trailing comma
          // --- ADDED Back Button ---
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                5, // Position below status bar
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, // Or Icons.arrow_back
                color: backButtonColor, // Use defined color
              ), // Add trailing comma
              tooltip: 'Back', // Simple tooltip
              onPressed: () {
                // Stop animation/timers and navigate back
                _stopActivityAndNavigate(() {
                  Navigator.pop(context);
                });
              }, // Add trailing comma
            ), // Add trailing comma
          ), // Add trailing comma

          // --- END Back Button ---
        ], // Add trailing comma
      ), // Add trailing comma
      // --- FIXED Bottom Nav Bar Call ---
      // Use the AppBottomNavBar class constructor
      bottomNavigationBar: AppBottomNavBar(
        navigationTimer: _navTimer,
      ), // Pass timer if needed by nav bar
      // --- END FIX ---
    ); // End Scaffold
  }
}
