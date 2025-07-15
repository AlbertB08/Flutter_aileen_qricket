import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Mock user database for demo purposes
  static final List<User> _mockUsers = [
    User(
      id: '1',
      email: 'admin@qricket.com',
      name: 'Admin User',
      password: 'admin123',
    ),
    User(
      id: '2',
      email: 'user@qricket.com',
      name: 'Regular User',
      password: 'user123',
    ),
  ];

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Login user
  static Future<bool> login(String email, String password) async {
    // Find user in mock database
    final user = _mockUsers.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => throw Exception('Invalid credentials'),
    );

    // Store user session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);

    return true;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Register new user (for demo purposes)
  static Future<bool> register(String email, String password, String name) async {
    // Check if user already exists
    if (_mockUsers.any((user) => user.email == email)) {
      throw Exception('User already exists');
    }

    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      password: password,
    );

    // Add to mock database
    _mockUsers.add(newUser);

    // Auto login after registration
    return await login(email, password);
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