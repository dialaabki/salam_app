// FinalResultsScreen.dart
import 'package:flutter/material.dart';

// Import SelfAssessmentScreen if you need to navigate back to it, otherwise remove.
// import 'SelfAssessmentScreen.dart';

// Define keys used in the results map (should match keys from SelfAssessmentScreen)
const String keyDepression = 'depression';
const String keyAnxiety = 'anxiety';
const String keyOCD = 'ocd';
const String keyBipolar = 'bipolar';
const String keyADHD = 'adhd';
const String keyAddiction = 'addiction';

class FinalResultsScreen extends StatelessWidget {
  final Map<String, dynamic> allResults;

  const FinalResultsScreen({super.key, required this.allResults});

  // --- Helper to safely get list data from results ---
  // T specifies the expected type within the list (e.g., int, bool)
  List<T?> _getListFromResult<T>(String key) {
    // Check if the key exists and the value is a List
    if (allResults.containsKey(key) && allResults[key] is List) {
      try {
        // Attempt to cast the list and its elements
        // Map each item: if it's the correct type T, keep it, otherwise map to null
        return List<T?>.from(
          (allResults[key] as List).map((item) => item is T ? item : null),
        );
      } catch (e) {
        // Log error if casting fails unexpectedly
        print(
          "Error casting list for key '$key': $e. Data: ${allResults[key]}",
        );
        return []; // Return empty list on error
      }
    }
    // Log warning if key not found or not a list (optional, can be noisy)
    // print("Warning: Result key '$key' not found or not a List.");
    return []; // Return empty list if key doesn't exist or isn't a list
  }

  // --- Helper to safely get map data from results ---
  Map<String, dynamic> _getMapFromResult(String key) {
    // Check if key exists and value is a Map
    if (allResults.containsKey(key) && allResults[key] is Map) {
      try {
        // Attempt to cast to the expected Map type
        // Note: This assumes Map<String, dynamic>, adjust if needed (e.g., Map<int, dynamic>)
        // For OCD checklist, the map might have int keys initially, but they get cast to String by Firestore often.
        // We handle potential String keys later if needed.
        if (key == keyOCD && allResults[key]['checklistAnswers'] != null) {
          // Special handling for OCD checklist map which might have int or String keys
          // We'll primarily work with the structure inside the calculation function
          return Map<String, dynamic>.from(allResults[key]);
        } else {
          return Map<String, dynamic>.from(allResults[key]);
        }
      } catch (e) {
        print("Error casting map for key '$key': $e. Data: ${allResults[key]}");
        return {}; // Return empty map on error
      }
    }
    // print("Warning: Result key '$key' not found or not a Map.");
    return {}; // Return empty map if key doesn't exist or isn't a map
  }

  // --- Calculation Methods (Perform scoring based on standard criteria) ---

  // Calculates Depression result (BDI-II Example)
  Map<String, dynamic> _calculateDepressionResult() {
    // Get answers, expecting List<int?>
    List<int?> answers = _getListFromResult<int>(keyDepression);
    int expectedLength = 21; // BDI-II has 21 questions

    // Validate data presence and completeness
    if (answers.isEmpty ||
        answers.length != expectedLength ||
        answers.contains(null)) {
      print(
        "Depression results incomplete or missing. Length: ${answers.length}, Contains null: ${answers.contains(null)}",
      );
      return {
        'isPositive': false, // Cannot determine positivity
        'message': 'Depression results are incomplete or missing.',
        'score': null,
      };
    }

    // Calculate score (summing 0-3 for each question)
    int score = answers.fold(0, (sum, answer) => sum + (answer ?? 0));

    // Determine severity based on standard BDI-II ranges
    String severity;
    if (score >= 0 && score <= 13)
      severity = 'Minimal depression';
    else if (score <= 19)
      severity = 'Mild depression';
    else if (score <= 28)
      severity = 'Moderate depression';
    else if (score <= 63)
      severity = 'Severe depression'; // Max score is 63
    else
      severity = 'Invalid score'; // Should not happen if answers are 0-3

    // Define 'positive screen' threshold (e.g., Moderate or Severe)
    bool isPositive = score >= 20; // Example threshold

    return {
      'isPositive': isPositive,
      'message': 'Score: $score. Suggests: $severity.',
      'score': score,
    };
  }

