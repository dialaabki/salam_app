import 'package:flutter/material.dart';
import 'dart:async';

import 'package:salam_app/screens/Resources/ResourceItem.dart';
import 'package:salam_app/screens/Resources/ResourceDetailScreen.dart';
import 'package:salam_app/screens/quiz/QuizScreen.dart';
import 'package:salam_app/screens/Resources/VideoScreen.dart';
import 'package:salam_app/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../../providers/theme_provider.dart'; // 2. Import ThemeNotifier


class ResourcesListScreen extends StatefulWidget {
  const ResourcesListScreen({super.key});

  @override
  State<ResourcesListScreen> createState() => _ResourcesListScreenState();
}

class _ResourcesListScreenState extends State<ResourcesListScreen> {
  // --- Data (Keep as is) ---
  final List<ResourceItem> allResources = [
    ResourceItem( id: 'article_stress', title: 'Why stress happens and how to manage it', description: 'Definition | Physical effects | Types | Causes | Treatment | Management...', imagePath: 'assets/images/resourcespic.png', type: 'Article', videoPath: null, ),
    ResourceItem( id: 'video_stress_management', title: '3-Minute Stress Management: Reduce Stress With This Short Activity', description: 'Therapy in a Nutshell • 486K views • 4 years ago', imagePath: 'assets/images/videopic.png', type: 'Video', videoPath: 'assets/videos/videoresource.mp4', ),
    ResourceItem( id: 'quiz_knowledge', title: 'Test Your Knowledge', description: 'Take our educational quiz on mental wellness.', imagePath: 'assets/images/knowledgepic.png', type: 'Quiz', videoPath: null, ),
  ];
  List<ResourceItem> filteredResources = [];
  String currentFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  // --- End Data ---

  @override
  void initState() { super.initState(); filteredResources = List.from(allResources); _searchController.addListener(_onSearchChanged); }
  @override
  void dispose() { _searchController.removeListener(_onSearchChanged); _searchController.dispose(); super.dispose(); }

