// File: lib/screens/activities/sleep_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed

// Import the player screen

// Placeholder Screen for navigation targets (if still needed for testing routes)
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Screen: $title')),
      // bottomNavigationBar: AppBottomNavBar(), // Use the widget here too if needed
    );
  }
}

class SleepActivityScreen extends StatefulWidget {
  // Optional: const routeName = '/sleepActivity';

  // Add const constructor
  const SleepActivityScreen({super.key});

  @override
  _SleepActivityScreenState createState() => _SleepActivityScreenState();
}

class _SleepActivityScreenState extends State<SleepActivityScreen> {
  String selectedSound = 'Soft wind blowing through trees';
  Timer? _navTimer; // Renamed from _timer

  // Keep data structure as Maps for this file as per request
  final Map<String, String> soundFiles = {
    'Gentle rain with soft thunder': 'rain.mp3',
    'Soft wind blowing through trees': 'wind.mp3',
    'Synth-based atmospheric music': 'synth.mp3',
  };

  final Map<String, String> soundImages = {
    'Gentle rain with soft thunder':
        'assets/images/rain_icon.png', // Replace path
    'Soft wind blowing through trees':
        'assets/images/wind_icon.png', // Replace path
    'Synth-based atmospheric music':
        'assets/images/music_icon.png', // Replace path
  };

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  // Removed _buildBottomNavBar method

  @override
  Widget build(BuildContext context) {
    final Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.white.withOpacity(0.8);
    final Color choiceButtonBackgroundColor = Color(0xFF4A4A7F);
    final Color startButtonColor = Color(0xFF4DB6AC);
    // Define back button color based on background contrast
    final Color backButtonColor = Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sleep_bg.png', // Correct background for sleep
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print(
                  "Error loading image: assets/images/sleep_bg.png, $error",
                );
                return Container(color: Color(0xFF2D2D5A)); // Fallback color
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40), // Add space below potential back button
                  Text(
                    'Sleeping Activity',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Choose sound',
                    style: TextStyle(
                      fontSize: 16,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black.withOpacity(0.4),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Column(
                    children:
                        soundFiles.keys.map((sound) {
                          bool isSelected = selectedSound == sound;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedSound = sound;
                                });
                              },
                              borderRadius: BorderRadius.circular(18.0),
                              splashColor: Colors.white.withOpacity(0.1),
                              highlightColor: Colors.white.withOpacity(0.05),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 18.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? choiceButtonBackgroundColor
                                              .withOpacity(1.0)
                                          : choiceButtonBackgroundColor
                                              .withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(18.0),
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            width: 2.0,
                                          )
                                          : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.asset(
                                        soundImages[sound] ??
                                            'assets/images/default_icon.png',
                                        height: 45,
                                        width: 45,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          print(
                                            "Error loading image: ${soundImages[sound]}, Error: $error",
                                          );
                                          return Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[700]
                                                  ?.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Icon(
                                              Icons.music_note,
                                              color: Colors.white54,
                                              size: 25,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 18),
                                    Expanded(
                                      child: Text(
                                        sound,
                                        style: TextStyle(
                                          color: primaryTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final soundFile = soundFiles[selectedSound];
                        if (soundFile != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: '/sleepPlayer'),
                              // Pass name and file to player
                              builder:
                                  (context) => SleepPlayerScreen(
                                    soundName: selectedSound,
                                    soundFile: soundFile,
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a sound first.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: startButtonColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 90,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // --- ADDED Back Button ---
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                5, // Position below status bar
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, // Or Icons.arrow_back
                color: backButtonColor, // White for contrast on dark bg
                shadows: [BoxShadow(color: Colors.black54, blurRadius: 3)],
              ),
              tooltip: 'Back to Activities',
              onPressed: () {
                Navigator.pop(context); // Simple pop to go back
              },
            ),
          ),
          // --- END Back Button ---
        ],
      ),
      // --- FIXED Bottom Nav Bar Call ---
      bottomNavigationBar: AppBottomNavBar(
        navigationTimer: _navTimer,
      ), // Use the external widget
      // --- END FIX ---
    );
  }
}

//********************************************************************
// Sleep Player Screen (Only fixing nav bar call and adding back button consistency)
// Assumes SleepPlayerScreen is defined in its own file: sleep_player_screen.dart
//********************************************************************
// You would typically put this in lib/screens/activities/sleep_player_screen.dart

class SleepPlayerScreen extends StatefulWidget {
  final String soundName; // Accept name
  final String soundFile; // Accept file

  // Use const constructor
  const SleepPlayerScreen({
    super.key,
    required this.soundName,
    required this.soundFile,
  });

  // Optional: static const routeName = '/sleepPlayer';

  @override
  _SleepPlayerScreenState createState() => _SleepPlayerScreenState();
}

class _SleepPlayerScreenState extends State<SleepPlayerScreen> {
  // Keep the robust player state logic from previous versions
  final AudioPlayer audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  Timer? _navTimer; // Timer reference potentially for nav bar

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    _playerStateChangeSubscription = audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) setState(() => _playerState = state);
    });
    _durationSubscription = audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _positionSubscription = audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
    _playerCompleteSubscription = audioPlayer.onPlayerComplete.listen((event) {
      if (mounted)
        setState(() {
          _position = _duration;
          _playerState = PlayerState.completed;
        });
    });
    _playSound();
  }

  Future<void> _playSound() async {
    try {
      await audioPlayer.play(AssetSource('sounds/${widget.soundFile}'));
      debugPrint("Playing: sounds/${widget.soundFile}");
    } catch (e) {
      debugPrint("Error playing sound: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sound: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await audioPlayer.pause();
      } else {
        if (_playerState == PlayerState.completed) {
          await audioPlayer.seek(Duration.zero);
          await audioPlayer.resume();
        } else {
          await audioPlayer.resume();
        }
      }
    } catch (e) {
      debugPrint("Error during play/pause: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playback error: ${e.toString()}')),
        );
      }
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _stopAndPop() {
    audioPlayer.stop();
    _navTimer?.cancel();
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    audioPlayer.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  // Removed _buildBottomNavBar method

  @override
  Widget build(BuildContext context) {
    final Color backButtonColor = Colors.white; // Back button color

    return Scaffold(
      // Using AppBar now for consistent back button placement
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: backButtonColor,
          ), // Use consistent icon
          tooltip: 'Back',
          onPressed: _stopAndPop, // Use helper to stop player
        ),
        title: Text(widget.soundName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true, // Body goes behind app bar
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sleep_bg.png',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      Container(color: Colors.blueGrey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const Text(
                    'Sweet Dreams',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5.0, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.soundName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16.0,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.2),
                    ),
                    child: Slider(
                      min: 0,
                      max:
                          _duration.inSeconds.toDouble() > 0
                              ? _duration.inSeconds.toDouble()
                              : 1.0,
                      value: _position.inSeconds.toDouble().clamp(
                        0.0,
                        _duration.inSeconds.toDouble(),
                      ),
                      onChanged: (value) async {
                        final seekPosition = Duration(seconds: value.toInt());
                        await audioPlayer.seek(seekPosition);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(_position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatTime(_duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 64,
                    ),
                    tooltip: _isPlaying ? 'Pause' : 'Play',
                    onPressed: _playPause,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Spacer(flex: 3),
                  ElevatedButton(
                    onPressed: _stopAndPop, // Also use helper for Finish button
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Finish',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Removed the Positioned back button as AppBar is used now
        ],
      ),
      // --- FIXED Bottom Nav Bar Call ---
      bottomNavigationBar: AppBottomNavBar(navigationTimer: _navTimer),
      // --- END FIX ---
    );
  }
}
