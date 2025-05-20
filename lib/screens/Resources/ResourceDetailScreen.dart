import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Adjust package name if yours is different
import '/screens/Resources/ResourceItem.dart';
import '/screens/quiz/QuizScreen.dart'; // Assuming this path

class ResourceDetailScreen extends StatefulWidget {
  final ResourceItem resource;
  const ResourceDetailScreen({super.key, required this.resource});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  int _currentRating = 0;
  final TextEditingController _commentController = TextEditingController();

  // Video Player state
  VideoPlayerController? _videoPlayerController; // For direct MP4s
  ChewieController? _chewieController;           // UI for direct MP4s
  YoutubePlayerController? _ytController;        // For YouTube videos

  bool _isLoadingPlayer = true;
  String? _playerErrorMessage;
  bool _isYoutubeVideo = false;

  @override
  void initState() {
    super.initState();
    final resourceTypeLower = widget.resource.type.toLowerCase();
    final videoUrl = widget.resource.videoUrl;

    if (resourceTypeLower == 'video' && videoUrl != null && videoUrl.isNotEmpty) {
      _isYoutubeVideo = YoutubePlayer.convertUrlToId(videoUrl, trimWhitespaces: true) != null;

      if (_isYoutubeVideo) {
        _initializeYoutubePlayer(videoUrl);
      } else {
        _initializeDirectVideoPlayer(videoUrl);
      }
    } else if (resourceTypeLower == 'video') {
      // This setState is safe in initState because it's called synchronously
      // after the condition check and before the build method is first called.
      _playerErrorMessage = "Video URL is missing or invalid for this resource.";
      _isLoadingPlayer = false;
    } else {
      _isLoadingPlayer = false; // Not a video, no player to initialize
    }
  }

  void _ytPlayerListener() {
    if (!mounted || _ytController == null) return;

    final playerValue = _ytController!.value;
    final PlayerState currentPlayerState = playerValue.playerState; // Get the current state

    // More detailed logging
    print(
        "ResourceDetailScreen: YT Player - Current State: $currentPlayerState, "
        "ErrorCode: ${playerValue.errorCode}, IsReady: ${playerValue.isReady}, "
        "IsLoading (UI state): $_isLoadingPlayer, Position: ${playerValue.position}, Buffered: ${playerValue.buffered}");

    bool shouldUpdateState = false;

    if (playerValue.errorCode != null && playerValue.errorCode != 0) { // Some players might use 0 for no error
      if (_playerErrorMessage == null || _isLoadingPlayer) {
        _playerErrorMessage = "YouTube Player Error (Code: ${playerValue.errorCode}).";
        _isLoadingPlayer = false;
        shouldUpdateState = true;
      }
    } else if (playerValue.isReady) {
      // If the player is ready, and we were in a loading state, it means initialization is complete.
      // The player widget itself will show buffering if it's buffering after being ready.
      if (_isLoadingPlayer) {
        _isLoadingPlayer = false;
        _playerErrorMessage = null; // Clear any previous transient error
        shouldUpdateState = true;
      }

      // You can log or react to other states here if needed:
      if (currentPlayerState == PlayerState.playing) {
        // print("YT Player is PLAYING");
      } else if (currentPlayerState == PlayerState.paused) {
        // print("YT Player is PAUSED");
      } else if (currentPlayerState == PlayerState.buffering) {
        print("YT Player is BUFFERING (after being ready)");
        // The YoutubePlayer widget should show its own buffering indicator.
        // No need to set _isLoadingPlayer back to true here unless you want a custom full-screen loader for buffering.
      } else if (currentPlayerState == PlayerState.ended) {
        print("YT Player Video has ENDED");
        // Potentially seek to start and pause, or show a replay button
        // _ytController?.seekTo(Duration.zero);
        // _ytController?.pause();
        // shouldUpdateState = true; // If you change player state
      } else if (currentPlayerState == PlayerState.unStarted && !_isLoadingPlayer) {
         print("YT Player is UNSTARTED (and UI is not in loading state)");
         // This means autoPlay might be false, and user needs to tap play.
         // Or it could be an issue if it was supposed to autoplay.
      }
    }

    if (shouldUpdateState && mounted) { // Ensure widget is still mounted before calling setState
      setState(() {});
    }
  }