  void _onSearchChanged() { _applyFiltersAndSearch(); }
  void _applyFiltersAndSearch() { /* ... filter/search logic ... */
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredResources = allResources.where((resource) {
            final matchesFilter = currentFilter == 'All' || resource.type == currentFilter;
            final matchesSearch = query.isEmpty || resource.title.toLowerCase().contains(query) || resource.description.toLowerCase().contains(query);
            return matchesFilter && matchesSearch;
          }).toList();
    });
  }

  void _selectFilter(String filter) { /* ... filter selection logic ... */
    setState(() {
      if (filter == 'All Libraries') currentFilter = 'All';
      else if (filter == 'Videos') currentFilter = 'Video';
      else if (filter == 'Articles') currentFilter = 'Article';
      else if (filter == 'Educational Quiz') currentFilter = 'Quiz';
      else currentFilter = 'All';
    });
    _applyFiltersAndSearch();
  }

  void _navigateToDetailScreen(ResourceItem resource) { /* ... navigation logic ... */
    const String currentRoute = '/resources';
    if (resource.type == 'Quiz') { Navigator.push( context, MaterialPageRoute( builder: (context) => const QuizScreen(), settings: const RouteSettings(name: '/quiz'), ), ); }
    else if (resource.type == 'Video') {
      if (resource.videoPath != null) { Navigator.push( context, MaterialPageRoute( builder: (context) => VideoScreen(resource: resource), settings: const RouteSettings(name: '/videoPlayer'), ), );
      } else { ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text('Video not available for "${resource.title}"'), ), ); }
    } else { Navigator.push( context, MaterialPageRoute( builder: (context) => ResourceDetailScreen(resource: resource), settings: const RouteSettings(name: '/resourceDetail'), ), ); }
  }

  // --- Build Method (Theme Aware) ---
  @override
  Widget build(BuildContext context) {
    // --- 3. Access Theme ---
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    // --- End Theme Access ---

    // 4. Use theme colors
    final Color scaffoldBackgroundColor = theme.scaffoldBackgroundColor; // Use theme scaffold bg
    final Color cardBackgroundColor = theme.cardColor; // Use theme card color
    final Color primaryTextColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87); // Theme text color
    final Color secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey; // Theme secondary text color

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor, // Use theme scaffold background
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Positioned background image (can stay as is)
            Positioned.fill(
              child: Image.asset(
                'assets/images/resourcespic.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                // Optional: Add blend mode for dark theme?
                // colorBlendMode: isDark ? BlendMode.darken : BlendMode.srcOver,
                // color: isDark ? Colors.black.withOpacity(0.15) : null,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only( top: 30.0, left: 20.0, right: 20.0, bottom: 10.0, ),
                  child: Text(
                    'Resources',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      // 5. Use theme color for title (e.g., onPrimary if background is primary)
                      // If the background image dictates white, keep white. Otherwise use theme.
                      color: Colors.white, // Kept white assuming it overlays the image well
                      // color: theme.colorScheme.onPrimary, // Alternative if bg matches primary
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric( horizontal: 20.0, vertical: 10.0, ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            // 6. Use theme surface variant for search field background
                            color: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.8 : 0.95),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Resources...',
                              // 7. Use theme hint color
                              hintStyle: TextStyle(color: theme.hintColor),
                              // 8. Use theme icon color
                              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color?.withOpacity(0.7)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric( vertical: 15.0, horizontal: 20.0, ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      // 8. Use theme icon color
                                      icon: Icon(Icons.clear, color: theme.iconTheme.color?.withOpacity(0.7)),
                                      onPressed: () { _searchController.clear(); },
                                      tooltip: 'Clear search',
                                    )
                                  : null,
                            ),
                            // 9. Use theme text color for input
                            style: TextStyle(color: primaryTextColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterButton(context, theme), // Pass theme
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor, // Use theme card color
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
                      boxShadow: isDark ? [] : [ // Optional: remove shadow in dark mode
                         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0,-5))
                      ]
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                      itemCount: filteredResources.length,
                      itemBuilder: (context, index) {
                        final resource = filteredResources[index];
                        // Pass theme and appropriate text color
                        return _buildResourceCard(context, theme, resource, primaryTextColor, secondaryTextColor);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(), // Keep nav bar
    );
  } // End build

  // --- Helper Widgets (Theme Aware) ---

  Widget _buildFilterButton(BuildContext context, ThemeData theme) { // Accept theme
     const String filterIconPath = 'assets/images/icon_filter.png';
     final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        // 10. Use theme surface variant for filter button background
        color: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.8 : 0.95),
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        icon: Image.asset(
          filterIconPath,
          height: 24,
          width: 24,
          // 11. Use theme icon color
          color: theme.iconTheme.color?.withOpacity(0.7),
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.filter_list, color: theme.iconTheme.color, size: 24),
        ),
        onSelected: _selectFilter,
        // 12. Style Popup Menu with theme colors
        color: theme.popupMenuTheme.color ?? theme.cardColor, // Background
        shape: theme.popupMenuTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'All Libraries',
            child: Text(
              'All Libraries',
              style: TextStyle(
                fontWeight: currentFilter == 'All' ? FontWeight.bold : FontWeight.normal,
                // Use theme color for selected/unselected text
                color: currentFilter == 'All' ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          PopupMenuItem<String>(
            value: 'Videos',
            child: Text(
              'Videos',
              style: TextStyle(
                fontWeight: currentFilter == 'Video' ? FontWeight.bold : FontWeight.normal,
                color: currentFilter == 'Video' ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          PopupMenuItem<String>(
            value: 'Articles',
            child: Text(
              'Articles',
              style: TextStyle(
                fontWeight: currentFilter == 'Article' ? FontWeight.bold : FontWeight.normal,
                color: currentFilter == 'Article' ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          PopupMenuItem<String>(
            value: 'Educational Quiz',
            child: Text(
              'Educational Quiz',
              style: TextStyle(
                fontWeight: currentFilter == 'Quiz' ? FontWeight.bold : FontWeight.normal,
                color: currentFilter == 'Quiz' ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
        tooltip: "Filter Resources",
        offset: const Offset(0, 55),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    ThemeData theme, // Accept theme
    ResourceItem resource,
    Color titleColor, // Accept theme-derived title color
    Color descriptionColor, // Accept theme-derived description color
  ) {
    return Card(
      elevation: theme.cardTheme.elevation ?? (theme.brightness == Brightness.dark ? 1.0 : 3.0), // Use theme elevation
      color: theme.cardColor, // Use theme card color
      shape: theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)), // Use theme shape
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetailScreen(resource),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  resource.imagePath,
                  height: 75,
                  width: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                      // 13. Use theme surface variant for error placeholder bg
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      resource.type == 'Video' ? Icons.video_library_outlined
                      : resource.type == 'Article' ? Icons.article_outlined
                      : resource.type == 'Quiz' ? Icons.quiz_outlined
                      : Icons.broken_image_outlined,
                      // 14. Use theme icon color for error placeholder icon
                      color: theme.iconTheme.color?.withOpacity(0.6),
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resource.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor, // Use passed theme text color
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resource.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: descriptionColor, // Use passed theme text color
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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