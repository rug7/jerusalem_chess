
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import '../main_screens/color_option_screen.dart';

class ThemeLanguageProvider with ChangeNotifier {
  bool _isLightMode = true;
  String _currentLanguage = 'Arabic';
  bool _useSystemTheme = true; // New flag to check if we should use the system theme

  ThemeLanguageProvider() {
    _initializeTheme();
  }

  void _initializeTheme() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    _isLightMode = brightness == Brightness.light;
  }
  bool get isLightMode => _isLightMode;
  String get currentLanguage => _currentLanguage;
  bool get useSystemTheme => _useSystemTheme;

  void toggleThemeMode() {
    _useSystemTheme = false; // Once user toggles theme, don't use system theme
    _isLightMode = !_isLightMode;
    notifyListeners();
  }

  void setUseSystemTheme(bool value) {
    _useSystemTheme = value;
    if (_useSystemTheme) {
      _initializeTheme(); // Re-initialize theme to reflect system settings
    }
    notifyListeners();
  }

  void changeLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }
}
