// lib/add_edit_note_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'noteEntry.dart';
import 'patientsScreen.dart';
import 'package:collection/collection.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteEntry? initialNote;
  final List<Patient> availablePatients;

  const AddEditNoteScreen({
    super.key,
    this.initialNote,
    required this.availablePatients,
  });

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noteTextController;
  Patient? _selectedPatient;
  late String _appBarTitle;
  late String _submitButtonText;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _noteTextController = TextEditingController(
      text: widget.initialNote?.noteText ?? '',
    );

    if (widget.initialNote != null) {
      _appBarTitle = 'Edit Note';
      _submitButtonText = 'Save Changes';
      _selectedPatient = widget.availablePatients.firstWhereOrNull(
        (p) => p.name == widget.initialNote!.patientName,
      );
      if (_selectedPatient == null) {
        print(
          "Warning: Initial patient '${widget.initialNote!.patientName}' for editing not found.",
        );
      }
    } else {
      _appBarTitle = 'Add New Note';
      _submitButtonText = 'Add Note';
      _selectedPatient = widget.availablePatients.firstOrNull;
    }
  }

  @override
  void dispose() {
    _noteTextController.dispose();
    super.dispose();
  }

  // --- UPDATED _submitNote ---
  void _submitNote() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a patient.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final noteText = _noteTextController.text;
      final now = DateTime.now();
      final timestampString =
          "Today ${TimeOfDay.fromDateTime(now).format(context)}";

      final note = NoteEntry(
        id: widget.initialNote?.id ?? _uuid.v4(),
        patientImagePath: _selectedPatient!.avatarPath,
        patientName: _selectedPatient!.name,
        patientAge: _selectedPatient!.age, // <-- ADDED: Pass age
        patientDetails:
            "${_selectedPatient!.age} Years, ${_selectedPatient!.condition}", // Keep display string
        noteText: noteText,
        timestampString: widget.initialNote?.timestampString ?? timestampString,
      );

      Navigator.pop(context, note);
    }
  }
  // --- End Update ---

  @override
  Widget build(BuildContext context) {
    // ... build method remains the same ...
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: const Color(0xFF5A7A9E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.availablePatients.isNotEmpty)
                DropdownButtonFormField<Patient>(
                  value: _selectedPatient,
                  decoration: InputDecoration(
                    labelText: 'Select Patient',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                  ),
                  items:
                      widget.availablePatients.map((patient) {
                        return DropdownMenuItem<Patient>(
                          value: patient,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundImage: AssetImage(patient.avatarPath),
                                onBackgroundImageError: (e, s) {},
                              ),
                              const SizedBox(width: 10),
                              Text(patient.name),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (Patient? newValue) {
                    setState(() {
                      _selectedPatient = newValue;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Please select a patient' : null,
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'No patients found to assign note.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _noteTextController,
                decoration: InputDecoration(
                  labelText: 'Note Details',
                  hintText: 'Enter your notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter note details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed:
                    (_selectedPatient == null &&
                            widget.availablePatients.isEmpty)
                        ? null
                        : _submitNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004A99),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: Text(_submitButtonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}