// models/recipe.dart
import '../config/api_config.dart';

class Recipe {
  final int id;
  final int userId;
  final int categoryId;
  final String name;
  final String ingredients;
  final String steps;
  final int cookingTime;
  final int servings;
  final String? description;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  Recipe({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    required this.servings,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  // FROM JSON - Convert response dari backend ke Recipe object

  /**
   * Method: fromJson()
   * Fungsi: Convert JSON response dari backend ke Recipe object
   * Parameter: json (Map<String, dynamic>)
   * Return: Recipe object
   */
  factory Recipe.fromJson(Map<String, dynamic> json) {
    print(json);
    return Recipe(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      ingredients: json['ingredients'] ?? '',
      steps: json['steps'] ?? '',
      cookingTime: json['cooking_time'] ?? 0,
      servings: json['servings'] ?? 0,
      description: json['description'],
      image: json['image'] != null && json['image'].toString().isNotEmpty
          ? ApiConfig.recipeImageUrl(json['image'].toString())
          : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // TO JSON - Convert Recipe object ke JSON

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'ingredients': ingredients,
      'steps': steps,
      'cooking_time': cookingTime,
      'servings': servings,
      'description': description,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // COPY WITH - Create copy dengan beberapa field yang diubah

  Recipe copyWith({
    int? id,
    int? userId,
    int? categoryId,
    String? name,
    String? ingredients,
    String? steps,
    int? cookingTime,
    int? servings,
    String? description,
    String? image,
    String? createdAt,
    String? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      description: description ?? this.description,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Recipe(id: $id, name: $name, categoryId: $categoryId, cookingTime: $cookingTime, servings: $servings)';
}
