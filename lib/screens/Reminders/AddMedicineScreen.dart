import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../../models/reminder.dart';
import 'AddMedicineScreen.dart'; // Keep for existing reference, ensure it's theme aware too
import 'AddActivityScreen.dart'; // Keep for existing reference, ensure it's theme aware too
import '../../providers/theme_provider.dart'; // 2. Import ThemeNotifier

// --- Define colors (Mostly replaced by theme) ---
// const Color mainAppColor = Color(0xFF5588A4); // Use theme.primaryColor
// const Color lightGreyColor = Color(0xFFF0F0F0); // Use theme surface variant
// const Color textInputColor = Color(0xFFE8E8E8); // Use theme surface variant or inputDec. theme

class AddMedicineScreen extends StatefulWidget {
  final Function(Reminder) addReminderCallback;

  const AddMedicineScreen({Key? key, required this.addReminderCallback}) : super(key: key);

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  // --- State Variables (Keep as is) ---
  final _formKey = GlobalKey<FormState>();
  final _pillNameController = TextEditingController();
  int _amount = 1;
  DateTime _beginDate = DateTime.now();
  DateTime _finishDate = DateTime.now().add(Duration(days: 30));
  TimeOfDay _selectedTime = TimeOfDay(hour: 9, minute: 0);
  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7};
  // --- End State Variables ---

  @override
  void dispose() {
    _pillNameController.dispose();
    super.dispose();
  }

  // --- Date/Time Pickers (Need Theme context) ---
  Future<void> _selectDate(BuildContext context, ThemeData theme, bool isBeginDate) async { // Pass theme
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBeginDate ? _beginDate : _finishDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      // 3. Apply theme to DatePicker
      builder: (context, child) {
        return Theme(
          data: theme.copyWith( // Use current theme as base
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary, // Header background
              onPrimary: theme.colorScheme.onPrimary, // Header text
              onSurface: theme.colorScheme.onSurface, // Body text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary, // Button text color
              ),
            ),
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
       // 4. Apply theme to TimePicker
       builder: (context, child) {
        return Theme(
          data: theme.copyWith(
             timePickerTheme: TimePickerThemeData(
                 backgroundColor: theme.dialogBackgroundColor, // Dialog background
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
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() { _selectedTime = picked; });
    }
  }

  // --- Submit Form (Keep logic as is) ---
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
       if (_selectedDays.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one day.'))); return; }
       final newReminder = Reminder( id: '', type: ReminderType.medicine, name: _pillNameController.text, amount: _amount, time: _selectedTime, startDate: _beginDate, endDate: _finishDate, selectedDays: _selectedDays, );
       widget.addReminderCallback(newReminder);
       Navigator.pop(context); // Pop AddMedicineScreen
       Navigator.pop(context); // Pop AddReminderScreen (Choice screen)
    }
  }


  @override
  Widget build(BuildContext context) {
    // --- 5. Access Theme ---
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    // --- End Theme Access ---

    final screenHeight = MediaQuery.of(context).size.height;
    final topImageHeight = screenHeight * 0.25;

    return Scaffold(
      // 6. Use theme primary color for background behind image
      backgroundColor: theme.colorScheme.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text( 'Add Medicine', style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold, shadows: [ Shadow( offset: Offset(1.0, 1.0), blurRadius: 3.0, color: Color.fromARGB(150, 0, 0, 0), ), ], ), ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 7. Ensure back button is white on image background
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      ),
      body: Column(
        children: [
          // --- 1. Top Image Area (Keep as is) ---
          Container( height: topImageHeight, width: double.infinity, decoration: const BoxDecoration( image: DecorationImage( image: AssetImage("assets/images/bg_add_pill.png"), fit: BoxFit.cover, ), ), ),

          // --- 2. Content Container Area (Theme Aware) ---
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  // 8. Use theme surface color for content background
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only( topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0), ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 25.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Pill Name ---
                          _buildSectionTitle(context, theme, 'Pill name'), // Pass theme
                          TextFormField(
                            controller: _pillNameController,
                            // 9. Use theme InputDecoration or define theme-aware style
                            decoration: InputDecoration(
                               hintText: 'e.g., Aspirin',
                               filled: true,
                               // Use a subtle theme color for fill
                               fillColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6),
                               border: OutlineInputBorder( borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none, ),
                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                               hintStyle: TextStyle(color: theme.hintColor) // Use theme hint color
                            ),
                            style: TextStyle(color: theme.colorScheme.onSurface), // Ensure input text color matches theme
                            validator: (value) { if (value == null || value.isEmpty) return 'Please enter a pill name'; return null; },
                          ),
                          const SizedBox(height: 20),

                          // --- Amount ---
                          _buildSectionTitle(context, theme, 'Amount'), // Pass theme
                          _buildAmountSelector(context, theme), // Pass theme
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
  } // End build

 // --- Helper Widgets (Modified to be Theme Aware) ---

  // 10. Accept theme in helper methods
  Widget _buildSectionTitle(BuildContext context, ThemeData theme, String title){
     return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
           title,
           // 11. Use theme secondary text color for titles
           style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color),
        ),
    );
  }

  Widget _buildAmountSelector(BuildContext context, ThemeData theme) { // Accept theme
    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          // 12. Use theme color for background
          color: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6),
          borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 13. Use theme colors for icons if desired, keeping red/green intent
          IconButton( icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent.withOpacity(0.8)), onPressed: () { if (_amount > 1) { setState(() => _amount--); } }, splashRadius: 20, constraints: BoxConstraints(), padding: EdgeInsets.all(8), ),
          VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor, indent: 8, endIndent: 8,), // Use theme divider
          Padding( padding: const EdgeInsets.symmetric(horizontal: 16.0),
             // 14. Use theme text color
             child: Text( '$_amount pill${_amount > 1 ? 's' : ''}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant) ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor, indent: 8, endIndent: 8,), // Use theme divider
          // 13. Use theme colors for icons if desired, keeping red/green intent
          IconButton( icon: Icon(Icons.add_circle_outline, color: Colors.green.withOpacity(0.8)), onPressed: () { setState(() => _amount++); }, splashRadius: 20, constraints: BoxConstraints(), padding: EdgeInsets.all(8), ),
        ],
      ),
    );
  }

  Widget _buildDatePickers(BuildContext context, ThemeData theme) { // Accept theme
    return Row( children: [ Expanded(child: _buildDatePickerButton(context, theme, isBeginDate: true)), const SizedBox(width: 10), Expanded(child: _buildDatePickerButton(context, theme, isBeginDate: false)), ], );
  }

  Widget _buildDatePickerButton(BuildContext context, ThemeData theme, {required bool isBeginDate}) { // Accept theme
    final bool isDark = theme.brightness == Brightness.dark;
    DateTime dateToShow = isBeginDate ? _beginDate : _finishDate;
    // 15. Style button using theme colors
    return ElevatedButton.icon(
      icon: Icon(Icons.calendar_today_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)), // Theme icon color
      label: Text( DateFormat('MMM, dd').format(dateToShow), style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant) ), // Theme text color
      style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6), // Theme background
          foregroundColor: theme.colorScheme.onSurfaceVariant, // Theme foreground (for ripple)
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14)
      ),
      onPressed: () => _selectDate(context, theme, isBeginDate), // Pass theme to picker
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
          // 16. Style FilterChip using theme colors
          return FilterChip(
            label: Text(days[index]), selected: isSelected,
            onSelected: (bool selected) { setState(() { if (selected) _selectedDays.add(weekDay); else { if (_selectedDays.length > 1) _selectedDays.remove(weekDay); else ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('At least one day must be selected.')), ); } }); },
            selectedColor: theme.colorScheme.primary, // Theme primary when selected
            checkmarkColor: theme.colorScheme.onPrimary, // Theme color for checkmark
            labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                // Theme color for label based on selection
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant
            ),
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5), // Theme background when not selected
            shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
            padding: const EdgeInsets.all(10), showCheckmark: false,
          );
        }),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, ThemeData theme) { // Accept theme
     final bool isDark = theme.brightness == Brightness.dark;
     // 17. Style button using theme colors
     return ElevatedButton.icon(
      icon: Icon(Icons.access_time_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7)), // Theme icon color
      label: Text( _selectedTime.format(context), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant) ), // Theme text color
      style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.3 : 0.6), // Theme background
          foregroundColor: theme.colorScheme.onSurfaceVariant, // Theme foreground (for ripple)
          elevation: 0,
          minimumSize: const Size(130, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      onPressed: () => _selectTime(context, theme), // Pass theme to picker
    );
   }

   Widget _buildSubmitButton(BuildContext context, ThemeData theme) { // Accept theme
      // 18. Style submit button using theme colors
      return ElevatedButton.icon(
         icon: Icon(Icons.check_circle_outline, size: 20, color: theme.colorScheme.onPrimary), // Theme icon color
         label: Text('Add Pill', style: TextStyle(color: theme.colorScheme.onPrimary)), // Theme text color
        style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary, // Theme primary background
            foregroundColor: theme.colorScheme.onPrimary, // Theme foreground (for ripple/text/icon)
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12.0) ),
            elevation: 2,
        ),
        onPressed: _submitForm,
      );
   }
} // End of _AddMedicineScreenState