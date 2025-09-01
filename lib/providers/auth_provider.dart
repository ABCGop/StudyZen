import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/firebase_config.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuthStateListener();
    _loadUserSession();
  }

  // Initialize Firebase Auth state listener
  void _initAuthStateListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null && _currentUser == null) {
        _loadUserFromFirebase(user);
      } else if (user == null) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserFromFirebase(User user) async {
    print('🔵 Loading user data from Firestore for: ${user.uid}');
    try {
      final userDoc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(user.uid)
          .get();
      
      print('🔵 Firestore document exists: ${userDoc.exists}');
      if (userDoc.exists) {
        print('🔵 Firestore document data: ${userDoc.data()}');
        _currentUser = {
          'id': user.uid,
          'name': userDoc.data()?['name'] ?? user.displayName ?? 'User',
          'email': user.email ?? '',
          'class': userDoc.data()?['class'] ?? 10,
          'createdAt': userDoc.data()?['createdAt'],
        };
        print('🔵 Current user set: $_currentUser');
        await _saveUserSession(_currentUser!);
        notifyListeners();
        print('🔵 User loaded successfully');
      } else {
        print('🟡 No Firestore document found, using Firebase Auth data only');
        _currentUser = {
          'id': user.uid,
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'class': 10,
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _saveUserSession(_currentUser!);
        notifyListeners();
      }
    } catch (e) {
      print('🔴 Error loading user from Firebase: $e');
      if (kDebugMode) {
        print('Error loading user from Firebase: $e');
      }
      // Still set basic user data from Firebase Auth
      _currentUser = {
        'id': user.uid,
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'class': 10,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await _saveUserSession(_currentUser!);
      notifyListeners();
    }
  }

  // Load user session from SharedPreferences
  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null && _auth.currentUser != null) {
      try {
        _currentUser = Map<String, dynamic>.from(jsonDecode(userJson));
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Error loading user session: $e');
        }
      }
    }
  }

  // Save user session to SharedPreferences
  Future<void> _saveUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user));
  }

  // Clear user session
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  // Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int classNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create user with Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Save user data to Firestore
        final userData = {
          'name': name,
          'email': email,
          'class': classNumber,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection(FirebaseConfig.usersCollection)
            .doc(user.uid)
            .set(userData);

        // Set current user
        _currentUser = {
          'id': user.uid,
          'name': name,
          'email': email,
          'class': classNumber,
          'createdAt': DateTime.now().toIso8601String(),
        };

        await _saveUserSession(_currentUser!);
        _setLoading(false);
        notifyListeners();
        
        if (kDebugMode) {
          print('User registered successfully: ${user.email}');
        }
        return true;
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          errorMsg = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMsg = 'An account already exists for this email';
          break;
        case 'invalid-email':
          errorMsg = 'Please enter a valid email address';
          break;
        default:
          errorMsg = e.message ?? 'Registration failed';
      }
      _setError(errorMsg);
      if (kDebugMode) {
        print('Registration error: $errorMsg');
      }
    } catch (e) {
      _setError('An unexpected error occurred during registration');
      if (kDebugMode) {
        print('Unexpected registration error: $e');
      }
    }

    _setLoading(false);
    return false;
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    print('🔵 AuthProvider: Login started for $email');
    _setLoading(true);
    _clearError();

    try {
      print('🔵 AuthProvider: Calling Firebase signInWithEmailAndPassword');
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔵 AuthProvider: Firebase auth successful');
      final User? user = userCredential.user;
      if (user != null) {
        print('🔵 AuthProvider: User found: ${user.uid}');
        await _loadUserFromFirebase(user);
        _setLoading(false);
        
        if (kDebugMode) {
          print('User logged in successfully: ${user.email}');
        }
        print('🔵 AuthProvider: Login completed successfully');
        return true;
      } else {
        print('🔴 AuthProvider: User is null after successful auth');
      }
    } on FirebaseAuthException catch (e) {
      print('🔴 AuthProvider: Firebase auth exception: ${e.code} - ${e.message}');
      String errorMsg = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No account found for this email';
          break;
        case 'wrong-password':
          errorMsg = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMsg = 'Please enter a valid email address';
          break;
        case 'too-many-requests':
          errorMsg = 'Too many failed attempts. Please try again later';
          break;
        default:
          errorMsg = e.message ?? 'Login failed';
      }
      _setError(errorMsg);
      if (kDebugMode) {
        print('Login error: $errorMsg');
      }
    } catch (e) {
      print('🔴 AuthProvider: Unexpected error: $e');
      _setError('An unexpected error occurred during login');
      if (kDebugMode) {
        print('Unexpected login error: $e');
      }
    }

    print('🔴 AuthProvider: Login failed, setting loading to false');
    _setLoading(false);
    return false;
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      await _clearUserSession();
      notifyListeners();
      
      if (kDebugMode) {
        print('User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required int classNumber,
  }) async {
    if (_currentUser == null || _auth.currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Update display name in Firebase Auth
      await _auth.currentUser!.updateDisplayName(name);

      // Update user document in Firestore
      await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(_auth.currentUser!.uid)
          .update({
        'name': name,
        'class': classNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local user data
      _currentUser!['name'] = name;
      _currentUser!['class'] = classNumber;
      await _saveUserSession(_currentUser!);
      
      _setLoading(false);
      notifyListeners();
      
      if (kDebugMode) {
        print('Profile updated successfully');
      }
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      if (kDebugMode) {
        print('Profile update error: $e');
      }
    }

    _setLoading(false);
    return false;
  }

  // Enable guest mode
  void enableGuestMode() {
    print('🔵 Enabling guest mode...');
    _currentUser = {
      'id': 'guest_user',
      'name': 'Guest User',
      'email': 'guest@eduai.com',
      'class': '10', // Default class
      'isGuest': true,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _clearError();
    notifyListeners();
    
    print('🔵 Guest mode enabled: $_currentUser');
  }

  // Check if current user is guest
  bool get isGuest => _currentUser?['isGuest'] == true;

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
