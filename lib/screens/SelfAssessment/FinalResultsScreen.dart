// FinalResultsScreen.dart
import 'package:flutter/material.dart';

// Import a screen to navigate to *after* results if needed.
// Example: To go back to the assessment selection.
// import 'SelfAssessmentScreen.dart';

class FinalResultsScreen extends StatelessWidget {
  final Map<String, dynamic> allResults;

  const FinalResultsScreen({Key? key, required this.allResults})
    : super(key: key);

  // --- Scoring Logic (Helper Functions - Do NOT need context) ---

  // Helper to safely get list data
  List<T?> _getListFromResult<T>(String key) {
    if (allResults.containsKey(key) && allResults[key] is List) {
      try {
        return List<T?>.from(
          allResults[key].map((item) => item is T ? item : null),
        );
      } catch (e) {
        print("Error casting list for key '$key': $e");
        return [];
      }
    }
    print("Warning: Result key '$key' not found or not a List.");
    return [];
  }

  // Helper to safely get map data
  Map<String, dynamic> _getMapFromResult(String key) {
    if (allResults.containsKey(key) && allResults[key] is Map) {
      try {
        return Map<String, dynamic>.from(allResults[key]);
      } catch (e) {
        print("Error casting map for key '$key': $e");
        return {};
      }
    }
    print("Warning: Result key '$key' not found or not a Map.");
    return {};
  }

  // --- Calculation Methods (No context needed) ---

  Map<String, dynamic> _calculateDepressionResult() {
    List<int?> answers = _getListFromResult<int>('depression');
    if (answers.length != 21 || answers.contains(null)) {
      return {
        'isPositive': false,
        'message': 'Depression results are incomplete.',
        'score': null,
      };
    }
    int score = answers.fold(0, (sum, answer) => sum + (answer ?? 0));
    String severity;
    if (score <= 13)
      severity = 'Minimal depression';
    else if (score <= 19)
      severity = 'Mild depression';
    else if (score <= 28)
      severity = 'Moderate depression';
    else if (score <= 63)
      severity = 'Severe depression';
    else
      severity = 'Invalid score';
    bool isPositive = score >= 29; // Standard Severe threshold
    return {
      'isPositive': isPositive,
      'message': 'Score: $score. $severity.',
      'score': score,
    };
  }

