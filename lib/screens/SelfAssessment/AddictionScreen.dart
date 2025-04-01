import 'package:flutter/material.dart';

class AddictionScreen extends StatefulWidget {
  const AddictionScreen({Key? key}) : super(key: key);

  @override
  State<AddictionScreen> createState() => _AddictionScreenState();
}

class _AddictionScreenState extends State<AddictionScreen> {
  final Color _primaryColor = const Color(0xFF5588A4);
  final Color _borderColor = const Color(0xFF276181);
  final Color _inactiveColor = Colors.grey.shade400;
  final Color _dividerColor = Colors.grey.shade300;
  final Color _questionTextColor = Colors.black87;
  final Color _optionTextColor = Colors.black54;
  final Color _checklistLabelColor = Colors.grey.shade600;

  // State for selected substances
  final Map<String, bool> _selectedSubstances = {
    'Alcohol': false,
    'Cannabis': false,
    'Stimulants': false,
    'Opioids': false,
    'Sedatives & Hypnotics': false,
    'Hallucinogens': false,
    'Inhalants': false,
    'Tobacco & Nicotine': false,
    'Other': false,
    'Nothing': false, // Mutually exclusive option
  };
  final Map<String, String> _substanceExamples = {
    // Keep examples
    'Alcohol': 'examples: Beer, Wine, vodka, whiskey',
    'Cannabis': 'examples: Marijuana, Hashish',
    'Stimulants': 'examples: Cocaine, crystal meth, Adderall, Ritalin',
    'Opioids':
        'examples: Heroin, Morphine, oxycodone, hydrocodone, fentanyl, tramadol',
    'Sedatives & Hypnotics':
        'examples: Xanax, Valium, Ativan, Sleeping pills (e.g., zolpidem, eszopiclone)',
    'Hallucinogens': 'examples: magic mushrooms, ecstasy, molly, phencyclidine',
    'Inhalants': 'examples: Glue, Paint thinner, Gasoline,',
    'Tobacco & Nicotine':
        'examples: Cigarettes, Cigars, E-cigarettes (vapes), Chewing tobacco',
    'Other': '',
    'Nothing': '',
  };

  // State for Yes/No answers (Q1-11), initialized to null
  final List<bool?> _yesNoAnswers = List.filled(11, null);

  // Yes/No questions list (remains the same as provided)
  final List<Map<String, dynamic>> _yesNoQuestions = [
    {
      'id': 1,
      'question':
          'Q1. Do you often take [substance] in larger amounts or over a longer period than you intended?',
    },
    {
      'id': 2,
      'question':
          'Q2. Have you tried to cut down or control your use of [substance] but found it difficult?',
    },
    {
      'id': 3,
      'question':
          'Q3. Do you spend a lot of time obtaining, using, or recovering from the effects of [substance]?',
    },
    {
      'id': 4,
      'question':
          'Q4. Do you experience strong cravings or urges to use [substance]?',
    },
    {
      'id': 5,
      'question':
          'Q5. Has your substance use caused you to neglect responsibilities at work, school, or home?',
    },
    {
      'id': 6,
      'question':
          'Q6. Have you continued using [substance] even when it caused problems with your relationships?',
    },
    {
      'id': 7,
      'question':
          'Q7. Have you given up important social, work, or recreational activities because of your substance use?',
    },
    {
      'id': 8,
      'question':
          'Q8. Have you used [substance] in situations where it could be physically dangerous (e.g., driving)?',
    },
    {
      'id': 9,
      'question':
          'Q9. Do you continue using [substance] despite knowing it causes physical or psychological problems?',
    },
    {
      'id': 10,
      'question':
          'Q10. Do you need to use more of [substance] to achieve the same effect, or does the same amount have less effect than before?',
    },
    {
      'id': 11,
      'question':
          'Q11. Have you experienced withdrawal symptoms when not using [substance] or used [substance] to avoid withdrawal?',
    },
  ];

  // Helper to determine if Yes/No questions should be shown
  bool get _shouldShowYesNoQuestions => _selectedSubstances.entries.any(
    (e) => e.key != 'Nothing' && e.value == true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Substance Use (Step 6)'), // Added step number
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false), // Pop with false
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            const SizedBox(height: 24.0),
            _buildSubstanceChecklist(),
            const SizedBox(height: 10),
            Divider(color: _dividerColor, thickness: 1.0),
            const SizedBox(height: 20),

