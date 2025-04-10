// FinalResultsScreen.dart
import 'package:flutter/material.dart';

// Import a screen to navigate to *after* results if needed.
// Example: To go back to the assessment selection.
// import 'SelfAssessmentScreen.dart'; // Ensure this path is correct if used

class FinalResultsScreen extends StatelessWidget {
  final Map<String, dynamic> allResults;

  const FinalResultsScreen({super.key, required this.allResults});

  // --- Scoring Logic (Helper Functions - Do NOT need context) ---

  // Helper to safely get list data
  List<T?> _getListFromResult<T>(String key) {
    if (allResults.containsKey(key) && allResults[key] is List) {
      try {
        // Ensure correct type casting, handle potential errors
        return List<T?>.from(
          (allResults[key] as List).map((item) => item is T ? item : null),
        );
      } catch (e) {
        print("Error casting list for key '$key': $e");
        return []; // Return empty list on error
      }
    }
    // Print warning if key not found or not a list
    // print("Warning: Result key '$key' not found or not a List.");
    return []; // Return empty list if key not found or wrong type
  }

  // Helper to safely get map data
  Map<String, dynamic> _getMapFromResult(String key) {
    if (allResults.containsKey(key) && allResults[key] is Map) {
      try {
        // Ensure correct type casting
        return Map<String, dynamic>.from(allResults[key]);
      } catch (e) {
        print("Error casting map for key '$key': $e");
        return {}; // Return empty map on error
      }
    }
    // Print warning if key not found or not a map
    // print("Warning: Result key '$key' not found or not a Map.");
    return {}; // Return empty map if key not found or wrong type
  }

  // --- Calculation Methods (No context needed) ---

  // Calculates Depression result based on BDI-II criteria (example)
  Map<String, dynamic> _calculateDepressionResult() {
    List<int?> answers = _getListFromResult<int>('depression');
    // BDI-II has 21 questions
    if (answers.length != 21 || answers.contains(null)) {
      return {
        'isPositive': false,
        'message': 'Depression results are incomplete.',
        'score': null,
      };
    }
    // Sum scores (assuming 0-3 per question)
    int score = answers.fold(0, (sum, answer) => sum + (answer ?? 0));
    String severity;
    // Standard BDI-II scoring ranges
    if (score <= 13) {
      severity = 'Minimal depression';
    } else if (score <= 19) {
      severity = 'Mild depression';
    } else if (score <= 28) {
      severity = 'Moderate depression';
    } else if (score <= 63) {
      // Max score is 63
      severity = 'Severe depression';
    } else {
      severity = 'Invalid score'; // Should not happen with validation
    }
    // Define 'positive' based on a threshold (e.g., Moderate or Severe)
    bool isPositive =
        score >= 20; // Example: Consider Moderate+ as positive screen
    return {
      'isPositive': isPositive,
      'message': 'Score: $score. $severity.',
      'score': score,
    };
  }

  // Calculates Anxiety result based on GAD-7 criteria (example)
  Map<String, dynamic> _calculateAnxietyResult() {
    List<int?> answers = _getListFromResult<int>('anxiety');
    // GAD-7 has 7 questions
    if (answers.length < 7 || answers.sublist(0, 7).contains(null)) {
      return {
        'isPositive': false,
        'message': 'Anxiety results are incomplete.',
        'score': null,
      };
    }
    // Sum scores for the 7 questions (assuming 0-3 per question)
    int score = answers
        .sublist(0, 7) // Take only the first 7 answers
        .fold(0, (sum, answer) => sum + (answer ?? 0));
    String severity;
    // Standard GAD-7 scoring ranges
    if (score <= 4) {
      severity = 'Minimal anxiety';
    } else if (score <= 9) {
      severity = 'Mild anxiety';
    } else if (score <= 14) {
      severity = 'Moderate anxiety';
    } else if (score <= 21) {
      // Max score is 21
      severity = 'Severe anxiety';
    } else {
      severity = 'Invalid score'; // Should not happen
    }
    // Define 'positive' based on a threshold (e.g., Moderate or Severe)
    bool isPositive =
        score >= 10; // Example: Consider Moderate+ as positive screen
    return {
      'isPositive': isPositive,
      'message': 'Score: $score. $severity.',
      'score': score,
    };
  }