  // Calculates Anxiety result (GAD-7 Example)
  Map<String, dynamic> _calculateAnxietyResult() {
    // Get answers, expecting List<int?>
    List<int?> answers = _getListFromResult<int>(keyAnxiety);
    int expectedLength = 7; // GAD-7 uses first 7 questions for score

    // Validate the first 7 answers needed for scoring
    if (answers.length < expectedLength ||
        answers.sublist(0, expectedLength).contains(null)) {
      print(
        "Anxiety results incomplete or missing. Length: ${answers.length}, Sublist contains null: ${answers.length >= expectedLength && answers.sublist(0, expectedLength).contains(null)}",
      );
      return {
        'isPositive': false,
        'message': 'Anxiety results (Q1-7) are incomplete or missing.',
        'score': null,
      };
    }

    // Calculate score (summing 0-3 for first 7 questions)
    int score = answers
        .sublist(0, expectedLength)
        .fold(0, (sum, answer) => sum + (answer ?? 0));

    // Determine severity based on standard GAD-7 ranges
    String severity;
    if (score >= 0 && score <= 4)
      severity = 'Minimal anxiety';
    else if (score <= 9)
      severity = 'Mild anxiety';
    else if (score <= 14)
      severity = 'Moderate anxiety';
    else if (score <= 21)
      severity = 'Severe anxiety'; // Max score is 21
    else
      severity = 'Invalid score';

    // Define 'positive screen' threshold (e.g., Moderate or Severe)
    bool isPositive = score >= 10; // Example threshold

    return {
      'isPositive': isPositive,
      'message': 'Score (Q1-7): $score. Suggests: $severity.',
      'score': score,
    };
  }

  // Calculates OCD result (Y-BOCS Severity Example)
  Map<String, dynamic> _calculateOCDResult() {
    // Get the entire OCD result map
    Map<String, dynamic> ocdData = _getMapFromResult(keyOCD);
    int severityQuestionsCount = 10; // Y-BOCS severity uses Q1-10

    // Check if the main key and the severity answers key exist
    if (ocdData.isEmpty || !ocdData.containsKey('severityAndFinalAnswers')) {
      print("OCD results map or severity answers missing.");
      return {
        'isPositive': false,
        'message': 'OCD results data structure is missing or incomplete.',
        'score': null,
      };
    }

    List<int?> answers;
    try {
      // Safely cast the severity answers list
      answers = List<int?>.from(
        (ocdData['severityAndFinalAnswers'] as List?)?.map(
              (item) => item is int ? item : null,
            ) ??
            [],
      );
    } catch (e) {
      print("Error casting OCD severity answers: $e");
      answers = []; // Default to empty on error
    }

    // Validate the severity answers needed for scoring
    if (answers.length < severityQuestionsCount ||
        answers.sublist(0, severityQuestionsCount).contains(null)) {
      print(
        "OCD severity results (Q1-10) incomplete. Length: ${answers.length}, Sublist contains null: ${answers.length >= severityQuestionsCount && answers.sublist(0, severityQuestionsCount).contains(null)}",
      );
      return {
        'isPositive': false,
        'message': 'OCD severity results (Q1-10) are incomplete.',
        'score': null,
      };
    }

    // Calculate severity score (summing 0-4 for first 10 questions)
    int score = answers
        .sublist(0, severityQuestionsCount)
        .fold(0, (sum, answer) => sum + (answer ?? 0));

    // Determine severity based on standard Y-BOCS ranges
    String severity;
    if (score >= 0 && score <= 7)
      severity = 'Subclinical signs';
    else if (score <= 15)
      severity = 'Mild signs';
    else if (score <= 23)
      severity = 'Moderate signs';
    else if (score <= 31)
      severity = 'Severe signs';
    else if (score <= 40)
      severity = 'Extreme signs'; // Max score is 40
    else
      severity = 'Invalid score';

    // Define 'positive screen' threshold (e.g., Moderate+)
    bool isPositive = score >= 16; // Example threshold

    return {
      'isPositive': isPositive,
      'message': 'Severity Score (Q1-10): $score. Suggests: $severity.',
      'score': score,
    };
  }

