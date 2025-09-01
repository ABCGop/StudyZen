// Firebase Configuration
class FirebaseConfig {
  // Firebase project configuration will be handled by firebase_options.dart
  // Project Information
  static const String projectId = 'eduai-76660';
  
  // Collections
  static const String usersCollection = 'users';
  static const String notesCollection = 'notes';
  static const String subjectsCollection = 'subjects';
  
  // Demo users for testing
  static final List<Map<String, dynamic>> demoUsers = [
    {
      'id': 'demo1',
      'name': 'Demo Student',
      'email': 'demo@eduai.com',
      'class': 10,
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'demo2',
      'name': 'Test User',
      'email': 'test@eduai.com',
      'class': 12,
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];
}
