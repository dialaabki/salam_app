// lib/screens/Resources/VideoScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // To detect web platform
import 'dart:io' show Platform; // To detect desktop platforms

import 'package:video_player/video_player.dart'; // For direct video files
import 'package:chewie/chewie.dart';             // UI for video_player
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // For YouTube videos on mobile
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

// Replace 'flutter_application_2' with your actual package name
import '/screens/Resources/ResourceItem.dart';

class VideoScreen extends StatefulWidget {
  final ResourceItem resource;

  const VideoScreen({super.key, required this.resource});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _ytController;

  bool _isLoading = true;
  String? _errorMessage;
  bool _isYoutubeVideo = false;
  bool _isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  void initState() {
    super.initState();
    if (widget.resource.videoUrl != null && widget.resource.videoUrl!.isNotEmpty) {
      final videoUrl = widget.resource.videoUrl!;
      _isYoutubeVideo = YoutubePlayer.convertUrlToId(videoUrl, trimWhitespaces: true) != null;

      if (_isYoutubeVideo) {
        if (_isDesktop) {
          // For desktop, we will offer to launch in browser instead of initializing player
          _isLoading = false; // Not loading in-app player
        } else {
          // For mobile or web (if youtube_player_flutter supports web well for you)
          _initializeYoutubePlayer(videoUrl);
        }
      } else {
        // For direct video files (e.g., MP4)
        _initializeDirectVideoPlayer(videoUrl);
      }
    } else {
      _errorMessage = "Video URL is missing for this resource.";
      _isLoading = false;
    }
  }

  void _initializeYoutubePlayer(String youtubeUrl) {
    // This will now primarily be for mobile/web
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl, trimWhitespaces: true);
    print("VideoScreen: YouTube URL: $youtubeUrl");
    print("VideoScreen: Extracted Video ID: $videoId");

    if (videoId != null) {
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true, // Autoplay on mobile might work better
          mute: false,
          enableCaption: true,
        ),
      )..addListener(_ytPlayerListener);
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = "Invalid YouTube URL.";
          _isLoading = false;
        });
      }
    }
  }

  void _ytPlayerListener() {
    if (!mounted || _ytController == null) return;
    final playerValue = _ytController!.value;
    print("VideoScreen: YT Player State: ${playerValue.playerState}, ErrorCode: ${playerValue.errorCode}, IsReady: ${playerValue.isReady}, IsLoading: $_isLoading");
    if (playerValue.errorCode != null && playerValue.errorCode != 0) {
      if (_errorMessage == null || _isLoading) {
        setState(() {
          _errorMessage = "YT Player Error (Code: ${playerValue.errorCode})";
          _isLoading = false;
        });
      }
    } else if (playerValue.isReady && _isLoading) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _initializeDirectVideoPlayer(String videoUrl) async {
    print("VideoScreen: Initializing direct video from URL: $videoUrl");
    if(!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    try {
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoInitialize: true, autoPlay: true, looping: false,
        placeholder: Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))),
        errorBuilder: (context, errMsg) => Container(color: Colors.black, child: Center(child: Text('Error playing video.\n$errMsg', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center))),
      );
      if (mounted) setState(() { _isLoading = false; _errorMessage = null; });
    } catch (error) {
      print("VideoScreen: Error initializing VideoPlayerController: $error");
      if (mounted) setState(() { _errorMessage = "Could not load video. Check URL/connection.\nError: $error"; _isLoading = false;});
    }
  }

  @override
  void dispose() {
    _ytController?.removeListener(_ytPlayerListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _ytController?.dispose();
    super.dispose();
  }

  Future<void> _launchVideoUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video URL is not available.')),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }

  void _retryInitialization() {
    if (widget.resource.videoUrl != null && widget.resource.videoUrl!.isNotEmpty) {
      _ytController?.removeListener(_ytPlayerListener);
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
      _ytController?.dispose();
      _videoPlayerController = null; _chewieController = null; _ytController = null;
      _isYoutubeVideo = false;

      if (mounted) setState(() { _isLoading = true; _errorMessage = null; });
      
      Future.delayed(const Duration(milliseconds: 100), () { // Give UI time to show loading
        if (mounted) {
            final videoUrl = widget.resource.videoUrl!;
            _isYoutubeVideo = YoutubePlayer.convertUrlToId(videoUrl, trimWhitespaces: true) != null;
            if (_isYoutubeVideo) {
              if (_isDesktop) {
                 if (mounted) setState(() => _isLoading = false); // Not using in-app player for desktop YT
              } else {
                _initializeYoutubePlayer(videoUrl);
              }
            } else {
              _initializeDirectVideoPlayer(videoUrl);
            }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.title, style: const TextStyle(fontSize: 18, overflow: TextOverflow.ellipsis)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : _errorMessage != null
                ? _buildErrorWidget(_errorMessage!)
                : _isYoutubeVideo
                    ? (_isDesktop // If it's YouTube and Desktop, show launch button
                        ? _buildLaunchInBrowserWidget(widget.resource.videoUrl!)
                        : (_ytController != null && _ytController!.value.isReady
                            ? YoutubePlayer(controller: _ytController!, showVideoProgressIndicator: true)
                            : _buildErrorWidget("YouTube player could not initialize.")))
                    : (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                        ? Chewie(controller: _chewieController!)
                        : _buildErrorWidget("Video player could not initialize.")),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: _retryInitialization,
          )
        ],
      ),
    );
  }

  Widget _buildLaunchInBrowserWidget(String videoUrl) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            const Icon(Icons.play_circle_outline, color: Colors.white70, size: 80),
            const SizedBox(height: 20),
            const Text(
            "This video will open in your web browser.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open Video'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () => _launchVideoUrl(videoUrl),
            )
        ],
    );
  }
}