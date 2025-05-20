// addictionscreen.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // Keep for potential future use
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the keys and constants
// Adjust the import path if necessary
import 'SelfAssessmentScreen.dart'
    show keyAddiction, firestoreCollection, fieldPartialSaves;

class AddictionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialState; // Accepts initial state

  const AddictionScreen({super.key, this.initialState});

  @override
  State<AddictionScreen> createState() => _AddictionScreenState();
}

class _AddictionScreenState extends State<AddictionScreen> {
  // --- UI Styling Constants ---
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;
  final Color _checklistLabelColor = Colors.grey.shade600;

  // --- State Variables ---
  // Map to store which substances are selected
  Map<String, bool> _selectedSubstances = {
    'Alcohol': false,
    'Cannabis': false, // (Marijuana, Hashish)
    'Stimulants': false, // (Cocaine, Meth, Amphetamines like Adderall)
    'Opioids':
        false, // (Heroin, Prescription Painkillers like Oxycodone, Fentanyl)
    'Sedatives & Hypnotics':
        false, // (Benzodiazepines like Xanax, Sleeping Pills)
    'Hallucinogens': false, // (LSD, Psilocybin/Mushrooms, PCP, Ecstasy/MDMA)
    'Inhalants': false, // (Glue, Solvents, Aerosols)
    'Tobacco & Nicotine': false, // (Cigarettes, Vapes, Chewing Tobacco)
    'Other': false, // Specify if needed
    'Nothing': false, // Mutually exclusive option
  };
  // List for the 11 DSM-5 criteria questions (Yes/No -> true/false)
  List<bool?> _yesNoAnswers = List.filled(11, null);

  // --- Firebase Instances and State ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  DocumentReference? _userProgressDocRef;
  bool _isSaving = false;

