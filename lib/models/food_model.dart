import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String stallId;
  final String name;
  final String description;
  final double price;
  final String category; // e.g. 'Makanan Berat', 'Minuman', 'Cemilan'
  final bool isAvailable;
  final String? imageUrl;
  final double rating;

  FoodModel({
    required this.id,
    required this.stallId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    this.imageUrl,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'stallId': stallId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }

  factory FoodModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodModel(
      id: doc.id,
      stallId: data['stallId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      imageUrl: data['imageUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  FoodModel copyWith({
    String? name,
    String? description,
    double? price,
    String? category,
    bool? isAvailable,
    String? imageUrl,
  }) {
    return FoodModel(
      id: id,
      stallId: stallId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating,
    );
  }
}
