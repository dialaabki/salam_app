// BipolarScreen.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // Keep for potential future use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the keys and constants
// Adjust the import path if necessary
import 'SelfAssessmentScreen.dart'
    show keyBipolar, firestoreCollection, fieldPartialSaves;

class BipolarScreen extends StatefulWidget {
  final Map<String, dynamic>? initialState; // Accepts initial state

  const BipolarScreen({super.key, this.initialState});

  @override
  State<BipolarScreen> createState() => _BipolarScreenState();
}

class _BipolarScreenState extends State<BipolarScreen> {
  // --- UI Styling Constants ---
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;

  // --- State Variables ---
  // MDQ has 13 symptom questions + 1 concurrence + 1 impairment + 2 history = 17 items
  List<int?> _answers = List.filled(17, null);

  // --- Firebase Instances and State ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentReference? _userProgressDocRef;
  bool _isSaving = false;

  // --- Questions Data ---
  // (Keep your existing _questions list here - omitted for brevity)
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 1, // Index 0
      'type': 'yes_no', // 0=Yes, 1=No
      'question':
          'Q1. Has there ever been a period of time when you were not your usual self and you felt so good or so hyper that other people thought you were not your normal self or you were so hyper that you got into trouble?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 2, // Index 1
      'type': 'yes_no',
      'question':
          'Q2. Has there ever been a period of time when you were not your usual self and you were so irritable that you shouted at people or started fights or arguments?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 3, // Index 2
      'type': 'yes_no',
      'question':
          'Q3. Has there ever been a period of time when you were not your usual self and you felt much more self-confident than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 4, // Index 3
      'type': 'yes_no',
      'question':
          'Q4. Has there ever been a period of time when you were not your usual self and you got much less sleep than usual and found you didn\'t really miss it?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 5, // Index 4
      'type': 'yes_no',
      'question':
          'Q5. Has there ever been a period of time when you were not your usual self and you were much more talkative or spoke faster than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 6, // Index 5
      'type': 'yes_no',
      'question':
          'Q6. Has there ever been a period of time when you were not your usual self and thoughts raced through your head or you couldn\'t slow your mind down?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 7, // Index 6
      'type': 'yes_no',
      'question':
          'Q7. Has there ever been a period of time when you were not your usual self and you were so easily distracted by things around you that you had trouble concentrating or staying on track?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 8, // Index 7
      'type': 'yes_no',
      'question':
          'Q8. Has there ever been a period of time when you were not your usual self and you had much more energy than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 9, // Index 8
      'type': 'yes_no',
      'question':
          'Q9. Has there ever been a period of time when you were not your usual self and you were much more active or did many more things than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 10, // Index 9
      'type': 'yes_no',
      'question':
          'Q10. Has there ever been a period of time when you were not your usual self and you were much more social or outgoing than usual, for example, you telephoned friends in the middle of the night?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 11, // Index 10
      'type': 'yes_no',
      'question':
          'Q11. Has there ever been a period of time when you were not your usual self and you were much more interested in sex than usual?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 12, // Index 11
      'type': 'yes_no',
      'question':
          'Q12. Has there ever been a period of time when you were not your usual self and you did things that were unusual for you or that other people might have thought were excessive, foolish, or risky?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 13, // Index 12
      'type': 'yes_no',
      'question':
          'Q13. Has there ever been a period of time when you were not your usual self and spending money got you or your family in trouble?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 14, // Index 13 - Concurrence
      'type': 'yes_no',
      'question':
          'Q14. If you checked YES to more than one of the above, have several of these ever happened during the same period of time?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 15, // Index 14 - Impairment
      'type': 'multiple_choice_4', // 0=No, 1=Minor, 2=Moderate, 3=Serious
      'question':
          'Q15. How much of a problem did any of these cause you — like being unable to work; having family, money, or legal troubles; getting into arguments or fights?',
      'options': [
        'No problem',
        'Minor problem',
        'Moderate problem',
        'Serious problem',
      ],
    },
    {
      'id': 16, // Index 15 - Family History
      'type': 'yes_no',
      'question':
          'Q16. Have any of your blood relatives (ie, children, siblings, parents, grandparents, aunts, uncles) had manic-depressive illness or bipolar disorder?',
      'options': ['Yes', 'No'],
    },
    {
      'id': 17, // Index 16 - Personal History
      'type': 'yes_no',
      'question':
          'Q17. Has a health professional ever told you that you have manic-depressive illness or bipolar disorder?',
      'options': ['Yes', 'No'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _userProgressDocRef = _firestore
          .collection(firestoreCollection)
          .doc(_currentUser!.uid);
      _initializeState();
    } else {
      print("Error: CurrentUser is null in BipolarScreen initState");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: User not logged in."),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop(); // Go back
        }
      });
    }
  }

  void _initializeState() {
    if (widget.initialState != null && mounted) {
      print(
        "BipolarScreen: Initializing state from passed data: ${widget.initialState}",
      );
      try {
        if (widget.initialState!.containsKey('answers') &&
            widget.initialState!['answers'] is List) {
          List<dynamic> dynamicList = widget.initialState!['answers'];
          List<int?> loadedAnswers =
              dynamicList.map((item) => item is int ? item : null).toList();
          if (loadedAnswers.length == _answers.length) {
            setState(() {
              _answers = loadedAnswers;
            });
            print("BipolarScreen: Initialized with saved state.");
          } else {
            print(
              "BipolarScreen: Initial state 'answers' length mismatch (${loadedAnswers.length} vs ${_answers.length}). Using defaults.",
            );
          }
        } else {
          print(
            "BipolarScreen: Initial state missing 'answers' key or not a list. Using defaults.",
          );
        }
      } catch (e) {
        print(
          "BipolarScreen: Error parsing initial state data: $e. Using defaults.",
        );
        setState(() {
          _answers = List.filled(17, null); // Reset
        });
      }
    } else {
      print("BipolarScreen: No initial state passed. Using defaults.");
    }
  }

  Future<void> _saveStateToFirestore() async {
    if (_userProgressDocRef == null) {
      print(
        "BipolarScreen Error: Cannot save state, _userProgressDocRef is null.",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not save. Are you logged in?'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (!mounted) return;

    setState(() => _isSaving = true);

    final Map<String, dynamic> currentStateForFirestore = {'answers': _answers};
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyBipolar';

    try {
      await _userProgressDocRef!.set({
        fieldPartialSaves: {keyBipolar: currentStateForFirestore},
      }, SetOptions(mergeFields: [fieldPathForThisStep]));

      print("BipolarScreen: Partial state saved to Firestore.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress saved.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, 'saved'); // Signal save
      }
    } catch (e) {
      print("BipolarScreen: Error saving state to Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save progress.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _clearPartialSaveFromFirestore() async {
    if (_userProgressDocRef == null || !mounted) return;
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyBipolar';
    try {
      await _userProgressDocRef!.update({
        fieldPathForThisStep: FieldValue.delete(),
      });
      print(
        "BipolarScreen: Cleared partial save for '$keyBipolar' from Firestore.",
      );
    } catch (e) {
      print(
        "BipolarScreen: Error clearing partial save for '$keyBipolar' from Firestore: $e.",
      );
    }
  }

  // Helper to get the correct index in the _answers list (0-based)
  int _getAnswerIndex(int questionId) {
    // Assuming question IDs are sequential 1 to 17
    return questionId - 1;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: _primaryColor,
        ),
        body: const Center(
          child: Text("User not available. Please log in again."),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        print("BipolarScreen: Back button pressed.");
        Navigator.pop(context, null); // Signal normal back navigation
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mood Questionnaire (Step 4)'),
          backgroundColor: _primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, null), // Normal back
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderImage(),
              const SizedBox(height: 24.0),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) => _buildQuestionBlock(index),
                separatorBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: _dividerColor, thickness: 1.0),
                    ),
              ),
              const SizedBox(height: 30.0),
              _buildNavigateButton(), // Complete button
              const SizedBox(height: 12.0),
              _buildSaveLink(), // Save link
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    const String imagePath =
        'assets/images/step4pic.png'; // Ensure path is correct
    return Center(
      child: Image.asset(
        imagePath,
        height: 60,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image '$imagePath': $error");
          return Container(
            height: 60,
            width: 100,
            color: _inactiveColor.withOpacity(0.3),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionBlock(int index) {
    final questionData = _questions[index];
    final String type = questionData['type'];
    final String questionText = questionData['question'];
    final int questionId = questionData['id'];
    final answerIndex = _getAnswerIndex(
      questionId,
    ); // Get index for _answers list

    // Basic validation
    if (answerIndex < 0 || answerIndex >= _answers.length) {
      print("Error: Invalid answer index $answerIndex for QID $questionId");
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
          ), // Avoid text touching edge
          child: Text(
            questionText,
            style: TextStyle(
              fontSize: 16.0, // Consistent font size
              fontWeight: FontWeight.w600,
              color: _questionTextColor,
              height: 1.4, // Line spacing
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        // Build options based on type
        if (type == 'yes_no')
          _buildYesNoOptions(answerIndex, questionData['options'])
        else if (type == 'multiple_choice_4')
          _buildMultipleChoiceOptions(answerIndex, questionData['options']),
      ],
    );
  }

  // Builds vertical radio options for Q15 (impairment)
  Widget _buildMultipleChoiceOptions(int answerIndex, List<String> options) {
    return Column(
      children: List.generate(
        options.length,
        (optionIndex) => _buildVerticalOption(
          text: options[optionIndex],
          optionValue: optionIndex, // Stores 0, 1, 2, 3
          questionIndexForAnswer: answerIndex,
        ),
      ),
    );
  }

  // Builds horizontal Yes/No options
  Widget _buildYesNoOptions(int answerIndex, List<String> options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(options.length, (optionIndex) {
        // Yes = 0, No = 1
        final bool isSelected = _answers[answerIndex] == optionIndex;
        return Padding(
          padding: EdgeInsets.only(right: optionIndex == 0 ? 30.0 : 0),
          child: InkWell(
            onTap: () {
              if (!mounted) return;
              setState(() {
                _answers[answerIndex] = optionIndex;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom radio button
                Container(
                  width: 22.0,
                  height: 22.0,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _borderColor : _inactiveColor,
                      width: 2.0,
                    ),
                  ),
                  child:
                      isSelected
                          ? Center(
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _borderColor,
                              ),
                            ),
                          )
                          : null,
                ),
                // Option text (Yes/No)
                Text(
                  options[optionIndex],
                  style: TextStyle(fontSize: 15.0, color: _optionTextColor),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Builds a single vertical radio option
  Widget _buildVerticalOption({
    required String text,
    required int optionValue,
    required int questionIndexForAnswer,
  }) {
    final bool isSelected = _answers[questionIndexForAnswer] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          setState(() {
            _answers[questionIndexForAnswer] = optionValue;
          });
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom radio button
            Container(
              width: 22.0,
              height: 22.0,
              margin: const EdgeInsets.only(top: 2.0, right: 12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _borderColor : _inactiveColor,
                  width: 2.0,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _borderColor,
                          ),
                        ),
                      )
                      : null,
            ),
            // Option text
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 15.0, color: _optionTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Make async
          if (!mounted) return;
          // Validation: Check all answered
          bool allAnswered = !_answers.contains(null);
          if (!allAnswered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please answer all questions before proceeding.'),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }

          // Clear partial save
          await _clearPartialSaveFromFirestore();

          // Pop with results
          print('Step 4 (Bipolar) Answers: $_answers');
          Navigator.pop(context, List<int?>.from(_answers)); // Return copy
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
        child: const Text('Complete Step 4'),
      ),
    );
  }

  Widget _buildSaveLink() {
    return Center(
      child: InkWell(
        onTap: _isSaving ? null : _saveStateToFirestore,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              _isSaving
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: _primaryColor, // <-- CORRECTED,
                    ),
                  )
                  : Text(
                    'Save and continue later >>',
                    style: TextStyle(
                      fontSize: 14,
                      color: _primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: _primaryColor,
                    ),
                  ),
        ),
      ),
    );
  }
}