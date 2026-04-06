import 'package:cloud_firestore/cloud_firestore.dart';

class StallModel {
  final String id;
  final String ownerUid;
  final String name;
  final String description;
  final String category; // e.g. 'Makanan Berat', 'Minuman', 'Cemilan'
  final bool isOpen;
  final String? imageUrl;
  final double rating;
  final int totalReviews;
  final String location; // e.g. 'Blok A No. 3'

  StallModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.description,
    required this.category,
    required this.isOpen,
    this.imageUrl,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.location = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'name': name,
      'description': description,
      'category': category,
      'isOpen': isOpen,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'location': location,
    };
  }

  factory StallModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StallModel(
      id: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      isOpen: data['isOpen'] ?? false,
      imageUrl: data['imageUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      location: data['location'] ?? '',
    );
  }

  StallModel copyWith({
    String? name,
    String? description,
    String? category,
    bool? isOpen,
    String? imageUrl,
    String? location,
  }) {
    return StallModel(
      id: id,
      ownerUid: ownerUid,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isOpen: isOpen ?? this.isOpen,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating,
      totalReviews: totalReviews,
      location: location ?? this.location,
    );
  }
}
