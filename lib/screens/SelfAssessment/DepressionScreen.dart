// depression_screen.dart
import 'package:flutter/material.dart';

class DepressionScreen extends StatefulWidget {
  const DepressionScreen({Key? key}) : super(key: key);

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

  // Keep track of the selected answer index for each question
  // Initialize with nulls to represent unanswered questions
  final List<int?> _answers = List.filled(21, null);

  final List<Map<String, dynamic>> _questions = [
    // (Questions list remains the same as provided earlier)
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depression Assessment (Step 1)'),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // **** ADD LOGGING for Back Button ****
            print("DepressionScreen: Back button pressed, popping with false.");
            Navigator.pop(context, false); // Pop with false (not completed)
          },
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
              itemBuilder: (context, index) {
                return _buildQuestionBlock(index);
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(color: _dividerColor, thickness: 1.0),
                );
              },
            ),
            const SizedBox(height: 30.0),
            _buildNavigateButton(), // Button with logging inside
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
    const String imagePath = 'assets/images/step1pic.png';
    return Center(
      child: Image.asset(
        imagePath,
        height: 60, // Example height, adjust as needed
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

  Widget _buildQuestionBlock(int questionIndex) {
    // (Question block build logic remains the same)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _questions[questionIndex]['question'],
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: _questionTextColor,
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
    // (Option build logic remains the same)
    final bool isSelected = _answers[questionIndex] == optionValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
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
        // --- ADDED LOGGING to onPressed ---
        onPressed: () {
          // **** START LOGGING ****
          print("[DepressionScreen] Complete Step 1 button pressed.");
          print(
            "[DepressionScreen] Current answers before validation: $_answers",
          );
          // **** END LOGGING ****

          // 1. Validate: Check if all questions have been answered
          bool allAnswered = !_answers.contains(null); // Check for any nulls

          // **** START LOGGING ****
          print(
            "[DepressionScreen] Validation result (allAnswered): $allAnswered",
          );
          // **** END LOGGING ****

          if (!allAnswered) {
            // **** START LOGGING ****
            print("[DepressionScreen] Validation FAILED. Showing SnackBar.");
            // **** END LOGGING ****
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please answer all questions before proceeding.'),
                backgroundColor: Colors.orangeAccent,
                duration: Duration(seconds: 2),
              ),
            );
            return; // Stop execution if not all answered
          }

          // 2. If valid, print and pop with the answers
          // **** START LOGGING ****
          print("[DepressionScreen] Validation PASSED. Popping with data.");
          // **** END LOGGING ****
          Navigator.pop(context, _answers); // Return the list of answers
        },
        // --- END MODIFIED onPressed ---
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
    // (Save link logic remains the same - no functionality implemented)
    return Center(
      child: InkWell(
        onTap: () {
          print(
            '[DepressionScreen] Save and continue later tapped',
          ); // Added screen context
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