  // Calculates OCD result based on Y-BOCS Symptom Checklist part (example - severity score)
  Map<String, dynamic> _calculateOCDResult() {
    Map<String, dynamic> ocdData = _getMapFromResult('ocd');
    if (ocdData.isEmpty || !ocdData.containsKey('severityAndFinalAnswers')) {
      return {
        'isPositive': false,
        'message': 'OCD results are incomplete (missing data).',
        'score': null,
      };
    }
    List<int?> answers;
    try {
      answers = List<int?>.from(
        (ocdData['severityAndFinalAnswers'] as List?)?.map(
              // Safer casting
              (item) => item is int ? item : null,
            ) ??
            [],
      );
    } catch (e) {
      print("Error casting OCD severity answers: $e");
      answers = [];
    }
    // Y-BOCS severity part has 10 items (5 obsession, 5 compulsion)
    if (answers.length < 10 || answers.sublist(0, 10).contains(null)) {
      return {
        'isPositive': false,
        'message': 'OCD severity results (Q1-10) are incomplete.',
        'score': null,
      };
    }
    // Sum scores (assuming 0-4 per question)
    int score = answers
        .sublist(0, 10) // Use only the 10 severity questions
        .fold(0, (sum, answer) => sum + (answer ?? 0));
    String severity;
    // Standard Y-BOCS severity ranges
    if (score <= 7) {
      severity = 'Subclinical signs';
    } else if (score <= 15) {
      severity = 'Mild signs';
    } else if (score <= 23) {
      severity = 'Moderate signs';
    } else if (score <= 31) {
      severity = 'Severe signs';
    } else if (score <= 40) {
      // Max score is 40
      severity = 'Extreme signs';
    } else {
      severity = 'Invalid score';
    }
    // Define 'positive' based on a threshold (e.g., Moderate+)
    bool isPositive = score >= 16; // Example: Moderate+ threshold
    return {
      'isPositive': isPositive,
      'message': 'Score: $score. $severity.',
      'score': score,
    };
  }

  // Calculates Bipolar result based on MDQ criteria (example)
  Map<String, dynamic> _calculateBipolarResult() {
    List<int?> answers = _getListFromResult<int>('bipolar');
    // MDQ has 13 symptom questions + 1 concurrence + 1 impairment question = 15 items minimum expected
    // Assuming your array might store more, check required parts
    if (answers.length < 15 || answers.sublist(0, 15).contains(null)) {
      return {
        'isPositive': false,
        'message': 'Bipolar screen results are incomplete.',
      };
    }
    // Q1-13: Symptom presence (assuming 0 = Yes, 1 = No)
    int yesCountQ1to13 = answers.sublist(0, 13).where((a) => a == 0).length;
    // Q14: Symptoms happened at same time (assuming 0 = Yes, 1 = No)
    bool criterion1metSymptoms = yesCountQ1to13 >= 7;
    // Q14: Concurrence (assuming 0 = Yes)
    bool criterion2metConcurrence = answers[13] == 0;
    // Q15: Impairment level (assuming 0=No, 1=Minor, 2=Moderate, 3=Serious)
    bool criterion3metImpairment =
        answers[14] != null && answers[14]! >= 2; // Moderate or Serious problem

    bool isPositive =
        criterion1metSymptoms &&
        criterion2metConcurrence &&
        criterion3metImpairment;

    String message =
        isPositive
            ? 'This screen suggests further evaluation for Bipolar Disorder may be warranted.'
            : 'This screen does not indicate likely Bipolar Disorder based on these criteria.';
    message +=
        "\n(Criteria: >=7 'Yes' in Q1-13 [met: $criterion1metSymptoms], 'Yes' in Q14 [met: $criterion2metConcurrence], 'Moderate' or 'Serious' problem in Q15 [met: $criterion3metImpairment])";
    return {'isPositive': isPositive, 'message': message};
  }

