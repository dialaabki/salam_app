import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
// Ensure this path is correct for your project structure
import '../../providers/theme_provider.dart'; // Import your ThemeNotifier

// --- Define Colors (Some might be fixed, others derived from theme) ---
// These might be specific to the design and not fully theme-dependent
const Color mainAppColor = Color(0xFF5588A4); // Base blue color, also used as primary in themes
const Color rowItemColor = Colors.white; // Fixed Text/icon color inside the blue rows
const Color rowBackgroundColor = Color(0xFF5588A4); // Fixed Background for the blue grouped rows/buttons

// You can still define fallback colors if needed, but theme is preferred
const Color darkTextColor = Color(0xFF30394F); // Defined via ThemeData
const Color lightTextColor = Color(0xFF6A7185); // Defined via ThemeData
const Color lightBgColor = Colors.white;      // Defined via ThemeData

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  // --- Local State Variables (excluding theme state) ---
  bool _remindersEnabled = false; // Example initial state (matches image)
  bool _streakTrackerEnabled = false; // Example initial state (matches image)
  bool _shareProgressEnabled = false; // Example initial state (matches image)
  String _selectedLanguage = 'English'; // Example initial state (matches image)
  final List<String> _languages = ['English', 'Arabic']; // Example options (matches image)

  @override
  Widget build(BuildContext context) {
    // Access the ThemeNotifier using Provider
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final bool isDark = themeNotifier.isDarkMode;

    // Get colors from the current theme for adaptive UI elements
    final Color currentScaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color currentAppBarColor = Theme.of(context).appBarTheme.backgroundColor ?? mainAppColor; // Fallback
    final Color currentAppBarFgColor = Theme.of(context).appBarTheme.foregroundColor ?? Colors.white; // Fallback
    final Color currentSectionTitleColor = Theme.of(context).textTheme.titleMedium?.color ?? (isDark ? Colors.white70 : darkTextColor); // Fallback needed if textTheme isn't fully defined
    final Color currentDropdownBgColor = isDark ? Colors.grey[700]! : Colors.grey[200]!; // Specific color for dropdown popup
    final Color currentDropdownFgColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : darkTextColor); // Text color inside dropdown popup

    // Define colors for the specific blue container style (these might not change with theme)
    const Color settingsGroupBg = rowBackgroundColor;
    const Color settingsGroupFg = rowItemColor;

    return Scaffold(
      // backgroundColor: currentAppBarColor, // Optional: Match AppBar background area color
      appBar: AppBar(
        // Theme automatically handles AppBar colors based on light/darkTheme in main.dart
        title: Row(
          children: [
            Icon(Icons.settings_outlined, color: currentAppBarFgColor, size: 28),
            const SizedBox(width: 10),
            Text(
                "Settings",
                 style: TextStyle(
                   color: currentAppBarFgColor,
                   fontWeight: FontWeight.bold,
                   fontSize: 22,
                 )
            ),
          ],
        ),
        // Optional: Add back button if this screen is pushed onto the stack
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: currentAppBarFgColor),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      // Replace with your actual BottomNavBar if you have one
      bottomNavigationBar: const _DummyBottomNavBar(),
      body: Container(
        // This container provides the main content area background (usually white or dark grey)
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: currentScaffoldBg, // Use theme's scaffold background
          // Apply rounding only if AppBar is a different color, otherwise it blends
          borderRadius: currentAppBarColor != currentScaffoldBg
              ? const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                )
              : null,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Optional: Nice scroll physics
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Account Settings Section ---
                _buildSectionTitle("Account Settings", currentSectionTitleColor),
                _buildSettingsGroupContainer(
                  backgroundColor: settingsGroupBg,
                  children: [
                    _buildSettingsRow("Name", fgColor: settingsGroupFg, onTap: () => _handleTap("Name")),
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildSettingsRow("Gender", fgColor: settingsGroupFg, onTap: () => _handleTap("Gender")),
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildSettingsRow("Birth date", fgColor: settingsGroupFg, onTap: () => _handleTap("Birth date")),
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildSettingsRow("Use of any substance", fgColor: settingsGroupFg, onTap: () => _handleTap("Substance Use")),
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildSettingsRow("Email", fgColor: settingsGroupFg, onTap: () => _handleTap("Email")),
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildSettingsRow("Password", fgColor: settingsGroupFg, onTap: () => _handleTap("Password")),
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildSettingsRow("Two-Factor Authentication", fgColor: settingsGroupFg, isLast: true, onTap: () => _handleTap("2FA")),
                  ],
                ),
                const SizedBox(height: 25),

                // --- Notification Section ---
                _buildSectionTitle("Notification", currentSectionTitleColor),
                _buildSettingsGroupContainer(
                   backgroundColor: settingsGroupBg,
                   children: [
                    _buildSettingsToggleRow(
                      "Reminders (activity/medicine)",
                      _remindersEnabled,
                      (value) => setState(() => _remindersEnabled = value),
                      fgColor: settingsGroupFg // Use fixed white for items inside blue container
                    ),
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildSettingsToggleRow(
                      "Streak Tracker",
                      _streakTrackerEnabled,
                      (value) => setState(() => _streakTrackerEnabled = value),
                      isLast: true,
                      fgColor: settingsGroupFg // Use fixed white
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // --- App Preferences Section ---
                _buildSectionTitle("App Preferences", currentSectionTitleColor),
                _buildSettingsGroupContainer(
                   backgroundColor: settingsGroupBg,
                   children: [
                    // *** THEME TOGGLE ROW ***
                    _buildSettingsToggleRow(
                      "Light mode/Dark mode",
                      themeNotifier.isDarkMode, // <-- Read value from notifier
                      (value) {
                        // Update the theme via the notifier
                        themeNotifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      },
                       fgColor: settingsGroupFg // Use fixed white
                    ),
                    // *************************
                    _buildDivider(color: settingsGroupFg.withOpacity(0.3)),
                    _buildLanguageDropdownRow(
                      "Language",
                      _selectedLanguage,
                      _languages,
                      (newValue) {
                        if (newValue != null) {
                           setState(() => _selectedLanguage = newValue);
                           // TODO: Add logic to actually change app language here
                           // e.g., using EasyLocalization, GetX localization, or standard Intl
                           print("Language changed to: $newValue");
                           // Example: context.setLocale(Locale(newValue == 'English' ? 'en' : 'ar'));
                        }
                      },
                      isLast: true,
                      fgColor: settingsGroupFg, // Text 'Language' and selected item color
                      dropdownBgColor: currentDropdownBgColor, // Background of popup menu
                      dropdownFgColor: currentDropdownFgColor // Text color inside popup menu
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // --- Self Assessment Section ---
                _buildSectionTitle("Self Assessment", currentSectionTitleColor),
                _buildSettingsButton( // This button uses the blue style
                    "Edit Self Assessment",
                    () => _handleTap("Edit Self Assessment"),
                    bgColor: settingsGroupBg,
                    fgColor: settingsGroupFg,
                    showArrow: true
                ),
                const SizedBox(height: 25),

                // --- Progress Sharing Section ---
                _buildSectionTitle("Progress sharing", currentSectionTitleColor),
                 _buildSettingsGroupContainer(
                   backgroundColor: settingsGroupBg,
                   children: [
                    _buildSettingsToggleRow(
                      "share progress with Dr",
                       _shareProgressEnabled,
                      (value) => setState(() => _shareProgressEnabled = value),
                      isLast: true,
                      fgColor: settingsGroupFg // Use fixed white
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                 // --- Contact Support Section ---
                _buildSectionTitle("Contact Support", currentSectionTitleColor),
                _buildSettingsButton( // This button uses the blue style
                  "Call app support",
                   () => _handleTap("Call Support"),
                  bgColor: settingsGroupBg,
                  fgColor: settingsGroupFg,
                  icon: Icons.phone_outlined
                ),
                const SizedBox(height: 35),

                 // --- Log Out Section ---
                Center(
                  child: _buildSettingsButton( // This button uses the blue style
                    "Log out",
                    () => _handleTap("Log Out"),
                    // Consider a different color for logout for emphasis?
                    // bgColor: Colors.redAccent.withOpacity(0.8),
                    // fgColor: Colors.white,
                    bgColor: settingsGroupBg, // Sticking to blue for now
                    fgColor: settingsGroupFg,
                    isLogout: true // Might affect styling like border radius
                  ),
                ),
                const SizedBox(height: 20), // Padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  } // End build

  // --- Helper Widgets ---

  // Builds the title for a section (e.g., "Account Settings")
  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 5.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor), // Use themed color passed as argument
      ),
    );
  }

  // Builds the blue container with rounded corners for grouping settings items
  Widget _buildSettingsGroupContainer({required List<Widget> children, required Color backgroundColor}) {
     return Container(
      decoration: BoxDecoration(
        color: backgroundColor, // Use passed background color (likely fixed blue)
        borderRadius: BorderRadius.circular(15.0), // Match image rounding
      ),
      child: ClipRRect( // Clip children to rounded corners
        borderRadius: BorderRadius.circular(15.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // Builds a standard settings row with text and a right arrow
  Widget _buildSettingsRow(String title, {required Color fgColor, bool isLast = false, required VoidCallback onTap}) {
    return Material( // Use Material for InkWell splash effect
      color: Colors.transparent, // Inherit background from container
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), // Adjust padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 15,
                    color: fgColor, // Use passed foreground color (likely fixed white)
                    fontWeight: FontWeight.w500),
              ),
              Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: fgColor // Use passed foreground color (likely fixed white)
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds a settings row with text and a toggle switch
  Widget _buildSettingsToggleRow(String title, bool value, ValueChanged<bool> onChanged, {required Color fgColor, bool isLast = false}) {
     // Define toggle colors specifically for the blue container background
     final Color activeThumbColor = fgColor; // White thumb
     final Color activeTrackColor = fgColor.withOpacity(0.5); // Semi-transparent white track
     final Color inactiveThumbColor = fgColor.withOpacity(0.9); // Slightly dimmer white thumb
     final Color inactiveTrackColor = fgColor.withOpacity(0.3); // More transparent white track

     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), // Less vertical padding for toggles
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
             title,
             style: TextStyle(
                fontSize: 15,
                color: fgColor, // Use passed foreground color (likely fixed white)
                fontWeight: FontWeight.w500),
           ),
          Transform.scale( // Make switch slightly smaller if needed
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              // Use the specifically defined colors for contrast on blue background
              activeColor: activeThumbColor,
              activeTrackColor: activeTrackColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
              // Don't use theme colors here as they are designed for the general scaffold background
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
     );
  }

  // Builds the language selection row with a dropdown
  Widget _buildLanguageDropdownRow(
      String title,
      String currentValue,
      List<String> items,
      ValueChanged<String?> onChanged,
      {required Color fgColor,
      required Color dropdownBgColor, // Background color of the popup menu
      required Color dropdownFgColor, // Text color inside the popup menu
      bool isLast = false})
  {
      return Padding(
      padding: const EdgeInsets.only(left: 16, right: 10, top: 8, bottom: 8), // Adjust padding for dropdown alignment
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, // e.g., "Language"
            style: TextStyle(
                fontSize: 15,
                color: fgColor, // Use passed color (likely fixed white)
                fontWeight: FontWeight.w500),
          ),
          Theme( // Override dropdown theme specifically for popup background
            data: Theme.of(context).copyWith(
              canvasColor: dropdownBgColor, // Use theme-aware popup background color
            ),
            child: DropdownButtonHideUnderline( // Hide default underline
              child: DropdownButton<String>(
                value: currentValue,
                icon: Icon(Icons.keyboard_arrow_down, color: fgColor), // Arrow color (fixed white)
                elevation: 2,
                style: TextStyle( // Style for items in dropdown LIST
                    color: dropdownFgColor, // Use theme-aware text color for list items
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
                selectedItemBuilder: (BuildContext context) { // Style for the SELECTED item shown in the button itself
                  return items.map<Widget>((String item) {
                    return Align(
                        alignment: Alignment.centerRight,
                        child: Padding( // Add padding to prevent text touching arrow
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            item, // e.g., "English" or "Arabic"
                            style: TextStyle(
                                color: fgColor, // Use fixed white for selected item text
                                fontWeight: FontWeight.w500),
                          ),
                        ));
                  }).toList();
                },
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Text shown in the popup list
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the standalone buttons (Edit Self Assessment, Call Support, Logout)
 Widget _buildSettingsButton(
     String text,
     VoidCallback onPressed,
     {required Color bgColor, // Background color (likely fixed blue)
     required Color fgColor, // Text/Icon color (likely fixed white)
     IconData? icon,
     bool showArrow = false,
     bool isLogout = false})
 {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0, // Flat design like the image
        minimumSize: const Size(double.infinity, 50), // Full width, standard height
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          // Slightly more rounded for logout, or keep consistent
          borderRadius: BorderRadius.circular(isLogout ? 25 : 15),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        // For 'Edit' and 'Call', push icon/arrow to the right
        // For 'Logout', center the text (since no icon/arrow is expected)
        mainAxisAlignment: (icon != null || showArrow)
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          if (icon != null)
            Icon(icon, size: 20, color: fgColor) // Ensure icon uses fgColor
          else if (showArrow)
             Icon(Icons.arrow_forward_ios, size: 16, color: fgColor) // Ensure arrow uses fgColor
          // No else needed for logout as centering handles it
        ],
      ),
    );
  }

  // Helper to build the divider between items in a group
  Widget _buildDivider({required Color color}) {
    return Divider(
      height: 0.5, // Thin divider
      thickness: 0.5,
      color: color, // Use passed color (likely semi-transparent white)
      indent: 16, // Indent from the left edge
      endIndent: 16, // Indent from the right edge
    );
  }


  // Placeholder handler for taps - Implement actual navigation/actions here
  void _handleTap(String setting) {
    print("Tapped on: $setting");
    // Example Navigation:
    // if (setting == "Name") {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => EditNameScreen()));
    // } else if (setting == "Password") {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordScreen()));
    // } else if (setting == "Log Out") {
    //   // Show confirmation dialog
    //   showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text("Log Out"),
    //       content: Text("Are you sure you want to log out?"),
    //       actions: [
    //          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
    //          TextButton(onPressed: () {
    //             // Perform actual logout logic (clear session, navigate to login)
    //             Navigator.pop(context); // Close dialog
    //             // Example: Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    //             print("Logout action performed!");
    //          }, child: Text("Log Out")),
    //       ],
    //     )
    //   );
    // }
    // Add cases for other settings...
  }
} // End of _UserSettingsScreenState


// --- Dummy Bottom Nav Bar (Replace with your actual one) ---
// This is theme-aware
class _DummyBottomNavBar extends StatelessWidget {
  const _DummyBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use AppBar background color from theme for consistency
    final navBarColor = Theme.of(context).appBarTheme.backgroundColor;
    // Define an active/inactive color, potentially theme-aware
    final activeIconColor = Colors.lightBlueAccent; // Example: Fixed active color
    final inactiveIconColor = isDark ? Colors.grey[600] : Colors.white.withOpacity(0.7); // Example: Theme-aware inactive

    // Assume first icon is active for demo purposes
    return Container(
      height: 65, // Adjust height as needed
      color: navBarColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home_outlined, color: activeIconColor, size: 30), // Active
          Icon(Icons.access_time, color: inactiveIconColor, size: 30),
          Icon(Icons.assignment_outlined, color: inactiveIconColor, size: 30),
          Icon(Icons.book_outlined, color: inactiveIconColor, size: 30),
          Icon(Icons.person_outline, color: inactiveIconColor, size: 30), // Map this to profile route later
        ],
      ),
    );
  }
}