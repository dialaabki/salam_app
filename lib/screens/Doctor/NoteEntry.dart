// lib/note_entry.dart
class NoteEntry {
  final String id; // Unique ID for editing/deleting
  final String patientImagePath;
  final String patientName;
  final String patientAge; // <-- ADDED: Store age separately for searching
  final String
  patientDetails; // Keep original details string for display consistency
  String noteText; // Mutable for editing
  String timestampString; // Display string (can be updated on edit)

  NoteEntry({
    required this.id,
    required this.patientImagePath,
    required this.patientName,
    required this.patientAge, // <-- ADDED to constructor
    required this.patientDetails,
    required this.noteText,
    required this.timestampString,
  });

  // Helper method to check if note matches search query (UPDATED)
  bool matchesSearch(String query) {
    final queryLower = query.toLowerCase();
    return patientName.toLowerCase().contains(queryLower) ||
        noteText.toLowerCase().contains(queryLower) ||
        patientDetails.toLowerCase().contains(
          queryLower,
        ) || // Keep details search
        patientAge.contains(queryLower); // <-- ADDED: Search by age string
  }
}