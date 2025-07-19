import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'data_service.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';

  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<User?> getCurrentUserFresh() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserJson = prefs.getString(_currentUserKey);
    if (currentUserJson != null) {
      _currentUser = User.fromJson(jsonDecode(currentUserJson));
      return _currentUser;
    }
    return null;
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Initialize with users from JSON if no users exist
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) {
      // Load initial users from DataService
      await DataService.loadInitialData();
      final usersMap = Map.fromEntries(
        DataService.users.map((user) => MapEntry(user.id, user)),
      );
      await prefs.setString(_usersKey, jsonEncode(usersMap));
    }

    // Load current user if exists
    final currentUserJson = prefs.getString(_currentUserKey);
    if (currentUserJson != null) {
      _currentUser = User.fromJson(jsonDecode(currentUserJson));
    }
  }

  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson != null) {
      final usersMap = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      for (final userJson in usersMap.values) {
        final user = User.fromJson(userJson);
        if (user.email == email && user.password == password) {
          _currentUser = user;
          
          // Add login activity
          final updatedUser = user.copyWith(
            activityLog: [
              ...user.activityLog,
              ActivityLogEntry(
                datetime: DateTime.now(),
                activity: 'Login',
                activityDetails: 'User logged in successfully',
                ip: '192.168.1.100', // Mock IP - in real app, get from device
              ),
            ],
          );
          
          // Update user in storage
          usersMap[user.id] = updatedUser.toJson();
          await prefs.setString(_usersKey, jsonEncode(usersMap));
          await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
          _currentUser = updatedUser;
          
          return true;
        }
      }
    }
    return false;
  }

  static Future<bool> register(String email, String name, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson != null) {
      final usersMap = Map<String, dynamic>.from(jsonDecode(usersJson));
      
      // Check if email already exists
      for (final userJson in usersMap.values) {
        final user = User.fromJson(userJson);
        if (user.email == email) {
          return false; // Email already exists
        }
      }
      
      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        password: password,
        participatedEventIds: [],
        activityLog: [
          ActivityLogEntry(
            datetime: DateTime.now(),
            activity: 'Account Registration',
            activityDetails: 'User registered with email $email',
            ip: '192.168.1.100', // Mock IP - in real app, get from device
          ),
          ActivityLogEntry(
            datetime: DateTime.now().add(Duration(seconds: 5)),
            activity: 'Account Verification',
            activityDetails: 'Email verification completed successfully',
            ip: '192.168.1.100', // Mock IP - in real app, get from device
          ),
        ],
      );
      
      usersMap[newUser.id] = newUser.toJson();
      await prefs.setString(_usersKey, jsonEncode(usersMap));
      
      _currentUser = newUser;
      await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));
      
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    _currentUser = null;
  }

  static Future<void> updateCurrentUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson != null) {
      final usersMap = Map<String, dynamic>.from(jsonDecode(usersJson));
      usersMap[updatedUser.id] = updatedUser.toJson();
      await prefs.setString(_usersKey, jsonEncode(usersMap));
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
      _currentUser = updatedUser;
    }
  }

  static Future<void> addActivityLog(String activity, String activityDetails) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        activityLog: [
          ..._currentUser!.activityLog,
          ActivityLogEntry(
            datetime: DateTime.now(),
            activity: activity,
            activityDetails: activityDetails,
            ip: '192.168.1.100', // Mock IP - in real app, get from device
          ),
        ],
      );
      await updateCurrentUser(updatedUser);
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
} 