  // Calculates ADHD result based on ASRS v1.1 Part A (example)
  Map<String, dynamic> _calculateADHDResult() {
    List<int?> answers = _getListFromResult<int>('adhd');
    // ASRS Part A has 6 questions. Part B has 12. Total 18.
    if (answers.length < 6 || answers.sublist(0, 6).contains(null)) {
      return {
        'isPositive': false,
        'message': 'ADHD screen results (Part A) are incomplete.',
      };
    }
    // Count how many Part A questions (Q1-6) are marked 'Often' or 'Very Often'
    // Assuming: 0=Never, 1=Rarely, 2=Sometimes, 3=Often, 4=Very Often
    int oftenOrVeryOftenCountPartA =
        answers.sublist(0, 6).where((a) => a != null && a >= 3).length;

    // Positive screen if 4 or more questions in Part A are marked Often/Very Often
    bool partAPositive = oftenOrVeryOftenCountPartA >= 4;
    bool isPositive =
        partAPositive; // For ASRS Part A, this is the primary screen result

    String message =
        isPositive
            ? 'This screen (Part A) suggests symptoms consistent with ADHD warranting further investigation.'
            : 'This screen (Part A) does not indicate likely ADHD based on these criteria.';
    message +=
        "\n(Part A requires >=4 'Often'/'Very Often' responses in Q1-6. You had $oftenOrVeryOftenCountPartA.)";

    // You could optionally analyze Part B here if needed for more detail, but Part A is the main screener.

    return {'isPositive': isPositive, 'message': message};
  }

