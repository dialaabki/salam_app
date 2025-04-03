// self_assessment_screen.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Import for Future

// Import all your assessment screen files (ensure correct paths)
// Make sure these files exist and the paths are correct relative to this file
import 'DepressionScreen.dart'; // Example: Replace with your actual file names if different
import 'anxietyscreen.dart';
import 'OCDScreen.dart';
import 'BipolarScreen.dart';
import 'ADHDScreen.dart';
import 'AddictionScreen.dart';

// Import the actual FinalResultsScreen (ensure correct path)
import 'FinalResultsScreen.dart'; // Example: Replace if needed

// Placeholder screen if skipped
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Home'),
        backgroundColor: const Color(0xFF5588A4), // Consistent header color
      ),
      body: const Center(child: Text('Assessment Skipped / Main App Area')),
    );
  }
}

// --- StatefulWidget ---
class SelfAssessmentScreen extends StatefulWidget {
  const SelfAssessmentScreen({super.key});

  @override
  State<SelfAssessmentScreen> createState() => _SelfAssessmentScreenState();
}

class _SelfAssessmentScreenState extends State<SelfAssessmentScreen> {
  // Define Colors based on image
  final Color headerColor = const Color(0xFF5588A4);
  final Color contentBgColor = Colors.white;
  final Color primaryTextColor = const Color(0xFF276181);
  final Color secondaryTextColor = Colors.black54;
  final Color stepItemBgColor = const Color(0xFFF8F8F8);
  final Color stepTextColor = Colors.grey;
  final Color stepTitleColor = Colors.black87;
  final Color checkmarkColorFilled = Colors.green;
  final Color checkmarkColorEmpty = Colors.grey.shade400;
  final Color skipLinkColor = const Color(0xFF5588A4);

  // --- State Variables ---
  int _highestCompletedStepIndex = -1; // Start with none completed
  final Map<String, dynamic> _allAssessmentResults =
      {}; // To store results from each step

