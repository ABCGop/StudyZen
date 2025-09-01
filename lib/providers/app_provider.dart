import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _selectedClass = 6;
  int _currentBottomNavIndex = 1; // Default to Home screen (center button)
  String _selectedSubject = 'Math';
  bool _isLoading = false;

  // Getters
  int get selectedClass => _selectedClass;
  int get currentBottomNavIndex => _currentBottomNavIndex;
  String get selectedSubject => _selectedSubject;
  bool get isLoading => _isLoading;

  // Available classes
  List<int> get availableClasses => List.generate(7, (index) => index + 6);

  // Available subjects with gradients like the image
  List<Map<String, dynamic>> get availableSubjects => [
    {
      'name': 'Math',
      'icon': Icons.calculate,
      'color': const Color(0xFF6366F1),
    },
    {
      'name': 'Science',
      'icon': Icons.science,
      'color': const Color(0xFF10B981),
    },
    {
      'name': 'History',
      'icon': Icons.account_balance,
      'color': const Color(0xFFEF4444),
    },
    {
      'name': 'English',
      'icon': Icons.menu_book,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'Geography',
      'icon': Icons.public,
      'color': const Color(0xFFF59E0B),
    },
    {
      'name': 'Physics',
      'icon': Icons.electrical_services,
      'color': const Color(0xFF06B6D4),
    },
    {
      'name': 'Chemistry',
      'icon': Icons.biotech,
      'color': const Color(0xFFEC4899),
    },
    {
      'name': 'Biology',
      'icon': Icons.eco,
      'color': const Color(0xFF84CC16),
    },
  ];

  // Methods
  void setSelectedClass(int classNumber) {
    if (classNumber >= 6 && classNumber <= 12) {
      _selectedClass = classNumber;
      notifyListeners();
    }
  }

  void setCurrentBottomNavIndex(int index) {
    // Ensure index is within bounds for 3-tab navigation
    if (index >= 0 && index < 3) {
      _currentBottomNavIndex = index;
      notifyListeners();
    }
  }

  void setSelectedSubject(String subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get subjects available for a specific class
  List<Map<String, dynamic>> getSubjectsForClass(int classNumber) {
    if (classNumber <= 8) {
      return availableSubjects.take(4).toList(); // Basic subjects for lower classes
    } else {
      return availableSubjects; // All subjects for higher classes
    }
  }
}
