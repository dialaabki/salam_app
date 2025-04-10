import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Video player core
import 'package:chewie/chewie.dart'; // Video player UI controller
// Import the data model (using your specified filename case)
import 'package:salam_app/screens/Resources/ResourceItem.dart';

class ResourceDetailScreen extends StatefulWidget {
  final ResourceItem resource;
  const ResourceDetailScreen({super.key, required this.resource});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  // Feedback state
  int _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();

  // Video Player state
  VideoPlayerController? _videoPlayerController; // Nullable initially
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false; // Flag for video loading errors

  @override
  void initState() {
    super.initState();
    // Initialize video ONLY if it's a video resource with a valid path
    if (widget.resource.type == 'Video' &&
        widget.resource.videoPath != null &&
        widget.resource.videoPath!.isNotEmpty) {
      _initializeVideoPlayer();
    } else if (widget.resource.type == 'Video') {
      // Handle case where it's a video type but path is missing/empty
      print(
        "Video resource '${widget.resource.id}' is missing a valid videoPath.",
      );
      _isVideoError = true; // Set error flag immediately
    }
  }

  Future<void> _initializeVideoPlayer() async {
    // Construct the full asset path
    final videoAssetPath = 'assets/videos/${widget.resource.videoPath!}';
    print("Initializing video from: $videoAssetPath"); // Debug print

    // Create the controller
    _videoPlayerController = VideoPlayerController.asset(videoAssetPath);

    try {
      // Initialize the core video controller
      await _videoPlayerController!
          .initialize(); // Use ! because we checked non-null path

      // Create the Chewie controller AFTER core controller is initialized
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoInitialize: true, // Let Chewie handle initialization internally now
        autoPlay: false, // Don't play immediately
        looping: false,
        // Custom placeholder shown while Chewie initializes
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        // Custom error widget within Chewie
        errorBuilder: (context, errorMessage) {
          print("Chewie Error: $errorMessage"); // Log Chewie errors
          return Container(
            color: Colors.black,
            child: Center(
              child: Text(
                'Error loading video.\nPlease check the file path and format.',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        // Add other Chewie options here if needed (custom controls, etc.)
      );

      // Update state to rebuild with the player
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isVideoInitialized = true;
          _isVideoError = false; // Clear error flag on success
        });
      }
    } catch (error) {
      print(
        "Error initializing VideoPlayerController: $error",
      ); // Log core errors
      if (mounted) {
        setState(() {
          _isVideoError = true; // Set error flag
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    // --- IMPORTANT: Dispose video controllers ---
    _videoPlayerController?.dispose(); // Use null-safe dispose
    _chewieController?.dispose();
    print("Video controllers disposed"); // Confirm disposal
    super.dispose();
  }

  // --- Feedback Submission Logic ---
  void _submitFeedback() {
    final rating = _currentRating;
    final comment = _commentController.text.trim();

    print('Submitting Feedback:');
    print('  Resource ID: ${widget.resource.id}');
    print('  Rating: $rating stars');
    print('  Comment: ${comment.isEmpty ? "[No Comment]" : comment}');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Feedback Submitted'),
            content: const Text('Thank you for your feedback!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Pops the detail screen after OK
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
    FocusScope.of(context).unfocus(); // Hide keyboard
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4A90E2);
    const Color scaffoldBackgroundColor = primaryColor;
    const Color cardBackgroundColor = Colors.white;
    const Color textColor = Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // --- Header Row ---
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      left: 5.0,
                      right: 15.0,
                      bottom: 5.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Back',
                        ),
                        Expanded(
                          child: Text(
                            widget.resource.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- Scrollable Content Area ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30.0),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Resource Content (Video/Article/etc.) ---
                            _buildResourceContent(widget.resource),
                            const SizedBox(height: 30),
                            // --- Feedback Section ---
                            const Text(
                              'Let us know what you think!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Rate this resource:',
                              style: TextStyle(fontSize: 15, color: textColor),
                            ),
                            const SizedBox(height: 5),
                            _buildRatingStars(primaryColor),
                            const SizedBox(height: 25),
                            const Text(
                              'Write your comment (optional):',
                              style: TextStyle(fontSize: 15, color: textColor),
                            ),
                            const SizedBox(height: 10),
                            _buildCommentField(textColor),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed:
                                    (_currentRating > 0 ||
                                            _commentController.text
                                                .trim()
                                                .isNotEmpty)
                                        ? _submitFeedback
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  disabledBackgroundColor: Colors.grey[300],
                                ),
                                child: const Text('Submit Feedback'),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // --- Bottom Navigation Bar ---
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  // --- Custom Bottom Navigation Bar Widget ---
  Widget _buildBottomNavBar() {
    const Color navBarColor = Color(0xFF276181);
    const Color iconColor = Color(0xFF5E94FF);
    return BottomAppBar(
      color: navBarColor,
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
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reminders');
            },
            tooltip: 'Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: iconColor),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/activity');
            },
            tooltip: 'Activity',
          ),
          IconButton(
            icon: const Icon(Icons.menu_book, color: iconColor),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/doctors');
            },
            tooltip: 'Doctors',
          ),
          IconButton(
            icon: const Icon(Icons.person, color: iconColor),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  // Builds the main content display (Video Player OR Article OR Error)
  Widget _buildResourceContent(ResourceItem resource) {
    // --- VIDEO ---
    if (resource.type == 'Video') {
      // Display error message if initialization failed or path was invalid
      if (_isVideoError) {
        return AspectRatio(
          // Maintain aspect ratio even for error
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
              child: Text(
                'Could not load video.\nPlease check the file.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
      // Display player if initialized successfully
      else if (_isVideoInitialized && _chewieController != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio:
                  _chewieController!.aspectRatio ??
                  16 / 9, // Use controller's ratio or default
              child: Chewie(controller: _chewieController!),
            ),
            const SizedBox(height: 15),
            Text(
              resource.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              resource.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        );
      }
      // Display loading indicator while initializing
      else {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      }
    }
    // --- ARTICLE ---
    else if (resource.type == 'Article') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.asset(
              resource.imagePath,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            resource.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            resource.description,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text(
            // Placeholder text
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
            textAlign: TextAlign.justify,
          ),
        ],
      );
    }
    // --- Fallback ---
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Center(child: Text('Unsupported resource type: ${resource.type}')),
    );
  }

  // Builds the star rating widget
  Widget _buildRatingStars(Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return IconButton(
          icon: Icon(
            _currentRating >= starNumber
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color:
                _currentRating >= starNumber ? activeColor : Colors.grey[400],
            size: 36,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => setState(() => _currentRating = starNumber),
          tooltip: 'Rate $starNumber star${starNumber > 1 ? "s" : ""}',
        );
      }),
    );
  }

  // Builds the comment input field
  Widget _buildCommentField(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: 5,
        minLines: 3,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          hintText: 'Share your thoughts here...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: TextStyle(color: textColor, fontSize: 15),
      ),
    );
  }
} // End of _ResourceDetailScreenState