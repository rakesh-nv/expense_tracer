import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeBox = 'theme_box';
  static const String _isDarkMode = 'is_dark_mode';
  static const String _primaryColor = 'primary_color';

  late Box _box;
  bool _darkMode = false;
  Color _color = Colors.blue;

  ThemeProvider() {
    _initializeTheme();
  }

  bool get isDarkMode => _darkMode;
  Color get primaryColor => _color;

  Future<void> _initializeTheme() async {
    _box = await Hive.openBox(_themeBox);
    _loadTheme();
  }

  void _loadTheme() {
    _darkMode = _box.get(_isDarkMode, defaultValue: false);
    final colorValue = _box.get(_primaryColor, defaultValue: Colors.blue.value);
    _color = Color(colorValue);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _darkMode = !_darkMode;
    await _box.put(_isDarkMode, _darkMode);
    notifyListeners();
  }

  Future<void> updatePrimaryColor(Color color) async {
    _color = color;
    await _box.put(_primaryColor, color.value);
    notifyListeners();
  }

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: _darkMode ? Brightness.dark : Brightness.light,
      primaryColor: _color,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _color,
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }
}
