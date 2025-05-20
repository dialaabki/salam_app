import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// --- Firebase Imports ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// --- End Firebase Imports ---

// Keep for theme access if needed directly
import '../../providers/theme_provider.dart';

class AddActivityScreen extends StatefulWidget {
  // Constructor without the callback
  const AddActivityScreen({Key? key}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedActivityName;
  final _customActivityController = TextEditingController();
  bool _isCustomActivity = false;
  DateTime _beginDate = DateTime.now();
  DateTime _finishDate = DateTime.now().add(const Duration(days: 30));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 17, minute: 30);

  // *** MODIFIED INITIALIZATION: Start with no days selected ***
  Set<int> _selectedDays = {}; // Mon=1...Sun=7

  final List<String> _activityOptions = [ 'Sleep', 'Breath', 'Walk', 'Mindfulness', 'BreakFree', 'Other...', ];
  bool _isLoading = false;

  @override
  void dispose() {
      _customActivityController.dispose();
      super.dispose();
  }

  // --- Date/Time Pickers (Same as AddMedicineScreen) ---
  Future<void> _selectDate(BuildContext context, ThemeData theme, bool isBeginDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBeginDate ? _beginDate : _finishDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              onSurface: theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
        setState(() {
            if (isBeginDate) {
                _beginDate = picked;
                if (_finishDate.isBefore(_beginDate)) { _finishDate = _beginDate; }
            } else {
                if (picked.isBefore(_beginDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Finish date cannot be before begin date.')));
                } else {
                    _finishDate = picked;
                }
            }
        });
    }
  }

  Future<void> _selectTime(BuildContext context, ThemeData theme) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
       builder: (context, child) {
        return Theme(
            data: theme.copyWith(
                timePickerTheme: theme.timePickerTheme.copyWith(
                  // dialHandColor: theme.colorScheme.secondary,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
              ),
            ),
            child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) { setState(() { _selectedTime = picked; }); }
  }

