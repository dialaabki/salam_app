import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// --- ADDED: Import ResourceItem model ---
import 'package:salam_app/screens/Resources/ResourceItem.dart';

// --- CHANGED: Accept ResourceItem ---
class VideoScreen extends StatefulWidget {
  final ResourceItem
  resource; // Accept the resource item passed from list screen

  const VideoScreen({super.key, required this.resource});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture; // To handle initialization state
  bool _isPlaying = false;
  bool _showControls = true; // State to show/hide controls
  String? _errorMessage; // To store potential initialization error

  @override
  void initState() {
    super.initState();
    // --- CHANGED: Use videoPath from the passed resource ---
    final videoPath = widget.resource.videoPath;

    if (videoPath != null && videoPath.isNotEmpty) {
      print("Initializing video from: $videoPath");
      // Check if it's a network URL or a local asset
      if (videoPath.startsWith('http://') || videoPath.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
      } else {
        // Assume it's an asset path
        _controller = VideoPlayerController.asset(videoPath);
      }

      // Store the initialization future
      _initializeVideoPlayerFuture = _controller
          .initialize()
          .then((_) {
            // Auto-play can be set here if desired
            // _controller.play();
            // _isPlaying = true;
            // Add listener for playback state changes (e.g., end of video)
            _controller.addListener(() {
              if (_isPlaying != _controller.value.isPlaying) {
                setState(() {
                  _isPlaying = _controller.value.isPlaying;
                });
              }
            });
            setState(() {}); // Update state once initialized
          })
          .catchError((error) {
            debugPrint("Error initializing VideoPlayerController: $error");
            setState(() {
              _errorMessage =
                  "Could not load video. Please check the path or network connection.\nError: $error";
            });
          });
    } else {
      // Handle case where videoPath is null or empty
      print(
        "Error: No valid videoPath provided for resource: ${widget.resource.title}",
      );
      _errorMessage = "Video path is missing for this resource.";
      // Create a dummy future that completes immediately to avoid null issues with FutureBuilder
      _initializeVideoPlayerFuture = Future.value();
    }
  }

  @override
  void dispose() {
    // Ensure the controller is disposed when the widget is removed
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_controller.value.isInitialized) {
      return; // Don't allow action if not ready
    }

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        // _isPlaying = false; // Listener handles this
      } else {
        _controller.play();
        // _isPlaying = true; // Listener handles this
      }
      _showControls = true; // Show controls when interacted with
    });
  }

  // Toggle visibility of controls
  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- CHANGED: Use resource title for AppBar ---
      appBar: AppBar(title: Text(widget.resource.title)),
      backgroundColor: Colors.black, // Set background for video player area
      body: Center(
        // Use FutureBuilder to wait for the controller to initialize
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (_errorMessage != null) {
              // Show error message if initialization failed or path was invalid
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the video.
              return GestureDetector(
                onTap:
                    _toggleControlsVisibility, // Tap video to toggle controls
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller),
                      // Add controls overlay
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildControlsOverlay(),
                      ),
                      // Add progress indicator
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 5.0,
                        ), // Adjust padding
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // If the VideoPlayerController is still initializing, show a
              // loading spinner.
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      // --- REMOVED: Moved FloatingActionButton into the Stack overlay ---
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _togglePlayPause,
      //   child: Icon(
      //     _controller.value.isInitialized && _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }

  // Helper widget for player controls
  Widget _buildControlsOverlay() {
    // Only build if controller is initialized
    if (!_controller.value.isInitialized) {
      return const SizedBox.shrink(); // Return empty if not ready
    }
    return Container(
      color: Colors.black.withOpacity(0.4), // Semi-transparent background
      child: Center(
        child: IconButton(
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 60.0, // Make button larger
          ),
          onPressed: _togglePlayPause,
        ),
      ),
    );
  }
}
