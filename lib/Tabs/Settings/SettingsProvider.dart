import 'package:flutter/material.dart';

class SettingProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  String languageCode = 'en' ;
  bool allowNotification = true;

  String get bg => themeMode == ThemeMode.light ? 'backgroundLight' : 'dark bg' ;

  void ChangeTheme(ThemeMode selectedTheme) {
    themeMode = selectedTheme ;
    notifyListeners() ;
  }

  void ChangeLanguage (String selectedlanguage) {
    languageCode = selectedlanguage ;
    notifyListeners() ;
  }


  void toggleNotification(bool value) {
    allowNotification = value;
    notifyListeners();
  }
}

