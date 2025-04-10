// File: lib/screens/activities/mindfulness_activity_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // Keep for PlayerScreen

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed

// Import the player screen

//********************************************************************
// Mindfulness Activity Selection Screen
//********************************************************************
class MindfulnessActivityScreen extends StatefulWidget {
  const MindfulnessActivityScreen({super.key});

  @override
  _MindfulnessActivityScreenState createState() =>
      _MindfulnessActivityScreenState();
}

class _MindfulnessActivityScreenState extends State<MindfulnessActivityScreen> {
  String? selectedMindfulnessSound;
  Timer? _navTimer; // Renamed from _timer for clarity if passed

  final Map<String, String> mindfulnessSoundFiles = {
    'Tranquil Flow': 'tranquil_flow.mp3',
    'Harmony Within': 'harmony_within.mp3',
    'Serene Escape': 'serene_escape.mp3',
  };

  final Map<String, String> mindfulnessSoundImages = {
    'Tranquil Flow': 'assets/images/tranquil_flow_icon.png',
    'Harmony Within': 'assets/images/harmony_within_icon.png',
    'Serene Escape': 'assets/images/serene_escape_icon.png',
  };

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  // Removed internal _buildBottomNavBar method

  Widget _buildActivityItem(BuildContext context, String soundName) {
    final String imagePath =
        mindfulnessSoundImages[soundName] ?? 'assets/images/default_icon.png';
    final bool isSelected = selectedMindfulnessSound == soundName;
    final Color choiceButtonColor = Color(0xFF3A4A7D);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMindfulnessSound = soundName;
        });
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 18.0),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        decoration: BoxDecoration(
          color: choiceButtonColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18.0),
          border:
              isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.9), width: 2.0)
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
                imagePath,
                height: 45,
                width: 45,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8.0),
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
                soundName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor = Colors.white.withOpacity(0.9);
    final Color startButtonColor = Color(0xFF3E8A9A);
    final Color backButtonColor = Colors.white.withOpacity(0.8);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mindfulness_bg_select.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    'Mindfulness Activity',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        mindfulnessSoundFiles.keys.map((sound) {
                          return _buildActivityItem(context, sound);
                        }).toList(),
                  ),

                  Spacer(),

                  Center(
                    child: ElevatedButton(
                      onPressed:
                          selectedMindfulnessSound == null
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(
                                      name: '/mindfulnessPlayer',
                                    ),
                                    builder:
                                        (context) => MindfulnessPlayerScreen(
                                          soundFile:
                                              mindfulnessSoundFiles[selectedMindfulnessSound]!,
                                        ),
                                  ),
                                );
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
                        disabledBackgroundColor: startButtonColor.withOpacity(
                          0.5,
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

          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: backButtonColor,
                shadows: [BoxShadow(color: Colors.black38, blurRadius: 3)],
              ),
              tooltip: 'Back',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        navigationTimer: _navTimer,
      ), // Use the external widget
    );
  }
}

//********************************************************************
// Mindfulness Player Screen - Only fixing nav bar call and adding commas
//********************************************************************
class MindfulnessPlayerScreen extends StatefulWidget {
  final String soundFile;

  const MindfulnessPlayerScreen({super.key, required this.soundFile});

  @override
  _MindfulnessPlayerScreenState createState() =>
      _MindfulnessPlayerScreenState();
}

class _MindfulnessPlayerScreenState extends State<MindfulnessPlayerScreen> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Timer? _navTimer; // Renamed from _timer

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();

    _playerStateChangeSubscription = player.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) setState(() => _playerState = state);
    });
    _durationSubscription = player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => duration = newDuration);
    });
    _positionSubscription = player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => position = newPosition);
    });
    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      if (mounted)
        setState(() {
          position = duration;
          _playerState = PlayerState.completed;
        });
    });
    _playSound();
  }

  Future<void> _playSound() async {
    try {
      await player.play(AssetSource('sounds/${widget.soundFile}'));
    } catch (e) {
      print("Error playing sound: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing sound: ${e.toString()}')),
        );
      }
    }
  }

  void togglePlayPause() async {
    try {
      if (_isPlaying) {
        await player.pause();
      } else {
        if (_playerState == PlayerState.completed) {
          await player.seek(Duration.zero);
          await player.resume();
        } else {
          await player.resume();
        }
      }
    } catch (e) {
      print("Error toggling play/pause: $e");
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player.stop();
    player.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _stopAndPop() {
    player.stop();
    _navTimer?.cancel();
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // Removed internal _buildBottomNavBar method

  @override
  Widget build(BuildContext context) {
    final Color quoteColor = Color(0xFF1E4B5F);
    final Color sliderActiveColor = Color(0xFF1E4B5F);
    final Color sliderInactiveColor = Colors.white.withOpacity(0.5);
    final Color playButtonColor = Color(0xFF1E4B5F).withOpacity(0.9);
    final Color backButtonColor = quoteColor;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mindfulness_bg_play.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 2),
                  Text(
                    'Yoga is the journey of the\nself, through the self, to the\nself.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: quoteColor,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: sliderActiveColor,
                            inactiveTrackColor: sliderInactiveColor,
                            trackHeight: 5.0,
                            thumbColor: sliderActiveColor,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 8.0,
                            ),
                            overlayColor: sliderActiveColor.withAlpha(0x29),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 16.0,
                            ),
                          ),
                          child: Slider(
                            min: 0,
                            max:
                                duration.inSeconds.toDouble() > 0
                                    ? duration.inSeconds.toDouble()
                                    : 1.0,
                            value: position.inSeconds.toDouble().clamp(
                              0.0,
                              duration.inSeconds.toDouble(),
                            ),
                            onChanged: (value) async {
                              final newPosition = Duration(
                                seconds: value.toInt(),
                              );
                              await player.seek(newPosition);
                            },
                          ),
                        ),
                        SizedBox(height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(position),
                              style: TextStyle(
                                color: quoteColor.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              formatDuration(duration),
                              style: TextStyle(
                                color: quoteColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: playButtonColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      tooltip: _isPlaying ? 'Pause' : 'Play',
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 45,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15),
                      onPressed: togglePlayPause,
                    ),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 10,
            child: IconButton(
              tooltip: 'Back',
              icon: Icon(Icons.arrow_back_ios, color: backButtonColor),
              onPressed: _stopAndPop,
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        navigationTimer: _navTimer,
      ), // Use the external widget
    );
  }
}