  // --- Data for the Steps ---
  final List<Map<String, dynamic>> _assessmentSteps = [
    {
      'key': 'depression',
      'step': 'Step-1',
      'title': 'Depression',
      'screenBuilder': (context) => const DepressionScreen(),
    },
    {
      'key': 'anxiety',
      'step': 'Step-2',
      'title': 'Anxiety',
      'screenBuilder': (context) => const AnxietyScreen(),
    },
    {
      'key': 'ocd',
      'step': 'Step-3',
      'title': 'OCD',
      'screenBuilder': (context) => const OCDScreen(),
    },
    {
      'key': 'bipolar',
      'step': 'Step-4',
      'title': 'Bipolar Disorder',
      'screenBuilder': (context) => const BipolarScreen(),
    },
    {
      'key': 'adhd',
      'step': 'Step-5',
      'title': 'ADHD',
      'screenBuilder': (context) => const ADHDScreen(),
    },
    {
      'key': 'addiction',
      'step': 'Step-6',
      'title': 'Addiction',
      'screenBuilder': (context) => const AddictionScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    print(
      "[SelfAssessmentScreen] initState called. Initial state: highestCompleted=$_highestCompletedStepIndex, results=${_allAssessmentResults.keys}", // Log keys for brevity
    );
    // TODO: Load saved state if implementing persistence
  }

  // --- Method to Handle Navigation and State Update (with logging) ---
  Future<void> _navigateToStep(BuildContext context, int stepIndex) async {
    print(
      "[SelfAssessmentScreen] _navigateToStep called for index: $stepIndex. Current highestCompleted: $_highestCompletedStepIndex",
    );

    // Check if the step is allowed (current or next)
    if (stepIndex <= _highestCompletedStepIndex + 1) {
      final stepData = _assessmentSteps[stepIndex];
      final String stepKey = stepData['key'];
      Widget Function(BuildContext) screenBuilder = stepData['screenBuilder'];

      print(
        "[SelfAssessmentScreen] Navigating to Step ${stepIndex + 1} ('$stepKey')...",
      );

      final result = await Navigator.push<dynamic>(
        context,
        MaterialPageRoute(builder: screenBuilder),
      );

      print(
        "[SelfAssessmentScreen] --- Returned from Step ${stepIndex + 1} ('$stepKey') --- Result: $result (Type: ${result.runtimeType})",
      );

      // Check if the screen popped AND returned valid data (not false or null)
      if (result != null && result != false) {
        print("[SelfAssessmentScreen] Result is valid, processing...");
        setState(() {
          print(
            "[SelfAssessmentScreen] setState: Storing result for '$stepKey'.",
          );
          _allAssessmentResults[stepKey] = result;
          // Update completion index only if it's the current furthest step or beyond
          if (stepIndex >= _highestCompletedStepIndex) {
            print(
              "[SelfAssessmentScreen] setState: Updating highestCompletedIndex from $_highestCompletedStepIndex to $stepIndex.",
            );
            _highestCompletedStepIndex = stepIndex;
          } else {
            print(
              "[SelfAssessmentScreen] setState: Step $stepIndex already completed or not the highest, index not changed.",
            );
          }
          print(
            "[SelfAssessmentScreen] setState: Results map updated: ${_allAssessmentResults.keys}",
          );
          print(
            "[SelfAssessmentScreen] setState: Highest completed index updated: $_highestCompletedStepIndex",
          );
        });
        print("[SelfAssessmentScreen] setState call finished.");

        // TODO: Save state here if implementing save/resume

        // Check if all steps are now complete
        if (_highestCompletedStepIndex == _assessmentSteps.length - 1) {
          print(
            "[SelfAssessmentScreen] All steps complete! Navigating to results.",
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      FinalResultsScreen(allResults: _allAssessmentResults),
            ),
          );
        } else {
          print(
            "[SelfAssessmentScreen] Step ${stepIndex + 1} completed, but not the last step yet.",
          );
        }
      } else if (result == false) {
        print(
          "[SelfAssessmentScreen] Step ${stepIndex + 1} ('$stepKey') was exited with 'false' (likely back button). State not changed.",
        );
      } else {
        print(
          "[SelfAssessmentScreen] Step ${stepIndex + 1} ('$stepKey') returned null result. State not changed.",
        );
      }
    } else {
      print(
        "[SelfAssessmentScreen] Step ${stepIndex + 1} access denied. highestCompleted=$_highestCompletedStepIndex",
      );
      // Show user-friendly message indicating which step to complete next
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // User sees 1-based index, show the *next* required step
          content: Text(
            'Please complete Step ${_highestCompletedStepIndex + 2} first.',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
    print(
      "[SelfAssessmentScreen] _navigateToStep finished for index: $stepIndex.",
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
      "[SelfAssessmentScreen] build method called. highestCompleted=$_highestCompletedStepIndex, resultsKeys=${_allAssessmentResults.keys}",
    );
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: headerColor, // Background for the whole screen initially
      body: SingleChildScrollView(
        // Allows content to scroll if it overflows
        child: Column(
          children: [
            // --- HEADER ---
            // Uses the revised header widget (Attempt 3) below
            _buildHeader(screenHeight, screenWidth),

            // --- CONTENT AREA ---
            _buildContentArea(context),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // REVISED HEADER WIDGET (Attempt 3 - Larger Right Image - Incorporated Here)
  // ==========================================================
  Widget _buildHeader(double screenHeight, double screenWidth) {
    // Define consistent padding/offset values
    const double horizontalPadding = 25.0;
    const double bottomTextPadding = 20.0;
    const double spaceAboveText =
        5.0; // Space between top of text and bottom of left image

    // Calculate approximate text height (adjust if needed)
    const double approxTextHeight = 30.0;
    final double leftImageBottom =
        bottomTextPadding + approxTextHeight + spaceAboveText;

    // --- Adjustments for Larger Right Image ---
    const double rightImageTopPadding = 10.0; // Reduced top padding
    const double rightImageRightPadding = 15.0; // Reduced right padding
    final double rightImageHeight =
        screenHeight * 0.22; // Significantly increased height

    return Container(
      color: headerColor,
      // Keep header height or adjust slightly if needed for the larger image
      height: screenHeight * 0.28,
      width: double.infinity,
      child: Stack(
        clipBehavior:
            Clip.none, // Allow potential overflow if image is very large
        children: [
          // --- Left Image (Positioned above Text - unchanged from previous attempt) ---
          Positioned(
            bottom: leftImageBottom,
            left: horizontalPadding,
            height: screenHeight * 0.12, // Keep this relatively small
            child: Image.asset(
              'assets/images/selfassepic2.png', // Ensure this path is correct
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading selfassepic2.png: $error");
                return const Icon(Icons.error, color: Colors.white, size: 50);
              },
            ),
          ),

          // --- Right Image (Top Right Corner - MADE LARGER) ---
          Positioned(
            // Use adjusted padding values
            top: rightImageTopPadding,
            right: rightImageRightPadding,
            // Use significantly increased height
            height: rightImageHeight,
            // Optionally set width too if aspect ratio needs controlling, but height + contain is usually enough
            // width: screenWidth * 0.3, // Example: uncomment and adjust if needed
            child: Image.asset(
              'assets/images/selfassepic1.png', // Ensure this path is correct
              fit: BoxFit.contain, // Keeps aspect ratio, fits within bounds
              errorBuilder: (context, error, stackTrace) {
                print("Error loading selfassepic1.png: $error");
                return const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 60,
                ); // Slightly larger error icon
              },
            ),
          ),

          // --- Text (Remains near bottom-left - unchanged) ---
          Positioned(
            bottom: bottomTextPadding,
            left: horizontalPadding,
            child: Text(
              'Self Assessment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ==========================================================
  // END OF REVISED HEADER WIDGET
  // ==========================================================

  Widget _buildContentArea(BuildContext context) {
    return Container(
      // Add padding inside the white container
      padding: const EdgeInsets.only(
        top: 30.0,
        left: 20.0,
        right: 20.0,
        bottom: 30.0, // Add bottom padding for scroll spacing
      ),
      // Decorate the content area
      decoration: BoxDecoration(
        color: contentBgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center items horizontally
        children: [
          Text(
            'Take a Step Towards\nUnderstanding Your Mental Health',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 15.0),
          Text(
            'Your Mental Health Matters – Answer\nAll Questions for Accurate Insights',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: secondaryTextColor,
              height: 1.4, // Line spacing
            ),
          ),
          const SizedBox(height: 35.0),

          // --- Steps List ---
          Column(
            // Generates the list of step items dynamically
            children: List.generate(_assessmentSteps.length, (index) {
              final stepData = _assessmentSteps[index];
              bool isCompleted = _allAssessmentResults.containsKey(
                stepData['key'],
              );
              bool isEnabled =
                  isCompleted || index == _highestCompletedStepIndex + 1;

              print(
                "[SelfAssessmentScreen] Generating Step Item ${index + 1} ('${stepData['title']}'): isCompleted=$isCompleted, isEnabled=$isEnabled",
              );

              return _buildStepItem(
                context: context,
                step: stepData['step']!,
                title: stepData['title']!,
                isCompleted: isCompleted,
                isEnabled: isEnabled,
                onTap: () => _navigateToStep(context, index),
              );
            }),
          ),
          const SizedBox(height: 30.0),
          _buildSkipLink(context),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required String step,
    required String title,
    required bool isCompleted,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final Color currentStepTextColor =
        isEnabled ? stepTextColor : stepTextColor.withOpacity(0.5);
    final Color currentTitleColor =
        isEnabled ? stepTitleColor : stepTitleColor.withOpacity(0.5);
    final Color currentCheckmarkColor =
        isCompleted
            ? checkmarkColorFilled
            : (isEnabled
                ? checkmarkColorEmpty
                : checkmarkColorEmpty.withOpacity(0.5));

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: isEnabled ? onTap : null, // Disable tap if not enabled
        borderRadius: BorderRadius.circular(15.0),
        child: Opacity(
          // Visually indicate disabled state
          opacity: isEnabled ? 1.0 : 0.6,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 18.0,
            ),
            decoration: BoxDecoration(
              color: stepItemBgColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontSize: 15,
                    color: currentStepTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 15),
                // Use Expanded to prevent long titles from overflowing
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long titles
                    maxLines: 1, // Ensure title stays on one line
                  ),
                ),
                const SizedBox(width: 10), // Add space before icon
                Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: currentCheckmarkColor,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipLink(BuildContext context) {
    return InkWell(
      onTap: () {
        print('[SelfAssessmentScreen] Skip for now tapped');
        // Use pushReplacement to prevent going back to the assessment
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      child: Padding(
        // Add padding for larger tap area
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Skip for now >>',
          style: TextStyle(
            fontSize: 15,
            color: skipLinkColor,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: skipLinkColor,
          ),
        ),
      ),
    );
  }
}
