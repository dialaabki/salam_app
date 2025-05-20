// File: lib/screens/MoodTrackingScreen.dart

import 'package:flutter/material.dart';
import 'dart:async';

// --- Firebase Imports ---
// import 'package:firebase_core/firebase_core.dart'; // Usually initialized in main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

// Import main.dart for route constants if needed for navigation elsewhere
// import '../../main.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  _MoodTrackingScreenState createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  // --- State Variables ---
  Map<String, int> _categoryRatings = {}; // Stores today's ratings (loaded/updated)
  String? _currentCategory; // The category currently being rated
  final List<String> _predefinedCategories = [ // Base list
    "Work", "Study", "Family", "Social", "Personal", "Health"
  ];
  final TextEditingController _customCategoryController = TextEditingController();
  bool _isSaving = false; // Loading state for saving individual category mood
  bool _isLoadingData = true; // State for loading today's initial data

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Mood Image Paths (Ensure these assets exist!) ---
  final Map<int, String> _moodImagePaths = {
    1: 'assets/images/mood_so_bad.png',    // Replace with YOUR actual paths
    2: 'assets/images/mood_bad.png',     // Replace with YOUR actual paths
    3: 'assets/images/mood_not_good.png', // Replace with YOUR actual paths
    4: 'assets/images/mood_great.png',   // Replace with YOUR actual paths
    5: 'assets/images/mood_awesome.png', // Replace with YOUR actual paths
  };

  @override
  void initState() {
    super.initState();
    // Wrap in WidgetsBinding to ensure context is ready if needed, although usually safe here
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _loadTodaysMoods(); // Load existing data for today when screen opens
    });
  }

  // --- Function to Load Existing Moods for Today ---
  Future<void> _loadTodaysMoods() async {
    if (!mounted) return;
     print("Starting _loadTodaysMoods..."); // Log start
    // Ensure loading state is true initially
    if (!_isLoadingData) {
       setState(() => _isLoadingData = true);
    }

    final user = _auth.currentUser;
    if (user == null) {
      print("MoodTracking: User not logged in, cannot load moods.");
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to track mood.'), backgroundColor: Colors.red,));
        // Optionally pop screen if login is mandatory for this feature
        // Navigator.pop(context);
      }
      return;
    }

    final String userId = user.uid;
    final now = DateTime.now();
    final String dateString = DateFormat('yyyy-MM-dd').format(now);
    final String documentId = "${userId}_$dateString";
    final DocumentReference docRef = _firestore.collection('daily_moods').doc(documentId);
    print("Attempting to load document: $documentId"); // Log document ID

    try {
      final DocumentSnapshot docSnap = await docRef.get();

      // Create a temporary map OUTSIDE the if block to hold results
      final Map<String, int> loadedRatings = {};

      if (docSnap.exists) {
        print("Document $documentId exists."); // Log existence
        final data = docSnap.data() as Map<String, dynamic>?;

        // More robust check for the 'ratings' field
        if (data != null && data.containsKey('ratings') && data['ratings'] is Map) {
             print("Found 'ratings' map in document."); // Log map found
             // Cast the ratings map safely
            final Map<String, dynamic> todaysRatingsRaw = data['ratings'] as Map<String, dynamic>;

             print("Raw ratings map from Firestore: $todaysRatingsRaw"); // Log raw map

            // Iterate and populate the temporary map
            todaysRatingsRaw.forEach((key, value) {
              if (value is int) {
                loadedRatings[key] = value;
              } else if (value is double) { // Handle Firestore number types
                loadedRatings[key] = value.toInt();
              } else {
                print("Warning: Skipping non-integer rating value for key '$key': $value (Type: ${value.runtimeType})");
              }
            });
        } else {
           print("Document exists but 'ratings' map is missing, null, or not a map.");
           if(data != null) print("'ratings' field type: ${data['ratings']?.runtimeType}");
        }
      } else {
        print("No mood document found for today ($documentId).");
      }

      // Update state AFTER processing the snapshot, only if mounted
      if (mounted) {
        setState(() {
          // Assign the potentially populated map (even if empty)
          _categoryRatings = loadedRatings;
          print("Updated _categoryRatings state: $_categoryRatings"); // Log final state map
          _isLoadingData = false; // <<< MOVE isLoadingData = false INSIDE setState
          print("Finished _loadTodaysMoods. isLoadingData = false"); // Log finish
        });
      }

    } catch (e) {
      print("Error loading today's mood data: $e");
      if (mounted) {
        setState(() => _isLoadingData = false); // Ensure loading stops on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load previous moods: ${e.toString()}'), backgroundColor: Colors.orange),
        );
      }
    }
    // Removed finally block as loading state is handled inside setState/catch
  }


  // --- Helper Functions ---
  int _getRatingForCurrentCategory() {
    if (_currentCategory == null) return 0;
    return _categoryRatings[_currentCategory!] ?? 0;
  }

  String _getMoodText() {
    int rating = _getRatingForCurrentCategory();
    String prompt = _currentCategory != null
        ? "How was your mood for\n$_currentCategory?"
        : "Select an area to track or update\nyour mood for:";

    switch (rating) {
      case 1: return "So Bad";
      case 2: return "Bad";
      case 3: return "Not Good";
      case 4: return "Great";
      case 5: return "Awesome";
      default: return prompt;
    }
  }

  Color _getBackgroundColor() {
    int rating = _getRatingForCurrentCategory();
    switch (rating) {
      case 1: return Colors.grey.shade600;
      case 2: return Colors.grey.shade400;
      case 3: return Colors.teal.shade200;
      case 4: return Colors.lightBlue.shade300;
      case 5: return Colors.blue.shade600;
      default: return Colors.grey.shade300;
    }
  }

  Widget _getMoodFaceWidget() {
    int rating = _getRatingForCurrentCategory();
    if (rating == 0) {
      return const SizedBox( height: 180); // Placeholder space
    }
    final imagePath = _moodImagePaths[rating];
    if (imagePath == null) {
      return const SizedBox(height: 180, child: Center(child: Icon(Icons.error_outline, size: 60, color: Colors.redAccent)));
    }
    return SizedBox(
      height: 180, width: 180,
      child: Image.asset(
        imagePath, fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $imagePath - $error");
          return const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.redAccent));
        },
      ),
    );
  }

  // --- Action Functions ---

  // Saves/Updates the mood for the category in TODAY's Firestore document
  Future<void> _saveOrUpdateCurrentCategoryMood() async {
    if (_currentCategory == null || _getRatingForCurrentCategory() == 0 || _isSaving) return;

    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Login required.'), backgroundColor: Colors.red)); }
      return;
    }

    if (mounted) setState(() => _isSaving = true);

    String category = _currentCategory!;
    int rating = _getRatingForCurrentCategory();

    final now = DateTime.now();
    final String dateString = DateFormat('yyyy-MM-dd').format(now);
    final String documentId = "${userId}_$dateString";
    final DocumentReference dailyDocRef = _firestore.collection('daily_moods').doc(documentId);

    // Use dot notation for targeted update within the nested map
    final Map<String, dynamic> dataToMerge = {
      'userId': userId,
      'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      'ratings.$category': rating, // Target specific category
      'lastUpdatedAt': FieldValue.serverTimestamp()
    };

    try {
      await dailyDocRef.set(dataToMerge, SetOptions(merge: true));
      print('Mood saved/updated: DocID="$documentId", Category="$category", Rating=$rating');

      if (mounted) {
        setState(() {
          _categoryRatings[category] = rating; // Update local state
          // _ratedCategoriesInSession.add(category); // Not strictly needed anymore
          _currentCategory = null; // Go back to category selection
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( content: Text('Mood for "$category" recorded for today!'), duration: const Duration(seconds: 2), backgroundColor: Colors.green,),
        );
      }
    } catch (e) {
      print("Error saving/updating mood to Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save mood: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Function to show the dialog for adding a custom category
  void _showAddCategoryDialog() {
    _customCategoryController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Add Custom Area"),
        content: TextField( controller: _customCategoryController, autofocus: true, decoration: const InputDecoration( hintText: "e.g., Hobby, Relationship", border: OutlineInputBorder(),),),
        actions: [
          TextButton( child: const Text("Cancel"), onPressed: () => Navigator.pop(context),),
          TextButton( child: const Text("Add & Select"), onPressed: () {
              final String newCategory = _customCategoryController.text.trim();
              Navigator.pop(context); // Close dialog first
              if (newCategory.isNotEmpty) {
                 // Check against existing categories (case-insensitive)
                 bool exists = _predefinedCategories.any((c) => c.toLowerCase() == newCategory.toLowerCase()) ||
                               _categoryRatings.keys.any((c) => c.toLowerCase() == newCategory.toLowerCase());
                 if (exists) {
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category "$newCategory" already exists or is predefined.'), backgroundColor: Colors.orange,));
                       // Optionally select the existing one if the user confirms? For now, just show message.
                    }
                 } else {
                   // Add and select the new category
                   setState(() {
                     _currentCategory = newCategory;
                     _categoryRatings.putIfAbsent(newCategory, () => 0); // Ensure exists with default rating
                   });
                 }
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Dispose Controller ---
  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    int currentRating = _getRatingForCurrentCategory();
    Color currentBackgroundColor = _getBackgroundColor();
    Color textColor = ThemeData.estimateBrightnessForColor(currentBackgroundColor) == Brightness.dark ? Colors.white : Colors.black87;
    Color iconColor = textColor;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: currentBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _isLoadingData
                ? Center(child: CircularProgressIndicator(color: iconColor)) // Show loading initially
                : Column(
                    children: [
                      // --- Top Row ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton( icon: Icon(Icons.arrow_back_ios, color: iconColor), tooltip: _currentCategory != null ? 'Change Area' : 'Back', onPressed: () { if (_isSaving) return; if (_currentCategory != null) { setState(() { _currentCategory = null; }); } else { if(Navigator.canPop(context)) Navigator.pop(context); } },), // Added canPop check
                          IconButton( icon: Icon(Icons.check_circle_outline_rounded, size: 30, color: iconColor), tooltip: 'Finish Tracking Session', onPressed: () { if (_isSaving) return; print("Finished Session. Final state for today: $_categoryRatings"); if (mounted && Navigator.canPop(context)) Navigator.pop(context); },), // Added canPop check
                        ],
                      ),

                      // --- Main Content Area ---
                      Expanded(
                        child: _currentCategory == null
                            ? _buildCategorySelector(textColor)
                            : _buildMoodRater(textColor),
                      ),

                      // --- Bottom Area: Save Button ---
                      AnimatedOpacity(
                        opacity: (_currentCategory != null && currentRating > 0) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: (_currentCategory != null && currentRating > 0)
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom( backgroundColor: Colors.white, foregroundColor: Colors.blue.shade800, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), disabledBackgroundColor: Colors.white.withOpacity(0.7), disabledForegroundColor: Colors.blue.shade300,),
                                  onPressed: _isSaving ? null : _saveOrUpdateCurrentCategoryMood,
                                  child: _isSaving
                                      ? const SizedBox( height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey)),) // Match button text color better
                                      : Text('Record Mood for $_currentCategory'),
                                ),
                              )
                            : const SizedBox(height: 68), // Placeholder
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // --- Widget Builder for Category Selector (Displays loaded/saved ratings) ---
  Widget _buildCategorySelector(Color textColor) {
    // Combine predefined and any keys from the ratings map to show all relevant categories
    // Use a List and sort it for consistent display order
    List<String> allCategoriesToShow = {..._predefinedCategories, ..._categoryRatings.keys}.toList()..sort();

    return SingleChildScrollView(
      key: const ValueKey('categorySelector'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select an area to track or update\nyour mood for:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10.0, runSpacing: 12.0, alignment: WrapAlignment.center,
              children: [
                ...allCategoriesToShow.map((category) {
                  int todaysRating = _categoryRatings[category] ?? 0; // Check the STATE map
                  bool alreadyRatedToday = todaysRating > 0;

                  return InputChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category),
                        if (alreadyRatedToday)
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700),
                                const SizedBox(width: 2),
                                Text( todaysRating.toString(), style: TextStyle( fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.7),),),
                              ],
                            ),
                          ),
                      ],
                    ),
                    selected: false, // Chip itself isn't 'selected' stateful
                    onPressed: () { // Allow tapping to select/update
                       setState(() {
                         _currentCategory = category;
                         // Ensure category exists in map, pre-populating with current rating if exists, else 0
                         _categoryRatings.putIfAbsent(category, () => 0);
                       });
                    },
                    backgroundColor: Colors.white.withOpacity(0.85),
                    side: BorderSide( color: Colors.grey.shade300, width: 1.0,),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    labelStyle: const TextStyle( color: Colors.black87, fontWeight: FontWeight.w500,),
                  );
                }).toList(),
                // --- Add Other Chip ---
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18, color: Colors.black54),
                  label: const Text("Add Other"),
                  onPressed: _showAddCategoryDialog,
                  backgroundColor: Colors.white.withOpacity(0.85),
                  labelStyle: const TextStyle(color: Colors.black87),
                   side: BorderSide( color: Colors.grey.shade300, width: 1.0,),
                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
              ],
            ),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- Widget Builder for Mood Rater ---
  Widget _buildMoodRater(Color textColor) {
    int rating = _getRatingForCurrentCategory(); // Gets rating from _categoryRatings state map
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text( _currentCategory ?? "Mood", style: TextStyle( fontSize: 22, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.9),),),
        const SizedBox(height: 10),
        Text( _getMoodText(), textAlign: TextAlign.center, style: TextStyle( fontSize: rating == 0 ? 28 : 32, fontWeight: FontWeight.bold, color: textColor,),),
        const SizedBox(height: 30),
        _getMoodFaceWidget(),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            int currentStar = index + 1;
            return IconButton(
              iconSize: 50, splashRadius: 30,
              icon: Icon( rating >= currentStar ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.cyan.shade300,),
              onPressed: () {
                // Update the local map immediately for visual feedback
                setState(() { _categoryRatings[_currentCategory!] = currentStar; });
                },
            );
          }),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

} // End of _MoodTrackingScreenState