// depression_screen.dart
import 'package:flutter/material.dart';
// import 'dart:convert'; // Not strictly needed now
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the keys and constants from SelfAssessmentScreen
import 'SelfAssessmentScreen.dart'
    show keyDepression, firestoreCollection, fieldPartialSaves;

class DepressionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialState;

  const DepressionScreen({super.key, this.initialState});

  @override
  State<DepressionScreen> createState() => _DepressionScreenState();
}

class _DepressionScreenState extends State<DepressionScreen> {
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;

  List<int?> _answers = List.filled(21, null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentReference? _userProgressDocRef;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Q1. How sad do you feel?',
      'options': [
        'I do not feel sad.',
        'I feel sad',
        'I am sad all the time and I can\'t snap out',
        'I am so sad and unhappy that I can\'t stand it.',
      ],
    },
    {
      'question': 'Q2. How do you feel about the future?',
      'options': [
        'I am not particularly discouraged about the future.',
        'I feel discouraged about the future.',
        'I feel I have nothing to look forward to.',
        'I feel the future is hopeless and that things cannot improve.',
      ],
    },
    {
      'question': 'Q3. Do you think you are a failure?',
      'options': [
        'I do not feel like a failure.',
        'I feel I have failed more than the average person',
        'As I look back on my life, all I can see is a lot of failures',
        'I feel I am a complete failure as a person.',
      ],
    },
    {
      'question': 'Q4. Do you get satisfaction from activities?',
      'options': [
        'I get as much satisfaction out of things as I used to.',
        'I don\'t enjoy things the way I used to.',
        'I don\'t get real satisfaction out of anything anymore.',
        'I am dissatisfied or bored with everything.',
      ],
    },
    {
      'question': 'Q5. Do you feel Guilty?',
      'options': [
        'I don\'t feel particularly guilty',
        'I feel guilty a good part of the time',
        'I feel quite guilty most of the time.',
        'I feel guilty all of the time.',
      ],
    },
    {
      'question': 'Q6. Do you think you are being punished?',
      'options': [
        'I don\'t feel I am being punished',
        'I feel I may be punished',
        'I expect to be punished',
        'I feel I am being punished.',
      ],
    },
    {
      'question': 'Q7. How do you feel about yourself?',
      'options': [
        'I don\'t feel disappointed in myself.',
        'I am disappointed in myself.',
        'I am disgusted with myself.',
        'I hate myself.',
      ],
    },
    {
      'question': 'Q8. Do you think you are worse than anybody?',
      'options': [
        'I don\'t feel I am any worse than anybody else',
        'I am critical of myself for my weaknesses or mistakes',
        'I blame myself all the time for my faults',
        'I blame myself for everything bad that happens.',
      ],
    },
    {
      'question': 'Q9. Do you think of self-harm or suicide?',
      'options': [
        'I don\'t have any thoughts of killing myself.',
        'I have thoughts of killing myself, but I wouldn\'t carry them out.',
        'I would like to kill myself.',
        'I would kill myself if I had the chance.',
      ],
    },
    {
      'question': 'Q10. How often do you cry?',
      'options': [
        'I don\'t cry any more than usual.',
        'I cry more now than I used to',
        'I cry all the time now',
        'I used to be able to cry, but now I can\'t cry even though I want to.',
      ],
    },
    {
      'question': 'Q11. How\'s your current level of annoyance?',
      'options': [
        'I am no more irritated by things than I ever was.',
        'I am slightly more irritated now than usual.',
        'I am annoyed or irritated a good deal of the time.',
        'I feel irritated all the time.',
      ],
    },
    {
      'question': 'Q12. Did you lost interest in people?',
      'options': [
        'I have not lost interest in other people',
        'I am less interested in other people than I used to be.',
        'I have lost most of my interest in other people.',
        'I have lost all of my interest in other people.',
      ],
    },
    {
      'question': 'Q13. Your current ability to make decisions?',
      'options': [
        'I make decisions about as well as I ever could.',
        'I put off making decisions more than I used to.',
        'I have greater difficulty in making decisions.',
        'I can\'t make decisions at all anymore.',
      ],
    },
    {
      'question': 'Q14. What do you think about your appearance?',
      'options': [
        'I don\'t feel that I look any worse than I used to.',
        'I am worried that I am looking old or unattractive',
        'I feel there are permanent changes in my appearance that make me look unattractive',
        'I believe that I look ugly.',
      ],
    },
    {
      'question': 'Q15. Current ability to work or get things done?',
      'options': [
        'I can work about as well as before.',
        'It takes extra effort to get started at something.',
        'I have to push myself very hard to do anything.',
        'I can\'t do any work at all.',
      ],
    },
    {
      'question': 'Q16. Do you sleep well?',
      'options': [
        'I can sleep as well as usual.',
        'I don\'t sleep as well as I used to.',
        'I wake up 1-2 hours earlier than usual and find it hard to get back to sleep.',
        'I wake up several hours earlier than I used to and cannot get back to sleep.',
      ],
    },
    {
      'question': 'Q17. Your current level of fatigue or tiredness?',
      'options': [
        'I don\'t get more tired than usual.',
        'I get tired more easily than I used to.',
        'I get tired from doing almost anything.',
        'I am too tired to do anything.',
      ],
    },
    {
      'question': 'Q18. How do you feel about your appetite?',
      'options': [
        'My appetite is no worse than usual.',
        'My appetite is not as good as it used to be.',
        'My appetite is much worse now.',
        'I have no appetite at all anymore.',
      ],
    },
    {
      'question': 'Q19. How much weight have you lost recently?',
      'options': [
        'I haven\'t lost much weight, if any, lately.',
        'I have lost more than five pounds.',
        'I have lost more than ten pounds.',
        'I have lost more than fifteen pounds.',
      ],
    },
    {
      'question': 'Q20. How you feel about your health?',
      'options': [
        'I am no more worried about my health than usual.',
        'I am worried about physical problems like aches, pains, upset stomach, or constipation.',
        'I am very worried about physical problems and it\'s hard to think of much else.',
        'I am so worried about my physical problems that I cannot think of anything else.',
      ],
    },
    {
      'question': 'Q21. How has your interest in sex changed?',
      'options': [
        'I have not noticed any recent change.',
        'I am less interested in sex than I used to be.',
        'I have almost no interest in sex.',
        'I have lost interest in sex completely.',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _userProgressDocRef = _firestore
          .collection(firestoreCollection) // Uses imported constant
          .doc(_currentUser!.uid);
      print("[DepressionScreen] initState: User ID: ${_currentUser!.uid}");
      print(
        "[DepressionScreen] Progress Document Path: ${_userProgressDocRef?.path}",
      );
      _initializeState();
    } else {
      print("Error: CurrentUser is null in DepressionScreen initState");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: User not logged in."),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _initializeState() {
    if (widget.initialState != null && mounted) {
      print(
        "DepressionScreen: Initializing state from passed data: ${widget.initialState}",
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
            print("DepressionScreen: Initialized with saved state: $_answers");
          } else {
            print(
              "DepressionScreen: Initial state 'answers' length mismatch (${loadedAnswers.length} vs ${_answers.length}). Using defaults.",
            );
          }
        } else {
          print(
            "DepressionScreen: Initial state missing 'answers' key or not a list. Using defaults.",
          );
        }
      } catch (e) {
        print(
          "DepressionScreen: Error parsing initial state data: $e. Using defaults.",
        );
        setState(() {
          _answers = List.filled(21, null);
        });
      }
    } else {
      print("DepressionScreen: No initial state passed. Using defaults.");
    }
  }

  Future<void> _saveStateToFirestore() async {
    if (_userProgressDocRef == null) {
      print(
        "DepressionScreen Error: Cannot save state, _userProgressDocRef is null. Ensure user is logged in and Firestore is reachable.",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not save. User session issue?'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (!mounted) return;

    setState(() => _isSaving = true);

    final Map<String, dynamic> currentStateForFirestore = {'answers': _answers};
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyDepression';

    // --- Enhanced Logging ---
    print("DepressionScreen: Attempting to save partial state to Firestore.");
    print("DepressionScreen: User ID: ${_currentUser?.uid}");
    print("DepressionScreen: Document Path: ${_userProgressDocRef?.path}");
    print(
      "DepressionScreen: Data to save under '$keyDepression': $currentStateForFirestore",
    );
    print(
      "DepressionScreen: Full data object for set: ${{
        fieldPartialSaves: {keyDepression: currentStateForFirestore},
      }}",
    );
    print(
      "DepressionScreen: Field path for merge option: $fieldPathForThisStep",
    );
    // --- End Enhanced Logging ---

    try {
      await _userProgressDocRef!.set({
        fieldPartialSaves: {keyDepression: currentStateForFirestore},
      }, SetOptions(mergeFields: [fieldPathForThisStep]));

      print(
        "DepressionScreen: Partial state SAVE SUCCEEDED for '$keyDepression'.",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress saved.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, 'saved');
      }
    } catch (e, s) {
      // Added stack trace to catch
      print("DepressionScreen: Error saving state to Firestore: $e");
      print("DepressionScreen: Stack trace: $s"); // Print stack trace
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save progress. Check console for errors.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _clearPartialSaveFromFirestore() async {
    if (_userProgressDocRef == null || !mounted) return;
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyDepression';
    print(
      "DepressionScreen: Attempting to clear partial save for '$keyDepression' at ${_userProgressDocRef!.path}",
    );
    try {
      await _userProgressDocRef!.update({
        fieldPathForThisStep: FieldValue.delete(),
      });
      print(
        "DepressionScreen: Cleared partial save for '$keyDepression' from Firestore.",
      );
    } catch (e, s) {
      print(
        "DepressionScreen: Error clearing partial save for '$keyDepression' from Firestore: $e. This might be okay if it wasn't saved before.",
      );
      print("Stack trace: $s");
    }
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
        print("DepressionScreen: Back button pressed.");
        Navigator.pop(context, null);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Depression Assessment (Step 1)'),
          backgroundColor: _primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, null),
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
              _buildNavigateButton(),
              const SizedBox(height: 12.0),
              _buildSaveLink(),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    const String imagePath = 'assets/images/step1pic.png';
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

  Widget _buildQuestionBlock(int questionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _questions[questionIndex]['question'],
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: _questionTextColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16.0),
        Column(
          children: List.generate(
            _questions[questionIndex]['options'].length,
            (optionIndex) => _buildOption(
              text: _questions[questionIndex]['options'][optionIndex],
              optionValue: optionIndex,
              questionIndex: questionIndex,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String text,
    required int optionValue,
    required int questionIndex,
  }) {
    final bool isSelected = _answers[questionIndex] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          if (!mounted) return;
          setState(() {
            _answers[questionIndex] = optionValue;
          });
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          if (!mounted) return;
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

          await _clearPartialSaveFromFirestore();
          print("[DepressionScreen] Popping with final data: $_answers");
          Navigator.pop(context, List<int?>.from(_answers));
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
        child: const Text('Complete Step 1'),
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
                      color: _primaryColor,
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