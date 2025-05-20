// lib/screens/resources/ResourcesListScreen.dart
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Keep if _showAddResourceDialog is kept, remove if dialog is fully deleted

// --- USE PACKAGE IMPORTS ---
// Replace 'flutter_application_2' with your actual package name from pubspec.yaml
// Assuming your file structure is lib/screens/Resources/ResourceItem.dart
// and lib/services/mongo_api_service.dart
// If these files are directly under lib, the path would be different.
// Example: import 'package:flutter_application_2/ResourceItem.dart';
// Based on your screenshot, these seem to be the correct paths if 'flutter_application_2' is your package name
import '/screens/Resources/ResourceItem.dart';
import '/services/mongo_api_service.dart';

import '/screens/Resources/ResourceDetailScreen.dart';
import '/screens/Resources/VideoScreen.dart';
import '/screens/quiz/QuizScreen.dart'; // Correct path for QuizScreen

// Comment out or replace with your actual bottom nav bar
// import 'package:flutter_application_2/widgets/bottom_nav_bar.dart';

// --- THEME PROVIDER IMPORTS (Comment out if not using Provider for theme) ---
// import 'package:provider/provider.dart';
// import 'package:flutter_application_2/providers/theme_provider.dart';
// --- END THEME PROVIDER IMPORTS ---

class ResourcesListScreen extends StatefulWidget {
  const ResourcesListScreen({super.key});

  @override
  State<ResourcesListScreen> createState() => _ResourcesListScreenState();
}

class _ResourcesListScreenState extends State<ResourcesListScreen> {
  // --- Hardcoded Quiz Item ---
  final ResourceItem _hardcodedQuizItem = ResourceItem(
    id: 'local_quiz_knowledge', // Unique local ID
    title: 'Test Your Knowledge',
    description: 'Take our educational quiz on mental wellness.',
    imageUrl: 'assets/images/knowledgepic.png', // Assuming local asset for the quiz thumbnail
    type: 'Quiz', // CRITICAL: Type is "Quiz"
    videoUrl: null,
    articleUrl: null,
  );
  // --- End Hardcoded Quiz Item ---

  List<ResourceItem> _apiFetchedResources = [];
  List<ResourceItem> _allDisplayableResources = [];
  List<ResourceItem> _filteredResources = [];

  String _currentFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  final MongoApiService _apiService = MongoApiService();