  // --- Submit Form (Modified for Firestore) ---
  Future<void> _submitForm() async {
     if (_isLoading) return;
     if (_formKey.currentState!.validate()) {
       String activityName;
       if (_isCustomActivity) { activityName = _customActivityController.text.trim(); if (activityName.isEmpty) { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please enter custom activity.')) ); return; } }
       else if (_selectedActivityName != null && _selectedActivityName != 'Other...') { activityName = _selectedActivityName!; }
       else { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please select an activity.')) ); return; }
       if (_selectedDays.isEmpty) { // Critical check
         ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please select at least one day.')) );
         return;
       }

       setState(() { _isLoading = true; });
       final User? user = FirebaseAuth.instance.currentUser;
       if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Error: No user logged in.')) );
          setState(() { _isLoading = false; }); return;
       }
       final String userId = user.uid;
       final Map<String, dynamic> reminderData = {
          'userId': userId, 'type': 'activity', 'name': activityName,
          'timeHour': _selectedTime.hour, 'timeMinute': _selectedTime.minute,
          'startDate': Timestamp.fromDate(_beginDate), 'endDate': Timestamp.fromDate(_finishDate),
          'selectedDays': _selectedDays.toList()..sort(), 'createdAt': Timestamp.now(),
          'isCompleted': false,
       };
       try {
          CollectionReference remindersCollection = FirebaseFirestore.instance.collection('reminders');
          await remindersCollection.add(reminderData);
          if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Activity reminder added!'), backgroundColor: Colors.green) );
             Navigator.pop(context); // Pop AddActivityScreen
             if (Navigator.canPop(context)) { Navigator.pop(context); } // Pop AddReminderScreen
          }
       } catch (e) {
          print("Error adding activity reminder: $e");
          if(mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Failed: ${e.toString()}'), backgroundColor: Colors.red) ); }
       } finally {
          if(mounted){ setState(() { _isLoading = false; }); }
       }
    }
  }
  // --- End Submit Form ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final topImageHeight = screenHeight * 0.25;

      return Scaffold(
        backgroundColor: theme.colorScheme.primary,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
           title: const Text( 'Add Activity', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold, shadows: [ Shadow( offset: Offset(1.0, 1.0), blurRadius: 3.0, color: Color.fromARGB(150, 0, 0, 0), ), ], ), ),
           backgroundColor: Colors.transparent,
           elevation: 0,
           iconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
        ),
        body: Column(
          children: [
            Container(
              height: topImageHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg_add_activity.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration( color: theme.colorScheme.surface, borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ), ),
                  child: SingleChildScrollView(
                       child: Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 25.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              _buildSectionTitle(context, theme, 'Activity name'),
                              _buildActivityNameInput(context, theme),
                              const SizedBox(height: 20),
                              Row( children: [ Expanded(child: _buildSectionTitle(context, theme, 'Begin')), const SizedBox(width: 10), Expanded(child: _buildSectionTitle(context, theme, 'Finish')), ], ),
                              _buildDatePickers(context, theme),
                              const SizedBox(height: 20),
                              _buildSectionTitle(context, theme, 'Days'),
                              _buildDaySelector(context, theme),
                              const SizedBox(height: 20),
                              _buildSectionTitle(context, theme, 'Time'),
                              Align( alignment: Alignment.centerLeft, child: _buildTimeSelector(context, theme), ),
                              const SizedBox(height: 30),
                              Center( child: _buildSubmitButton(context, theme), ),
                              const SizedBox(height: 10),
                          ],
                          ),
                      ),
                      ),
                  ),
                ),
              ),
            ),
          ],
        ),
        );
  }

  Widget _buildSectionTitle(BuildContext context, ThemeData theme, String title){
     return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
           title,
           style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color),
        ),
    );
  }

  Widget _buildActivityNameInput(BuildContext context, ThemeData theme) {
    final bool isDark = theme.brightness == Brightness.dark;
    final inputFillColor = theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6);
    final hintColor = theme.hintColor;
    final inputTextColor = theme.colorScheme.onSurface;
    final iconColor = theme.iconTheme.color?.withOpacity(0.6);

    if (_isCustomActivity) {
      return TextFormField(
        controller: _customActivityController,
        enabled: !_isLoading,
        style: TextStyle(color: _isLoading ? hintColor : inputTextColor),
        decoration: InputDecoration(
          hintText: 'Enter custom activity name',
          filled: true,
          fillColor: inputFillColor,
          border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: TextStyle(color: hintColor),
           suffixIcon: IconButton(
             icon: Icon(Icons.list_alt, color: _isLoading ? hintColor : iconColor),
             tooltip: 'Select from list',
             splashRadius: 20,
             onPressed: _isLoading ? null : (){ setState(() { _isCustomActivity = false; _selectedActivityName = null; }); },
           )
        ),
        validator: (value) {
            if (_isCustomActivity && (value == null || value.trim().isEmpty)) {
                return 'Please enter an activity name';
            }
            return null;
        },
      );
    } else {
      String? displayValue = (_selectedActivityName == 'Other...') ? null : _selectedActivityName;

      return DropdownButtonFormField<String>(
        value: displayValue,
        hint: Text('Select an activity', style: TextStyle(color: hintColor)),
        decoration: InputDecoration(
          filled: true, fillColor: inputFillColor,
          border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          disabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
          enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
        ),
         dropdownColor: theme.cardColor,
         style: TextStyle(color: _isLoading ? hintColor : inputTextColor),
         isExpanded: true,
         icon: Icon(Icons.arrow_drop_down_rounded, color: _isLoading ? hintColor : iconColor),
        items: _activityOptions.map((String value) {
          return DropdownMenuItem<String>( value: value, child: Text(value), );
        }).toList(),
        onChanged: _isLoading ? null : (String? newValue) {
          setState(() {
            if (newValue == 'Other...') {
               _isCustomActivity = true;
               _selectedActivityName = newValue;
               _customActivityController.clear();
            } else {
               _isCustomActivity = false;
               _selectedActivityName = newValue;
            }
          });
        },
        validator: (value) {
             if (!_isCustomActivity && value == null && _selectedActivityName == null) {
                 return 'Please select an activity';
             }
             return null;
        },
      );
    }
  }

  Widget _buildDatePickers(BuildContext context, ThemeData theme) {
     return Row( children: [ Expanded(child: _buildDatePickerButton(context, theme, isBeginDate: true)), const SizedBox(width: 10), Expanded(child: _buildDatePickerButton(context, theme, isBeginDate: false)), ], );
  }

  Widget _buildDatePickerButton(BuildContext context, ThemeData theme, {required bool isBeginDate}) {
    final bool isDark = theme.brightness == Brightness.dark;
    DateTime dateToShow = isBeginDate ? _beginDate : _finishDate;
    return ElevatedButton.icon(
      icon: Icon(Icons.calendar_today_outlined, size: 18, color: _isLoading ? theme.hintColor.withOpacity(0.7) : theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
      label: Text( DateFormat('MMM, dd').format(dateToShow), style: TextStyle(fontWeight: FontWeight.bold, color: _isLoading ? theme.hintColor : theme.colorScheme.onSurfaceVariant) ),
      style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6),
          foregroundColor: theme.colorScheme.onSurfaceVariant,
          elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14),
          disabledBackgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.1 : 0.3),
          disabledForegroundColor: theme.hintColor,
      ),
      onPressed: _isLoading ? null : () => _selectDate(context, theme, isBeginDate),
    );
  }

  Widget _buildDaySelector(BuildContext context, ThemeData theme) {
    final List<String> chipLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<int> weekdayValuesToStore = [
      DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday,
      DateTime.thursday, DateTime.friday, DateTime.saturday,
    ];

    return Container(
       alignment: Alignment.center,
      child: Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        alignment: WrapAlignment.center,
        children: List<Widget>.generate(chipLabels.length, (index) {
            final String dayName = chipLabels[index];
            final int valueToStoreForThisChip = weekdayValuesToStore[index];
            final bool isSelected = _selectedDays.contains(valueToStoreForThisChip);

            return FilterChip(
              label: Text(
                dayName,
                style: TextStyle( fontSize: 13, fontWeight: FontWeight.w500, ),
              ),
              selected: isSelected,
              onSelected: _isLoading ? null : (bool newSelectedState) {
                 setState(() {
                    if (newSelectedState) { // If chip is now selected, add the day
                       _selectedDays.add(valueToStoreForThisChip);
                    } else { // If chip is now unselected, remove the day
                       _selectedDays.remove(valueToStoreForThisChip);
                    }
                    print("Chip '$dayName' toggled. New state: $newSelectedState. Stored weekday: $valueToStoreForThisChip. Current _selectedDays: $_selectedDays");
                 });
              },
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: theme.colorScheme.onPrimary,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _isLoading
                         ? theme.hintColor
                         : (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant)
              ),
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(_isLoading ? 0.2 : 0.5),
              disabledColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.transparent)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              showCheckmark: false,
           );
        }),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, ThemeData theme) {
     final bool isDark = theme.brightness == Brightness.dark;
     return ElevatedButton.icon(
      icon: Icon(Icons.access_time_outlined, size: 20, color: _isLoading ? theme.hintColor.withOpacity(0.7) : theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
      label: Text( _selectedTime.format(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isLoading ? theme.hintColor : theme.colorScheme.onSurfaceVariant) ),
      style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6),
          foregroundColor: theme.colorScheme.onSurfaceVariant,
          elevation: 0, minimumSize: const Size(130, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          disabledBackgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.1 : 0.3),
          disabledForegroundColor: theme.hintColor,
      ),
      onPressed: _isLoading ? null : () => _selectTime(context, theme),
    );
   }

   Widget _buildSubmitButton(BuildContext context, ThemeData theme) {
      return ElevatedButton.icon(
         icon: _isLoading
             ? Container( width: 18, height: 18, padding: const EdgeInsets.all(2.0), child: CircularProgressIndicator(color: theme.colorScheme.onPrimary, strokeWidth: 2) )
             : Icon(Icons.check_circle_outline, size: 20, color: theme.colorScheme.onPrimary),
         label: Text(_isLoading ? 'Adding...' : 'Add Activity', style: TextStyle(color: theme.colorScheme.onPrimary)), // Changed label
       style: ElevatedButton.styleFrom(
           backgroundColor: theme.colorScheme.primary,
           foregroundColor: theme.colorScheme.onPrimary,
           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
           textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
           shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12.0) ),
           elevation: _isLoading ? 0 : 2,
           disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.5)
       ),
       onPressed: _isLoading ? null : _submitForm,
     );
  }

} // End of _AddActivityScreenState