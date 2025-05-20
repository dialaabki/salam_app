import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- Ensure these paths are correct for your project structure ---
// Make sure these imports point to the correct files in your project.
// Adjust these paths if your file structure is different.
import '../../widgets/bottom_nav_bar.dart';    // Assuming this exists at this path
import '../../providers/theme_provider.dart';  // Import your ThemeNotifier
import '../auth/loginScreen.dart';           // Import your LoginScreen
// Or use named routes if defined in main.dart
// import '../../main.dart'; // If using MyApp.loginRoute

// --- Define Base Colors (Optional, but can be useful) ---
const Color baseBlueColor = Color(0xFF5588A4); // Your original blue for light mode groups

// --- Fallback Text Color ---
const Color lightModeFallbackTextColor = Color(0xFF30394F); // Fallback for light theme text if needed

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  // --- Local State Variables (excluding theme state) ---
  bool _remindersEnabled = true; // Example: Default to true
  bool _streakTrackerEnabled = false;
  bool _shareProgressEnabled = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Arabic']; // Add more as needed

  // --- Logout Function (with Dialog) ---
  Future<void> _logout() async {
    // Get theme data *before* showing the dialog to style it correctly
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
    final dialogBgColor = theme.dialogTheme.backgroundColor ?? theme.dialogBackgroundColor;
    final dialogTextColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final destructiveActionColor = isDark ? Colors.redAccent[100] : Colors.red;

    try {
      // Show confirmation dialog
      final bool? confirmLogout = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // User must explicitly choose an option
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            title: Text('Confirm Logout', style: TextStyle(color: dialogTextColor)),
            content: Text('Are you sure you want to log out?', style: TextStyle(color: dialogTextColor)),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel', style: TextStyle(color: dialogTextColor?.withOpacity(0.8))),
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false
                },
              ),
              TextButton(
                child: Text('Log Out', style: TextStyle(color: destructiveActionColor, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true
                },
              ),
            ],
          );
        },
      );

      // Proceed only if user confirmed
      if (confirmLogout == true) {
        await FirebaseAuth.instance.signOut();
        // Check if the widget is still mounted before navigating
        if (mounted) {
          // Navigate to Login Screen and remove all previous routes
          // *** IMPORTANT: Make sure '/login' is defined in your MaterialApp routes ***
          // If not, use the MaterialPageRoute alternative.
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login', // Use your actual LOGIN route name
            (Route<dynamic> route) => false, // Remove all routes below
          );
          // --- Alternative if '/login' route is not defined ---
          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(builder: (context) => const LoginScreen()),
          //   (Route<dynamic> route) => false,
          // );
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Error during logout: ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.message ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("An unexpected error occurred during logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred during logout.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // --- END LOGOUT FUNCTION ---


  @override
  Widget build(BuildContext context) {
    // Access ThemeNotifier and Theme data
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);
    final bool isDark = themeNotifier.isDarkMode;

    // --- Theme-Aware Colors ---

    // General Theme Colors from Theme Data (more robust)
    final Color currentScaffoldBg = theme.scaffoldBackgroundColor;
    final Color currentAppBarFgColor = theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : Colors.black);
    final Color currentSectionTitleColor = theme.textTheme.titleSmall?.color ?? (isDark ? Colors.grey[400]! : Colors.black54); // Use titleSmall for section titles
    final Color currentCardColor = theme.cardColor; // Use for group backgrounds in dark mode
    final Color currentBodyTextColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black); // General text
    final Color currentHintTextColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.grey[400]! : Colors.grey[600]!); // For less important text/icons
    final Color currentDividerColorTheme = theme.dividerColor;
    final Color currentDropdownPopupBgColor = theme.popupMenuTheme.color ?? theme.cardColor; // Background of the dropdown menu itself
    final Color currentDropdownItemFgColor = theme.popupMenuTheme.textStyle?.color ?? currentBodyTextColor; // Text color inside the dropdown menu

    // Colors for Settings Groups/Buttons (derived from theme)
    final Color currentSettingsGroupBg = isDark
        ? currentCardColor    // Use theme's card color for dark mode groups
        : baseBlueColor;      // Keep original blue for light mode groups

    final Color currentSettingsGroupFg = isDark
        ? currentHintTextColor  // Use hint text color (lighter grey) for dark groups
        : Colors.white;       // Keep original white for light mode (blue background)

    final Color currentDividerColor = isDark
        ? currentDividerColorTheme // Use theme divider color in dark mode
        : currentSettingsGroupFg.withOpacity(0.3); // Use FG-derived divider in light mode (white on blue)

    // Toggle Switch Colors (Derived from theme or FG color)
    final Color currentActiveThumbColor = theme.colorScheme.primary; // Use primary color for active toggle
    final Color currentActiveTrackColor = theme.colorScheme.primary.withOpacity(0.5);
    final Color currentInactiveThumbColor = isDark ? Colors.grey.shade600 : currentSettingsGroupFg.withOpacity(0.7); // Different inactive for dark
    final Color currentInactiveTrackColor = isDark ? Colors.grey.shade800 : currentSettingsGroupFg.withOpacity(0.2); // Different inactive track for dark


    // --- END THEME-AWARE COLORS ---


    return Scaffold(
      // Background color handled by theme
      backgroundColor: currentScaffoldBg,
      appBar: AppBar(
        // Use theme settings for AppBar
        elevation: 0, // Optional: remove shadow
        title: Row(
          children: [
            Icon(Icons.settings_outlined, color: currentAppBarFgColor, size: 28),
            const SizedBox(width: 10),
            Text(
                "Settings",
                 style: theme.appBarTheme.titleTextStyle?.copyWith(color: currentAppBarFgColor, fontSize: 22) // Use theme style
            ),
          ],
        ),
        automaticallyImplyLeading: false, // Assuming settings is a root tab
      ),
      // --- Use your Bottom Navigation Bar ---
      // Ensure AppBottomNavBar is also theme-aware if necessary
      bottomNavigationBar: const AppBottomNavBar(),

      // Body uses theme background implicitly via Scaffold
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Account Settings Section ---
              _buildSectionTitle("Account Settings", currentSectionTitleColor),
              _buildSettingsGroupContainer(
                backgroundColor: currentSettingsGroupBg,
                children: [
                  _buildSettingsRow("Name", fgColor: currentSettingsGroupFg, hintColor: currentSettingsGroupFg.withOpacity(0.7), dividerColor: currentDividerColor, onTap: () => _handleTap("Name")),
                  _buildSettingsRow("Gender", fgColor: currentSettingsGroupFg, hintColor: currentSettingsGroupFg.withOpacity(0.7), dividerColor: currentDividerColor, onTap: () => _handleTap("Gender")),
                  _buildSettingsRow("Birth date", fgColor: currentSettingsGroupFg, hintColor: currentSettingsGroupFg.withOpacity(0.7), dividerColor: currentDividerColor, onTap: () => _handleTap("Birth date")),
                  _buildSettingsRow("Use of any substance", fgColor: currentSettingsGroupFg, hintColor: currentSettingsGroupFg.withOpacity(0.7), dividerColor: currentDividerColor, onTap: () => _handleTap("Substance Use")),
                  _buildSettingsRow("Email", fgColor: currentSettingsGroupFg, hintColor: currentSettingsGroupFg.withOpacity(0.7), dividerColor: currentDividerColor, onTap: () => _handleTap("Email")),
                  _buildSettingsRow("Password", fgColor: currentSettingsGroupFg, hintColor: currentSettingsGroupFg.withOpacity(0.7), dividerColor: currentDividerColor, onTap: () => _handleTap("Password")),
                  _buildSettingsRow("Two-Factor Authentication", fgColor: currentSettingsGroupFg, hintColor: currentSettingsGroupFg.withOpacity(0.7), isLast: true, onTap: () => _handleTap("2FA")), // No divider for last
                ],
              ),
              const SizedBox(height: 25),

              // --- Notification Section ---
              _buildSectionTitle("Notification", currentSectionTitleColor),
              _buildSettingsGroupContainer(
                 backgroundColor: currentSettingsGroupBg,
                 children: [
                  _buildSettingsToggleRow(
                    "Reminders (activity/medicine)",
                    _remindersEnabled,
                    (value) => setState(() => _remindersEnabled = value),
                    fgColor: currentSettingsGroupFg, // Text color
                    dividerColor: currentDividerColor,
                    // Pass themed toggle colors
                    activeThumbColor: currentActiveThumbColor,
                    activeTrackColor: currentActiveTrackColor,
                    inactiveThumbColor: currentInactiveThumbColor,
                    inactiveTrackColor: currentInactiveTrackColor,
                  ),
                  _buildSettingsToggleRow(
                    "Streak Tracker",
                    _streakTrackerEnabled,
                    (value) => setState(() => _streakTrackerEnabled = value),
                    fgColor: currentSettingsGroupFg, // Text color
                    isLast: true, // No divider
                    // Pass themed toggle colors
                    activeThumbColor: currentActiveThumbColor,
                    activeTrackColor: currentActiveTrackColor,
                    inactiveThumbColor: currentInactiveThumbColor,
                    inactiveTrackColor: currentInactiveTrackColor,
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- App Preferences Section ---
              _buildSectionTitle("App Preferences", currentSectionTitleColor),
              _buildSettingsGroupContainer(
                 backgroundColor: currentSettingsGroupBg,
                 children: [
                  _buildSettingsToggleRow(
                    "Dark Mode", // Simpler label
                    themeNotifier.isDarkMode,
                    (value) {
                      themeNotifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    },
                     fgColor: currentSettingsGroupFg, // Text color
                     dividerColor: currentDividerColor,
                     // Pass themed toggle colors
                     activeThumbColor: currentActiveThumbColor,
                     activeTrackColor: currentActiveTrackColor,
                     inactiveThumbColor: currentInactiveThumbColor,
                     inactiveTrackColor: currentInactiveTrackColor,
                  ),
                  _buildLanguageDropdownRow(
                    "Language",
                    _selectedLanguage,
                    _languages,
                    (newValue) {
                      if (newValue != null && newValue != _selectedLanguage) {
                         setState(() => _selectedLanguage = newValue);
                         // TODO: Implement actual language change logic here
                         print("Language changed to: $newValue. Implement app localization.");
                      }
                    },
                    isLast: true, // No divider
                    fgColor: currentSettingsGroupFg, // Label and selected item color
                    hintColor: currentSettingsGroupFg.withOpacity(0.7), // Arrow color
                    dropdownPopupBgColor: currentDropdownPopupBgColor, // Menu background
                    dropdownItemFgColor: currentDropdownItemFgColor  // Menu item text color
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- Self Assessment Section ---
              _buildSectionTitle("Self Assessment", currentSectionTitleColor),
              _buildSettingsButton(
                  "Edit Self Assessment",
                  () => _handleTap("Edit Self Assessment"),
                  bgColor: currentSettingsGroupBg,
                  fgColor: currentSettingsGroupFg,
                  showArrow: true
              ),
              const SizedBox(height: 25),

              // --- Progress Sharing Section ---
              _buildSectionTitle("Progress Sharing", currentSectionTitleColor), // Corrected typo
               _buildSettingsGroupContainer(
                 backgroundColor: currentSettingsGroupBg,
                 children: [
                  _buildSettingsToggleRow(
                    "Share Progress with Dr.", // Slightly better phrasing
                     _shareProgressEnabled,
                    (value) => setState(() => _shareProgressEnabled = value),
                    fgColor: currentSettingsGroupFg, // Text color
                    isLast: true, // No divider
                    // Pass themed toggle colors
                    activeThumbColor: currentActiveThumbColor,
                    activeTrackColor: currentActiveTrackColor,
                    inactiveThumbColor: currentInactiveThumbColor,
                    inactiveTrackColor: currentInactiveTrackColor,
                  ),
                ],
              ),
              const SizedBox(height: 25),

               // --- Contact Support Section ---
              _buildSectionTitle("Contact Support", currentSectionTitleColor),
              _buildSettingsButton(
                "Call App Support", // Slightly better phrasing
                 () => _handleTap("Call Support"),
                bgColor: currentSettingsGroupBg,
                fgColor: currentSettingsGroupFg,
                icon: Icons.phone_outlined
              ),
              const SizedBox(height: 35),

               // --- Log Out Section ---
              Center(
                child: _buildSettingsButton(
                  "Log out",
                  _logout, // Calls the function with the confirmation dialog
                  bgColor: currentSettingsGroupBg,
                  fgColor: currentSettingsGroupFg,
                  isLogout: true // Keeps the specific styling for logout button
                ),
              ),
              const SizedBox(height: 30), // More padding at the bottom
            ],
          ),
        ),
      ),
    );
  } // End build

  // --- Helper Widgets (Updated for Theme Colors and Dividers) ---

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 5.0, top: 10.0), // Added top padding
      child: Text(
        title.toUpperCase(), // Optional: Uppercase for emphasis
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: textColor, // Uses passed theme color
            fontWeight: FontWeight.w600, // Make slightly bolder than default titleSmall
            letterSpacing: 0.8, // Optional spacing
        ) ?? TextStyle( // Fallback style
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsGroupContainer({required List<Widget> children, required Color backgroundColor}) {
     final isDark = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
     final theme = Theme.of(context);
     return Container(
      decoration: BoxDecoration(
        color: backgroundColor, // Uses passed theme color
        borderRadius: BorderRadius.circular(15.0),
        // Use theme's shadow or border definition
        border: isDark ? Border.all(color: theme.dividerColor.withOpacity(0.5), width: 0.5) : null,
        boxShadow: isDark ? null : (theme.cardTheme.shadowColor != null ? [
            BoxShadow(
                color: theme.cardTheme.shadowColor!,
                // *** FIXED num to int/double issue ***
                spreadRadius: theme.cardTheme.elevation?.toDouble() ?? 1.0,
                blurRadius: (theme.cardTheme.elevation?.toDouble() ?? 0.0) == 0.0 ? 0.0 : (theme.cardTheme.elevation?.toDouble() ?? 5.0) * 2.0,
                offset: const Offset(0, 2),
            )
          ] : [ // Default light shadow if theme doesn't specify
             BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1.0, // Use double
                blurRadius: 5.0,  // Use double
                offset: const Offset(0, 2),
            ),
          ]),
      ),
      child: ClipRRect( // Ensures children conform to rounded corners
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // Updated to include optional divider and hintColor for arrow
  Widget _buildSettingsRow(String title, {required Color fgColor, required Color hintColor, Color? dividerColor, bool isLast = false, required VoidCallback onTap}) {
    return Material( // Needed for InkWell splash effect
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( // Allow text to wrap if long
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 15,
                          color: fgColor, // Use passed theme color
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
                  ),
                  const SizedBox(width: 8), // Space before arrow
                  Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: hintColor // Use hint color for arrow
                  ),
                ],
              ),
            ),
            if (!isLast && dividerColor != null) // Add divider if not last and color provided
              _buildDivider(color: dividerColor, indent: 16, endIndent: 16),
          ],
        ),
      ),
    );
  }

  // Updated to include optional divider and accept themed toggle colors
  Widget _buildSettingsToggleRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    required Color fgColor, // Text color
    Color? dividerColor,    // Divider color
    bool isLast = false,
    // Themed toggle colors
    required Color activeThumbColor,
    required Color activeTrackColor,
    required Color inactiveThumbColor,
    required Color inactiveTrackColor,
  }) {
     // Use Material for splash effect on the row (optional)
     return Material(
       color: Colors.transparent,
       child: InkWell(
         // Optional: Tapping the row toggles the switch
         onTap: () => onChanged(!value),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8), // Adjusted padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Expanded( // Allow text to wrap if needed
                     child: Text(
                       title,
                       style: TextStyle(
                          fontSize: 15,
                          color: fgColor, // Use passed theme color
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   const SizedBox(width: 10), // Space before toggle
                  Transform.scale(
                    scale: 0.85, // Make switch slightly smaller
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: value,
                      onChanged: onChanged, // Direct interaction still works
                      activeColor: activeThumbColor, // Thumb color when ON
                      activeTrackColor: activeTrackColor, // Track color when ON
                      inactiveThumbColor: inactiveThumbColor, // Thumb color when OFF
                      inactiveTrackColor: inactiveTrackColor, // Track color when OFF
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Minimize tap area slightly
                    ),
                  ),
                ],
              ),
             ),
             if (!isLast && dividerColor != null) // Add divider if not last and color provided
                _buildDivider(color: dividerColor, indent: 16, endIndent: 16),
           ],
         ),
       ),
     );
  }

 // Updated to include optional divider and themed dropdown colors
  Widget _buildLanguageDropdownRow(
      String title,
      String currentValue,
      List<String> items,
      ValueChanged<String?> onChanged,
      { required Color fgColor, // Label color and selected item color
        required Color hintColor, // Arrow icon color
        Color? dividerColor, // Divider color
        required Color dropdownPopupBgColor, // Background of the menu
        required Color dropdownItemFgColor, // Text color inside the menu
        bool isLast = false})
  {
      final theme = Theme.of(context);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 10, top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 15,
                      color: fgColor, // Use passed theme color for label
                      fontWeight: FontWeight.w500),
                ),
                // Dropdown wrapped in Theme to control its popup menu color
                Theme(
                  data: theme.copyWith(
                    canvasColor: dropdownPopupBgColor, // Sets background of the dropdown menu
                    // Use splash/highlight from the main theme or override if needed
                    splashColor: theme.splashColor,
                    highlightColor: theme.highlightColor,
                    popupMenuTheme: theme.popupMenuTheme.copyWith( // Ensure popup inherits theme
                      color: dropdownPopupBgColor,
                      textStyle: theme.popupMenuTheme.textStyle?.copyWith(color: dropdownItemFgColor)
                                  ?? TextStyle(color: dropdownItemFgColor, fontSize: 15, fontWeight: FontWeight.w500)
                    )
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentValue,
                      icon: Icon(Icons.keyboard_arrow_down, color: hintColor), // Use hint color for icon
elevation: (theme.popupMenuTheme.elevation ?? 2.0).toInt(), // Convert double? or fallback double to int                      // Style for the items *inside* the dropdown menu
                      style: theme.popupMenuTheme.textStyle?.copyWith(color: dropdownItemFgColor)
                             ?? TextStyle(color: dropdownItemFgColor, fontSize: 15, fontWeight: FontWeight.w500),

                      // Builder for the *selected* item displayed when dropdown is closed
                      selectedItemBuilder: (BuildContext context) {
                        return items.map<Widget>((String item) {
                          return Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Text(
                                  item,
                                  style: TextStyle( // Use main FG color for selected item text
                                      color: fgColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ));
                        }).toList();
                      },
                      onChanged: onChanged,
                      items: items.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value), // Text uses the 'style' defined above
                        );
                      }).toList(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast && dividerColor != null) // Add divider if not last and color provided
              _buildDivider(color: dividerColor, indent: 16, endIndent: 16),
        ],
      );
  }

 // *** REVISED VERSION ***
 // Updated to use passed theme colors and corrected styling approach
 Widget _buildSettingsButton(
     String text,
     VoidCallback onPressed,
     {required Color bgColor, // Use passed theme color
     required Color fgColor, // Use passed theme color
     IconData? icon,
     bool showArrow = false,
     bool isLogout = false})
 {
    final isDark = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
    final theme = Theme.of(context);

    // Get the base theme style, if any
    final ButtonStyle? baseThemeStyle = theme.elevatedButtonTheme.style;

    // Create the final style by potentially merging our overrides onto the base
    // Use copyWith on the base style (or an empty one if base is null)
    final ButtonStyle finalStyle = (baseThemeStyle ?? const ButtonStyle())
        .copyWith(
            backgroundColor: WidgetStateProperty.all(bgColor), // Simple override
            foregroundColor: WidgetStateProperty.all(fgColor), // Simple override
            shadowColor: WidgetStateProperty.all(Colors.black26),
            minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
            shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isLogout ? 25 : 15),
                )
            ),
            splashFactory: InkRipple.splashFactory,

            // *** DEFINE STATE PROPERTIES USING WidgetStateProperty.resolveWith ***
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
               (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                     // Use the foreground color with some opacity for the splash effect
                     return fgColor.withOpacity(0.12);
                  }
                  // Return null for default behavior in other states
                  return null;
               },
            ),
            elevation: WidgetStateProperty.resolveWith<double?>( // Ensure nullable double
               (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                     return 0.0; // Flatten the button when pressed
                  }
                  // Apply a subtle elevation based on light/dark mode
                  return isDark ? 1.0 : 2.0;
               },
            ),
     ); // End of copyWith

    return ElevatedButton(
      style: finalStyle, // Apply the final merged style
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Always space between for consistency
        children: [
          // If icon exists, place it first
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, size: 20, color: fgColor), // Icon color matches foreground
            )
          else
            // Add SizedBox to balance row if there's an arrow on the right but no icon here
            SizedBox(width: showArrow ? (IconTheme.of(context).size ?? 16.0) + 8.0 : 0),

          // Center the text
          Expanded(
            child: Text(
              text,
              textAlign: icon == null && !showArrow ? TextAlign.center : TextAlign.left, // Center only if no icons/arrows
              // Text style is primarily controlled by 'foregroundColor' in the style
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
            ),
          ),

          // Show arrow if requested
          if (showArrow)
             Padding(
               padding: const EdgeInsets.only(left: 8.0),
               child: Icon(
                 Icons.arrow_forward_ios,
                 size: 16,
                 // Use foreground color with opacity for the arrow hint
                 color: fgColor.withOpacity(0.7)
               ),
             )
           else if (icon == null)
            // Add SizedBox to balance row if there's an icon on the left but no arrow here
             const SizedBox(width: 0),
        ],
      ),
    );
 }


  // Updated to allow indent/endIndent and use theme defaults potentially
  Widget _buildDivider({required Color color, double indent = 0, double endIndent = 0}) {
    final theme = Theme.of(context);
    return Divider(
      height: theme.dividerTheme.space ?? 0.8,
      thickness: theme.dividerTheme.thickness ?? 0.5,
      color: color, // Use passed color override
      indent: indent,
      endIndent: endIndent,
    );
  }

  // --- Navigation/Action Handler ---
  void _handleTap(String setting) {
    print("Tapped on: $setting");
    // TODO: Implement navigation or actions for each settings item
  }

} // End of _UserSettingsScreenState