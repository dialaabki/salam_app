import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../../models/reminder.dart';
import 'AddMedicineScreen.dart'; // Keep for context, ensure theme-aware
import 'AddActivityScreen.dart'; // Keep for context, ensure theme-aware
import '../../providers/theme_provider.dart'; // 2. Import ThemeNotifier

// --- Define colors (Mostly replaced by theme) ---
// const Color mainAppColor = Color(0xFF5588A4); // Use theme.primaryColor
// const Color lightGreyColor = Color(0xFFF0F0F0); // Use theme surface variant
// const Color textInputColor = Color(0xFFE8E8E8); // Use theme surface variant or inputDec. theme

class AddActivityScreen extends StatefulWidget {
 final Function(Reminder) addReminderCallback;

  const AddActivityScreen({Key? key, required this.addReminderCallback}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  // --- State Variables (Keep as is) ---
  final _formKey = GlobalKey<FormState>();
  String? _selectedActivityName;
  final _customActivityController = TextEditingController();
  bool _isCustomActivity = false;
  DateTime _beginDate = DateTime.now();
  DateTime _finishDate = DateTime.now().add(Duration(days: 30));
  TimeOfDay _selectedTime = TimeOfDay(hour: 17, minute: 30);
  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7};
  final List<String> _activityOptions = [ 'Sleep', 'Breath', 'Walk', 'Mindfulness', 'BreakFree', 'Other...', ];
  // --- End State Variables ---

  @override
  void dispose() {
      _customActivityController.dispose();
      super.dispose();
  }

