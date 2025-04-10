import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For saving track date
import 'package:intl/intl.dart'; // For formatting date

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  _MoodTrackingScreenState createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  int _selectedRating = 0; // 0 = none, 1-5 for stars

  // --- Map storing the image paths for each mood rating ---
  // IMPORTANT: Replace these paths with the ACTUAL paths to your images
  // in your 'assets/images/' folder.
  final Map<int, String> _moodImagePaths = {
    1: 'assets/images/mood_so_bad.png', // Replace with your actual image path
    2: 'assets/images/mood_bad.png', // Replace with your actual image path
    3: 'assets/images/mood_not_good.png', // Replace with your actual image path
    4: 'assets/images/mood_great.png', // Replace with your actual image path
    5: 'assets/images/mood_awesome.png', // Replace with your actual image path
  };

  // --- Helper functions to get UI elements based on rating ---

  String _getMoodText(int rating) {
    switch (rating) {
      case 1:
        return "So Bad";
      case 2:
        return "Bad";
      case 3:
        return "Not Good";
      case 4:
        return "Great";
      case 5:
        return "Awesome";
      default:
        return "How was your mood today?"; // Default text before selection
    }
  }

  Color _getBackgroundColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.grey.shade600;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.teal.shade200;
      case 4:
        return Colors.lightBlue.shade300;
      case 5:
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade300; // Default background before selection
    }
  }

  // Function to display the mood face image
  Widget _getMoodFaceWidget(int rating) {
    if (rating == 0) {
      // Return an empty container or a placeholder prompt/image
      // Use a fixed height to prevent layout jumps when the image appears
      return SizedBox(
        height: 180, // Match the image container height
        // Optional: Add a placeholder widget
        // child: Center(child: Text("Select a rating", style: TextStyle(color: Colors.black54))),
      );
    }

    final imagePath = _moodImagePaths[rating];

    if (imagePath == null) {
      print("Error: No image path found for rating $rating");
      return SizedBox(
        height: 180, // Match the image container height
        child: Center(
          child: Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
        ),
      );
    }

    // Display the image
    return SizedBox(
      height: 180, // Adjust height as needed for your face images
      width: 180, // Adjust width as needed
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain, // Or BoxFit.cover, etc.
        // Optional: Add an error builder for robustness
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $imagePath - $error");
          return Center(
            child: Icon(Icons.broken_image, size: 60, color: Colors.redAccent),
          );
        },
      ),
    );
  }

  // Function to save the mood tracking date using SharedPreferences
  Future<void> _saveMoodTrackedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String todayString = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());
      // Use the same key as used in HomeScreen for checking
      await prefs.setString('lastMoodTrackDate', todayString);
      print('Saved mood track date: $todayString');
    } catch (e) {
      print("Error saving mood track date: $e");
      // Optionally show an error message to the user via SnackBar if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save tracking date.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color currentBackgroundColor = _getBackgroundColor(_selectedRating);
    // Determine text color based on background brightness for good contrast
    Color textColor =
        ThemeData.estimateBrightnessForColor(currentBackgroundColor) ==
                Brightness.dark
            ? Colors.white
            : Colors.black;
    Color iconColor = textColor; // Use the same color for icons by default

    return Scaffold(
      // Use AnimatedContainer for smooth background color transitions
      body: AnimatedContainer(
        duration: const Duration(
          milliseconds: 400,
        ), // Slightly slower transition
        color: currentBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, // Pushes content to top/bottom
              children: [
                // --- Top Row: Back Button and Close Button ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: iconColor),
                      tooltip: 'Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor),
                      tooltip: 'Close',
                      onPressed:
                          () =>
                              Navigator.pop(context), // Or specific close logic
                    ),
                  ],
                ),

                // --- Middle Section: Mood Question, Text, and Face ---
                // Wrap in Expanded to allow it to take up available space
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    children: [
                      Text(
                        // Show question only if no rating is selected
                        _selectedRating == 0
                            ? 'How was your mood today?'
                            : _getMoodText(_selectedRating),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              _selectedRating == 0
                                  ? 28
                                  : 32, // Make text larger when selected
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 40),
                      // Display the face image
                      _getMoodFaceWidget(_selectedRating),
                      SizedBox(height: 40),
                    ],
                  ),
                ),

                // --- Bottom Section: Stars and Finish Button ---
                Column(
                  children: [
                    // Star Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        int currentStar = index + 1;
                        return IconButton(
                          iconSize: 50, // Slightly larger stars
                          splashRadius: 30,
                          icon: Icon(
                            _selectedRating >= currentStar
                                ? Icons
                                    .star_rounded // Filled star
                                : Icons.star_outline_rounded, // Outline star
                            color:
                                Colors.cyan.shade300, // Consistent star color
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRating = currentStar;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 30),

                    // Finish Button (conditionally visible)
                    // Use AnimatedOpacity for smooth appearance/disappearance
                    AnimatedOpacity(
                      opacity: _selectedRating > 0 ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child:
                          _selectedRating > 0
                              ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white, // Button background
                                  foregroundColor:
                                      Colors.blue.shade800, // Text color
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 60,
                                    vertical: 15,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      30,
                                    ), // More rounded
                                  ),
                                ),
                                onPressed: () async {
                                  // Make onPressed async
                                  print(
                                    'Mood selected: $_selectedRating stars',
                                  );

                                  // --- SAVE THE DATE ---
                                  await _saveMoodTrackedDate();
                                  // --- END SAVE ---

                                  // TODO: Add logic here to save the actual mood RATING (_selectedRating)
                                  // This could be to Firebase, a local database, or an API call.

                                  // Check if the widget is still mounted before navigating
                                  if (mounted) {
                                    Navigator.pop(
                                      context,
                                    ); // Go back to the previous screen
                                  }
                                },
                                child: Text('Finish'),
                              )
                              : SizedBox(
                                height: 60,
                              ), // Maintain space when button is hidden
                    ),
                    SizedBox(height: 20), // Add some padding at the very bottom
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
