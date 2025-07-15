class User {
  final String id;
  final String email;
  final String name;
  final String? password; // Optional for security reasons

  User({
    required this.id,
    required this.email,
    required this.name,
    this.password,
  });

  // Convert User to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      // Don't include password in JSON for security
    };
  }

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 