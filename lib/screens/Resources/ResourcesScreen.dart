import 'package:flutter/material.dart';
// Import your other screens if they exist (e.g., QuizScreen, ArticleScreen, VideoScreen)
// import 'path/to/quiz_screen.dart';
// import 'path/to/article_screen.dart';
// import 'path/to/video_screen.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  int _selectedIndex = 3; // Assuming 'Resources' is the 4th item (index 3)

  // Placeholder navigation function
  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // Placeholder screens for navigation
  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Content for $title goes here')),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
        // Navigate to Home
        // _navigateToScreen(_buildPlaceholderScreen('Home'));
        print("Navigate to Home");
        break;
      case 1:
        // Navigate to Timer/History
        // _navigateToScreen(_buildPlaceholderScreen('History'));
        print("Navigate to History/Timer");
        break;
      case 2:
        // Navigate to Main Quiz/Tasks
        // _navigateToScreen(_buildPlaceholderScreen('Tasks'));
        print("Navigate to Tasks/Quiz List");
        break;
      case 3:
        // Already on Resources screen
        print("Already on Resources");
        break;
      case 4:
        // Navigate to Profile
        // _navigateToScreen(_buildPlaceholderScreen('Profile'));
        print("Navigate to Profile");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on your screenshots
    const Color primaryColor = Color(0xFF4A90E2); // Adjust as needed
    const Color scaffoldBackgroundColor = primaryColor;
    const Color cardBackgroundColor = Colors.white;
    const Color textColor = Color(0xFF4A4A4A); // Dark grey for text
    const Color headingColor = Color(0xFF00579B); // Darker blue for headings

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false, // Prevent overlap with bottom nav bar area
        child: Stack(
          children: [
            // --- Top Decorative Brain ---
            Positioned(
              top: 10,
              right: 10,
              child: Image.asset(
                'assets/images/reading_brain.png', // Your brain reading image
                height: 80,
              ),
            ),
            // --- Main Content ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0,
                    left: 20.0,
                    right: 20.0,
                    bottom: 10.0,
                  ),
                  child: Text(
                    'Resources',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White title on blue background
                    ),
                  ),
                ),

                // --- Search and Filter Row ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search Resources...',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                                horizontal: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filter Button
                      _buildFilterButton(context),
                    ],
                  ),
                ),

                // --- Scrollable Content Area ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30.0), // Rounded top corners
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(20.0),
                      children: [
                        _buildSectionHeader('Article', headingColor),
                        _buildArticleCard(context, textColor),
                        const SizedBox(height: 20),
                        _buildSectionHeader('Video', headingColor),
                        _buildVideoCard(context, textColor),
                        const SizedBox(height: 20),
                        _buildSectionHeader('Educational Quiz', headingColor),
                        _buildQuizCard(context, textColor),
                        const SizedBox(
                          height: 80,
                        ), // Add space at the bottom for nav bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icon_home.png',
              height: 24,
              color: _selectedIndex == 0 ? primaryColor : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icon_clock.png',
              height: 24,
              color: _selectedIndex == 1 ? primaryColor : Colors.grey,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icon_quiz.png',
              height: 24,
              color: _selectedIndex == 2 ? primaryColor : Colors.grey,
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icon_book.png',
              height: 24,
              color: _selectedIndex == 3 ? primaryColor : Colors.grey,
            ),
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icon_profile.png',
              height: 24,
              color: _selectedIndex == 4 ? primaryColor : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        showUnselectedLabels:
            true, // Optional: show labels for unselected items
        backgroundColor: Colors.white, // Or match your theme
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildFilterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        icon: Image.asset(
          'assets/images/icon_filter.png', // Your filter icon
          height: 20,
          color: Colors.grey[700],
        ),
        onSelected: (String result) {
          // Handle filter selection
          print('Filter selected: $result');
          // Add filtering logic here based on result
        },
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('All Libraries'),
              ),
              const PopupMenuItem<String>(
                value: 'Videos',
                child: Text('Videos'),
              ),
              const PopupMenuItem<String>(
                value: 'Articles',
                child: Text('Articles'),
              ),
              const PopupMenuItem<String>(
                value: 'Guides',
                child: Text('Mental health guides'),
              ),
              const PopupMenuItem<String>(
                value: 'Quiz',
                child: Text('Educational Quiz'),
              ),
            ],
        tooltip: "Filter Resources",
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Color textColor) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: InkWell(
        onTap: () {
          print('Article tapped');
          // _navigateToScreen(_buildPlaceholderScreen('Article Detail'));
          // Or navigate to your actual ArticleScreen
          // _navigateToScreen(ArticleScreen(articleId: 'why-stress-happens'));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why stress happens and how to manage it',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Definition | Physical effects | Types | Causes | Treatment | Management',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Stress is a natural reaction to specific demands and events, but ongoing stress can affect a person\'s health and wellbeing. Tips for managing stress include exercise, setting priorities, counseling, and more.',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Color textColor) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          print('Video tapped');
          // _navigateToScreen(_buildPlaceholderScreen('Video Player'));
          // Or navigate to your actual VideoScreen/Player
          // _navigateToScreen(VideoScreen(videoId: 'some_video_id'));
          // Or launch URL if it's a web video
          // launchUrl(Uri.parse('https://www.youtube.com/watch?v=...'));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for Video Thumbnail
            Image.asset(
              'assets/images/resource_video_thumbnail.png', // Your video thumbnail
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150, // Adjust height as needed
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3-Minute Stress Management: Reduce Stress With This Short Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Therapy in a Nutshell • 486K views • 4 years ago',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Color textColor) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          print('Quiz tapped');
          // Navigate to the start of your quiz
          // _navigateToScreen(QuizStartScreen()); // Or your first quiz question screen
          _navigateToScreen(_buildPlaceholderScreen('Educational Quiz'));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/resource_quiz_brain.png', // Your quiz brain image
                height: 60,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Test Your Knowledge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
