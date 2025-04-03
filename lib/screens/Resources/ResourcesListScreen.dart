import 'package:flutter/material.dart';
// Import the data model
import 'package:salam_app/screens/Resources/ResourceItem.dart';
// Import the detail screen
import 'package:salam_app/screens/Resources/ResourceDetailScreen.dart';
// Import the Quiz Screen
import 'package:salam_app/screens/quiz/QuizScreen.dart'; // Adjust path if needed
// Import the Video Screen
import 'package:salam_app/screens/Resources/VideoScreen.dart'; // <-- Needed for navigation

class ResourcesListScreen extends StatefulWidget {
  const ResourcesListScreen({super.key});

  @override
  State<ResourcesListScreen> createState() => _ResourcesListScreenState();
}

class _ResourcesListScreenState extends State<ResourcesListScreen> {
  // --- Data using the imported ResourceItem ---
  final List<ResourceItem> allResources = [
    ResourceItem(
      id: 'article_stress',
      title: 'Why stress happens and how to manage it',
      description:
          'Definition | Physical effects | Types | Causes | Treatment | Management...',
      imagePath: 'assets/images/resourcespic.png', // Ensure this image exists
      type: 'Article',
      videoPath: null,
    ),
    ResourceItem(
      id: 'video_stress_management',
      title:
          '3-Minute Stress Management: Reduce Stress With This Short Activity',
      description: 'Therapy in a Nutshell • 486K views • 4 years ago',
      imagePath: 'assets/images/videopic.png', // Ensure this image exists
      type: 'Video',
      // --- CHANGED: Corrected videoPath ---
      // This should be the ACTUAL path to your video asset file.
      // Make sure this file exists and is declared in pubspec.yaml
      videoPath: 'assets/videos/videoresource.mp4',
    ),
    ResourceItem(
      id: 'quiz_knowledge',
      title: 'Test Your Knowledge',
      description: 'Take our educational quiz on mental wellness.',
      imagePath: 'assets/images/knowledgepic.png', // Ensure this image exists
      type: 'Quiz',
      videoPath: null,
    ),
  ];

