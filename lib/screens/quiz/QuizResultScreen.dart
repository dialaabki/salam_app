// lib/screens/quiz/QuizResultScreen.dart

import 'package:flutter/material.dart';
import 'package:salam_app/screens/quiz/QuizScreen.dart'; // For "Try Again"

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  // --- Styling Constants ---
  static const Color primaryColor = Color(0xFF2D7A8F); // Teal from screenshots
  static const Color scaffoldBackgroundColor = primaryColor;
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColor = Color(0xFF4A4A4A);
  static const Color whiteText = Colors.white;
  static const Color buttonTextColor = Colors.white;
  static const Color tryAgainButtonColor = Color(
    0xFF4A90E2,
  ); // Blue button from screenshots
  static const Color finishButtonColor = Color(
    0xFF8DB0CE,
  ); // Lighter blue/grey button

  @override
  Widget build(BuildContext context) {
    // Prevent division by zero
    final double percentage = totalQuestions > 0 ? (score / totalQuestions) : 0;
    // Adjust threshold as needed (e.g., >= 70% is Awesome)
    final bool isAwesome = percentage >= 0.7;
    final String title = isAwesome ? 'You are Awesome' : 'Hard Luck!';
    final String imagePath =
        isAwesome
            ? 'assets/images/goodmarkpic.png'
            : 'assets/images/badmarkpic.png';
    final String heartPath =
        'assets/images/broken_heart.png'; // Broken heart for hard luck
    final String scoreText = '$score/$totalQuestions';

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- Title Text ---
            Padding(
              padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: whiteText,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // --- Main Content Card ---
            Expanded(
              child: Center(
                // Center the card vertically if there's extra space
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 35.0,
                  ),
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ), // Limit width on large screens
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Card size fits content
                    children: [
                      // --- "Your score is:" Text ---
                      const Text(
                        'your score is:',
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              primaryColor, // Use primary color for this text
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // --- Score Display ---
                      Text(
                        scoreText,
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: primaryColor, // Use primary color for score
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // --- Result Image ---
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior:
                            Clip.none, // Allow heart to overflow slightly
                        children: [
                          Image.asset(
                            imagePath,
                            height: 160,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const SizedBox(height: 160),
                          ),
                          if (!isAwesome) // Show broken heart only on "Hard Luck"
                            Positioned(
                              top: -5, // Adjust position relative to brain
                              left: 20, // Adjust horizontal position
                              child: Image.asset(
                                heartPath,
                                height: 35,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // --- Action Buttons ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // --- Try Again Button ---
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuizScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  tryAgainButtonColor, // Blue button
                              foregroundColor: buttonTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Try again'),
                          ),

                          // --- Finish Button ---
                          ElevatedButton(
                            onPressed: () {
                              // Pop back to the screen *before* the QuizScreen was pushed.
                              // Assuming QuizScreen was pushed from ResourcesListScreen, this works.
                              Navigator.pop(context);
                              // If navigation stack is more complex, use popUntil with a route predicate:
                              // Navigator.popUntil(context, ModalRoute.withName('/resources')); // Use your list screen's route name
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  finishButtonColor, // Lighter blue/grey
                              foregroundColor: buttonTextColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('Finish'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ), // Padding at the bottom of card
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between card and navbar
          ],
        ),
      ),
    );
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavBar(BuildContext context) {
    const Color navBarColor = Color(0xFF276181);
    const Color iconColor = Color(0xFF5E94FF);
    return BottomAppBar(
      color: navBarColor,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: iconColor),
            onPressed:
                () => Navigator.popUntil(context, (route) => route.isFirst),
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.access_time, color: iconColor),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pushNamed(context, '/reminders');
            },
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: iconColor),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pushNamed(context, '/activity');
            },
            tooltip: 'Activity',
          ),
          IconButton(
            icon: const Icon(Icons.menu_book, color: iconColor),
            onPressed: () {
              // From results, pop back to the resource list
              Navigator.popUntil(
                context,
                ModalRoute.withName('/resources'),
              ); // Adjust route name if needed
            },
            tooltip: 'Resources',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: iconColor),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pushNamed(context, '/profile');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}
