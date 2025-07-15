import 'dart:convert';
import 'dart:math';

/// Represents a feedback entry in the system
class FeedbackModel {
  final String _id;
  final String _title;
  final String _description;
  final DateTime _timestamp;
  final String _eventId; // Reference to the event this feedback is for
  final int _rating; // Rating from 1 to 5 stars
  final String _userId;

  // Getters for encapsulation
  String get id => _id;
  String get title => _title;
  String get description => _description;
  DateTime get timestamp => _timestamp;
  String get eventId => _eventId;
  int get rating => _rating;
  String get userId => _userId;

  /// Constructor for creating a new feedback entry
  FeedbackModel({
    required String id,
    required String title,
    required String description,
    required DateTime timestamp,
    required String eventId,
    required int rating,
    required String userId,
  })  : _id = id,
        _title = title,
        _description = description,
        _timestamp = timestamp,
        _eventId = eventId,
        _rating = _validateRating(rating),
        _userId = userId;

  /// Validates rating to ensure it's between 1 and 5
  static int _validateRating(int rating) {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }
    return rating;
  }

  /// Creates a copy of the feedback with updated fields
  FeedbackModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    String? eventId,
    int? rating,
    String? userId,
  }) {
    return FeedbackModel(
      id: id ?? _id,
      title: title ?? _title,
      description: description ?? _description,
      timestamp: timestamp ?? _timestamp,
      eventId: eventId ?? _eventId,
      rating: rating ?? _rating,
      userId: userId ?? _userId,
    );
  }

  /// Converts the feedback to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'title': _title,
      'description': _description,
      'timestamp': _timestamp.toIso8601String(),
      'eventId': _eventId,
      'rating': _rating,
      'userId': _userId,
    };
  }

  /// Creates a FeedbackModel from a Map
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      eventId: map['eventId'] as String,
      rating: map['rating'] as int,
      userId: map['userId'] as String? ?? '',
    );
  }

  /// Converts the feedback to JSON string
  String toJson() => json.encode(toMap());

  /// Creates a FeedbackModel from JSON string
  factory FeedbackModel.fromJson(String jsonString) {
    return FeedbackModel.fromMap(json.decode(jsonString) as Map<String, dynamic>);
  }

  /// Creates a new feedback with current timestamp
  factory FeedbackModel.create({
    required String title,
    required String description,
    required String eventId,
    required int rating,
    required String userId,
  }) {
    final random = Random();
    final uniqueId = 'feedback_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}';
    
    return FeedbackModel(
      id: uniqueId,
      title: title,
      description: description,
      timestamp: DateTime.now(),
      eventId: eventId,
      rating: rating,
      userId: userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedbackModel && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'FeedbackModel(id: $_id, title: $_title, rating: $_rating, eventId: $_eventId)';
  }
} 