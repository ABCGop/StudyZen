import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF4A90E2),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4A90E2),
        secondary: Color(0xFF9B59B6),
        surface: Colors.white,
        background: Color(0xFFF5F7FA),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF2C3E50),
        onBackground: Color(0xFF2C3E50),
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF4A90E2),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4A90E2),
        secondary: Color(0xFF9B59B6),
        surface: Color(0xFF2D2D2D),
        background: Color(0xFF1A1A1A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      cardTheme: const CardTheme(
        color: Color(0xFF2D2D2D),
        elevation: 4,
        shadowColor: Colors.black54,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
