// File: lib/screens/activities/sleep_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math; // For Slider max value if needed

// Firebase Imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:google_fonts/google_fonts.dart'; // For consistent styling

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed

// IMPORT THE NEW SCREEN YOU WILL CREATE
import 'LogNightlySleepScreen.dart'; // Create this file in the same directory or adjust path

enum SleepScreenState { selection, playing, completion }

class SleepActivityScreen extends StatefulWidget {
  const SleepActivityScreen({super.key});

  @override
  _SleepActivityScreenState createState() => _SleepActivityScreenState();
}

class _SleepActivityScreenState extends State<SleepActivityScreen> {
  SleepScreenState _screenState = SleepScreenState.selection;
  String? _selectedSoundName;
  String? _selectedSoundFile;

  // --- Audio Player State ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  // --- Duration & Saving State ---
  DateTime? _playbackStartTime;
  int? _completedDurationMinutes; // This is for the SOUND SESSION
  bool _isSavingCompletion = false; // For sound session saving
  Timer? _autoFinishTimer;

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Activity Data
  final Map<String, String> _soundFiles = {
    'Gentle Rain': 'rain.mp3',
    'Soft Wind': 'wind.mp3',
    'Atmospheric Synth': 'synth.mp3',
  };

  final Map<String, String> _soundImages = {
    'Gentle Rain': 'assets/images/rain_icon.png',
    'Soft Wind': 'assets/images/wind_icon.png',
    'Atmospheric Synth': 'assets/images/music_icon.png',
  };
  final String _defaultPlayerImage = 'assets/images/sleep_icon_large.png';


  // Player UI
  bool get _isPlaying => _playerState == PlayerState.playing;
  IconData get _playPauseIcon => _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled;
  String get _playPauseTooltip => _isPlaying ? 'Pause' : 'Play';

  @override
  void initState() {
    super.initState();
    _setupPlayerListeners();
  }