  // Calculates Addiction result based on DSM-5 criteria count (example - using simplified Yes/No)
  Map<String, dynamic> _calculateAddictionResult() {
    Map<String, dynamic> addictionData = _getMapFromResult('addiction');
    if (addictionData.isEmpty ||
        !addictionData.containsKey(
          'yesNoAnswers',
        ) || // Expecting list of booleans
        !addictionData.containsKey('selectedSubstances')) {
      // Expecting map of String->bool
      return {
        'isPositive': false,
        'message': 'Addiction results are incomplete (missing data structure).',
        'score': null,
      };
    }

    Map<String, bool> selectedSubstances;
    try {
      // Ensure the map is correctly typed
      selectedSubstances = Map<String, bool>.from(
        addictionData['selectedSubstances'] ?? {},
      );
    } catch (e) {
      print("Error casting Addiction selected substances: $e");
      selectedSubstances = {}; // Default to empty on error
    }

    // If user explicitly selected "Nothing", result is negative.
    if (selectedSubstances['Nothing'] == true) {
      return {
        'isPositive': false,
        'message': 'No substance use reported.',
        'score': 0, // Score is 0 if no use reported
      };
    }

    List<bool?> answers;
    try {
      // Ensure the list contains booleans or nulls
      answers = List<bool?>.from(
        (addictionData['yesNoAnswers'] as List?)?.map(
              (item) => item is bool ? item : null,
            ) ??
            [],
      );
    } catch (e) {
      print("Error casting Addiction Yes/No answers: $e");
      answers = []; // Default to empty on error
    }

    // Check if any substance (other than 'Nothing') was selected
    bool anySubstanceSelected = selectedSubstances.entries.any(
      (e) => e.key != 'Nothing' && e.value == true,
    );

    // If substances were selected, but the Yes/No answers are missing/incomplete
    // (Assuming 11 DSM criteria mapped to 11 Y/N questions)
    if (anySubstanceSelected &&
        (answers.length < 11 || answers.contains(null))) {
      return {
        'isPositive': false,
        'message': 'Addiction criteria questions are incomplete.',
        'score': null,
      };
    } else if (!anySubstanceSelected && selectedSubstances['Nothing'] != true) {
      // If NO substance was selected AND "Nothing" wasn't selected either -> incomplete state
      return {
        'isPositive': false,
        'message': 'Addiction screen substance selection is incomplete.',
        'score': null,
      };
    }

    // Count 'Yes' answers (true values) - Represents criteria met
    int yesCount = 0;
    if (answers.isNotEmpty) {
      // Ensure we only count non-null true values
      yesCount = answers.where((a) => a == true).length;
    }

    // Determine severity based on DSM-5 criteria count for SUD
    String severity;
    if (yesCount >= 6) {
      severity = 'Severe Substance Use Disorder indicated';
    } else if (yesCount >= 4) {
      severity = 'Moderate Substance Use Disorder indicated';
    } else if (yesCount >= 2) {
      severity = 'Mild Substance Use Disorder indicated';
    } else {
      // 0 or 1 criterion met
      severity =
          'Low likelihood of Substance Use Disorder (less than 2 criteria met)';
    }

    // Define 'positive' based on a threshold (e.g., meeting criteria for Mild SUD or higher)
    bool isPositive =
        yesCount >= 2; // Example: Mild+ is considered a positive screen

    return {
      'isPositive': isPositive,
      'message': 'Criteria met: $yesCount. $severity.',
      'score': yesCount, // Return the count
    };
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen dimensions ONCE for efficiency
    final screenHeight = MediaQuery.of(context).size.height;

    // --- Calculate all results ---
    // These methods use the helper functions and don't need context directly
    final depressionResult = _calculateDepressionResult();
    final anxietyResult = _calculateAnxietyResult();
    final ocdResult = _calculateOCDResult();
    final bipolarResult = _calculateBipolarResult();
    final adhdResult = _calculateADHDResult();
    final addictionResult = _calculateAddictionResult();

    // List to hold the widgets to be displayed
    List<Widget> resultsWidgets = [];
    int positiveCount = 0; // To track if any result is positive

    // --- Build sections for POSITIVE results ONLY ---
    // Check each result's 'isPositive' flag
    if (depressionResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight, // Pass height for layout
          imagePath: 'assets/images/deppic.png', // Ensure path is correct
          title: 'Signs Consistent with Depression',
          message: depressionResult['message'],
          isFirst:
              positiveCount ==
              0, // True only for the very first positive result
          showAlsoPrefix: positiveCount > 0, // Add "Also," if not the first
        ),
      );
      positiveCount++; // Increment count of positive results
    }
    if (anxietyResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/anxietypic.png', // Ensure path is correct
          title: 'Signs Consistent with Anxiety',
          message: anxietyResult['message'],
          isFirst: positiveCount == 0,
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (ocdResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/ocdpic.png', // Ensure path is correct
          title: 'Signs Consistent with OCD',
          message: ocdResult['message'],
          isFirst: positiveCount == 0,
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (bipolarResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/bipolarpic1.png', // Ensure path is correct
          title: 'Signs Warranting Bipolar Evaluation',
          message: bipolarResult['message'],
          isFirst: positiveCount == 0,
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (adhdResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/adhdpic.png', // Ensure path is correct
          title: 'Signs Consistent with ADHD',
          message: adhdResult['message'],
          isFirst: positiveCount == 0,
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (addictionResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/addictionpic.png', // Ensure path is correct
          title: 'Signs Consistent with Substance Use Disorder',
          message: addictionResult['message'],
          isFirst: positiveCount == 0,
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }

    // --- Check if ANY positive results were found ---
    // *This is the core logic for your request*
    if (resultsWidgets.isEmpty) {
      // *** If NO positive results were added, display the "No Significant Signs" widget ***
      // We pass context here because the "Done" button needs it for navigation
      resultsWidgets.add(_buildNoSignificantSigns(context, screenHeight));
    } else {
      // *** If there WERE positive results, add the final disclaimer section ***
      // We pass context here because the "Finish" button needs it for navigation
      resultsWidgets.add(_buildFinalDisclaimer(context));
    }

    // Return the Scaffold containing a ListView of the determined widgets
    return Scaffold(
      // Use a ListView to allow scrolling if content exceeds screen height
      body: ListView(
        padding: EdgeInsets.zero, // Remove default ListView padding
        children: resultsWidgets,
      ),
    );
  }

  // --- Widget Builder Methods (Need context ONLY if they contain interactive elements like Buttons) ---

  // Widget for the "No significant signs" message
  // Receives context ONLY for the 'Done' button's onPressed action.
  Widget _buildNoSignificantSigns(BuildContext context, double screenHeight) {
    final Color noteColor = Colors.grey.shade700;
    final Color buttonColor = const Color(0xFF5588A4); // Example button color

    return Container(
      // Constrain height to prevent excessive scrolling on short screens
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.9,
      ), // Ensure it fills most of the screen
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 40,
      ), // Adjusted padding
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              // *** IMPORTANT: Make sure this image path is correct in your assets folder ***
              'assets/images/nomentalissuepic.png',
              height: 150, // Adjust size as needed
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.check_circle_outline, // Fallback icon
                    size: 80,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 40),
            Text(
              'Based on your responses, this screening did not indicate significant signs matching the criteria for the assessed conditions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                color: noteColor,
                height: 1.5, // Line spacing
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            // Important disclaimer even if no signs found
            Text(
              'Remember, this assessment is a preliminary screening tool and not a substitute for a professional diagnosis. If you have ongoing concerns about your mental health, please consult a qualified healthcare professional.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: noteColor.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            // Button to close the results screen
            ElevatedButton(
              onPressed: () {
                // Use the context passed to this method for navigation
                // Pops the current screen (FinalResultsScreen) off the stack
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Handle case where it cannot pop (e.g., it's the first screen)
                  print("Cannot pop. Maybe navigate home?");
                  // Navigator.pushReplacementNamed(context, '/home'); // Example fallback
                }
                print("Done button tapped");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white, // Text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 15.0,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("Done"),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Widget for each positive result section
  // Does NOT need context directly if no interactive elements inside. Uses passed screenHeight.
  Widget _buildResultSection({
    required double screenHeight, // Receive height from build method
    required String imagePath,
    required String title,
    required String message,
    bool isFirst =
        true, // Not strictly needed for display but kept from original
    bool showAlsoPrefix = false,
  }) {
    // Define colors for consistency
    final Color headerColor = const Color(0xFF5588A4);
    final Color contentBgColor = Colors.white;
    final Color primaryTextColor = const Color(0xFF276181);
    final Color secondaryTextColor = Colors.black87;

    // Add "Also," prefix if this isn't the first positive result shown
    String displayTitle = showAlsoPrefix ? "Also, $title" : title;

    return Column(
      children: [
        // Header section with image
        Container(
          color: headerColor,
          height: screenHeight * 0.28, // Percentage of screen height
          width: double.infinity, // Full width
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Padding around image
            child: Image.asset(
              imagePath, // Display the specific image for the condition
              fit: BoxFit.contain, // Ensure image fits within bounds
              errorBuilder:
                  (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.warning_amber_rounded, // Fallback icon
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
            ),
          ),
        ),
        // Content section with text
        Container(
          width: double.infinity,
          // Negative margin to overlap the header slightly for curved effect
          transform: Matrix4.translationValues(0.0, -30.0, 0.0),
          padding: const EdgeInsets.only(
            top: 40.0, // Space above title inside the white box
            left: 25.0,
            right: 25.0,
            bottom: 30.0, // Space below content
          ),
          decoration: BoxDecoration(
            color: contentBgColor,
            // Apply border radius only to top corners
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display the title (with "Also," if applicable)
              Text(
                displayTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  height: 1.3, // Line spacing
                ),
              ),
              const SizedBox(height: 25.0), // Space between title and message
              // Display the specific result message from the calculation method
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor.withOpacity(0.9),
                  height: 1.5, // Line spacing
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30.0), // Space at the bottom
              // No button here in the original code, add if needed
            ],
          ),
        ),
      ],
    );
  }

  // Widget for the final disclaimer note (shown only when positive results exist)
  // Receives context ONLY for the 'Finish' button's onPressed action.
  Widget _buildFinalDisclaimer(BuildContext context) {
    final Color noteColor = Colors.grey.shade600;
    final Color primaryTextColor = const Color(0xFF276181);
    final Color buttonColor = const Color(0xFF5588A4); // Example button color

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      color: Colors.white, // White background for this section
      child: Column(
        children: [
          // Disclaimer Title
          Text(
            'Important Considerations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          // Disclaimer Text Paragraphs
          Text(
            'This assessment is a screening tool and does not provide a diagnosis. The results indicate the potential presence of symptoms based on your self-reported answers and specific scoring criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: noteColor, height: 1.5),
          ),
          const SizedBox(height: 15),
          Text(
            'Mental health is complex, and symptoms can overlap between conditions. Only a qualified healthcare professional (like a psychiatrist or psychologist) can provide an accurate diagnosis after a comprehensive evaluation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: noteColor, height: 1.5),
          ),
          const SizedBox(height: 15),
          Text(
            'If you are concerned about your mental health, please consult a professional. They can help you understand your situation better and discuss appropriate treatment options.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: noteColor,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          // Final Button to close the screen
          ElevatedButton(
            onPressed: () {
              // Use context passed to this method for navigation
              // Pops the current screen (FinalResultsScreen) off the stack
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                print("Cannot pop. Maybe navigate home?");
                // Navigator.pushReplacementNamed(context, '/home'); // Example fallback
              }
              print("Finish button tapped");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 15.0,
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }
} // End of FinalResultsScreen class