  void _initializeYoutubePlayer(String youtubeUrl) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl, trimWhitespaces: true);
    print("ResourceDetailScreen: YouTube URL: $youtubeUrl, Extracted Video ID: $videoId");

    if (videoId != null) {
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false, // Start paused, user interaction is better
          mute: false,
          enableCaption: true,
          // controlsVisibleAtStart: true, // Show controls immediately
        ),
      )..addListener(_ytPlayerListener);
      // isLoadingPlayer will be set to false by the listener when isReady/playing or error occurs
    } else {
      if (mounted) {
        setState(() {
          _playerErrorMessage = "Invalid YouTube URL format.";
          _isLoadingPlayer = false;
        });
      }
    }
  }

  Future<void> _initializeDirectVideoPlayer(String videoUrl) async {
    print("ResourceDetailScreen: Initializing direct video from URL: $videoUrl");
    if (!mounted) return;
    // Ensure isLoadingPlayer is true at the start of this async operation
    // and clear any previous error.
    setState(() {
      _isLoadingPlayer = true;
      _playerErrorMessage = null;
    });

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    try {
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoInitialize: true,
        autoPlay: false, // Start paused
        looping: false,
        placeholder: _buildPlayerLoadingIndicator(),
        errorBuilder: (context, errMsg) {
          // This error builder in Chewie might also catch the UnimplementedError if it occurs after basic init
          print("ResourceDetailScreen: Chewie Error: $errMsg");
          return _buildPlayerErrorWidget('Error playing video.\n$errMsg');
        },
      );
      if (mounted) {
        setState(() {
          _isLoadingPlayer = false;
          _playerErrorMessage = null;
        });
      }
    } catch (error) {
      print("ResourceDetailScreen: Error initializing VideoPlayerController (direct): $error");
      if (mounted) {
        setState(() {
          _playerErrorMessage =
              "Could not load video. Check URL/connection or platform support.\nError: $error";
          _isLoadingPlayer = false;
        });
      }
    }
  }

  Widget _buildPlayerLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12.0)),
      child: const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
    );
  }

  Widget _buildPlayerErrorWidget(String message) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(12.0)),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            if (_isYoutubeVideo && widget.resource.videoUrl != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.open_in_new, color: Colors.lightBlueAccent),
                label: const Text('Open in Browser', style: TextStyle(color: Colors.lightBlueAccent)),
                onPressed: () => _launchUrlInBrowser(widget.resource.videoUrl),
              )
            ]
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ytController?.removeListener(_ytPlayerListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _ytController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    print('Submitting Feedback for Resource ID: ${widget.resource.id}');
    print('Rating: $_currentRating, Comment: ${_commentController.text}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback Submitted'),
        content: const Text('Thank you for your feedback!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  Future<void> _launchUrlInBrowser(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL is not available.')));
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
    }
  }

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
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 5.0, right: 15.0, bottom: 5.0),
                    child: Row(children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context)),
                      Expanded(
                          child: Text(widget.resource.title,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                    ]),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0))),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Description always shown above content
                            Text(widget.resource.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 8),
                            Text(widget.resource.description, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                            const SizedBox(height: 20),

                            _buildResourceContentWidget(), // Video Player / Article Button / Quiz Button
                            const SizedBox(height: 30),

                            // --- Feedback Section ---
                            const Text('Let us know what you think!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                            const SizedBox(height: 15),
                            const Text('Rate this resource:', style: TextStyle(fontSize: 15, color: textColor)),
                            const SizedBox(height: 5),
                            _buildRatingStars(primaryColor),
                            const SizedBox(height: 25),
                            const Text('Write your comment (optional):', style: TextStyle(fontSize: 15, color: textColor)),
                            const SizedBox(height: 10),
                            _buildCommentField(textColor),
                            const SizedBox(height: 30),
                            Center(
                                child: ElevatedButton(
                              onPressed: (_currentRating > 0 || _commentController.text.trim().isNotEmpty)
                                  ? _submitFeedback
                                  : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                              child: const Text('Submit Feedback'),
                            )),
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
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildResourceContentWidget() {
    final resource = widget.resource;
    final typeLower = resource.type.toLowerCase();

    if (typeLower == 'video') {
      // For all video types, wrap in an AspectRatio to maintain space
      return AspectRatio(
        aspectRatio: 16 / 9, // Common video aspect ratio
        child: _isLoadingPlayer
            ? _buildPlayerLoadingIndicator()
            : _playerErrorMessage != null
                ? _buildPlayerErrorWidget(_playerErrorMessage!)
                : _isYoutubeVideo
                    ? (_ytController != null && _ytController!.value.isReady
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: YoutubePlayer(
                              controller: _ytController!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.amber,
                              progressColors: const ProgressBarColors(
                                playedColor: Colors.amber,
                                handleColor: Colors.amberAccent,
                              ),
                               onReady: () {
                                if (mounted && _isLoadingPlayer) {
                                  setState(() { _isLoadingPlayer = false; });
                                }
                                print("YT Player is ready (onReady callback).");
                              },
                            ))
                        // If YT controller isn't ready but no error/not loading, might be stuck or needs play tap
                        : _buildPlayerErrorWidget("YouTube player failed to become ready. Try opening in browser."))
                    : (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Chewie(controller: _chewieController!))
                        : _buildPlayerErrorWidget("Video player failed to initialize for direct file.")),
      );
    } else if (typeLower == 'article') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (resource.imageUrl != null && resource.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                resource.imageUrl!,
                fit: BoxFit.cover, height: 200, width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(height: 200, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15.0)), child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                loadingBuilder: (context, child, progress) => progress == null ? child : Container(height: 200, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15.0)), child: const Center(child: CircularProgressIndicator())),
              ),
            ),
            const SizedBox(height: 20), // Space after image if it exists
          ],
          if (resource.articleUrl != null && resource.articleUrl!.isNotEmpty)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Read Full Article'),
                onPressed: () => _launchUrlInBrowser(resource.articleUrl),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2), foregroundColor: Colors.white),
              ),
            )
          else
            const Text("Article content link is missing.", style: TextStyle(fontSize: 16, height: 1.6)),
        ],
      );
    } else if (typeLower == 'quiz') {
       return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           if (resource.imageUrl != null && resource.imageUrl!.isNotEmpty) ...[
             ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                resource.imageUrl!,
                fit: BoxFit.cover, height: 200, width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(height: 200, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15.0)), child: const Icon(Icons.quiz_outlined, size: 50, color: Colors.grey)),
                loadingBuilder: (context, child, progress) => progress == null ? child : Container(height: 200, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15.0)), child: const Center(child: CircularProgressIndicator())),
              ),
            ),
            const SizedBox(height: 20),
          ],
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill_outlined),
            label: const Text('Start Quiz'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizScreen())),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2), foregroundColor: Colors.white),
          )
        ],
      );
    }
    return _buildPlayerErrorWidget('Unsupported resource type: ${resource.type}');
  }

  Widget _buildRatingStars(Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return IconButton(
          icon: Icon(
            _currentRating >= starNumber ? Icons.star_rounded : Icons.star_border_rounded,
            color: _currentRating >= starNumber ? activeColor : Colors.grey[400],
            size: 36,
          ),
          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
          onPressed: () => setState(() => _currentRating = starNumber),
          tooltip: 'Rate $starNumber star${starNumber > 1 ? "s" : ""}',
        );
      }),
    );
  }

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
        maxLines: 5, minLines: 3,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(hintText: 'Share your thoughts here...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey)),
        style: TextStyle(color: textColor, fontSize: 15),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    const Color navBarColor = Color(0xFF276181);
    const Color iconColor = Color(0xFF5E94FF);
    return BottomAppBar(
      color: navBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home, color: iconColor), onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), tooltip: 'Home'),
          IconButton(icon: const Icon(Icons.access_time, color: iconColor), onPressed: () => _navigateToCustom('/reminders'), tooltip: 'Reminders'),
          IconButton(icon: const Icon(Icons.checklist, color: iconColor), onPressed: () => _navigateToCustom('/activity'), tooltip: 'Activity'),
          IconButton(icon: const Icon(Icons.menu_book, color: iconColor), onPressed: () => _navigateToCustom('/resourcesList'), tooltip: 'Resources'),
          IconButton(icon: const Icon(Icons.person, color: iconColor), onPressed: () => _navigateToCustom('/profile'), tooltip: 'Profile'),
        ],
      ),
    );
  }

   void _navigateToCustom(String routeName) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == routeName && routeName != '/') {
      // If already on the target route (and it's not home), do nothing to prevent multiple pushes
      return;
    }

    if (currentRouteName == '/resourceDetail' || currentRouteName == '/videoPlayer' || currentRouteName == '/quiz') {
      Navigator.pop(context); // Pop the current detail/player/quiz screen
      // Use a post-frame callback to ensure the pop has completed before checking the new route
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.settings.name != routeName) { // Check again after pop
          if (routeName == '/') {
             Navigator.popUntil(context, (route) => route.isFirst);
          } else {
            Navigator.pushNamed(context, routeName);
          }
        }
      });
    } else {
      // If not on a detail screen, or if currentRouteName is null (e.g. first screen)
      if (routeName == '/') {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        Navigator.pushNamed(context, routeName);
      }
    }
  }
}