  @override
  void dispose() {
    print("SleepActivityScreen: Disposing...");
    _cancelSubscriptionsAndStopPlayer();
    _autoFinishTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupPlayerListeners() {
    _playerStateChangeSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    }, onError: (msg) { if (mounted) setState(() => _playerState = PlayerState.stopped); });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted && _playerState != PlayerState.stopped) {
          setState(() {
            _position = _duration > Duration.zero ? _duration : Duration.zero;
            _playerState = PlayerState.completed;
          });
      }
    }, onError: (msg) { /* Handle error */ });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted && newDuration > Duration.zero) setState(() => _duration = newDuration);
    }, onError: (msg) { /* Handle error */ });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted && newPosition >= Duration.zero && newPosition <= _duration) {
        setState(() => _position = newPosition);
      } else if (mounted && newPosition > _duration && _duration > Duration.zero) {
        setState(() => _position = _duration);
      }
    }, onError: (msg) { /* Handle error */ });
  }

  Future<void> _startPlayback() async { // This starts the AMBIENT SOUND
    if (_selectedSoundFile == null || !mounted) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Please select a sound first.'), backgroundColor: Colors.orange));
      }
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    _playbackStartTime = DateTime.now();
    _completedDurationMinutes = null; // Reset for sound session
    _position = Duration.zero;
    _duration = Duration.zero;

    try {
      final String assetPath = 'sounds/${_selectedSoundFile!}';
      print("SleepActivity: Attempting to play '$assetPath'");
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(assetPath));
      print("SleepActivity: Playback started successfully for '$assetPath'");

      if (mounted) {
        setState(() => _screenState = SleepScreenState.playing);
      }
    } catch (e, s) {
      print("SleepActivity: ERROR in _startPlayback: $e");
      print("SleepActivity: Stacktrace: $s");
      _playbackStartTime = null;
      if (mounted) {
        String errorMessageToShow = "An unknown error occurred during playback.";
        if (e is AudioPlayerException) {
          String eString = e.toString().toLowerCase();
          if (eString.contains("source error") ||
              eString.contains("file not found") ||
              eString.contains("80070002")) {
            errorMessageToShow = "Audio file not found. Check assets setup & pubspec.yaml.";
          } else {
            errorMessageToShow = "Audio playback error. Please try again.";
          }
        } else {
          errorMessageToShow = e.toString();
        }
        if (errorMessageToShow.length > 150) {
          errorMessageToShow = "${errorMessageToShow.substring(0, 147)}...";
        }
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error starting audio: $errorMessageToShow'),
            backgroundColor: Colors.red));
      }
    }
  }


  void _togglePlayPause() async { // For AMBIENT SOUND
    if (!mounted) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_playerState == PlayerState.completed) {
          _playbackStartTime = DateTime.now();
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.resume();
        } else if (_selectedSoundFile != null) {
           if(_playerState == PlayerState.stopped && _playbackStartTime == null) _playbackStartTime = DateTime.now();
          await _audioPlayer.resume();
        } else {
            if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No sound selected.'), backgroundColor: Colors.orange));
        }
      }
    } catch (e) { /* Handle error */ }
  }

  void _handleActivityFinish({bool autoFinished = false}) { // For AMBIENT SOUND SESSION
    if (!mounted || _screenState == SleepScreenState.completion) return;

    _cancelSubscriptionsAndStopPlayer(keepPlayerStateIntact: autoFinished);
    _autoFinishTimer?.cancel();

    if (_playbackStartTime != null) {
      final Duration elapsed = DateTime.now().difference(_playbackStartTime!);
      _completedDurationMinutes = (elapsed.inSeconds / 60).ceil().clamp(1, 9999);
    } else if (autoFinished && _duration > Duration.zero) {
        _completedDurationMinutes = (_duration.inSeconds / 60).ceil().clamp(1,9999);
    }
    else {
      _completedDurationMinutes = 1;
    }

    if (mounted) {
      setState(() {
        _screenState = SleepScreenState.completion;
        if (_duration > Duration.zero) _position = _duration;
      });
    }
  }

  void _cancelSubscriptionsAndStopPlayer({bool keepPlayerStateIntact = false}) {
    _durationSubscription?.cancel(); _durationSubscription = null;
    _positionSubscription?.cancel(); _positionSubscription = null;
    if (!keepPlayerStateIntact) {
        _playerCompleteSubscription?.cancel(); _playerCompleteSubscription = null;
        _playerStateChangeSubscription?.cancel(); _playerStateChangeSubscription = null;
    }

    if (_audioPlayer.state != PlayerState.stopped && _audioPlayer.state != PlayerState.disposed) {
      try {
        _audioPlayer.stop();
      } catch (e) { /* Ignore */ }
    }
    if (mounted && !keepPlayerStateIntact) {
      setState(() { _playerState = PlayerState.stopped; });
    }
  }

  void _resetToSelectionScreen() {
    print("SleepActivity: _resetToSelectionScreen CALLED. mounted: $mounted");
    if (!mounted) return;

    _cancelSubscriptionsAndStopPlayer();
    _autoFinishTimer?.cancel();

    setState(() {
      _screenState = SleepScreenState.selection;
      _selectedSoundName = null;
      _selectedSoundFile = null;
      _playbackStartTime = null;
      _completedDurationMinutes = null; // For sound session
      _duration = Duration.zero;
      _position = Duration.zero;
      _isSavingCompletion = false; // For sound session
    });
     _setupPlayerListeners(); // Re-initialize listeners
  }

  Future<void> _saveCompletionToFirestore() async { // Saves AMBIENT SOUND SESSION duration
    if (!mounted) return;

    print("SleepActivity: SAVE SOUND SESSION START. Setting _isSavingCompletion = true.");
    setState(() { _isSavingCompletion = true; });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final user = _auth.currentUser;
      String? snackBarMessage;
      Color? snackBarColor;

      if (user == null) {
        snackBarMessage = "Error: Not logged in. Sound session not saved.";
        snackBarColor = Colors.red;
      } else if (_completedDurationMinutes == null || _completedDurationMinutes! < 1) {
        snackBarMessage = "Error: Sound session duration invalid. Not saved.";
        snackBarColor = Colors.red;
      } else {
        final String activityName = _selectedSoundName ?? "Sleep Sound"; // Use selected sound name
        final int durationToLog = _completedDurationMinutes!;
        final now = DateTime.now();
        final String dateString = DateFormat('yyyy-MM-dd').format(now);
        final String documentId = "${user.uid}_$dateString";
        final DocumentReference dailySummaryRef = _firestore.collection('daily_activity_summary').doc(documentId);

        final activityData = {
          'userId': user.uid,
          'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
          'durations': { activityName: FieldValue.increment(durationToLog.toDouble()) }, // Log specific sound
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        };

        await dailySummaryRef.set(activityData, SetOptions(merge: true));
        snackBarMessage = "$activityName session logged ($durationToLog min)!";
        snackBarColor = Colors.green;
      }

      if (mounted && snackBarMessage != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(snackBarMessage), backgroundColor: snackBarColor),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    } catch (e, s) {
      print("SleepActivity: SAVE SOUND SESSION EXCEPTION: $e\n$s");
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.length > 100) errorMsg = "${errorMsg.substring(0,97)}...";
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Failed to log sound session: $errorMsg"), backgroundColor: Colors.red),
        );
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    } finally {
      if (mounted) {
        _resetToSelectionScreen(); // Always reset to selection after attempting to save sound session
      }
    }
  }

  void _handleBackButtonOnNonSelectionScreen() {
    if (!mounted || _isSavingCompletion) return; // Check _isSavingCompletion for sound session
    if (_screenState == SleepScreenState.playing || _screenState == SleepScreenState.completion) {
      _resetToSelectionScreen();
    }
  }

  String formatDuration(Duration d) {
    try { String twoDigits(int n) => n.toString().padLeft(2, '0'); final minutes = twoDigits(d.inMinutes.remainder(60)); final seconds = twoDigits(d.inSeconds.remainder(60)); return '$minutes:$seconds'; }
    catch (e) { return '00:00'; }
  }


  // --- UI BUILDERS ---
  Widget _buildSelectionScreen(BuildContext context) {
    final Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.white.withOpacity(0.8);
    final Color choiceButtonBackgroundColor = Color(0xFF4A4A7F);
    final Color startSoundButtonColor = Color(0xFF4DB6AC); // For starting sound session
    final Color logSleepButtonColor = Color(0xFF5C6BC0);  // A different color for general sleep log

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 40), // Adjusted top padding
          Text(
            'Sleep & Sounds', // Updated Title
            style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTextColor, shadows: [Shadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.4), offset: Offset(1,1))]),
          ),
          SizedBox(height: 25),

          // --- NEW BUTTON TO LOG GENERAL NIGHTLY SLEEP ---
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.nightlight_round_outlined, size: 22), // Changed icon slightly
              label: Text('Log Last Night\'s Sleep'), // More direct text
              onPressed: () { // No need to check _isSavingCompletion here as it's for sound session
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogNightlySleepScreen()), // Navigate here
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: logSleepButtonColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Increased padding
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                textStyle: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.bold), // Bolder text
              ),
            ),
          ),
          SizedBox(height: 30),
          // --- END NEW BUTTON ---

          Text(
            'Or, choose an ambient sound for relaxation:', // Modified text
            style: GoogleFonts.lato(fontSize: 18, color: secondaryTextColor, fontWeight: FontWeight.w500, shadows: [Shadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.4), offset: Offset(1,1))]),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: _soundFiles.keys.map((sound) {
                bool isSelected = _selectedSoundName == sound;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: InkWell(
                    onTap: _isSavingCompletion ? null : () { // Check _isSavingCompletion for sound session
                      setState(() {
                        _selectedSoundName = sound;
                        _selectedSoundFile = _soundFiles[sound];
                      });
                    },
                    borderRadius: BorderRadius.circular(18.0),
                    child: Container(
                       width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                       decoration: BoxDecoration(
                           color: isSelected ? choiceButtonBackgroundColor.withOpacity(1) : choiceButtonBackgroundColor.withOpacity(0.7),
                           borderRadius: BorderRadius.circular(18.0),
                           border: Border.all(color: isSelected ? Colors.white70 : Colors.transparent, width: 2.0),
                           boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))]),
                       child: Row( children: [
                           ClipRRect( borderRadius: BorderRadius.circular(8.0),
                               child: Image.asset( _soundImages[sound] ?? 'assets/images/default_icon.png', height: 45, width: 45, fit: BoxFit.cover,
                                   errorBuilder: (c,e,s) => Container(height:45, width:45, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(8.0)), child: Icon(Icons.music_note, color: Colors.white54, size: 25)))),
                           const SizedBox(width: 18),
                           Expanded( child: Text( sound, style: GoogleFonts.lato(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.w600))),
                       ]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: (_selectedSoundFile == null || _isSavingCompletion) ? null : _startPlayback, // Check _isSavingCompletion
              style: ElevatedButton.styleFrom(
                backgroundColor: startSoundButtonColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledBackgroundColor: startSoundButtonColor.withOpacity(0.5),
              ),
              child: Text('Start Sound Session', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 15), // Adjusted bottom padding
        ],
      ),
    );
  }

  Widget _buildPlayerScreen(BuildContext context) { // This is for the AMBIENT SOUND
    final Color primaryTextColor = Colors.white;
    final Color sliderColor = Colors.tealAccent.shade100;
    final Color buttonColor = Colors.teal.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(
              _selectedSoundName ?? 'Relaxation Sound', // More generic title
              style: GoogleFonts.lato(fontSize: 24, color: primaryTextColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Relax and unwind...', // More generic subtitle
              style: GoogleFonts.lato(fontSize: 18, color: primaryTextColor.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 1),
            Image.asset(
              _soundImages[_selectedSoundName ?? ''] ?? _defaultPlayerImage,
              height: MediaQuery.of(context).size.height * 0.20,
              errorBuilder: (c, e, s) => const Icon(Icons.music_note_outlined, size: 100, color: Colors.white54),
            ),
            const Spacer(flex: 2),
            if (_duration > Duration.zero)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: sliderColor,
                        inactiveTrackColor: sliderColor.withOpacity(0.3),
                        trackHeight: 4.0,
                        thumbColor: sliderColor,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        overlayColor: sliderColor.withAlpha(0x29),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: math.max(1.0, _duration.inSeconds.toDouble()),
                        value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                        onChanged: (value) async {
                          if (_duration > Duration.zero && _playerState != PlayerState.stopped && _playerState != PlayerState.disposed) {
                            final newPosition = Duration(seconds: value.toInt());
                            await _audioPlayer.seek(newPosition);
                            if (!_isPlaying && mounted) { setState(() => _position = newPosition); }
                          }
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDuration(_position), style: TextStyle(color: primaryTextColor.withOpacity(0.8))),
                        Text(formatDuration(_duration), style: TextStyle(color: primaryTextColor.withOpacity(0.8))),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: buttonColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2))]),
              child: IconButton(
                tooltip: _playPauseTooltip,
                icon: Icon(_playPauseIcon, size: 60, color: Colors.white),
                padding: EdgeInsets.zero,
                onPressed: _isSavingCompletion ? null : _togglePlayPause, // Check _isSavingCompletion for sound session
              ),
            ),
            const SizedBox(height: 30),
            TextButton.icon(
              icon: Icon(Icons.stop_circle_outlined, size: 22, color: Colors.red.shade300),
              label: Text("Finish Sound Session", style: TextStyle(fontSize: 17, color: Colors.red.shade300, fontWeight: FontWeight.w600)),
              onPressed: _isSavingCompletion ? null : () => _handleActivityFinish(), // Check _isSavingCompletion
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

   Widget _buildCompletionScreen(BuildContext context) { // This is for the AMBIENT SOUND SESSION
    final Color primaryTextColor = Colors.white;
    final Color logSessionButtonColor = const Color(0xFF4DB6AC);
    final Color startAnotherTextColor = Colors.white.withOpacity(0.85);
    final int durationCompleted = _completedDurationMinutes ?? 0; // Sound session duration

    const double screenHorizontalPadding = 20.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: screenHorizontalPadding, vertical: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            'Sound Session Ended', // Clarify this is for sound
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                fontSize: 34, // Slightly smaller than main sleep log screen
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
                shadows: [ Shadow( blurRadius: 2, color: Colors.black.withOpacity(0.3), offset: Offset(1, 1)) ]),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Align(
            alignment: const Alignment(-0.25, 0.0), // Align content block to left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.22), // Space for BG moon
                Text(
                  'You listened to ${_selectedSoundName ?? 'the sound'} for $durationCompleted minute${durationCompleted == 1 ? '' : 's'}.', // Clarify
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 17,
                    color: primaryTextColor.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed:
                      _isSavingCompletion ? null : _saveCompletionToFirestore, // Saves SOUND session
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logSessionButtonColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: logSessionButtonColor.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16), // Adjusted padding
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(30)),
                    textStyle: GoogleFonts.lato( fontSize: 18, fontWeight: FontWeight.bold),
                    minimumSize: Size( MediaQuery.of(context).size.width * 0.50, 50),
                  ),
                  child: _isSavingCompletion // For sound session
                      ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator( color: Colors.white, strokeWidth: 2.5))
                      : const Text('Log Sound Session'),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _isSavingCompletion ? null : _resetToSelectionScreen, // Check for sound session
                  child: Text(
                    "Choose Another Sound", // Clarify action
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: startAnotherTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreenWidget;
    switch (_screenState) {
      case SleepScreenState.playing:
        currentScreenWidget = _buildPlayerScreen(context);
        break;
      case SleepScreenState.completion:
        currentScreenWidget = _buildCompletionScreen(context);
        break;
      case SleepScreenState.selection:
      default:
        currentScreenWidget = _buildSelectionScreen(context);
    }

    final Color commonBackButtonColor = Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sleep_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFF2D2D5A)),
            ),
          ),
          SafeArea(child: currentScreenWidget),
          if (_screenState != SleepScreenState.selection)
            Positioned(
              top: MediaQuery.of(context).padding.top + 5,
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: commonBackButtonColor,
                      shadows: [
                        BoxShadow(color: Colors.black54, blurRadius: 3)
                      ]),
                  onPressed: _isSavingCompletion // Check for sound session saving
                      ? null
                      : _handleBackButtonOnNonSelectionScreen,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}