  // --- Question Data ---
  // Examples for substance clarification
  final Map<String, String> _substanceExamples = {
    'Alcohol': '(e.g., Beer, Wine, Liquor)',
    'Cannabis': '(e.g., Marijuana, Hashish, Edibles)',
    'Stimulants': '(e.g., Cocaine, Methamphetamine, Adderall, Ritalin)',
    'Opioids': '(e.g., Heroin, Oxycodone, Fentanyl, Morphine, Codeine)',
    'Sedatives & Hypnotics': '(e.g., Xanax, Valium, Ambien, Lunesta)',
    'Hallucinogens': '(e.g., LSD, Psilocybin/Mushrooms, MDMA/Ecstasy, PCP)',
    'Inhalants': '(e.g., Glue, Paint Thinner, Aerosols, Nitrous Oxide)',
    'Tobacco & Nicotine':
        '(e.g., Cigarettes, Vapes, Chewing Tobacco, Nicotine Pouches)',
    'Other': '(Specify if applicable)',
    'Nothing': '(I have not used any substances in the past 12 months)',
  };
  // DSM-5 criteria mapped to Yes/No questions
  final List<Map<String, dynamic>> _yesNoQuestions = [
    {
      'id': 1,
      'question':
          'Q1. Taken in larger amounts or over longer period than intended?',
    },
    {
      'id': 2,
      'question':
          'Q2. Persistent desire or unsuccessful efforts to cut down/control use?',
    },
    {
      'id': 3,
      'question':
          'Q3. Great deal of time spent obtaining, using, or recovering?',
    },
    {'id': 4, 'question': 'Q4. Craving, or a strong desire or urge to use?'},
    {
      'id': 5,
      'question':
          'Q5. Recurrent use resulting in failure to fulfill major role obligations (work, school, home)?',
    },
    {
      'id': 6,
      'question':
          'Q6. Continued use despite persistent social/interpersonal problems caused/exacerbated by effects?',
    },
    {
      'id': 7,
      'question':
          'Q7. Important social, occupational, or recreational activities given up/reduced?',
    },
    {
      'id': 8,
      'question':
          'Q8. Recurrent use in situations where it is physically hazardous (e.g., driving)?',
    },
    {
      'id': 9,
      'question':
          'Q9. Use continued despite knowledge of persistent physical/psychological problem likely caused/exacerbated by it?',
    },
    {
      'id': 10,
      'question':
          'Q10. Tolerance (need more for same effect, or diminished effect with same amount)?',
    },
    {
      'id': 11,
      'question':
          'Q11. Withdrawal (characteristic withdrawal syndrome, or substance taken to relieve/avoid withdrawal)?',
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
      print("Error: CurrentUser is null in AddictionScreen initState");
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
        "AddictionScreen: Initializing state from passed data: ${widget.initialState}",
      );
      try {
        Map<String, dynamic> loadedState = widget.initialState!;

        // Load selectedSubstances (Map<String, bool>)
        if (loadedState.containsKey('selectedSubstances') &&
            loadedState['selectedSubstances'] is Map) {
          Map<String, dynamic> rawMap = Map<String, dynamic>.from(
            loadedState['selectedSubstances'],
          );
          Map<String, bool> loadedMap = {};
          bool keysMatch = true;

          // Check if all keys from saved data exist in the current _selectedSubstances map
          // and if values are booleans
          rawMap.forEach((key, value) {
            if (_selectedSubstances.containsKey(key) && value is bool) {
              loadedMap[key] = value;
            } else {
              print(
                "AddictionScreen: Mismatch/Invalid key or type in saved 'selectedSubstances': $key -> $value",
              );
              keysMatch = false; // Mark as mismatch if key/type invalid
            }
          });

          // Also ensure all expected keys are present in the loaded data
          if (keysMatch &&
              loadedMap.keys.length == _selectedSubstances.keys.length) {
            setState(() {
              _selectedSubstances = loadedMap;
            });
            print("AddictionScreen: Initialized selectedSubstances.");
          } else {
            print(
              "AddictionScreen: Initial selectedSubstances keys/types mismatch or incomplete. Using defaults.",
            );
            // Reset to default if mismatch
            setState(() {
              _selectedSubstances = {
                for (var k in _selectedSubstances.keys) k: false,
              };
            });
          }
        } else {
          print(
            "AddictionScreen: Initial state missing 'selectedSubstances' or not a map. Using defaults.",
          );
        }

        // Load yesNoAnswers (List<bool?>)
        if (loadedState.containsKey('yesNoAnswers') &&
            loadedState['yesNoAnswers'] is List) {
          List<dynamic> dynamicList = loadedState['yesNoAnswers'];
          // Safely map to List<bool?>, handling potential nulls or wrong types
          List<bool?> loadedAnswers =
              dynamicList.map((item) => item is bool ? item : null).toList();

          // Check if length matches expected number of Yes/No questions
          if (loadedAnswers.length == _yesNoAnswers.length) {
            setState(() {
              _yesNoAnswers = loadedAnswers;
            });
            print("AddictionScreen: Initialized yesNoAnswers.");
          } else {
            print(
              "AddictionScreen: Initial yesNoAnswers length mismatch (${loadedAnswers.length} vs ${_yesNoAnswers.length}). Using defaults.",
            );
            // Keep default if length mismatch
          }
        } else {
          // Only print warning if Yes/No questions *should* have been present
          if (_shouldShowYesNoQuestionsBasedOnState(loadedState)) {
            print(
              "AddictionScreen: Initial state missing 'yesNoAnswers' or not a list, but substances were selected. Using defaults.",
            );
          } else {
            print(
              "AddictionScreen: Initial state missing 'yesNoAnswers' (expected if 'Nothing' was selected). Using defaults.",
            );
          }
        }
      } catch (e) {
        print(
          "AddictionScreen: Error parsing initial state data: $e. Using defaults for all.",
        );
        setState(() {
          _selectedSubstances = {
            for (var k in _selectedSubstances.keys) k: false,
          };
          _yesNoAnswers = List.filled(11, null);
        });
      }
    } else {
      print("AddictionScreen: No initial state passed. Using defaults.");
    }
  }

  // Helper to check if Yes/No questions should be expected based on loaded state
  bool _shouldShowYesNoQuestionsBasedOnState(Map<String, dynamic> state) {
    if (state.containsKey('selectedSubstances') &&
        state['selectedSubstances'] is Map) {
      Map<String, dynamic> subs = Map<String, dynamic>.from(
        state['selectedSubstances'],
      );
      if (subs['Nothing'] == true) return false;
      return subs.entries.any((e) => e.key != 'Nothing' && e.value == true);
    }
    return false; // Default to false if data is missing/invalid
  }

  Future<void> _saveStateToFirestore() async {
    if (_userProgressDocRef == null) {
      print(
        "AddictionScreen Error: Cannot save state, _userProgressDocRef is null.",
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

    // Prepare combined state for saving
    final Map<String, dynamic> currentStateForFirestore = {
      'selectedSubstances': _selectedSubstances, // Map<String, bool>
      'yesNoAnswers': _yesNoAnswers, // List<bool?>
    };
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyAddiction';

    try {
      await _userProgressDocRef!.set({
        fieldPartialSaves: {keyAddiction: currentStateForFirestore},
      }, SetOptions(mergeFields: [fieldPathForThisStep]));

      print("AddictionScreen: Partial state saved to Firestore.");
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
      print("AddictionScreen: Error saving state to Firestore: $e");
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
    final String fieldPathForThisStep = '$fieldPartialSaves.$keyAddiction';
    try {
      await _userProgressDocRef!.update({
        fieldPathForThisStep: FieldValue.delete(),
      });
      print(
        "AddictionScreen: Cleared partial save for '$keyAddiction' from Firestore.",
      );
    } catch (e) {
      print(
        "AddictionScreen: Error clearing partial save for '$keyAddiction' from Firestore: $e.",
      );
    }
  }

  // Getter to determine if the Yes/No questions should be displayed based on current state
  bool get _shouldShowYesNoQuestions => _selectedSubstances.entries.any(
    (entry) => entry.key != 'Nothing' && entry.value == true,
  );

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
        print("AddictionScreen: Back button pressed.");
        Navigator.pop(context, null); // Signal normal back navigation
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          // Using 'Step 6 of 6' for clarity
          title: const Text('Substance Use (Step 6 of 6)'),
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
              // Substance Selection Checklist
              _buildSubstanceChecklist(),
              const SizedBox(height: 10),
              Divider(color: _dividerColor, thickness: 1.0),
              const SizedBox(height: 20),

              // Conditionally display Yes/No Questions
              if (_shouldShowYesNoQuestions)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _yesNoQuestions.length,
                  itemBuilder:
                      (context, index) => _buildYesNoQuestionBlock(index),
                  separatorBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: _dividerColor, thickness: 1.0),
                      ),
                )
              else if (_selectedSubstances['Nothing'] == true)
                // Show message if "Nothing" is selected
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "No further questions required based on selection.",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              else
                // Show message if nothing is selected yet (initial state)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      "Select substances used above, or select 'Nothing'.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30.0),
              _buildFinishButton(), // Finish Assessment button
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
        'assets/images/step6pic.png'; // Ensure path is correct
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

  // Builds the checklist for selecting substances
  Widget _buildSubstanceChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'In the past 12 months, which of the following substances have you used? (Check all that apply, or select "Nothing")',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: _questionTextColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16.0),
        // Generate checkbox for each substance
        ..._selectedSubstances.keys.map((String key) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: InkWell(
              // Toggle selection on tap
              onTap:
                  () => _handleSubstanceSelection(
                    key,
                    !_selectedSubstances[key]!,
                  ),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _selectedSubstances[key],
                        onChanged:
                            (bool? value) =>
                                _handleSubstanceSelection(key, value!),
                        activeColor: _primaryColor,
                        side: BorderSide(color: _inactiveColor, width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key, // Substance name
                            style: TextStyle(
                              fontSize: 15.0,
                              color: _optionTextColor,
                            ),
                          ),
                          // Show examples if available
                          if (_substanceExamples[key]?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                _substanceExamples[key]!,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: _checklistLabelColor,
                                ),
                                softWrap: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(), // Convert map iterator to list
      ],
    );
  }

  // Handles logic when a substance checkbox is tapped
  void _handleSubstanceSelection(String key, bool value) {
    if (!mounted) return;
    setState(() {
      if (key == 'Nothing') {
        // If "Nothing" is selected (value=true)
        if (value) {
          // Deselect all other substances
          _selectedSubstances.updateAll((k, v) => false);
          // Select "Nothing"
          _selectedSubstances['Nothing'] = true;
          // Reset Yes/No answers as they are no longer relevant
          _yesNoAnswers.fillRange(0, _yesNoAnswers.length, null);
        } else {
          // If "Nothing" is deselected, just update its state
          _selectedSubstances['Nothing'] = false;
          // Do not automatically select others
        }
      } else {
        // If any other substance is selected
        _selectedSubstances[key] = value;
        // If this substance was selected (value=true)
        if (value) {
          // Ensure "Nothing" is deselected
          _selectedSubstances['Nothing'] = false;
        }
      }

      // If, after changes, no substance (excluding Nothing) is selected,
      // reset Yes/No answers. This handles deselecting the last substance.
      if (!_shouldShowYesNoQuestions) {
        _yesNoAnswers.fillRange(0, _yesNoAnswers.length, null);
      }
    });
  }

  // Builds a block for a single Yes/No DSM criteria question
  Widget _buildYesNoQuestionBlock(int index) {
    final questionData = _yesNoQuestions[index];
    final String questionText = questionData['question'];
    final int questionId = questionData['id'];
    // Index in the _yesNoAnswers list (0-based)
    final answerIndex = questionId - 1;

    if (answerIndex < 0 || answerIndex >= _yesNoAnswers.length) {
      print(
        "Error: Invalid answer index $answerIndex for Yes/No QID $questionId",
      );
      return const SizedBox.shrink();
    }

    // Determine placeholder text based on selections
    List<String> selected =
        _selectedSubstances.entries
            .where((e) => e.key != 'Nothing' && e.value == true)
            .map(
              (e) => e.key.split(' ')[0],
            ) // Use first word for brevity maybe?
            .toList();
    String substancePlaceholder = "your substance use"; // Default
    if (selected.length == 1) {
      substancePlaceholder = "your ${selected[0]} use";
    } else if (selected.length > 1) {
      substancePlaceholder = "your use of the selected substance(s)";
    }

    // Replace placeholder in question text (simple replacement)
    // String formattedQuestion = questionText.replaceAll('[substance]', substancePlaceholder);
    // Or simply ask generally if placeholder logic is complex/unreliable:
    String formattedQuestion = questionText; // Using the general question text

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            formattedQuestion, // Use the (potentially formatted) question text
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: _questionTextColor,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        // Build Yes/No options for this question index
        _buildYesNoOptions(answerIndex, ['Yes', 'No']),
      ],
    );
  }

  // Builds horizontal Yes/No radio options for the DSM criteria
  Widget _buildYesNoOptions(int answerIndex, List<String> options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(options.length, (optionIndex) {
        // Yes = true (index 0), No = false (index 1)
        final bool optionRepresentsValue = (optionIndex == 0);
        // Check if the answer in state matches this option's boolean value
        final bool isSelected =
            _yesNoAnswers[answerIndex] == optionRepresentsValue;

        return Padding(
          padding: EdgeInsets.only(right: optionIndex == 0 ? 30.0 : 0),
          child: InkWell(
            onTap: () {
              if (!mounted) return;
              setState(() {
                // Store true for Yes, false for No
                _yesNoAnswers[answerIndex] = optionRepresentsValue;
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
                // Option Text (Yes/No)
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

  // Builds the final "Finish Assessment" button
  Widget _buildFinishButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Make async
          if (!mounted) return;
          // --- Validation ---
          // 1. Check if at least one substance option (including "Nothing") is selected
          bool anySubstanceOptionSelected = _selectedSubstances.containsValue(
            true,
          );
          if (!anySubstanceOptionSelected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please select the substance(s) you used, or select "Nothing".',
                ),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 3),
              ),
            );
            return;
          }

          // 2. If substances (not "Nothing") were selected, check if all Yes/No questions are answered
          bool allYesNoAnswered = true; // Assume true if questions not shown
          if (_shouldShowYesNoQuestions) {
            allYesNoAnswered = !_yesNoAnswers.contains(null); // Check for nulls
            if (!allYesNoAnswered) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please answer all Yes/No questions (Q1-Q11).'),
                  backgroundColor: Colors.orangeAccent,
                  duration: Duration(seconds: 3),
                ),
              );
              return;
            }
          }

          // --- Completion ---
          // Clear the partial save for this final step
          await _clearPartialSaveFromFirestore();

          // Prepare final results to return
          final results = {
            'selectedSubstances': Map<String, bool>.from(_selectedSubstances),
            // Only include Yes/No answers if they were relevant
            'yesNoAnswers':
                _shouldShowYesNoQuestions
                    ? List<bool?>.from(
                      _yesNoAnswers,
                    ) // Return copy of bool list
                    : <bool?>[], // Return empty list if not applicable
          };

          print('Step 6 (Addiction) Results: $results');
          Navigator.pop(context, results); // Pop with final combined results
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          // Wider button for "Finish"
          padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 14.0),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
        child: const Text('Finish Assessment'),
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