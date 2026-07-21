// models/category.dart
class Category {
  final int id;
  final int userId;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  // FROM JSON - Convert response dari backend ke Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // TO JSON - Convert Category object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // COPY WITH - Create copy dengan beberapa field yang diubah
  Category copyWith({
    int? id,
    int? userId,
    String? name,
    String? createdAt,
    String? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Category(id: $id, name: $name)';
}