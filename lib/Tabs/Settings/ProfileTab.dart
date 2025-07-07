import 'package:flutter/material.dart';
import 'package:shop_n_goo/AppTheme.dart';
import 'Edit_Profile.dart';
import 'About_us.dart';
import 'Privacy_policy.dart';
import 'package:provider/provider.dart';
import 'SettingsProvider.dart';
import 'package:shop_n_goo/data/data_sources/auth_local_data_source.dart';
import 'package:shop_n_goo/data/data_sources/shopping_data_source.dart';
import 'package:shop_n_goo/Tabs/Settings/VisaManagementPage.dart';
import 'package:shop_n_goo/Tabs/Settings/PhoneNumberManagementPage.dart';
import 'package:dio/dio.dart';
import 'package:shop_n_goo/api_constants.dart';
import 'package:shop_n_goo/ui_utils.dart';
import 'package:shop_n_goo/Tabs/Settings/Personal_Offers.dart';

class Profiletab extends StatefulWidget {
  static const String routeName = "Profiletab";

  @override
  State<Profiletab> createState() => _ProfiletabState();
}

class _ProfiletabState extends State<Profiletab> {
  List<Language> languages = [
    Language(name: "English", code: "En"),
    Language(name: "العربيه", code: "Er"),
  ];
  
  String? firstName;
  String? lastName;
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final ShoppingDataSource _shoppingDataSource = ShoppingDataSource();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Always fetch fresh user data from backend
      try {
        final token = await _authLocalDataSource.getToken();
        final response = await _shoppingDataSource.getUserProfile(token);
        print('DEBUG: Fetched from backend - response: $response');
        
        // Handle nested user object structure
        final userData = response['user'] ?? response;
        final backendFirstName = userData['firstName'] ?? '';
        final backendLastName = userData['lastName'] ?? '';
        
        // Update local storage with backend data
        await _authLocalDataSource.saveUserData(backendFirstName, backendLastName);
        
        setState(() {
          firstName = backendFirstName;
          lastName = backendLastName;
        });
        print('DEBUG: Updated with backend data - firstName: "$backendFirstName", lastName: "$backendLastName"');
      } catch (e) {
        print('DEBUG: Failed to fetch from backend: $e');
        // Fall back to local storage data
        final fName = await _authLocalDataSource.getFirstName();
        final lName = await _authLocalDataSource.getLastName();
        print('DEBUG: Fallback to local storage - firstName: "$fName", lastName: "$lName"');
        setState(() {
          firstName = fName;
          lastName = lName;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Call backend logout endpoint
        try {
          String token = await _authLocalDataSource.getToken();
          await _dio.post(
            ApiConstants.baseUrl + 'auth/logout',
            options: Options(headers: {"Authorization": "Bearer $token"}),
          );
        } catch (e) {
          // Continue with logout even if backend call fails
          print('Backend logout failed: $e');
        }

        // Clear local data
        await _authLocalDataSource.logout();
        
        // Show success message
        UIUtils.showMessage('Logged out successfully');
        
        // Navigate to first screen (login)
        Navigator.pushNamedAndRemoveUntil(context, 'FirstScreen', (route) => false);
      }
    } catch (e) {
      UIUtils.showMessage('Logout failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingProvider = Provider.of<SettingProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.Bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.06),
          // child: Icon(Icons.settings, color: AppTheme.darkGreen),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: AppTheme.darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.07,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: ListView(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.08,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: screenWidth * 0.1, color: AppTheme.white),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(
                    "${firstName ?? 'User'}${lastName != null && lastName!.isNotEmpty ? ' $lastName' : ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.055,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.08),

            // Account Settings
            Text(
              "Account Settings",
              style: TextStyle(
                color: Color(0xFF808080),
                fontSize: screenWidth * 0.035,
              ),
            ),
            SizedBox(height: screenWidth * 0.025),

            buildListTile(
              "Edit Profile",
              AppTheme.darkGreen,
              onTap: () async {
                await Navigator.pushNamed(context, EditProfile.routeName);
                // Refresh user data when returning from edit profile
                _loadUserData();
              },
              fontSize: screenWidth * 0.04,
            ),

            // New: Manage Visas
            buildListTile(
              "Manage Visas",
              AppTheme.darkGreen,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VisaManagementPage()),
                );
              },
              fontSize: screenWidth * 0.04,
            ),

            // New: Manage Phone Number
            buildListTile(
              "Manage Phone Number",
              AppTheme.darkGreen,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneNumberManagementPage()),
                );
              },
              fontSize: screenWidth * 0.04,
            ),

            // New: Personal Offers
            buildListTile(
              "Personal Offers",
              AppTheme.darkGreen,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonalOffersPage()),
                );
              },
              fontSize: screenWidth * 0.04,
            ),

            SizedBox(height: screenWidth * 0.02),

            // Language Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Language ',
                  style: TextStyle(color: AppTheme.darkGreen, fontSize: screenWidth * 0.04),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Language>(
                    value: languages.first,
                    items: languages
                        .map((language) => DropdownMenuItem<Language>(
                      value: language,
                      child: Text(language.name),
                    ))
                        .toList(),
                    onChanged: (selectedLanguage) {},
                  ),
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.02),

            // Allow Notification Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allow Notification',
                  style: TextStyle(color: AppTheme.darkGreen, fontSize: screenWidth * 0.04),
                ),
                Switch(
                  value: settingProvider.allowNotification,
                  onChanged: (value) {
                    settingProvider.toggleNotification(value);
                  },
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.02),

            // Dark Mode Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode', style: TextStyle(color: AppTheme.darkGreen, fontSize: screenWidth * 0.04)),
                Switch(
                  value: settingProvider.themeMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    settingProvider.ChangeTheme(isDark ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.08),

            // More
            Text(
              "More",
              style: TextStyle(
                color: Color(0xFF808080),
                fontSize: screenWidth * 0.035,
              ),
            ),
            SizedBox(height: screenWidth * 0.025),

            buildListTile(
              "About us",
              AppTheme.darkGreen,
              fontSize: screenWidth * 0.04,
              onTap: () {
                Navigator.pushNamed(context, AboutUs.routeName);
              },
            ),
            buildListTile(
              "Privacy Policy",
              AppTheme.darkGreen,
              fontSize: screenWidth * 0.04,
              onTap: () {
                Navigator.pushNamed(context, PrivacyPolicy.routeName);
              },
            ),

            SizedBox(height: screenWidth * 0.08),

            // Logout Section
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(String title, Color color,
      {IconData icon = Icons.chevron_right, VoidCallback? onTap, double fontSize = 16}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        title,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      trailing: Icon(icon, color: color),
      onTap: onTap,
    );
  }
}

class Language {
  String name;
  String code;

  Language({required this.name, required this.code});
}