            // Conditionally display Yes/No questions only if a substance (not 'Nothing') is selected
            if (_shouldShowYesNoQuestions)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _yesNoQuestions.length,
                itemBuilder: (context, index) {
                  return _buildYesNoQuestionBlock(index);
                },
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: _dividerColor, thickness: 1.0),
                  );
                },
              ),
            if (!_shouldShowYesNoQuestions &&
                _selectedSubstances['Nothing'] == true)
              Padding(
                // Message if 'Nothing' is selected
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    "No further questions required.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),

            const SizedBox(height: 30.0),
            _buildFinishButton(),
            const SizedBox(height: 12.0),
            _buildSaveLink(),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    // (Header image build logic remains the same)
    const String imagePath = 'assets/images/step6pic.png';
    return Center(
      child: Image.asset(
        imagePath,
        height: 60, // Example height
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $error");
          return Container(
            height: 60,
            color: _inactiveColor.withOpacity(0.5),
            child: const Center(
              child: Text(
                'Image Error',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubstanceChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the substances you have used in the past 12 months. (Check all that apply, or select "Nothing")', // Updated instructions
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: _questionTextColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16.0),
        ..._selectedSubstances.keys.map((String key) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: InkWell(
              // Make the whole row tappable
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
                        side: BorderSide(color: _inactiveColor, width: 2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: _optionTextColor,
                            ),
                          ),
                          if (_substanceExamples[key] != null &&
                              _substanceExamples[key]!.isNotEmpty)
                            Padding(
                              // Add padding for examples
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
        }).toList(),
      ],
    );
  }

  // Helper function to manage exclusive selection of "Nothing"
  void _handleSubstanceSelection(String key, bool value) {
    setState(() {
      if (key == 'Nothing') {
        // If 'Nothing' is selected, deselect all others
        _selectedSubstances.updateAll((k, v) => k == 'Nothing' ? value : false);
        // Clear Yes/No answers if Nothing is selected
        if (value) _yesNoAnswers.fillRange(0, _yesNoAnswers.length, null);
      } else {
        // If any other substance is selected, deselect 'Nothing'
        _selectedSubstances[key] = value;
        if (value) {
          _selectedSubstances['Nothing'] = false;
        }
      }
      // If no substances (except potentially 'Nothing') are selected, clear Y/N answers
      if (!_shouldShowYesNoQuestions) {
        _yesNoAnswers.fillRange(0, _yesNoAnswers.length, null);
      }
    });
  }

  Widget _buildYesNoQuestionBlock(int index) {
    final questionData = _yesNoQuestions[index];
    final String questionText = questionData['question'];
    final int questionId = questionData['id'];
    final answerIndex =
        questionId - 1; // Yes/No questions map 1-11 to indices 0-10

    // Safety check
    if (answerIndex < 0 || answerIndex >= _yesNoAnswers.length) {
      print(
        "Error: Invalid answer index $answerIndex for Y/N question ID: $questionId",
      );
      return const SizedBox.shrink();
    }

    // Determine the substance placeholder text
    List<String> selected =
        _selectedSubstances.entries
            .where((e) => e.key != 'Nothing' && e.value == true)
            .map((e) => e.key)
            .toList();
    String substancePlaceholder = "the substance(s) you selected";
    if (selected.length == 1) {
      substancePlaceholder = "your use of ${selected[0]}";
    } else if (selected.isEmpty) {
      // Should not happen if questions are shown, but as a fallback
      substancePlaceholder = "substance use";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            questionText.replaceAll(
              '[substance]',
              substancePlaceholder,
            ), // Replace placeholder
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: _questionTextColor,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        _buildYesNoOptions(answerIndex, ['Yes', 'No']),
      ],
    );
  }

  Widget _buildYesNoOptions(int answerIndex, List<String> options) {
    // (Yes/No build logic remains the same, uses true/false for bool list)
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(options.length, (optionIndex) {
        final bool? expectedValue =
            optionIndex == 0 ? true : false; // Yes = true, No = false
        final bool isSelected = _yesNoAnswers[answerIndex] == expectedValue;

        return Padding(
          padding: EdgeInsets.only(
            right: optionIndex == 0 ? 30.0 : 0,
            left: 0, // Start from left edge
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _yesNoAnswers[answerIndex] = expectedValue;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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

  Widget _buildFinishButton() {
    return Center(
      child: ElevatedButton(
        // ***MODIFIED onPressed***
        onPressed: () {
          // 1. Validate: Check if at least one substance OR 'Nothing' is selected
          bool substanceSelected = _selectedSubstances.containsValue(true);
          if (!substanceSelected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please select the substance(s) you used, or select "Nothing".',
                ),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 3),
              ),
            );
            return; // Stop if nothing is selected
          }

          // 2. Validate Yes/No questions ONLY IF a substance (not 'Nothing') was selected
          bool allYesNoAnswered = true; // Assume true if 'Nothing' selected
          if (_shouldShowYesNoQuestions) {
            allYesNoAnswered = !_yesNoAnswers.contains(null);
            if (!allYesNoAnswered) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please answer all Yes/No questions (Q1-Q11).'),
                  backgroundColor: Colors.orangeAccent,
                  duration: Duration(seconds: 2),
                ),
              );
              return; // Stop if Yes/No questions are required but not answered
            }
          }

          // 3. If valid, prepare results map and pop
          final results = {
            'selectedSubstances': _selectedSubstances,
            // Send empty list if 'Nothing' was selected, otherwise send answers
            'yesNoAnswers':
                _shouldShowYesNoQuestions ? _yesNoAnswers : <bool?>[],
          };
          print('Step 6 (Addiction) Answers: $results');
          Navigator.pop(context, results); // Return the map of answers
        },
        // *** END MODIFIED onPressed***
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 14.0),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
        child: const Text('Finish Assessment'), // Changed text slightly
      ),
    );
  }

  Widget _buildSaveLink() {
    // (Save link logic remains the same)
    return Center(
      child: InkWell(
        onTap: () {
          print('Save and continue later tapped');
          // TODO: Implement save functionality if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Save functionality not implemented yet.'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Text(
          'Save and continue later >>',
          style: TextStyle(
            fontSize: 14,
            color: _primaryColor,
            decoration: TextDecoration.underline,
            decorationColor: _primaryColor,
          ),
        ),
      ),
    );
  }
}