  // --- Date/Time Pickers (Need Theme context - Copied from AddMedicineScreen modifications) ---
  Future<void> _selectDate(BuildContext context, ThemeData theme, bool isBeginDate) async { // Pass theme
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBeginDate ? _beginDate : _finishDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary, onPrimary: theme.colorScheme.onPrimary, onSurface: theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData( style: TextButton.styleFrom( foregroundColor: theme.colorScheme.primary, ), ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != (isBeginDate ? _beginDate : _finishDate)) {
      setState(() {
        if (isBeginDate) { /* ... keep logic ... */ _beginDate = picked; if (_finishDate.isBefore(_beginDate)) _finishDate = _beginDate; }
        else { /* ... keep logic ... */ if (picked.isBefore(_beginDate)) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Finish date cannot be before begin date.'))); else _finishDate = picked; }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, ThemeData theme) async { // Pass theme
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
       builder: (context, child) {
        return Theme(
          data: theme.copyWith(
             timePickerTheme: TimePickerThemeData(
                 backgroundColor: theme.dialogBackgroundColor,
                 hourMinuteShape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(8), side: BorderSide(color: theme.dividerColor) ),
                 dayPeriodShape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(8), side: BorderSide(color: theme.dividerColor) ),
                 hourMinuteColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? theme.colorScheme.primary.withOpacity(0.15) : theme.colorScheme.surfaceVariant),
                 hourMinuteTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                 dayPeriodColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? theme.colorScheme.primary.withOpacity(0.15) : theme.colorScheme.surfaceVariant),
                 dayPeriodTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                 dialHandColor: theme.colorScheme.primary,
                 dialBackgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                 dialTextColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant),
                 entryModeIconColor: theme.iconTheme.color,
                 helpTextStyle: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface),
             ),
            textButtonTheme: TextButtonThemeData( style: TextButton.styleFrom( foregroundColor: theme.colorScheme.primary, ), ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) { setState(() { _selectedTime = picked; }); }
  }

  // --- Submit Form (Keep logic as is) ---
  void _submitForm() {
     if (_formKey.currentState!.validate()) {
       String activityName;
       if (_isCustomActivity) { activityName = _customActivityController.text.trim(); if (activityName.isEmpty) { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please enter a custom activity name.')), ); return; } }
       else if (_selectedActivityName != null && _selectedActivityName != 'Other...') { activityName = _selectedActivityName!; }
       else { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please select or enter an activity name.')), ); return; }
       if (_selectedDays.isEmpty) { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please select at least one day.')), ); return; }
        final newReminder = Reminder( id: '', type: ReminderType.activity, name: activityName, amount: null, time: _selectedTime, startDate: _beginDate, endDate: _finishDate, selectedDays: _selectedDays, );
        widget.addReminderCallback(newReminder);
        Navigator.pop(context); // Pop AddActivityScreen
        Navigator.pop(context); // Pop AddReminderScreen (Choice screen)
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 3. Access Theme ---
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    // --- End Theme Access ---

    final screenHeight = MediaQuery.of(context).size.height;
    final topImageHeight = screenHeight * 0.25;

      return Scaffold(
        // 4. Use theme primary color for background behind image
        backgroundColor: theme.colorScheme.primary,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            title: const Text( 'Add Activity', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold, shadows: [ Shadow( offset: Offset(1.0, 1.0), blurRadius: 3.0, color: Color.fromARGB(150, 0, 0, 0), ), ], ), ),
             backgroundColor: Colors.transparent,
             elevation: 0,
             // 5. Ensure back button is white on image background
             iconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
        ),
        body: Column(
          children: [
            // --- 1. Top Image Area (Keep as is) ---
            Container( height: topImageHeight, width: double.infinity, decoration: const BoxDecoration( image: DecorationImage( image: AssetImage("assets/images/bg_add_activity.png"), fit: BoxFit.cover, ), ), ),

            // --- 2. Content Container Area (Theme Aware) ---
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ),
                child: Container(
                  width: double.infinity,
                  // 6. Use theme surface color for content background
                  decoration: BoxDecoration( color: theme.colorScheme.surface, borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ), ),
                  child: SingleChildScrollView(
                       child: Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 25.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              // --- Activity Name (Dropdown or TextField) ---
                              _buildSectionTitle(context, theme, 'Activity name'), // Pass theme
                              _buildActivityNameInput(context, theme), // Pass theme
                              const SizedBox(height: 20),

                              // --- Begin / Finish Dates ---
                              Row( children: [ Expanded(child: _buildSectionTitle(context, theme, 'Begin')), const SizedBox(width: 10), Expanded(child: _buildSectionTitle(context, theme, 'Finish')), ], ), // Pass theme
                              _buildDatePickers(context, theme), // Pass theme
                              const SizedBox(height: 20),

                              // --- Days ---
                              _buildSectionTitle(context, theme, 'Days'), // Pass theme
                              _buildDaySelector(context, theme), // Pass theme
                              const SizedBox(height: 20),

                              // --- Time ---
                              _buildSectionTitle(context, theme, 'Time'), // Pass theme
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildTimeSelector(context, theme), // Pass theme
                              ),
                              const SizedBox(height: 30),

                              // --- Submit Button ---
                              Center(
                                  child: _buildSubmitButton(context, theme), // Pass theme
                              ),
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

 // --- Helper Widgets (Modified to be Theme Aware) ---

  // 7. Accept theme in helper methods
  Widget _buildSectionTitle(BuildContext context, ThemeData theme, String title){
     return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          // 8. Use theme secondary text color
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color),
        ),
    );
  }

  // Widget for Activity Name Input (Dropdown or TextField - Theme Aware)
  Widget _buildActivityNameInput(BuildContext context, ThemeData theme) { // Accept theme
    final bool isDark = theme.brightness == Brightness.dark;
    final inputFillColor = theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6);
    final hintColor = theme.hintColor;
    final inputTextColor = theme.colorScheme.onSurface;
    final iconColor = theme.iconTheme.color?.withOpacity(0.6);

    if (_isCustomActivity) {
      return TextFormField(
        controller: _customActivityController,
        style: TextStyle(color: inputTextColor), // Theme text color
        decoration: InputDecoration(
          hintText: 'Enter custom activity name',
          filled: true,
          fillColor: inputFillColor, // Theme background
          border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: TextStyle(color: hintColor), // Theme hint color
           suffixIcon: IconButton(
             icon: Icon(Icons.list_alt, color: iconColor), // Theme icon color
             tooltip: 'Select from list',
             splashRadius: 20,
             onPressed: (){ setState(() { _isCustomActivity = false; _selectedActivityName = null; }); },
           )
        ),
        validator: (value) { if (value == null || value.trim().isEmpty) return 'Please enter an activity name'; return null; },
      );
    } else {
      return DropdownButtonFormField<String>(
        value: _selectedActivityName,
        hint: Text('Select an activity', style: TextStyle(color: hintColor)), // Theme hint color
        decoration: InputDecoration(
          filled: true, fillColor: inputFillColor, // Theme background
          border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none,),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
         dropdownColor: theme.cardColor, // Use theme card color for dropdown background
         style: TextStyle(color: inputTextColor), // Theme text color for items
         isExpanded: true,
         icon: Icon(Icons.arrow_drop_down_rounded, color: iconColor), // Theme icon color
        items: _activityOptions.map((String value) {
          return DropdownMenuItem<String>( value: value, child: Text(value), );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            if (newValue == 'Other...') { _isCustomActivity = true; _selectedActivityName = newValue; _customActivityController.clear(); }
            else { _isCustomActivity = false; _selectedActivityName = newValue; }
          });
        },
        validator: (value) { if (value == null) return 'Please select an activity'; return null; },
      );
    }
  }


  // --- Re-used Widgets from AddMedicineScreen (Modified to accept theme) ---
  Widget _buildDatePickers(BuildContext context, ThemeData theme) { // Accept theme
     return Row( children: [ Expanded(child: _buildDatePickerButton(context, theme, isBeginDate: true)), const SizedBox(width: 10), Expanded(child: _buildDatePickerButton(context, theme, isBeginDate: false)), ], );
  }

  Widget _buildDatePickerButton(BuildContext context, ThemeData theme, {required bool isBeginDate}) { // Accept theme
    final bool isDark = theme.brightness == Brightness.dark;
    DateTime dateToShow = isBeginDate ? _beginDate : _finishDate;
    return ElevatedButton.icon(
      icon: Icon(Icons.calendar_today_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
      label: Text( DateFormat('MMM, dd').format(dateToShow), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant) ),
      style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6),
          foregroundColor: theme.colorScheme.onSurfaceVariant,
          elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 14)
      ),
      onPressed: () => _selectDate(context, theme, isBeginDate), // Pass theme
    );
  }

   Widget _buildDaySelector(BuildContext context, ThemeData theme) { // Accept theme
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dayMapping = {0: 7, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6};
    return Container(
       alignment: Alignment.center,
      child: Wrap(
        spacing: 8.0, runSpacing: 6.0, alignment: WrapAlignment.center,
        children: List<Widget>.generate(7, (index) {
          final weekDay = dayMapping[index]!;
          final isSelected = _selectedDays.contains(weekDay);
          return FilterChip(
            label: Text(days[index]), selected: isSelected,
            onSelected: (bool selected) { setState(() { if (selected) _selectedDays.add(weekDay); else { if (_selectedDays.length > 1) _selectedDays.remove(weekDay); else ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('At least one day must be selected.')), ); } }); },
            selectedColor: theme.colorScheme.primary,
            checkmarkColor: theme.colorScheme.onPrimary,
            labelStyle: TextStyle( fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant ),
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
            padding: const EdgeInsets.all(10), showCheckmark: false,
          );
        }),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, ThemeData theme) { // Accept theme
     final bool isDark = theme.brightness == Brightness.dark;
     return ElevatedButton.icon(
      icon: Icon(Icons.access_time_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)),
      label: Text( _selectedTime.format(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant) ),
      style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6),
          foregroundColor: theme.colorScheme.onSurfaceVariant,
          elevation: 0, minimumSize: const Size(130, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      onPressed: () => _selectTime(context, theme), // Pass theme
    );
   }

   Widget _buildSubmitButton(BuildContext context, ThemeData theme) { // Accept theme
      return ElevatedButton.icon(
         icon: Icon(Icons.check_circle_outline, size: 20, color: theme.colorScheme.onPrimary),
         label: Text('Add Activity', style: TextStyle(color: theme.colorScheme.onPrimary)), // Changed label
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12.0) ),
            elevation: 2,
        ),
        onPressed: _submitForm,
      );
   }

} // End of _AddActivityScreenState