  @override
  void initState() {
    super.initState();
    _loadAllResources();
    _searchController.addListener(_applyFiltersAndSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFiltersAndSearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllResources() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedApiResources = await _apiService.getResources();
      if (!mounted) return;

      _apiFetchedResources = fetchedApiResources;
      _rebuildDisplayableList(); 

      setState(() { // Ensure isLoading is set to false after operations
        _isLoading = false;
      });

    } catch (e) {
      print("Error in _loadAllResources: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
        _rebuildDisplayableList(apiFetchFailed: true); 
      });
    }
  }

  void _rebuildDisplayableList({bool apiFetchFailed = false}) {
    List<ResourceItem> combined = [_hardcodedQuizItem];

    if (!apiFetchFailed) {
      combined.addAll(_apiFetchedResources.where((res) => res.type.toLowerCase() != 'quiz'));
    }

    var distinctMap = <String, ResourceItem>{};
    for (var item in combined) {
      distinctMap[item.id] = item;
    }
    _allDisplayableResources = distinctMap.values.toList();
    
    _allDisplayableResources.sort((a, b) {
      if (a.type.toLowerCase() == 'quiz' && b.type.toLowerCase() != 'quiz') return -1;
      if (b.type.toLowerCase() == 'quiz' && a.type.toLowerCase() != 'quiz') return 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    _applyFiltersAndSearch(); 
  }


  void _applyFiltersAndSearch() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredResources = _allDisplayableResources.where((resource) {
        final typeMatches = resource.type.toLowerCase();
        final filterMatches = _currentFilter == 'All' || typeMatches == _currentFilter.toLowerCase();

        final searchMatches = query.isEmpty ||
            resource.title.toLowerCase().contains(query) ||
            resource.description.toLowerCase().contains(query);
        return filterMatches && searchMatches;
      }).toList();
    });
  }

  void _selectFilter(String filter) { // filter values from PopupMenu: 'All', 'Video', 'Article', 'Quiz'
    if (!mounted) return;
    setState(() {
      _currentFilter = filter; // Assign directly
    });
    _applyFiltersAndSearch();
  }

  void _navigateToDetailScreen(ResourceItem resource) {
    final typeLower = resource.type.toLowerCase();

    if (typeLower == 'quiz') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizScreen(),
          settings: const RouteSettings(name: '/quiz'),
        ),
      );
    } else if (typeLower == 'video') {
      if (resource.videoUrl != null && resource.videoUrl!.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(resource: resource),
            settings: const RouteSettings(name: '/videoPlayer'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video URL not available for "${resource.title}"')),
        );
      }
    } else { 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResourceDetailScreen(resource: resource),
          settings: const RouteSettings(name: '/resourceDetail'),
        ),
      );
    }
  }

  // You can keep this method if you might re-add the button later,
  // or delete it and remove the FirebaseAuth import if you're sure.
  /*
  void _showAddResourceDialog() {
     if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add a resource.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final titleController = TextEditingController();
    // ... other controllers and dialog logic ...
    // ... as you had before ...
  }
  */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color scaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    final Color cardBackgroundColor = theme.cardColor;
    final Color primaryTextColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final Color secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final Color iconThemeColor = theme.iconTheme.color ?? (isDark ? Colors.white70 : Colors.black54);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/resourcespic.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                colorBlendMode: isDark ? BlendMode.dstATop : BlendMode.srcOver,
                color: isDark ? Colors.black.withOpacity(0.3) : null,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 10.0),
                  child: Text(
                    'Resources',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.white,
                      shadows: [ Shadow(blurRadius: isDark ? 2.0 : 1.0, color: Colors.black.withOpacity(0.3), offset: const Offset(1,1)) ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(isDark ? 0.2 : 0.85),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Resources...',
                              hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.search, color: iconThemeColor.withOpacity(0.7)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: iconThemeColor.withOpacity(0.7)),
                                      onPressed: () => _searchController.clear(),
                                      tooltip: 'Clear search',
                                    )
                                  : null,
                            ),
                            style: TextStyle(color: primaryTextColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFilterButton(context, theme),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,-5))]
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                       Icon(Icons.error_outline, color: Colors.red.shade700, size: 50),
                                       const SizedBox(height: 10),
                                      Text('Error: $_errorMessage', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade700, fontSize: 16)),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: _loadAllResources, // Changed from _fetchResources
                                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                                        child: Text('Retry', style: TextStyle(color: theme.colorScheme.onPrimary))
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : _filteredResources.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        _searchController.text.isNotEmpty || _currentFilter != 'All'
                                            ? 'No resources found matching your criteria.'
                                            // Updated message to reflect that quiz is always present
                                            : 'No API resources available. Only the local quiz is shown.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, color: secondaryTextColor),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0), // Adjusted padding
                                    itemCount: _filteredResources.length,
                                    itemBuilder: (context, index) {
                                      final resource = _filteredResources[index];
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
      // --- REMOVE THESE TWO LINES TO REMOVE THE FAB ---
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _showAddResourceDialog,
      //   tooltip: 'Add Resource',
      //   backgroundColor: theme.colorScheme.primary,
      //   child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // --- END OF FAB REMOVAL ---
       bottomNavigationBar: BottomAppBar( 
        color: const Color(0xFF276181),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(icon: const Icon(Icons.home, color: Color(0xFF5E94FF)), onPressed: () => Navigator.popUntil(context, (route) => route.isFirst)),
            IconButton(icon: const Icon(Icons.access_time, color: Color(0xFF5E94FF)), onPressed: () => Navigator.pushNamed(context, '/reminders')),
            IconButton(icon: const Icon(Icons.checklist, color: Color(0xFF5E94FF)), onPressed: () => Navigator.pushNamed(context, '/activitySelection')),
            IconButton(icon: const Icon(Icons.menu_book, color: Color(0xFF5E94FF)), onPressed: () {
                if (ModalRoute.of(context)?.settings.name != '/resourcesList') {
                  Navigator.pushNamed(context, '/resourcesList');
                } else {
                  _loadAllResources(); // Refresh if already on the screen
                }
            }),
            IconButton(icon: const Icon(Icons.person, color: Color(0xFF5E94FF)), onPressed: () => Navigator.pushNamed(context, '/user/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, ThemeData theme) {
     const String filterIconPath = 'assets/images/icon_filter.png';
     final bool isDark = theme.brightness == Brightness.dark;
     final Color iconColor = theme.iconTheme.color?.withOpacity(0.7) ?? (isDark ? Colors.white70 : Colors.black54);

    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(isDark ? 0.2 : 0.85),
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        icon: Image.asset(
          filterIconPath,
          height: 24,
          width: 24,
          color: iconColor,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading filter icon asset: $error");
            return Icon(Icons.filter_list, color: iconColor, size: 24);
          }
        ),
        onSelected: _selectFilter,
        color: theme.popupMenuTheme.color ?? theme.cardColor,
        shape: theme.popupMenuTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          _buildPopupMenuItem(theme, 'All', 'All Libraries'),
          _buildPopupMenuItem(theme, 'Video', 'Videos'),
          _buildPopupMenuItem(theme, 'Article', 'Articles'),
          _buildPopupMenuItem(theme, 'Quiz', 'Educational Quiz'), // This will set _currentFilter to 'Quiz'
        ],
        tooltip: "Filter Resources",
        offset: const Offset(0, 55),
        padding: EdgeInsets.zero,
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(ThemeData theme, String value, String text) {
    final bool isSelected = _currentFilter == value;
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context,
    ThemeData theme,
    ResourceItem resource,
    Color titleColor,
    Color descriptionColor,
  ) {
    final bool isDark = theme.brightness == Brightness.dark;
    final Color placeholderIconColor = theme.iconTheme.color?.withOpacity(0.6) ?? (isDark ? Colors.white54 : Colors.black45);
    final Color placeholderBgColor = theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.1);

    // Check if imageUrl is a network URL or a local asset path
    bool isNetworkImage = resource.imageUrl?.startsWith('http') ?? false;
    // Specifically for the hardcoded quiz, ensure its local asset path is used correctly
    if (resource.id == 'local_quiz_knowledge') {
        isNetworkImage = false; // Force asset image for the hardcoded quiz
    }


    return Card(
      elevation: theme.cardTheme.elevation ?? (isDark ? 2.0 : 1.0),
      color: theme.cardColor,
      shape: theme.cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                child: (resource.imageUrl != null && resource.imageUrl!.isNotEmpty)
                    ? (isNetworkImage
                        ? Image.network(
                            resource.imageUrl!,
                            height: 75, width: 75, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder(75, 75, resource.type, placeholderIconColor, placeholderBgColor),
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container( height: 75, width: 75, decoration: BoxDecoration(color: placeholderBgColor, borderRadius: BorderRadius.circular(10.0)),
                                child: Center(child: CircularProgressIndicator( strokeWidth: 2.0,
                                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                )),
                              );
                            },
                          )
                        : Image.asset( // For local assets like the quiz image
                            resource.imageUrl!,
                            height: 75, width: 75, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                               print("Error loading local asset image '${resource.imageUrl}': $error");
                               return _imageErrorPlaceholder(75, 75, resource.type, placeholderIconColor, placeholderBgColor);
                            }
                          )
                      )
                    : _imageErrorPlaceholder(75, 75, resource.type, placeholderIconColor, placeholderBgColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resource.title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resource.description,
                      style: TextStyle(fontSize: 13, color: descriptionColor),
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

  Widget _imageErrorPlaceholder(double height, double width, String type, Color iconColor, Color bgColor) {
    IconData iconData;
    switch (type.toLowerCase()) {
      case 'video': iconData = Icons.video_library_outlined; break;
      case 'article': iconData = Icons.article_outlined; break;
      case 'quiz': iconData = Icons.quiz_outlined; break;
      default: iconData = Icons.broken_image_outlined;
    }
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10.0)),
      child: Icon(iconData, color: iconColor, size: 30),
    );
  }
}