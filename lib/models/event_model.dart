import 'dart:convert';
import 'dart:math';

/// Represents a predefined event in the system
class EventModel {
  final String _id;
  final String _name;
  final String _description;
  final String _category;
  final DateTime _date;
  final String _location;
  final int _maxParticipants;
  final List<Map<String, dynamic>> _existingComments; // Now contains comment and rating

  // Getters for encapsulation
  String get id => _id;
  String get name => _name;
  String get description => _description;
  String get category => _category;
  DateTime get date => _date;
  String get location => _location;
  int get maxParticipants => _maxParticipants;
  List<Map<String, dynamic>> get existingComments => List.unmodifiable(_existingComments);

  /// Get existing comments as strings
  List<String> get existingCommentTexts => _existingComments.map((c) => c['comment'] as String).toList();

  /// Get rating for a specific comment index
  int getCommentRating(int index) {
    if (index >= 0 && index < _existingComments.length) {
      return _existingComments[index]['rating'] as int;
    }
    return 5; // Default rating
  }

  /// Get title for a specific comment index
  String getCommentTitle(int index) {
    if (index >= 0 && index < _existingComments.length) {
      return _existingComments[index]['title'] as String? ?? 'Feedback';
    }
    return 'Feedback'; // Default title
  }

  /// Constructor for creating a new event
  EventModel({
    required String id,
    required String name,
    required String description,
    required String category,
    required DateTime date,
    required String location,
    required int maxParticipants,
    required List<Map<String, dynamic>> existingComments,
  })  : _id = id,
        _name = name,
        _description = description,
        _category = category,
        _date = date,
        _location = location,
        _maxParticipants = _validateMaxParticipants(maxParticipants),
        _existingComments = existingComments;

  /// Validates max participants to ensure it's positive
  static int _validateMaxParticipants(int maxParticipants) {
    if (maxParticipants <= 0) {
      throw ArgumentError('Max participants must be greater than 0');
    }
    return maxParticipants;
  }

  /// Creates a copy of the event with updated fields
  EventModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    DateTime? date,
    String? location,
    int? maxParticipants,
    List<Map<String, dynamic>>? existingComments,
  }) {
    return EventModel(
      id: id ?? _id,
      name: name ?? _name,
      description: description ?? _description,
      category: category ?? _category,
      date: date ?? _date,
      location: location ?? _location,
      maxParticipants: maxParticipants ?? _maxParticipants,
      existingComments: existingComments ?? _existingComments,
    );
  }

  /// Converts the event to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'description': _description,
      'category': _category,
      'date': _date.toIso8601String(),
      'location': _location,
      'maxParticipants': _maxParticipants,
      'existingComments': _existingComments,
    };
  }

  /// Creates an EventModel from a Map
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      location: map['location'] as String,
      maxParticipants: map['maxParticipants'] as int,
      existingComments: List<Map<String, dynamic>>.from(map['existingComments'] ?? []),
    );
  }

  /// Converts the event to JSON string
  String toJson() => json.encode(toMap());

  /// Creates an EventModel from JSON string
  factory EventModel.fromJson(String jsonString) {
    return EventModel.fromMap(json.decode(jsonString) as Map<String, dynamic>);
  }

  /// Creates a new event with current timestamp
  factory EventModel.create({
    required String name,
    required String description,
    required String category,
    required DateTime date,
    required String location,
    required int maxParticipants,
    required List<Map<String, dynamic>> existingComments,
  }) {
    final random = Random();
    final uniqueId = '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}';
    
    return EventModel(
      id: uniqueId,
      name: name,
      description: description,
      category: category,
      date: date,
      location: location,
      maxParticipants: maxParticipants,
      existingComments: existingComments,
    );
  }

  /// Check if event is in the past
  bool get isPast => DateTime.now().isAfter(_date);

  /// Check if event is today
  bool get isToday {
    final now = DateTime.now();
    return _date.year == now.year &&
           _date.month == now.month &&
           _date.day == now.day;
  }

  /// Check if event is in the future
  bool get isFuture => DateTime.now().isBefore(_date);

  /// Get formatted date string
  String get formattedDate {
    return '${_date.day}/${_date.month}/${_date.year}';
  }

  /// Get formatted time string
  String get formattedTime {
    return '${_date.hour.toString().padLeft(2, '0')}:${_date.minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() {
    return 'EventModel(id: $_id, name: $_name, category: $_category)';
  }
} 