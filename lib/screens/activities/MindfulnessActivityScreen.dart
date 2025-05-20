// File: lib/screens/activities/MindfulnessActivityScreen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math; // For math.min if used in error messages
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the shared bottom nav bar widget
import '../../widgets/bottom_nav_bar.dart'; // Adjust path if needed

// Enum to manage screen states within this single screen
enum MindfulnessScreenState { selection, playing, completion }

class MindfulnessActivityScreen extends StatefulWidget {
  const MindfulnessActivityScreen({super.key});

  @override
  _MindfulnessActivityScreenState createState() =>
      _MindfulnessActivityScreenState();
}

class _MindfulnessActivityScreenState extends State<MindfulnessActivityScreen> {
  // --- State Management ---
  MindfulnessScreenState _screenState = MindfulnessScreenState.selection;
  String? _selectedSoundName;
  String? _selectedSoundFile;

  // --- Audio Player State ---
  final AudioPlayer _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  // --- Duration & Saving State ---
  DateTime? _startTime;
  int? _completedDurationMinutes;
  bool _isSavingCompletion = false;

  // --- Firebase Instances ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Activity Data (Maps) ---
  final Map<String, String> _mindfulnessSoundFiles = {
    'Tranquil Flow': 'tranquil_flow.mp3',
    'Harmony Within': 'harmony_within.mp3',
    'Serene Escape': 'serene_escape.mp3',
  };
  final Map<String, String> _mindfulnessSoundImages = {
    'Tranquil Flow': 'assets/images/tranquil_flow_icon.png',
    'Harmony Within': 'assets/images/harmony_within_icon.png',
    'Serene Escape': 'assets/images/serene_escape_icon.png',
  };

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
    print("MindfulnessPlayer: Disposing...");
    _cancelSubscriptionsAndStopPlayer();
    _player.dispose();
    super.dispose();
  }

  void _setupPlayerListeners() {
    _playerStateChangeSubscription?.cancel(); _playerCompleteSubscription?.cancel();
    _durationSubscription?.cancel(); _positionSubscription?.cancel();

    _playerStateChangeSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    }, onError: (msg) { if (mounted) setState(() => _playerState = PlayerState.stopped); });
    _playerCompleteSubscription = _player.onPlayerComplete.listen((event) { _handleActivityFinish(); }, onError: (msg) { /* Handle error */ });
    _durationSubscription = _player.onDurationChanged.listen((newDuration) { if (mounted && newDuration > Duration.zero) setState(() => _duration = newDuration); }, onError: (msg) { /* Handle error */ });
    _positionSubscription = _player.onPositionChanged.listen((newPosition) { if (mounted && newPosition >= Duration.zero && newPosition <= _duration) setState(() => _position = newPosition); else if (mounted && newPosition > _duration && _duration > Duration.zero) setState(() => _position = _duration); }, onError: (msg) { /* Handle error */ });
  }

  Future<void> _startPlayback() async {
    if (_selectedSoundFile == null || !mounted) return;
    _startTime = DateTime.now(); _completedDurationMinutes = null; _isSavingCompletion = false; _position = Duration.zero; _duration = Duration.zero;
    try {
      if (_playerStateChangeSubscription == null) _setupPlayerListeners();
      await _player.stop();
      await _player.play(AssetSource('sounds/${_selectedSoundFile!}'));
      if (mounted) setState(() => _screenState = MindfulnessScreenState.playing);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting audio: ${e.toString()}'), backgroundColor: Colors.red));
      _startTime = null;
    }
  }

  void _togglePlayPause() async {
    if (!mounted) return;
    final currentStatus = _playerState;
    try {
      if (currentStatus == PlayerState.playing) { await _player.pause(); }
      else {
        if (currentStatus == PlayerState.completed || currentStatus == PlayerState.stopped || _selectedSoundFile == null) {
          if (_selectedSoundFile != null) {
            await _player.play(AssetSource('sounds/${_selectedSoundFile!}'));
            _startTime = DateTime.now();
          } else {
             if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No sound selected.'), backgroundColor: Colors.orange));
          }
        }
        else { await _player.resume(); }
      }
    } catch (e) { /* Handle error */ }
  }

  void _handleActivityFinish() {
     if (!mounted || _screenState == MindfulnessScreenState.completion) return;
     _cancelSubscriptionsAndStopPlayer();
     if (_startTime != null) { final Duration elapsed = DateTime.now().difference(_startTime!); _completedDurationMinutes = (elapsed.inSeconds / 60).ceil().clamp(1, 999); }
     else { _completedDurationMinutes = (_duration.inSeconds > 0) ? (_duration.inSeconds / 60).ceil().clamp(1, 999) : 1; }
     if (mounted) { setState(() { _screenState = MindfulnessScreenState.completion; _position = _duration > Duration.zero ? _duration : Duration.zero; }); }
  }

  void _cancelSubscriptionsAndStopPlayer() {
     _durationSubscription?.cancel(); _durationSubscription = null;
     _positionSubscription?.cancel(); _positionSubscription = null;
     _playerCompleteSubscription?.cancel(); _playerCompleteSubscription = null;
     _playerStateChangeSubscription?.cancel(); _playerStateChangeSubscription = null;
     if (_player.state != PlayerState.stopped) {
        try { _player.stop(); } catch (e) { /* Ignore */ }
     }
     if(mounted){ setState((){ _playerState = PlayerState.stopped; }); }
  }

  void _resetToSelectionScreen() {
    print("MindfulnessReset: _resetToSelectionScreen CALLED. mounted: $mounted");
    if (!mounted) {
      print("MindfulnessReset: Not mounted. Exiting _resetToSelectionScreen.");
      return;
    }
    _cancelSubscriptionsAndStopPlayer(); 

    setState(() {
      print("MindfulnessReset: Inside setState for _resetToSelectionScreen.");
      _screenState = MindfulnessScreenState.selection;
      _selectedSoundName = null;
      _selectedSoundFile = null;
      _startTime = null;
      _completedDurationMinutes = null;
      _duration = Duration.zero;
      _position = Duration.zero;
      _isSavingCompletion = false; // CRITICAL: Reset the saving flag HERE
      print("MindfulnessReset: setState COMPLETED - screenState: $_screenState, _isSavingCompletion: $_isSavingCompletion");
    });
    print("MindfulnessReset: _resetToSelectionScreen ENDED.");
  }


  Future<void> _saveCompletionToFirestore() async {
    if (!mounted) {
      print("MindfulnessSave: Aborting, widget not mounted at start.");
      return;
    }

    print("MindfulnessSave: START. Setting _isSavingCompletion = true.");
    setState(() { _isSavingCompletion = true; });

    try {
      final user = _auth.currentUser;
      String? snackBarMessage;
      Color? snackBarColor;

      if (user == null) {
        print("MindfulnessSave: User not logged in.");
        snackBarMessage = "Error: Not logged in. Activity not saved.";
        snackBarColor = Colors.red;
      } else if (_completedDurationMinutes == null || _completedDurationMinutes! < 1) {
        print("MindfulnessSave: Duration invalid: $_completedDurationMinutes");
        snackBarMessage = "Error: Activity duration is invalid. Activity not saved.";
        snackBarColor = Colors.red;
      } else {
        print("MindfulnessSave: Attempting to log to Firestore. User ID: ${user.uid}, Duration: $_completedDurationMinutes");
        final String activityName = "Mindfulness";
        final int durationToLog = _completedDurationMinutes!;
        final now = DateTime.now();
        final String dateString = DateFormat('yyyy-MM-dd').format(now);
        final String documentId = "${user.uid}_$dateString";
        final DocumentReference dailySummaryRef = _firestore.collection('daily_activity_summary').doc(documentId);
        
        final activityData = {
          'userId': user.uid,
          'date': Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
          'durations': { activityName: FieldValue.increment(durationToLog.toDouble()) },
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        };
        
        await dailySummaryRef.set(activityData, SetOptions(merge: true));
        
        print("MindfulnessSave: Firestore log SUCCESS!");
        snackBarMessage = "Mindfulness activity logged!";
        snackBarColor = Colors.green;
      }

      // Attempt to show SnackBar if there's a message and widget is still mounted
      if (mounted && snackBarMessage != null) {
        print("MindfulnessSave: Attempting to show SnackBar: '$snackBarMessage'");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackBarMessage), backgroundColor: snackBarColor),
        );
        // Wait for SnackBar to be seen.
        await Future.delayed(const Duration(milliseconds: 1500)); 
        print("MindfulnessSave: SnackBar delay finished.");
      } else if (snackBarMessage != null) {
         print("MindfulnessSave: SnackBar message present but widget not mounted before display attempt.");
      }

    } catch (e, s) {
      print("MindfulnessSave: EXCEPTION in try block: $e");
      print("MindfulnessSave: StackTrace: $s");
      if (mounted) {
        // To avoid making the error message too long for SnackBar
        String shortError = e.toString();
        if (shortError.length > 100) shortError = "${shortError.substring(0, 97)}...";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $shortError"), backgroundColor: Colors.red),
        );
        // Give error SnackBar time to display
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    } finally {
      print("MindfulnessSave: FINALLY block. mounted: $mounted");
      // This block ensures that UI reset and _isSavingCompletion = false happens
      // regardless of success or failure in the try block, as long as the widget is mounted.
      if (mounted) {
        print("MindfulnessSave: FINALLY - Calling _resetToSelectionScreen.");
        _resetToSelectionScreen();
      } else {
        print("MindfulnessSave: FINALLY - Widget not mounted, cannot call _resetToSelectionScreen.");
      }
    }
    print("MindfulnessSave: _saveCompletionToFirestore END.");
  }


  void _handleBackButton() {
    if (!mounted || _isSavingCompletion) return;
    if (_screenState == MindfulnessScreenState.playing || _screenState == MindfulnessScreenState.completion) {
      _resetToSelectionScreen(); 
    } else {
      if (Navigator.canPop(context)) { Navigator.pop(context); }
    }
  }

  // --- UI Section Builders (Keep these as they were in the last fully provided code) ---

  Widget _buildSelectionScreen(BuildContext context) {
      final theme = Theme.of(context);
      final Color primaryTextColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : const Color(0xFF333333);
      final Color secondaryTextColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.7) : Colors.black54;
      final Color startButtonColor = theme.colorScheme.primary;
      final Color backButtonColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87;

      return Stack(
        children: [
          Positioned.fill( child: Image.asset( 'assets/images/mindfulness_bg_select.png', fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: theme.scaffoldBackgroundColor),),),
          SafeArea( bottom: false, child: Column( children: [
              Padding( padding: EdgeInsets.only( top: 5.0, left: 10.0, right: 20.0), child: Row( mainAxisAlignment: MainAxisAlignment.start, children: [ IconButton( icon: Icon(Icons.arrow_back_ios_new, color: backButtonColor), tooltip: 'Back', onPressed: _isSavingCompletion ? null : _handleBackButton,),],),),
              const SizedBox(height: 20),
              Expanded( child: Container( width: double.infinity, decoration: const BoxDecoration( color: Colors.transparent ),
                  child: SingleChildScrollView( padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                         Text( 'Mindfulness Activity', style: GoogleFonts.cormorantGaramond( fontSize: 30, fontWeight: FontWeight.bold, color: primaryTextColor,),),
                         const SizedBox(height: 8), Text( 'Choose your background sound', style: GoogleFonts.lato( fontSize: 18, color: secondaryTextColor, fontWeight: FontWeight.w500,),),
                         const SizedBox(height: 30),
                         Column( mainAxisSize: MainAxisSize.min, children: _mindfulnessSoundFiles.keys.map((sound) => _buildActivityItem(context, theme, sound)).toList(),),
                         const SizedBox(height: 40),
                          Center( child: ElevatedButton( onPressed: _selectedSoundName == null || _isSavingCompletion ? null : _startPlayback, style: ElevatedButton.styleFrom( backgroundColor: startButtonColor, foregroundColor: theme.colorScheme.onPrimary, padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), disabledBackgroundColor: startButtonColor.withOpacity(0.5),), child: const Text( 'Start', style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold,),),),),
                       ],),),),),],),),
         ],
       );
  }

  Widget _buildPlayerScreen(BuildContext context) {
     final theme = Theme.of(context);
     final Color quoteColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
     final Color sliderActiveColor = theme.colorScheme.primary;
     final Color sliderInactiveColor = theme.colorScheme.secondary.withOpacity(0.3);
     final Color playButtonColor = theme.colorScheme.primary.withOpacity(0.9);

     return Container( color: theme.scaffoldBackgroundColor, child: Padding( padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Spacer(flex: 2), Text( 'Focus on your breath,\nanchor in the present moment.', textAlign: TextAlign.center, style: GoogleFonts.cormorantGaramond(fontSize: 22, color: quoteColor, fontWeight: FontWeight.w500, height: 1.4),),
                  const Spacer(flex: 1), Image.asset( _mindfulnessSoundImages[_selectedSoundName ?? ''] ?? 'assets/images/mindful_icon.png', height: MediaQuery.of(context).size.height * 0.25, errorBuilder: (c, e, s) => const Icon(Icons.spa, size: 100, color: Colors.grey),),
                  const Spacer(flex: 2),
                  Padding( padding: const EdgeInsets.symmetric(horizontal: 10.0), child: Column( children: [
                        SliderTheme( data: SliderTheme.of(context).copyWith( activeTrackColor: sliderActiveColor, inactiveTrackColor: sliderInactiveColor, trackHeight: 5.0, thumbColor: sliderActiveColor, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0), overlayColor: sliderActiveColor.withAlpha(0x29), overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),),
                          child: Slider( min: 0, max: math.max(1.0, _duration.inSeconds.toDouble()), value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                            onChanged: (value) async { if (_duration > Duration.zero && _playerState != PlayerState.stopped && _playerState != PlayerState.completed) { final newPosition = Duration(seconds: value.toInt()); await _player.seek(newPosition); if (!_isPlaying && mounted) { setState(() => _position = newPosition); } } },),),
                        Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(formatDuration(_position), style: TextStyle(color: quoteColor.withOpacity(0.8))), Text(formatDuration(_duration), style: TextStyle(color: quoteColor.withOpacity(0.8))),],),],),),
                  const SizedBox(height: 20),
                  Container( decoration: BoxDecoration( color: playButtonColor, shape: BoxShape.circle, boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2)),],), child: IconButton( tooltip: _playPauseTooltip, icon: Icon( _playPauseIcon, size: 60, color: Colors.white,), padding: EdgeInsets.zero, onPressed: _isSavingCompletion ? null : _togglePlayPause, ),),
                   const SizedBox(height: 30),
                  TextButton.icon( icon: const Icon(Icons.check_circle_outline, size: 20, color: Colors.green), label: const Text("Finish Activity", style: TextStyle(fontSize: 16, color: Colors.green)), onPressed: _isSavingCompletion ? null : _handleActivityFinish, style: TextButton.styleFrom( padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),),),
                  const Spacer(flex: 2),],),),);
  }

  Widget _buildCompletionScreen(BuildContext context) {
    final theme = Theme.of(context);
    final Color primaryTextColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final Color finishButtonColor = theme.colorScheme.primary;
    final int durationCompleted = _completedDurationMinutes ?? 0;

    return Container( color: theme.scaffoldBackgroundColor, child: Center( child: Padding( padding: const EdgeInsets.all(20.0),
          child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
              Text( 'Well Done!', style: GoogleFonts.cormorantGaramond( fontSize: 36, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),),
              const SizedBox(height: 15),
              Text( 'You completed $durationCompleted minute${durationCompleted == 1 ? '' : 's'} of Mindfulness.', textAlign: TextAlign.center, style: GoogleFonts.lato(fontSize: 18, color: primaryTextColor.withOpacity(0.9), height: 1.4),),
              const SizedBox(height: 40),
              Icon(Icons.spa_outlined, size: 120, color: finishButtonColor.withOpacity(0.7)),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _isSavingCompletion ? null : _saveCompletionToFirestore,
                style: ElevatedButton.styleFrom( backgroundColor: finishButtonColor, foregroundColor: theme.colorScheme.onPrimary, disabledBackgroundColor: finishButtonColor.withOpacity(0.5), padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                child: _isSavingCompletion ? SizedBox( height: 20, width: 20, child: CircularProgressIndicator( color: theme.colorScheme.onPrimary, strokeWidth: 2.5,)) : const Text('Finish & Log'),
              ),
               const SizedBox(height: 20),
               TextButton( 
                 onPressed: _isSavingCompletion ? null : _resetToSelectionScreen, 
                 child: Text("Track Another Area", style: TextStyle(color: theme.colorScheme.secondary)),
               ),
            ],),),),);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreenWidget;
    switch (_screenState) {
      case MindfulnessScreenState.playing: currentScreenWidget = _buildPlayerScreen(context); break;
      case MindfulnessScreenState.completion: currentScreenWidget = _buildCompletionScreen(context); break;
      case MindfulnessScreenState.selection: default: currentScreenWidget = _buildSelectionScreen(context);
    }

    final theme = Theme.of(context);
    final Color commonBackButtonColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87;

    return Scaffold(
      body: Stack(
        children: [
           SafeArea(child: currentScreenWidget),
           if (_screenState != MindfulnessScreenState.selection)
             Positioned(
               top: MediaQuery.of(context).padding.top + 5, left: 10,
               child: Material( color: Colors.transparent, child: IconButton( tooltip: 'Back', icon: Icon(Icons.arrow_back_ios, color: commonBackButtonColor), onPressed: _isSavingCompletion ? null : _handleBackButton,),),
             ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }

  Widget _buildActivityItem(BuildContext context, ThemeData theme, String soundName) {
     final String imagePath = _mindfulnessSoundImages[soundName] ?? 'assets/images/default_icon.png';
     final bool isSelected = _selectedSoundName == soundName;
     final Color itemBgColor = isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.7) : theme.colorScheme.surfaceVariant.withOpacity(0.7);
     final Color textColor = isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant;
     final Color borderColor = isSelected ? theme.colorScheme.primary : Colors.transparent;

     return GestureDetector(
       onTap: _isSavingCompletion ? null : () { setState(() { _selectedSoundName = soundName; _selectedSoundFile = _mindfulnessSoundFiles[soundName]; }); },
       child: Container(
         width: double.infinity, margin: const EdgeInsets.only(bottom: 18.0), padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0), decoration: BoxDecoration( color: itemBgColor, borderRadius: BorderRadius.circular(18.0), border: Border.all(color: borderColor, width: 2.0), boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2),),],),
         child: Row( children: [ ClipRRect( borderRadius: BorderRadius.circular(8.0), child: Image.asset( imagePath, height: 45, width: 45, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container( height: 45, width: 45, decoration: BoxDecoration( color: Colors.grey[700], borderRadius: BorderRadius.circular(8.0),), child: Icon( Icons.music_note, color: Colors.white54, size: 25,),),),), const SizedBox(width: 18), Expanded( child: Text( soundName, style: GoogleFonts.lato( color: textColor, fontSize: 16, fontWeight: FontWeight.w600,),),),],),
       ),
     );
   }

  String formatDuration(Duration d) {
      try { String twoDigits(int n) => n.toString().padLeft(2, '0'); final minutes = twoDigits(d.inMinutes.remainder(60)); final seconds = twoDigits(d.inSeconds.remainder(60)); return '$minutes:$seconds'; }
      catch (e) { return '00:00'; }
  }

}