import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';

class DataService {
  static List<User> _users = [];
  static List<EventModel> _events = [];

  static List<User> get users => _users;
  static List<EventModel> get events => _events;

  static Future<void> loadInitialData() async {
    await Future.wait([
      _loadUsers(),
      _loadEvents(),
    ]);
  }

  static Future<void> _loadUsers() async {
    try {
      final String response = await rootBundle.loadString('assets/data/users.json');
      final data = await json.decode(response);
      _users = (data['users'] as List)
          .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading users: $e');
      _users = [];
    }
  }

  static Future<void> _loadEvents() async {
    try {
      final String response = await rootBundle.loadString('assets/data/events.json');
      final data = await json.decode(response);
      _events = (data['events'] as List)
          .map((eventJson) => EventModel.fromMap(eventJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading events: $e');
      _events = [];
    }
  }

  static User? findUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static User? findUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  static EventModel? findEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<EventModel> getEventsByCategory(String category) {
    return _events.where((event) => event.category == category).toList();
  }

  static List<EventModel> searchEvents(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _events.where((event) =>
        event.name.toLowerCase().contains(lowercaseQuery) ||
        event.description.toLowerCase().contains(lowercaseQuery) ||
        event.category.toLowerCase().contains(lowercaseQuery) ||
        event.location.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
} 