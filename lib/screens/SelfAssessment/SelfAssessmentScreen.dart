// self_assessment_screen.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Import for Future

// Import all your assessment screen files (ensure correct paths)
import 'DepressionScreen.dart';
import 'anxietyscreen.dart';
import 'OCDScreen.dart';
import 'BipolarScreen.dart';
import 'ADHDScreen.dart';
import 'AddictionScreen.dart';

// Import the actual FinalResultsScreen (ensure correct path)
import 'FinalResultsScreen.dart';

// Placeholder screen if skipped
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Home'),
        backgroundColor: const Color(0xFF5588A4),
      ),
      body: const Center(child: Text('Assessment Skipped / Main App Area')),
    );
  }
}

// --- StatefulWidget ---
class SelfAssessmentScreen extends StatefulWidget {
  const SelfAssessmentScreen({Key? key}) : super(key: key);

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
      "[SelfAssessmentScreen] initState called. Initial state: highestCompleted=$_highestCompletedStepIndex, results=$_allAssessmentResults",
    );
    // TODO: Load saved state
  }

  // --- Method to Handle Navigation and State Update (with logging) ---
  Future<void> _navigateToStep(BuildContext context, int stepIndex) async {
    // **** START LOGGING ****
    print(
      "[SelfAssessmentScreen] _navigateToStep called for index: $stepIndex. Current highestCompleted: $_highestCompletedStepIndex",
    );
    // **** END LOGGING ****

    // Check if the step is allowed (current or next)
    if (stepIndex <= _highestCompletedStepIndex + 1) {
      final stepData = _assessmentSteps[stepIndex];
      final String stepKey = stepData['key'];
      Widget Function(BuildContext) screenBuilder = stepData['screenBuilder'];

      // **** START LOGGING ****
      print(
        "[SelfAssessmentScreen] Navigating to Step ${stepIndex + 1} ('$stepKey')...",
      );
      // **** END LOGGING ****

      // Navigate and wait for results (can be answers list/map or false)
      final result = await Navigator.push<dynamic>(
        // Expect dynamic result now
        context,
        MaterialPageRoute(builder: screenBuilder),
      );

      // **** START LOGGING ****
      print(
        "[SelfAssessmentScreen] --- Returned from Step ${stepIndex + 1} ('$stepKey') ---",
      );
      print("[SelfAssessmentScreen] Result type: ${result.runtimeType}");
      // Be cautious printing large results, maybe just check type or length
      // print("[SelfAssessmentScreen] Result value: $result");
      if (result is List) {
        print(
          "[SelfAssessmentScreen] Result value (List length): ${result.length}",
        );
      } else if (result is Map) {
        print("[SelfAssessmentScreen] Result value (Map keys): ${result.keys}");
      } else {
        print("[SelfAssessmentScreen] Result value: $result");
      }
      print("[SelfAssessmentScreen] Is result null? ${result == null}");
      print("[SelfAssessmentScreen] Is result false? ${result == false}");
      // **** END LOGGING ****

      // Check if the screen popped AND returned valid data (not false or null)
      if (result != null && result != false) {
        // **** START LOGGING ****
        print("[SelfAssessmentScreen] Result is valid, processing...");
        // **** END LOGGING ****

        setState(() {
          // **** START LOGGING ****
          print(
            "[SelfAssessmentScreen] setState: Storing result for '$stepKey'.",
          );
          // **** END LOGGING ****
          _allAssessmentResults[stepKey] = result;
          // Update completion index only if it's the current furthest step or beyond
          if (stepIndex >= _highestCompletedStepIndex) {
            // **** START LOGGING ****
            print(
              "[SelfAssessmentScreen] setState: Updating highestCompletedIndex from $_highestCompletedStepIndex to $stepIndex.",
            );
            // **** END LOGGING ****
            _highestCompletedStepIndex = stepIndex;
          } else {
            print(
              "[SelfAssessmentScreen] setState: Step $stepIndex already completed or not the highest, index not changed.",
            );
          }
          // Print state *after* potential updates inside setState
          print(
            "[SelfAssessmentScreen] setState: Results map updated: ${_allAssessmentResults.keys}",
          ); // Print only keys for brevity
          print(
            "[SelfAssessmentScreen] setState: Highest completed index updated: $_highestCompletedStepIndex",
          );
        });
        print(
          "[SelfAssessmentScreen] setState call finished.",
        ); // Log setState finish

        // TODO: Save state here if implementing save/resume

        // Check if all steps are now complete
        if (_highestCompletedStepIndex == _assessmentSteps.length - 1) {
          print(
            "[SelfAssessmentScreen] All steps complete! Navigating to results.",
          ); // Debug print
          // Navigate to the final results screen, passing all collected data
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
          "[SelfAssessmentScreen] Step ${stepIndex + 1} ('$stepKey') was exited with 'false' (likely back button).",
        );
      } else {
        print(
          "[SelfAssessmentScreen] Step ${stepIndex + 1} ('$stepKey') returned null result.",
        );
      }
    } else {
      // **** START LOGGING ****
      print(
        "[SelfAssessmentScreen] Step ${stepIndex + 1} access denied. highestCompleted=$_highestCompletedStepIndex",
      );
      // **** END LOGGING ****
      // User tried to skip steps that are not yet accessible
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete Step ${stepIndex} first.', // User sees 1-based index
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
    print(
      "[SelfAssessmentScreen] _navigateToStep finished for index: $stepIndex.",
    ); // Log end of function
  }

  @override
  Widget build(BuildContext context) {
    // **** START LOGGING ****
    print(
      "[SelfAssessmentScreen] build method called. highestCompleted=$_highestCompletedStepIndex, resultsKeys=${_allAssessmentResults.keys}",
    );
    // **** END LOGGING ****
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: headerColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(screenHeight, screenWidth),
            _buildContentArea(context), // Contains the step list generator
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenHeight, double screenWidth) {
    // (Header code remains the same)
    return Container(
      color: headerColor,
      height: screenHeight * 0.25,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            bottom: 25,
            left: screenWidth * 0.08,
            height: screenHeight * 0.15,
            child: Image.asset(
              'assets/images/selfassepic2.png',
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.error, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 10,
            right: screenWidth * 0.05,
            height: screenHeight * 0.18,
            child: Image.asset(
              'assets/images/selfassepic1.png',
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.error, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 25,
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

  Widget _buildContentArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 30.0,
        left: 20.0,
        right: 20.0,
        bottom: 30.0,
      ),
      decoration: BoxDecoration(
        color: contentBgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              height: 1.4,
            ),
          ),
          const SizedBox(height: 35.0),
          // --- Steps List (with logging in generation) ---
          Column(
            children: List.generate(_assessmentSteps.length, (index) {
              final stepData = _assessmentSteps[index];
              // Check completion based on whether results exist for this step's key
              bool isCompleted = _allAssessmentResults.containsKey(
                stepData['key'],
              );
              // Enable if it's completed OR it's the very next step after the highest completed
              bool isEnabled =
                  isCompleted || index == _highestCompletedStepIndex + 1;

              // **** START LOGGING ****
              print(
                "[SelfAssessmentScreen] Generating Step Item ${index + 1} ('${stepData['title']}'): highestCompleted=$_highestCompletedStepIndex, key='${stepData['key']}', resultsExist=${_allAssessmentResults.containsKey(stepData['key'])}, isCompleted=$isCompleted, isEnabled=$isEnabled",
              );
              // **** END LOGGING ****

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
    // (Step item build logic remains the same)
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

    // Optional: Add logging inside _buildStepItem too if needed, but the generation log above is often sufficient
    // print("[SelfAssessmentScreen] _buildStepItem rendering '$title': isCompleted=$isCompleted, isEnabled=$isEnabled");

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: isEnabled ? onTap : null, // Only allow tap if enabled
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: currentTitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: currentCheckmarkColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipLink(BuildContext context) {
    // (Skip link logic remains the same)
    return InkWell(
      onTap: () {
        print(
          '[SelfAssessmentScreen] Skip for now tapped',
        ); // Added screen context
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
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
    );
  }
}