  List<ResourceItem> filteredResources = [];
  String currentFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredResources = List.from(allResources);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredResources =
          allResources.where((resource) {
            final matchesFilter =
                currentFilter == 'All' || resource.type == currentFilter;
            final matchesSearch =
                query.isEmpty ||
                resource.title.toLowerCase().contains(query) ||
                resource.description.toLowerCase().contains(query);
            return matchesFilter && matchesSearch;
          }).toList();
    });
  }

  void _selectFilter(String filter) {
    setState(() {
      if (filter == 'All Libraries') {
        currentFilter = 'All';
      } else if (filter == 'Videos') {
        currentFilter = 'Video';
      } else if (filter == 'Articles') {
        currentFilter = 'Article';
      } else if (filter == 'Educational Quiz') {
        currentFilter = 'Quiz';
      } else {
        print("Selected unmapped filter: $filter. Defaulting to All.");
        currentFilter = 'All';
      }
    });
    _applyFiltersAndSearch();
  }

  // --- CHANGED: Updated navigation logic ---
  void _navigateToDetailScreen(ResourceItem resource) {
    if (resource.type == 'Quiz') {
      print('Navigate to Quiz Start');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizScreen(),
          settings: const RouteSettings(name: '/quiz'),
        ),
      );
    } else if (resource.type == 'Video') {
      // <-- ADDED: Check for Video type
      print('Navigate to Video Screen for: ${resource.title}');
      if (resource.videoPath != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Pass the specific resource to VideoScreen
            builder: (context) => VideoScreen(resource: resource),
            settings: const RouteSettings(
              name: '/videoPlayer',
            ), // Optional route name
          ),
        );
      } else {
        print('Error: Video resource "${resource.title}" has no videoPath.');
        // Optionally show a snackbar or dialog to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video not available for "${resource.title}"'),
          ),
        );
      }
    } else {
      // Handles 'Article' and any other types
      print('Navigate to Detail Screen for: ${resource.title}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResourceDetailScreen(resource: resource),
          settings: const RouteSettings(name: '/resourceDetail'),
        ),
      );
    }
  }
  // --- End of Changed Section ---

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4A90E2);
    const Color scaffoldBackgroundColor = primaryColor;
    const Color cardBackgroundColor = Colors.white;
    const Color textColor = Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Consider making this image dynamic or removing if not needed
            Positioned(
              top: 10,
              right: 10,
              child: Image.asset(
                'assets/images/resourcespic.png', // Ensure this image exists
                height: 80,
                errorBuilder:
                    (context, error, stackTrace) => const SizedBox(
                      height: 80,
                      width: 80,
                    ), // Placeholder on error
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
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
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Resources...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                                horizontal: 20.0,
                              ),
                              suffixIcon:
                                  _searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          // _applyFiltersAndSearch(); // Already handled by listener
                                        },
                                        tooltip: 'Clear search',
                                      )
                                      : null,
                            ),
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterButton(context),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    decoration: const BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30.0),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias, // Prevents content overflow
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        20.0,
                        20.0,
                        80.0, // Padding at bottom for nav bar overlap avoidance
                      ),
                      itemCount: filteredResources.length,
                      itemBuilder: (context, index) {
                        final resource = filteredResources[index];
                        // Pass resource to card builder
                        return _buildResourceCard(context, resource, textColor);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Custom Bottom Navigation Bar Widget ---
  Widget _buildBottomNavBar() {
    const Color navBarColor = Color(0xFF276181);
    const Color iconColor = Color(0xFF5E94FF);
    // Consider making this more dynamic based on current route if needed
    return BottomAppBar(
      color: navBarColor,
      height: 60,
      // Consider using notch shape if using FAB
      // shape: const CircularNotchedRectangle(),
      // notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: iconColor),
            onPressed:
                () => Navigator.popUntil(context, ModalRoute.withName('/')),
            tooltip: 'Home',
          ),
          IconButton(
            icon: const Icon(Icons.access_time, color: iconColor),
            onPressed: () => Navigator.pushNamed(context, '/reminders'),
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: iconColor),
            onPressed: () => Navigator.pushNamed(context, '/activity'),
            tooltip: 'Activity',
          ),
          IconButton(
            // Highlight this icon if on the Resources screen?
            icon: const Icon(
              Icons.menu_book,
              color: Colors.white,
            ), // Example highlight
            onPressed: () {
              /* Already on this screen */
            },
            tooltip: 'Resources',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: iconColor),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildFilterButton(BuildContext context) {
    const String filterIconPath =
        'assets/images/icon_filter.png'; // Ensure this exists
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        icon: Image.asset(
          filterIconPath,
          height: 24,
          width: 24,
          color: Colors.grey[700],
          errorBuilder:
              (context, error, stackTrace) => Icon(
                Icons.filter_list,
                color: Colors.grey[700],
                size: 24,
              ), // Fallback icon
        ),
        onSelected: _selectFilter,
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'All Libraries',
                child: Text(
                  'All Libraries',
                  style: TextStyle(
                    color:
                        currentFilter == 'All'
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'Videos',
                child: Text(
                  'Videos',
                  style: TextStyle(
                    color:
                        currentFilter == 'Video'
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'Articles',
                child: Text(
                  'Articles',
                  style: TextStyle(
                    color:
                        currentFilter == 'Article'
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'Educational Quiz',
                child: Text(
                  'Educational Quiz',
                  style: TextStyle(
                    color:
                        currentFilter == 'Quiz'
                            ? Theme.of(context).primaryColor
                            : null,
                  ),
                ),
              ),
            ],
        tooltip: "Filter Resources",
        offset: const Offset(0, 55), // Adjust offset slightly below button
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    ResourceItem resource,
    Color textColor,
  ) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Use the updated navigation function
        onTap: () => _navigateToDetailScreen(resource),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items top
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  resource.imagePath, // Use path from resource
                  height: 75,
                  width: 75,
                  fit: BoxFit.cover,
                  errorBuilder: // Placeholder for missing images
                      (context, error, stackTrace) => Container(
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(
                          // Indicate type if image fails?
                          resource.type == 'Video'
                              ? Icons.video_library_outlined
                              : resource.type == 'Article'
                              ? Icons.article_outlined
                              : resource.type == 'Quiz'
                              ? Icons.quiz_outlined
                              : Icons.broken_image_outlined,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Vertically center text
                  children: [
                    SizedBox(
                      height: (75 - 50) / 2,
                    ), // Adjust spacing to roughly center text block vertically
                    Text(
                      resource.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resource.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: (75 - 50) / 2), // Adjust spacing
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // End of _ResourcesListScreenState