  // Calculates Bipolar result (MDQ Example)
  Map<String, dynamic> _calculateBipolarResult() {
    // Get answers, expecting List<int?>
    List<int?> answers = _getListFromResult<int>(keyBipolar);
    int requiredLength =
        15; // Need Q1-13 (symptoms), Q14 (concurrence), Q15 (impairment)

    // Validate data
    if (answers.length < requiredLength ||
        answers.sublist(0, requiredLength).contains(null)) {
      print(
        "Bipolar screen results (Q1-15) incomplete. Length: ${answers.length}, Sublist contains null: ${answers.length >= requiredLength && answers.sublist(0, requiredLength).contains(null)}",
      );
      return {
        'isPositive': false,
        'message': 'Bipolar screen results (Q1-15) are incomplete or missing.',
      };
    }

    // MDQ Screening Criteria:
    // 1. Criterion 1: >= 7 "Yes" answers for Q1-13 (where Yes=0)
    int yesCountQ1to13 = answers.sublist(0, 13).where((a) => a == 0).length;
    bool criterion1met = yesCountQ1to13 >= 7;

    // 2. Criterion 2: "Yes" for Q14 (concurrence - where Yes=0)
    bool criterion2met = answers[13] == 0; // Index 13 is Q14

    // 3. Criterion 3: "Moderate" (2) or "Serious" (3) problem for Q15 (impairment)
    bool criterion3met =
        answers[14] != null && answers[14]! >= 2; // Index 14 is Q15

    // Positive screen if all 3 criteria are met
    bool isPositive = criterion1met && criterion2met && criterion3met;

    String message =
        isPositive
            ? 'This screen suggests further evaluation for Bipolar Disorder may be warranted.'
            : 'This screen does not indicate likely Bipolar Disorder based on MDQ criteria.';
    // Add details for clarity
    message +=
        "\n(Criteria Check: >=7 symptoms [${criterion1met ? 'Met' : 'Not Met'}], Symptoms concurrent [${criterion2met ? 'Met' : 'Not Met'}], Moderate/Serious problem [${criterion3met ? 'Met' : 'Not Met'}])";

    return {'isPositive': isPositive, 'message': message};
  }

  // Calculates ADHD result (ASRS v1.1 Part A Example)
  Map<String, dynamic> _calculateADHDResult() {
    // Get answers, expecting List<int?>
    List<int?> answers = _getListFromResult<int>(keyADHD);
    int partALength = 6; // ASRS Part A uses Q1-6 for screening score

    // Validate Part A answers
    if (answers.length < partALength ||
        answers.sublist(0, partALength).contains(null)) {
      print(
        "ADHD screen results (Part A: Q1-6) incomplete. Length: ${answers.length}, Sublist contains null: ${answers.length >= partALength && answers.sublist(0, partALength).contains(null)}",
      );
      return {
        'isPositive': false,
        'message':
            'ADHD screen results (Part A: Q1-6) are incomplete or missing.',
      };
    }

    // ASRS Part A scoring: Count how many Q1-6 are marked 'Often'(3) or 'Very Often'(4)
    int oftenOrVeryOftenCountPartA =
        answers
            .sublist(0, partALength)
            .where((a) => a != null && a >= 3) // Check for 3 or 4
            .length;

    // Positive screen if 4 or more questions in Part A meet the threshold
    bool isPositive = oftenOrVeryOftenCountPartA >= 4;

    String message =
        isPositive
            ? 'This screen (Part A) suggests symptoms consistent with ADHD warranting further investigation.'
            : 'This screen (Part A) does not indicate likely ADHD based on ASRS Part A criteria.';
    message +=
        "\n(Screening requires >=4 'Often'/'Very Often' responses in Q1-6. Count: $oftenOrVeryOftenCountPartA)";

    // Optional: Could calculate a Part B score here for additional info if needed

    return {'isPositive': isPositive, 'message': message};
  }