  Map<String, dynamic> _calculateAnxietyResult() {
    List<int?> answers = _getListFromResult<int>('anxiety');
    if (answers.length < 7 || answers.sublist(0, 7).contains(null)) {
      return {
        'isPositive': false,
        'message': 'Anxiety results are incomplete.',
        'score': null,
      };
    }
    int score = answers
        .sublist(0, 7)
        .fold(0, (sum, answer) => sum + (answer ?? 0));
    String severity;
    if (score <= 4)
      severity = 'Minimal anxiety';
    else if (score <= 9)
      severity = 'Mild anxiety';
    else if (score <= 14)
      severity = 'Moderate anxiety';
    else if (score >= 15)
      severity = 'Severe anxiety'; // GAD-7 stops at 21
    else
      severity = 'Invalid score';
    bool isPositive = score >= 15; // Severe threshold
    return {
      'isPositive': isPositive,
      'message': 'Score: $score. $severity.',
      'score': score,
    };
  }

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
        ocdData['severityAndFinalAnswers']?.map(
              (item) => item is int ? item : null,
            ) ??
            [],
      );
    } catch (e) {
      print("Error casting OCD severity answers: $e");
      answers = [];
    }
    if (answers.length < 10 || answers.sublist(0, 10).contains(null)) {
      return {
        'isPositive': false,
        'message': 'OCD severity results (Q1-10) are incomplete.',
        'score': null,
      };
    }
    int score = answers
        .sublist(0, 10)
        .fold(0, (sum, answer) => sum + (answer ?? 0));
    String severity;
    if (score <= 7)
      severity = 'Subclinical signs';
    else if (score <= 15)
      severity = 'Mild signs';
    else if (score <= 23)
      severity = 'Moderate signs';
    else if (score <= 31)
      severity = 'Severe signs';
    else if (score <= 40)
      severity = 'Extreme signs';
    else
      severity = 'Invalid score';
    bool isPositive = score >= 24; // Severe/Extreme threshold
    return {
      'isPositive': isPositive,
      'message': 'Score: $score. $severity.',
      'score': score,
    };
  }

  Map<String, dynamic> _calculateBipolarResult() {
    List<int?> answers = _getListFromResult<int>('bipolar');
    if (answers.length != 17 || answers.contains(null)) {
      return {
        'isPositive': false,
        'message': 'Bipolar screen results are incomplete.',
      };
    }
    int yesCountQ1to13 = answers.sublist(0, 13).where((a) => a == 0).length;
    bool criterion1Met = yesCountQ1to13 >= 7;
    bool criterion2Met = answers[13] == 0;
    bool criterion3Met = answers[14] != null && answers[14]! >= 2;
    bool isPositive = criterion1Met && criterion2Met && criterion3Met;
    String message =
        isPositive
            ? 'This screen suggests further evaluation for Bipolar Disorder may be warranted.'
            : 'This screen does not indicate Bipolar Disorder based on these criteria.';
    message +=
        "\n(Criteria: >=7 Yes in Q1-13 [$yesCountQ1to13 met: ${criterion1Met}], Yes in Q14 [met: ${criterion2Met}], Moderate/Serious problem in Q15 [met: ${criterion3Met}])";
    return {'isPositive': isPositive, 'message': message};
  }

  Map<String, dynamic> _calculateADHDResult() {
    List<int?> answers = _getListFromResult<int>('adhd');
    if (answers.length != 18 || answers.contains(null)) {
      return {
        'isPositive': false,
        'message': 'ADHD screen results are incomplete.',
      };
    }
    int oftenOrVeryOftenCountPartA =
        answers.sublist(0, 6).where((a) => a != null && a >= 3).length;
    bool partAPositive = oftenOrVeryOftenCountPartA >= 4;
    bool isPositive = partAPositive;
    String message =
        isPositive
            ? 'This screen (Part A) suggests symptoms consistent with ADHD warranting further investigation.'
            : 'This screen (Part A) does not indicate likely ADHD based on these criteria.';
    message +=
        "\n(Part A requires >=4 'Often'/'Very Often' in Q1-6. You had $oftenOrVeryOftenCountPartA.)";
    return {'isPositive': isPositive, 'message': message};
  }

  Map<String, dynamic> _calculateAddictionResult() {
    Map<String, dynamic> addictionData = _getMapFromResult('addiction');
    if (addictionData.isEmpty ||
        !addictionData.containsKey('yesNoAnswers') ||
        !addictionData.containsKey('selectedSubstances')) {
      return {
        'isPositive': false,
        'message': 'Addiction results are incomplete (missing data).',
        'score': null,
      };
    }

    Map<String, bool> selectedSubstances;
    try {
      selectedSubstances = Map<String, bool>.from(
        addictionData['selectedSubstances'] ?? {},
      );
    } catch (e) {
      print("Error casting Addiction selected substances: $e");
      selectedSubstances = {};
    }

    if (selectedSubstances['Nothing'] == true) {
      return {
        'isPositive': false,
        'message': 'No substance use reported.',
        'score': 0,
      };
    }

    List<bool?> answers;
    try {
      answers = List<bool?>.from(
        addictionData['yesNoAnswers']?.map(
              (item) => item is bool ? item : null,
            ) ??
            [],
      );
    } catch (e) {
      print("Error casting Addiction Yes/No answers: $e");
      answers = [];
    }

    bool anySubstanceSelected = selectedSubstances.entries.any(
      (e) => e.key != 'Nothing' && e.value == true,
    );

    if (anySubstanceSelected && (answers.isEmpty || answers.contains(null))) {
      // Substances selected, but Y/N questions are missing/null
      return {
        'isPositive': false,
        'message': 'Addiction Yes/No questions are incomplete.',
        'score': null,
      };
    } else if (!anySubstanceSelected && selectedSubstances['Nothing'] != true) {
      // No substance OR nothing selected
      return {
        'isPositive': false,
        'message': 'Addiction screen substance selection incomplete.',
        'score': null,
      };
    }

    // If we reach here and answers is empty, it means !anySubstanceSelected is true (and Nothing is false), which was caught above.
    // So, if answers is not empty, proceed to count.
    int yesCount = 0;
    if (answers.isNotEmpty) {
      yesCount = answers.where((a) => a == true).length;
    }

    String severity;
    if (yesCount >= 6)
      severity = 'Severe Substance Use Disorder indicated';
    else if (yesCount >= 4)
      severity = 'Moderate Substance Use Disorder indicated';
    else if (yesCount >= 2)
      severity = 'Mild Substance Use Disorder indicated';
    else
      severity =
          'Low likelihood of Substance Use Disorder (less than 2 criteria met)';

    bool isPositive = yesCount >= 6; // Severe threshold

    return {
      'isPositive': isPositive,
      'message': 'Criteria met: $yesCount. $severity.',
      'score': yesCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Context is available here
    // Calculate screen dimensions ONCE
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate all results
    final depressionResult = _calculateDepressionResult();
    final anxietyResult = _calculateAnxietyResult();
    final ocdResult = _calculateOCDResult();
    final bipolarResult = _calculateBipolarResult();
    final adhdResult = _calculateADHDResult();
    final addictionResult = _calculateAddictionResult();

    List<Widget> resultsWidgets = [];
    int positiveCount = 0;

    // Add sections for POSITIVE results, passing screenHeight
    if (depressionResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight, // Pass height
          imagePath: 'assets/images/deppic.png',
          title: 'Signs Consistent with Depression',
          message: depressionResult['message'],
          isFirst: positiveCount == 0,
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (anxietyResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight, // Pass height
          imagePath: 'assets/images/anxietypic.png',
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
          screenHeight: screenHeight, // Pass height
          imagePath: 'assets/images/ocdpic.png',
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
          screenHeight: screenHeight, // Pass height
          imagePath: 'assets/images/bipolarpic1.png',
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
          screenHeight: screenHeight, // Pass height
          imagePath: 'assets/images/adhdpic.png',
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
          screenHeight: screenHeight, // Pass height
          imagePath: 'assets/images/addictionpic.png',
          title: 'Signs Consistent with Substance Use Disorder',
          message: addictionResult['message'],
          isFirst: positiveCount == 0,
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }

    if (resultsWidgets.isEmpty) {
      // Pass screenHeight and context for navigation
      resultsWidgets.add(_buildNoSignificantSigns(context, screenHeight));
    } else {
      // Pass context for navigation
      resultsWidgets.add(_buildFinalDisclaimer(context));
    }

    return Scaffold(body: ListView(children: resultsWidgets));
  }

  // Widget for "No significant signs" message
  // Now receives context for navigation and screenHeight
  Widget _buildNoSignificantSigns(BuildContext context, double screenHeight) {
    final Color noteColor = Colors.grey.shade700;
    return Container(
      // Use screenHeight passed from build method
      height: screenHeight,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/all_good_placeholder.png', // Replace with actual asset
              height: 150,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.check_circle_outline,
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
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
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
            ElevatedButton(
              onPressed: () {
                // Use the context passed to this method for navigation
                if (Navigator.canPop(context)) Navigator.pop(context);
                print("Done button tapped");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5588A4),
                foregroundColor: Colors.white,
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
  // Does NOT need context directly, uses passed screenHeight
  Widget _buildResultSection({
    required double screenHeight, // Receive height instead of context
    required String imagePath,
    required String title,
    required String message,
    bool isFirst = true,
    bool showAlsoPrefix = false,
  }) {
    final Color headerColor = const Color(0xFF5588A4);
    final Color contentBgColor = Colors.white;
    final Color primaryTextColor = const Color(0xFF276181);
    final Color secondaryTextColor = Colors.black87;
    // final Color buttonTextColor = Colors.white; // No button currently

    String displayTitle = title;
    if (showAlsoPrefix) displayTitle = "Also, $title";

    return Column(
      children: [
        Container(
          color: headerColor,
          // Use screenHeight passed from build method
          height: screenHeight * 0.28,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          transform: Matrix4.translationValues(0.0, -30.0, 0.0),
          padding: const EdgeInsets.only(
            top: 40.0,
            left: 25.0,
            right: 25.0,
            bottom: 30.0,
          ),
          decoration: BoxDecoration(
            color: contentBgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                displayTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 25.0),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor.withOpacity(0.9),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30.0),
              // Button removed for simplicity, add back if needed, passing context then
            ],
          ),
        ),
      ],
    );
  }

  // Widget for the final disclaimer note
  // Receives context for the final navigation button
  Widget _buildFinalDisclaimer(BuildContext context) {
    final Color noteColor = Colors.grey.shade600;
    final Color primaryTextColor = const Color(0xFF276181);
    final Color headerColor = const Color(0xFF5588A4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Important Considerations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
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
          ElevatedButton(
            onPressed: () {
              // Use context passed to this method for navigation
              if (Navigator.canPop(context)) Navigator.pop(context);
              print("Finish button tapped");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: headerColor,
              foregroundColor: Colors.white,
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
}
