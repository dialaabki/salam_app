// lib/notes_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'noteEntry.dart'; // Uses updated NoteEntry
import 'addEditNoteScreen.dart';
import 'patientsScreen.dart';
import 'package:collection/collection.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // ... (keep existing variables: _screenIndex, paths, controllers, lists, uuid, patients, colors) ...
  final int _screenIndex = 2;
  final String malePatientImagePath = 'assets/images/malepatientpic.png';
  final String femalePatientImagePath = 'assets/images/femalepatientpic.png';
  final TextEditingController _searchController = TextEditingController();
  final List<NoteEntry> _allNotes = [];
  List<NoteEntry> _filteredNotes = [];
  final _uuid = const Uuid();
  List<Patient> _availablePatients = [];
  final Color headerColor = const Color(0xFF5A7A9E);
  final Color primaryTextColor = const Color(0xFF003366);
  final Color noteTextColor = Colors.black87;
  final Color secondaryTextColor = Colors.grey.shade600;
  final Color searchBarColor = Colors.grey.shade200;
  final Color blueCardBg = const Color(0xFFE0F2F7);
  final Color blueAvatarBg = const Color(0xFFB3E5FC);
  final Color purpleCardBg = const Color(0xFFEDE7F6);
  final Color purpleAvatarBg = const Color(0xFFD1C4E9);
  static const Color bottomNavColor = Color(0xFF004A99);
  static const Color bottomNavSelectedColor = Colors.white;
  static const Color bottomNavUnselectedColor = Color(0xFFADD8E6);

  @override
  void initState() {
    super.initState();
    _availablePatients = _getDummyPatientsForNotes();
    _loadInitialNotes(); // Now includes age
    _filteredNotes = List.from(_allNotes);
    _searchController.addListener(_filterNotes);
  }

  // ... (_getDummyPatientsForNotes, dispose, _filterNotes, navigation methods, _buildNoteItem, delete methods - keep as is from previous corrections) ...
  List<Patient> _getDummyPatientsForNotes() {
    /* ... same ... */
    const String maleAvatarPath = 'assets/images/malepatientpic.png';
    const String femaleAvatarPath = 'assets/images/femalepatientpic.png';
    const Color maleAvatarBg = Color(0xFFA5D6F0);
    const Color femaleAvatarBg = Color(0xFFD1C4E9);
    return [
      Patient(
        id: '1',
        name: 'Morad',
        age: '34',
        condition: 'Depression',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '2',
        name: 'Lara',
        age: '23',
        condition: 'Anxiety',
        avatarPath: femaleAvatarPath,
        avatarBgColor: femaleAvatarBg,
      ),
      Patient(
        id: '3',
        name: 'Tamer',
        age: '28',
        condition: 'Addiction',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '5',
        name: 'Ahmad',
        age: '29',
        condition: 'Depression',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
      Patient(
        id: '7',
        name: 'Omar',
        age: '18',
        condition: 'ADHD',
        avatarPath: maleAvatarPath,
        avatarBgColor: maleAvatarBg,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterNotes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterNotes() {
    /* ... same ... uses NoteEntry.matchesSearch which now includes age */
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = List.from(_allNotes);
      } else {
        _filteredNotes =
            _allNotes.where((note) => note.matchesSearch(query)).toList();
      }
    });
  }

  void _navigateToAddNote() async {
    /* ... same ... */
    final result = await Navigator.push<NoteEntry>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddEditNoteScreen(availablePatients: _availablePatients),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _allNotes.insert(0, result);
        _filterNotes();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note for ${result.patientName} added!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToEditNote(NoteEntry noteToEdit) async {
    /* ... same ... */
    final result = await Navigator.push<NoteEntry>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddEditNoteScreen(
              initialNote: noteToEdit,
              availablePatients: _availablePatients,
            ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        final index = _allNotes.indexWhere((note) => note.id == result.id);
        if (index != -1) {
          _allNotes[index] = result;
          _filterNotes();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note for ${result.patientName} updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildNoteItem(NoteEntry note) {
    /* ... same ... includes delete */
    bool isBlue = note.patientImagePath == malePatientImagePath;
    Color cardBg = isBlue ? blueCardBg : purpleCardBg;
    Color avatarBg = isBlue ? blueAvatarBg : purpleAvatarBg;
    return Container(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: avatarBg,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(note.patientImagePath),
                            backgroundColor: Colors.transparent,
                            onBackgroundImageError: (e, s) {},
                            child:
                                AssetImage(note.patientImagePath) == null
                                    ? const Icon(Icons.person)
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF4A4A6A),
                            ),
                          ),
                          Text(
                            note.patientDetails,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit Note',
                  onPressed: () => _navigateToEditNote(note),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red[400],
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete Note',
                  onPressed: () => _confirmDeleteNote(note),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                note.noteText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      noteTextColor,
                  height: 1.3,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                note.timestampString,
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteNote(NoteEntry noteToDelete) {
    /* ... same ... */
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Delete note for ${noteToDelete.patientName}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNote(noteToDelete);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(NoteEntry noteToDelete) {
    /* ... same ... */
    setState(() {
      _allNotes.removeWhere((note) => note.id == noteToDelete.id);
      _filterNotes();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note for ${noteToDelete.patientName} deleted.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _onItemTapped(int index) {
    /* ... same ... */
    if (index == _screenIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/patients');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // --- UPDATED _loadInitialNotes ---
  void _loadInitialNotes() {
    // Sample data using NoteEntry - NOW INCLUDES AGE
    _allNotes.addAll([
      NoteEntry(
        id: _uuid.v4(),
        patientImagePath: malePatientImagePath,
        patientName: 'Morad',
        patientAge: '34', // <-- Pass Age
        patientDetails: '34 Years, Depression', // Keep display string
        noteText:
            'Needs follow up regarding medication adjustment. Mood seems slightly lower this week.',
        timestampString: 'Today 3:00 PM',
      ),
      NoteEntry(
        id: _uuid.v4(),
        patientImagePath: femalePatientImagePath,
        patientName: 'Lara',
        patientAge: '23', // <-- Pass Age
        patientDetails: '23 Years, Anxiety',
        noteText:
            'Patient reports increased anxiety before exams. Discussed coping mechanisms. Scheduled extra check-in.',
        timestampString: 'Today 10:15 AM',
      ),
      NoteEntry(
        id: _uuid.v4(),
        patientImagePath: malePatientImagePath,
        patientName: 'Tamer',
        patientAge: '28', // <-- Pass Age
        patientDetails: '28 Years, OCD',
        noteText:
            'High Priority. Checkup frequency maintained. Showing good progress with exposure therapy.',
        timestampString: 'Yesterday 5:00 PM',
      ),
    ]);
  }
  // --- End Update ---

  @override
  Widget build(BuildContext context) {
    // ... build method structure remains the same ...
    // Update search hint text
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        backgroundColor: bottomNavColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Note',
      ),
      body: Column(
        children: [
          // --- Header (keep as is) ---
          Container(
            /* ... */
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 30,
              left: 25,
              right: 25,
            ),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(35),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.assignment_outlined, color: Colors.white, size: 35),
                SizedBox(width: 15),
                Text(
                  'Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // --- Search Bar (Update Hint Text) ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 15.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                color: searchBarColor,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: Icon(Icons.tune, color: Colors.grey[600]),
                  hintText:
                      'Search by patient, age, content...', // <-- UPDATED HINT
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () => _searchController.clear(),
                          )
                          : Icon(Icons.search, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
          // --- List View (keep as is) ---
          Expanded(
            /* ... */
            child:
                _filteredNotes.isEmpty
                    ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No notes yet.\nTap + to add one.'
                            : 'No notes found.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _filteredNotes.length,
                      itemBuilder:
                          (context, index) =>
                              _buildNoteItem(_filteredNotes[index]),
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                            indent: 20,
                            endIndent: 20,
                          ),
                    ),
          ),
        ],
      ),
      // --- Bottom Nav (keep as is) ---
      bottomNavigationBar: Container(
        /* ... */
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: _screenIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bottomNavColor,
          selectedItemColor: bottomNavSelectedColor,
          unselectedItemColor: bottomNavUnselectedColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 1,
          unselectedFontSize: 1,
          elevation: 5,
          selectedIconTheme: const IconThemeData(size: 28),
          unselectedIconTheme: const IconThemeData(size: 24),
        ),
      ),
    );
  }
}