  // Calculates Addiction result (DSM-5 Criteria Count Example)
  Map<String, dynamic> _calculateAddictionResult() {
    // Get the combined addiction results map
    Map<String, dynamic> addictionData = _getMapFromResult(keyAddiction);
    int criteriaQuestionsCount = 11; // 11 Yes/No questions mapping to criteria

    // Check for essential keys in the map
    if (addictionData.isEmpty ||
        !addictionData.containsKey('selectedSubstances') ||
        !addictionData.containsKey('yesNoAnswers')) {
      print("Addiction results data structure is missing or incomplete.");
      return {
        'isPositive': false,
        'message': 'Addiction results data structure is missing or incomplete.',
        'score': null,
      };
    }

    Map<String, bool> selectedSubstances;
    List<bool?> yesNoAnswers;

    // Safely extract and cast selected substances map
    try {
      if (addictionData['selectedSubstances'] is Map) {
        selectedSubstances = Map<String, bool>.from(
          addictionData['selectedSubstances'],
        );
      } else {
        throw FormatException("selectedSubstances is not a Map");
      }
    } catch (e) {
      print("Error casting Addiction selected substances: $e");
      selectedSubstances = {}; // Default to empty on error
    }

    // Safely extract and cast Yes/No answers list
    try {
      if (addictionData['yesNoAnswers'] is List) {
        yesNoAnswers = List<bool?>.from(
          (addictionData['yesNoAnswers'] as List).map(
            (item) => item is bool ? item : null,
          ),
        );
      } else {
        throw FormatException("yesNoAnswers is not a List");
      }
    } catch (e) {
      print("Error casting Addiction Yes/No answers: $e");
      yesNoAnswers = []; // Default to empty on error
    }

    // --- Logic based on selections ---

    // Case 1: User explicitly selected "Nothing"
    if (selectedSubstances['Nothing'] == true) {
      return {
        'isPositive': false, // Negative screen if no use reported
        'message': 'No substance use reported in the past 12 months.',
        'score': 0, // Score is 0
      };
    }

    // Case 2: User selected some substances (or didn't select "Nothing")
    bool anySubstanceSelected = selectedSubstances.entries.any(
      (e) => e.key != 'Nothing' && e.value == true,
    );

    if (!anySubstanceSelected) {
      // This means they didn't select "Nothing" NOR any other substance - incomplete input
      print(
        "Addiction screen substance selection is incomplete (neither 'Nothing' nor specific substances selected).",
      );
      return {
        'isPositive': false,
        'message': 'Addiction screen substance selection is incomplete.',
        'score': null,
      };
    }

    // If substances were selected, the Yes/No answers are required
    if (yesNoAnswers.length < criteriaQuestionsCount ||
        yesNoAnswers.contains(null)) {
      print(
        "Addiction criteria questions (Q1-11) are incomplete. Length: ${yesNoAnswers.length}, Contains null: ${yesNoAnswers.contains(null)}",
      );
      return {
        'isPositive': false,
        'message': 'Addiction criteria questions (Q1-11) are incomplete.',
        'score': null,
      };
    }

    // --- Calculate Score (Criteria Met) ---
    // Count 'Yes' answers (true values) among the 11 criteria questions
    int criteriaMetCount = yesNoAnswers.where((a) => a == true).length;

    // Determine severity based on DSM-5 criteria count for Substance Use Disorder (SUD)
    String severity;
    bool isPositive; // Define positive screen based on meeting SUD criteria

    if (criteriaMetCount >= 6) {
      severity = 'Severe Substance Use Disorder criteria met';
      isPositive = true;
    } else if (criteriaMetCount >= 4) {
      severity = 'Moderate Substance Use Disorder criteria met';
      isPositive = true;
    } else if (criteriaMetCount >= 2) {
      severity = 'Mild Substance Use Disorder criteria met';
      isPositive = true;
    } else {
      // 0 or 1 criterion met
      severity =
          'Does not meet criteria for Substance Use Disorder (less than 2 criteria met)';
      isPositive = false;
    }

    return {
      'isPositive': isPositive,
      'message': 'Criteria Met: $criteriaMetCount/11. Suggests: $severity.',
      'score': criteriaMetCount, // Return the count of criteria met
    };
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen dimensions once
    final screenHeight = MediaQuery.of(context).size.height;

    // --- Calculate all results ---
    // These methods use the helper functions and don't need context
    final depressionResult = _calculateDepressionResult();
    final anxietyResult = _calculateAnxietyResult();
    final ocdResult = _calculateOCDResult();
    final bipolarResult = _calculateBipolarResult();
    final adhdResult = _calculateADHDResult();
    final addictionResult = _calculateAddictionResult();

    // List to hold the widgets for positive results
    List<Widget> resultsWidgets = [];
    int positiveCount = 0; // Track number of positive results shown

    // --- Build sections for POSITIVE results ONLY ---
    if (depressionResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/deppic.png', // Verify path
          title: 'Signs Consistent with Depression',
          message:
              depressionResult['message'] ??
              'Details unavailable.', // Use null-aware operator
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (anxietyResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/anxietypic.png', // Verify path
          title: 'Signs Consistent with Anxiety',
          message: anxietyResult['message'] ?? 'Details unavailable.',
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (ocdResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/ocdpic.png', // Verify path
          title: 'Signs Consistent with OCD',
          message: ocdResult['message'] ?? 'Details unavailable.',
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (bipolarResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/bipolarpic1.png', // Verify path
          title: 'Signs Warranting Bipolar Evaluation',
          message: bipolarResult['message'] ?? 'Details unavailable.',
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (adhdResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/adhdpic.png', // Verify path
          title: 'Signs Consistent with ADHD',
          message: adhdResult['message'] ?? 'Details unavailable.',
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }
    if (addictionResult['isPositive'] == true) {
      resultsWidgets.add(
        _buildResultSection(
          screenHeight: screenHeight,
          imagePath: 'assets/images/addictionpic.png', // Verify path
          title: 'Signs Consistent with Substance Use Disorder',
          message: addictionResult['message'] ?? 'Details unavailable.',
          showAlsoPrefix: positiveCount > 0,
        ),
      );
      positiveCount++;
    }

    // --- Determine final output based on positive count ---
    if (resultsWidgets.isEmpty) {
      // *** If NO positive results were found, show the "No Significant Signs" message ***
      // Add the specific widget for this case. It needs context for the button.
      resultsWidgets.add(_buildNoSignificantSigns(context, screenHeight));
    } else {
      // *** If there WERE positive results, add the final disclaimer at the end ***
      // Add the disclaimer widget. It needs context for the button.
      resultsWidgets.add(_buildFinalDisclaimer(context));
    }

    // Return the Scaffold containing a ListView of the determined widgets
    return Scaffold(
      backgroundColor: Colors.white, // Set background for the whole screen area
      body: ListView(
        // Use ListView for scrollability
        padding: EdgeInsets.zero, // Remove default padding
        children: resultsWidgets, // Display the generated list of widgets
      ),
    );
  }

  // --- Widget Builder Methods ---

  // Widget for the "No significant signs" message
  // Takes context for the 'Done' button navigation
  Widget _buildNoSignificantSigns(BuildContext context, double screenHeight) {
    final Color noteColor = Colors.grey.shade700;
    final Color buttonColor = const Color(0xFF5588A4);
    final Color iconColor = Colors.green.shade600; // Positive outcome color

    return Container(
      // Ensure it takes up significant vertical space
      constraints: BoxConstraints(minHeight: screenHeight * 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      color: Colors.white, // Ensure background is white
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            Image.asset(
              // Ensure this path is correct in your assets
              'assets/images/nomentalissuepic.png',
              height: screenHeight * 0.2, // Responsive image size
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.check_circle_outline_rounded, // Fallback icon
                    size: 80,
                    color: iconColor,
                  ),
            ),
            const SizedBox(height: 40),
            // Main message
            Text(
              'Based on your responses, this screening did not indicate significant signs matching the criteria for the assessed conditions at this time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18, // Slightly smaller for better fit
                color: noteColor,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 25),
            // Standard disclaimer
            Text(
              'Remember, this is a screening tool, not a diagnosis. If you have ongoing concerns about your mental health, please consult a qualified healthcare professional.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: noteColor.withOpacity(0.9), // Slightly darker note color
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            // Done Button
            ElevatedButton(
              onPressed: () {
                // Pop the current screen (FinalResultsScreen)
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Fallback if it cannot pop (e.g., deep linking)
                  // Consider navigating home: Navigator.pushReplacementNamed(context, '/home');
                  print("Cannot pop FinalResultsScreen.");
                }
                print("Done button tapped (No significant signs)");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
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
  // Does NOT need context directly. Uses passed screenHeight.
  Widget _buildResultSection({
    required double screenHeight,
    required String imagePath,
    required String title,
    required String message,
    bool showAlsoPrefix = false, // Flag to add "Also,"
  }) {
    // Define colors
    final Color headerColor = const Color(0xFF5588A4);
    final Color contentBgColor = Colors.white;
    final Color primaryTextColor = const Color(0xFF276181);
    final Color secondaryTextColor = Colors.black87;

    // Prepend "Also, " if needed
    String displayTitle = showAlsoPrefix ? "Also, $title" : title;

    return Column(
      children: [
        // Header with Image
        Container(
          color: headerColor,
          height: screenHeight * 0.28, // Responsive height
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              imagePath, // Specific image for the condition
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image '$imagePath': $error");
                return const Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white70,
                    size: 50,
                  ),
                );
              },
            ),
          ),
        ),
        // Content Area (White, curved top)
        Container(
          width: double.infinity,
          transform: Matrix4.translationValues(0.0, -30.0, 0.0), // Overlap
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
            boxShadow: [
              // Optional shadow for depth between sections
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2), // Shadow below the curve
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title (e.g., "Signs Consistent with Depression")
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
              // Specific message from the calculation
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
              const SizedBox(
                height: 30.0,
              ), // Bottom padding inside the white box
            ],
          ),
        ),
      ],
    );
  }

  // Widget for the final disclaimer note (shown only when positive results exist)
  // Takes context for the 'Finish' button navigation
  Widget _buildFinalDisclaimer(BuildContext context) {
    final Color noteColor = Colors.grey.shade600;
    final Color primaryTextColor = const Color(0xFF276181);
    final Color buttonColor = const Color(0xFF5588A4);

    return Container(
      // Add padding around the disclaimer section
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
      color: Colors.white, // Ensure white background
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
            'Mental health is complex, and symptoms can overlap between conditions. Only a qualified healthcare professional (like a psychiatrist, psychologist, or licensed therapist) can provide an accurate diagnosis after a comprehensive evaluation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: noteColor, height: 1.5),
          ),
          const SizedBox(height: 15),
          Text(
            'If you are concerned about your mental health based on these results or other factors, please consult a professional. They can help you understand your situation better and discuss appropriate next steps or treatment options.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: noteColor,
              height: 1.5,
              fontWeight: FontWeight.w500, // Slightly emphasize call to action
            ),
          ),
          const SizedBox(height: 40),
          // Finish Button
          ElevatedButton(
            onPressed: () {
              // Pop the current screen (FinalResultsScreen)
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                print("Cannot pop FinalResultsScreen.");
                // Fallback: Navigator.pushReplacementNamed(context, '/home');
              }
              print("Finish button tapped (Positive results shown)");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
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
} // End of FinalResultsScreen class