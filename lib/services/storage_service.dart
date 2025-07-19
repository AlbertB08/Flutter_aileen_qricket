import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback_model.dart';
import '../models/event_model.dart';

/// Abstract interface for storage operations
abstract class StorageService {
  /// Initialize the storage service
  Future<void> initialize();
  
  /// Save feedback data
  Future<void> saveData(List<FeedbackModel> feedbacks);
  
  /// Load feedback data
  Future<List<FeedbackModel>> loadData();
  
  /// Save event data
  Future<void> saveEvents(List<EventModel> events);
  
  /// Load event data
  Future<List<EventModel>> loadEvents();
  
  /// Clear all stored data
  Future<void> clearData();
}

/// Implementation of StorageService using SharedPreferences
class SharedPreferencesStorageService implements StorageService {
  static const String _feedbackStorageKey = 'feedback_data';
  static const String _eventStorageKey = 'event_data';
  static const String _userIdKey = 'user_id';
  static const String _participatedEventsKey = 'participated_event_ids';
  
  @override
  Future<void> initialize() async {
    // SharedPreferences doesn't need explicit initialization
    // but we keep this for consistency with the interface
  }
  
  @override
  Future<void> saveData(List<FeedbackModel> feedbacks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String feedbacksJson = feedbacks
          .map((feedback) => feedback.toJson())
          .toList()
          .toString();
      await prefs.setString(_feedbackStorageKey, feedbacksJson);
    } catch (e) {
      throw StorageException('Failed to save feedback data: $e');
    }
  }
  
  @override
  Future<List<FeedbackModel>> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? feedbacksJson = prefs.getString(_feedbackStorageKey);
      
      if (feedbacksJson == null || feedbacksJson.isEmpty) {
        return [];
      }
      
      // Parse the JSON array string
      final List<dynamic> feedbacksList = json.decode(feedbacksJson);
      return feedbacksList
          .map((json) => FeedbackModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Failed to load feedback data: $e');
    }
  }

  @override
  Future<void> saveEvents(List<EventModel> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String eventsJson = events
          .map((event) => event.toJson())
          .toList()
          .toString();
      await prefs.setString(_eventStorageKey, eventsJson);
    } catch (e) {
      throw StorageException('Failed to save event data: $e');
    }
  }
  
  @override
  Future<List<EventModel>> loadEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? eventsJson = prefs.getString(_eventStorageKey);
      
      if (eventsJson == null || eventsJson.isEmpty) {
        return [];
      }
      
      // Parse the JSON array string
      final List<dynamic> eventsList = json.decode(eventsJson);
      return eventsList
          .map((json) => EventModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Failed to load event data: $e');
    }
  }
  
  @override
  Future<void> clearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_feedbackStorageKey);
      await prefs.remove(_eventStorageKey);
    } catch (e) {
      throw StorageException('Failed to clear data: $e');
    }
  }

  /// Get or create a persistent user ID
  static Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    if (userId == null || userId.isEmpty) {
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 10000}';
      await prefs.setString(_userIdKey, userId);
    }
    return userId;
  }

  /// Get the list of participated event IDs
  static Future<List<String>> getParticipatedEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_participatedEventsKey) ?? [];
  }

  /// Add an event ID to the participated list
  static Future<void> addParticipatedEventId(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_participatedEventsKey) ?? [];
    if (!ids.contains(eventId)) {
      ids.add(eventId);
      await prefs.setStringList(_participatedEventsKey, ids);
    }
  }

  /// Set the participated event IDs (overwrite)
  static Future<void> setParticipatedEventIds(List<String> eventIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_participatedEventsKey, eventIds);
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;
  
  StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
} 