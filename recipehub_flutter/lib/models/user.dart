// models/user.dart
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  // FROM JSON - Convert response dari backend ke User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // TO JSON - Convert User object ke JSON (jika diperlukan)
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
    };
  }

  // COPY WITH - Create copy dengan beberapa field yang diubah
  User copyWith({
    int? id,
    String? name,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}