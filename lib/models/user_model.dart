import 'dart:convert';

class ActivityLogEntry {
  final DateTime datetime;
  final String activity;
  final String activityDetails;
  final String ip;

  ActivityLogEntry({
    required this.datetime,
    required this.activity,
    required this.activityDetails,
    required this.ip,
  });

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime.toIso8601String(),
      'activity': activity,
      'activityDetails': activityDetails,
      'ip': ip,
    };
  }

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      datetime: DateTime.parse(json['datetime']),
      activity: json['activity'],
      activityDetails: json['activityDetails'],
      ip: json['ip'],
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String password;
  final List<String> participatedEventIds;
  final List<ActivityLogEntry> activityLog;
  final String? profileImagePath;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.participatedEventIds,
    required this.activityLog,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
      'participatedEventIds': participatedEventIds,
      'activityLog': activityLog.map((entry) => entry.toJson()).toList(),
      'profileImagePath': profileImagePath,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      password: json['password'],
      participatedEventIds: List<String>.from(json['participatedEventIds']),
      activityLog: (json['activityLog'] as List)
          .map((entry) => ActivityLogEntry.fromJson(entry))
          .toList(),
      profileImagePath: json['profileImagePath'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? password,
    List<String>? participatedEventIds,
    List<ActivityLogEntry>? activityLog,
    String? profileImagePath,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      participatedEventIds: participatedEventIds ?? this.participatedEventIds,
      activityLog: activityLog ?? this.activityLog,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
} 