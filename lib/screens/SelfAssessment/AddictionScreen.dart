import 'package:flutter/material.dart';

class AddictionScreen extends StatefulWidget {
  const AddictionScreen({super.key});

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

  // State for selected substances checklist
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

  // Examples for substances (optional display)
  final Map<String, String> _substanceExamples = {
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
    'Other': '', // No examples for Other/Nothing
    'Nothing': '',
  };

  // State for Yes/No answers (Q1-11), corresponding to DSM-5 criteria for SUD
  // Initialized to null (unanswered)
  final List<bool?> _yesNoAnswers = List.filled(11, null);

  // List of Yes/No questions based on DSM-5 SUD criteria
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
          'Q10. Do you need to use more of [substance] to achieve the same effect, or does the same amount have less effect than before? (Tolerance)',
    }, // Added context
    {
      'id': 11,
      'question':
          'Q11. Have you experienced withdrawal symptoms when not using [substance] or used [substance] to avoid withdrawal?',
    },
  ];

  // --- Computed Property ---

  // Helper getter to determine if Yes/No questions should be shown.
  // Returns true ONLY if at least one substance (and NOT 'Nothing') is selected.
  bool get _shouldShowYesNoQuestions => _selectedSubstances.entries.any(
    (e) => e.key != 'Nothing' && e.value == true,
  );

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Substance Use (Step 6 of 6)'), // Updated step count
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Return false when popping back manually (indicates incomplete)
          onPressed:
              () => Navigator.pop(context, null), // Return null for manual back
        ),
      ),
      body: SingleChildScrollView(
        // Allows scrolling if content overflows
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(), // Display step indicator image
            const SizedBox(height: 24.0),
            _buildSubstanceChecklist(), // Build the checklist section
            const SizedBox(height: 10),
            Divider(color: _dividerColor, thickness: 1.0), // Separator
            const SizedBox(height: 20),

            // *** CONDITIONAL DISPLAY LOGIC ***
            // Only build the Yes/No questions ListView if _shouldShowYesNoQuestions is true
            if (_shouldShowYesNoQuestions)
              ListView.separated(
                shrinkWrap: true, // Takes only needed vertical space
                physics:
                    const NeverScrollableScrollPhysics(), // Disables internal scrolling
                itemCount: _yesNoQuestions.length,
                itemBuilder: (context, index) {
                  // Build each Yes/No question block
                  return _buildYesNoQuestionBlock(index);
                },
                separatorBuilder: (context, index) {
                  // Build dividers between questions
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: _dividerColor, thickness: 1.0),
                  );
                },
              ),
            // Display a message if 'Nothing' is selected (and thus questions are hidden)
            if (!_shouldShowYesNoQuestions &&
                _selectedSubstances['Nothing'] == true)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    "No further questions required.",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            // *** END CONDITIONAL DISPLAY LOGIC ***
            const SizedBox(height: 30.0),
            _buildFinishButton(), // Build the finish button
            const SizedBox(height: 12.0),
            _buildSaveLink(), // Build the "save later" link
            const SizedBox(height: 20.0), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- Widget Builder Helper Methods ---

  Widget _buildHeaderImage() {
    const String imagePath =
        'assets/images/step6pic.png'; // Ensure this asset exists
    return Center(
      child: Image.asset(
        imagePath,
        height: 60, // Adjust height as needed
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image '$imagePath': $error"); // Log error
          // Provide a fallback UI element
          return Container(
            height: 60,
            color: _inactiveColor.withOpacity(0.3),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.grey),
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
        // Instruction text
        Text(
          'Select the substances you have used in the past 12 months. (Check all that apply, or select "Nothing")',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: _questionTextColor,
            height: 1.4, // Line spacing
          ),
        ),
        const SizedBox(height: 16.0),
        // Generate checklist items from the map keys
        ..._selectedSubstances.keys.map((String key) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: InkWell(
              // Makes the whole row tappable for better UX
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
                    // Checkbox widget
                    SizedBox(
                      width: 24, // Constrain size
                      height: 24,
                      child: Checkbox(
                        value: _selectedSubstances[key],
                        onChanged:
                            (bool? value) =>
                                _handleSubstanceSelection(key, value!),
                        activeColor: _primaryColor, // Color when checked
                        side: BorderSide(
                          color: _inactiveColor,
                          width: 1.5,
                        ), // Border when unchecked
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap, // Reduce tap area
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Substance name and examples
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
                          // Display examples if available
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
        }),
      ],
    );
  }

  // Handles the logic for substance selection, ensuring "Nothing" is exclusive
  void _handleSubstanceSelection(String key, bool value) {
    setState(() {
      if (key == 'Nothing') {
        // If 'Nothing' is checked (value is true)
        if (value) {
          // Deselect all other substances
          _selectedSubstances.updateAll((k, v) => false);
          // Set 'Nothing' to true
          _selectedSubstances['Nothing'] = true;
          // Clear all Yes/No answers as they are not needed
          _yesNoAnswers.fillRange(0, _yesNoAnswers.length, null);
        } else {
          // If 'Nothing' is unchecked, just update its value
          _selectedSubstances['Nothing'] = false;
        }
      } else {
        // If any other substance is checked/unchecked
        _selectedSubstances[key] = value;
        // If this substance is being checked (value is true), ensure 'Nothing' is unchecked
        if (value) {
          _selectedSubstances['Nothing'] = false;
        }
      }

      // After any change, check if Yes/No questions should still be shown.
      // If not (e.g., all substances unchecked), clear the Yes/No answers.
      if (!_shouldShowYesNoQuestions &&
          _selectedSubstances['Nothing'] == false) {
        _yesNoAnswers.fillRange(0, _yesNoAnswers.length, null);
      }
    });
  }

  // Builds a single Yes/No question block
  Widget _buildYesNoQuestionBlock(int index) {
    // Get question data from the list
    final questionData = _yesNoQuestions[index];
    final String questionText = questionData['question'];
    final int questionId = questionData['id'];
    // Calculate the corresponding index in the _yesNoAnswers list (0-based)
    final answerIndex = questionId - 1;

    // Basic validation for index bounds
    if (answerIndex < 0 || answerIndex >= _yesNoAnswers.length) {
      print(
        "Error: Invalid answer index $answerIndex for Y/N question ID: $questionId",
      );
      return const SizedBox.shrink(); // Return empty widget on error
    }

    // Determine the text to replace '[substance]' placeholder
    List<String> selected =
        _selectedSubstances.entries
            .where(
              (e) => e.key != 'Nothing' && e.value == true,
            ) // Filter selected substances (excluding 'Nothing')
            .map((e) => e.key) // Get their names
            .toList();

    String substancePlaceholder;
    if (selected.length == 1) {
      substancePlaceholder =
          "your use of ${selected[0]}"; // Specific substance if only one selected
    } else if (selected.isEmpty) {
      substancePlaceholder =
          "substance use"; // Fallback (shouldn't happen if questions are shown)
    } else {
      substancePlaceholder =
          "the substance(s) you selected"; // Generic if multiple selected
    }

    // Build the question text and options
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
          ), // Avoid text touching edge
          child: Text(
            // Replace the placeholder in the question string
            questionText.replaceAll('[substance]', substancePlaceholder),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: _questionTextColor,
              height: 1.4, // Line spacing
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        // Build the 'Yes' and 'No' radio button options
        _buildYesNoOptions(answerIndex, ['Yes', 'No']),
      ],
    );
  }

  // Builds the Yes/No radio button row for a given question index
  Widget _buildYesNoOptions(int answerIndex, List<String> options) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Align options to the left
      children: List.generate(options.length, (optionIndex) {
        // Determine the boolean value this option represents (Yes=true, No=false)
        final bool optionRepresentsValue = optionIndex == 0;
        // Check if this option is currently selected
        final bool isSelected =
            _yesNoAnswers[answerIndex] == optionRepresentsValue;

        return Padding(
          // Add spacing between 'Yes' and 'No' options
          padding: EdgeInsets.only(right: optionIndex == 0 ? 30.0 : 0),
          child: InkWell(
            // Make option tappable
            onTap: () {
              setState(() {
                // Update the answer state for this question index
                _yesNoAnswers[answerIndex] = optionRepresentsValue;
              });
            },
            borderRadius: BorderRadius.circular(
              8,
            ), // Rounded corners for tap effect
            child: Row(
              mainAxisSize: MainAxisSize.min, // Row takes minimum space
              children: [
                // Custom radio button appearance
                Container(
                  width: 22.0,
                  height: 22.0,
                  margin: const EdgeInsets.only(
                    right: 8.0,
                  ), // Space between circle and text
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? _borderColor
                              : _inactiveColor, // Border color changes if selected
                      width: 2.0,
                    ),
                  ),
                  // Show inner circle if selected
                  child:
                      isSelected
                          ? Center(
                            child: Container(
                              width: 10.0, // Size of inner circle
                              height: 10.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _borderColor, // Color of inner circle
                              ),
                            ),
                          )
                          : null, // No inner circle if not selected
                ),
                // Option text ('Yes' or 'No')
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
        onPressed: () {
          // --- Validation Logic ---
          // 1. Check if ANYTHING is selected (either a substance or 'Nothing')
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
              ),
            );
            return; // Stop execution
          }

          // 2. Check if Yes/No questions need to be answered and if they are
          bool allYesNoAnswered =
              true; // Default to true (handles 'Nothing' case)
          if (_shouldShowYesNoQuestions) {
            // Only validate if questions are visible
            allYesNoAnswered =
                !_yesNoAnswers.contains(
                  null,
                ); // Check if any answer is still null
            if (!allYesNoAnswered) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please answer all Yes/No questions (Q1-Q11).'),
                  backgroundColor: Colors.orangeAccent,
                ),
              );
              return; // Stop execution
            }
          }

          // --- Data Preparation & Navigation ---
          // If all validations pass:
          final results = {
            'selectedSubstances': Map<String, bool>.from(
              _selectedSubstances,
            ), // Send a copy
            // Send the answers list ONLY if questions were shown, otherwise send empty list
            'yesNoAnswers':
                _shouldShowYesNoQuestions
                    ? List<bool?>.from(_yesNoAnswers)
                    : <bool?>[],
          };

          print(
            'Step 6 (Addiction) Results: $results',
          ); // Log results for debugging
          Navigator.pop(context, results); // Pop screen and return results map
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor, // Button background color
          foregroundColor: Colors.white, // Button text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 60.0,
            vertical: 14.0,
          ), // Button padding
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2, // Subtle shadow
        ),
        child: const Text('Finish Assessment'),
      ),
    );
  }

  // Builds the "Save and continue later" link
  Widget _buildSaveLink() {
    return Center(
      child: InkWell(
        onTap: () {
          print('Save and continue later tapped');
          // Placeholder for save functionality
          // TODO: Implement actual save logic if required
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Save functionality not yet implemented.'),
              duration: Duration(seconds: 2),
            ),
          );
          // Optionally pop or navigate elsewhere after saving attempt
          // Navigator.pop(context, null); // Example: pop after attempting save
        },
        child: Text(
          'Save and continue later >>',
          style: TextStyle(
            fontSize: 14,
            color: _primaryColor,
            decoration: TextDecoration.underline, // Underline to indicate link
            decorationColor: _primaryColor, // Match underline color
          ),
        ),
      ),
    );
  }
}
